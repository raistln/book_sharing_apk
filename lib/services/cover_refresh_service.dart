import 'dart:developer' as developer;
import 'dart:io';

import 'package:drift/drift.dart' show Value;

import '../data/local/database.dart';
import '../data/repositories/book_repository.dart';
import '../models/book_genre.dart';
import 'cover_image_service_base.dart';
import 'google_books_client.dart';
import 'open_library_client.dart';

class CoverRefreshResult {
  const CoverRefreshResult({
    required this.totalProcessed,
    required this.successCount,
    required this.failedCount,
    required this.skippedCount,
  });

  final int totalProcessed;
  final int successCount;
  final int failedCount;
  final int skippedCount;
}

class _MetadataCandidate {
  final String? isbn;
  final String? coverUrl;
  final int? pageCount;
  final int? publicationYear;
  final String? genre; // CSV of BookGenre names
  final String? description;

  _MetadataCandidate({
    this.isbn,
    this.coverUrl,
    this.pageCount,
    this.publicationYear,
    this.genre,
    this.description,
  });

  bool get hasData =>
      isbn != null ||
      coverUrl != null ||
      pageCount != null ||
      publicationYear != null ||
      genre != null ||
      description != null;
}

class CoverRefreshService {
  CoverRefreshService({
    required BookRepository bookRepository,
    required CoverImageService coverService,
    required OpenLibraryClient openLibraryClient,
    required GoogleBooksClient googleBooksClient,
  })  : _bookRepository = bookRepository,
        _coverService = coverService,
        _openLibraryClient = openLibraryClient,
        _googleBooksClient = googleBooksClient;

  final BookRepository _bookRepository;
  final CoverImageService _coverService;
  final OpenLibraryClient _openLibraryClient;
  final GoogleBooksClient _googleBooksClient;

  // Configuración del throttling (control de velocidad)
  static const _defaultDelayBetweenRequests = Duration(milliseconds: 500);
  static const _delayAfterError = Duration(seconds: 2);

  /// Verifica si un libro tiene toda la metadata completa
  bool _hasCompleteMetadata(Book book) {
    final hasIsbn = book.isbn != null && book.isbn!.isNotEmpty;
    final hasCover = book.coverPath != null &&
        book.coverPath!.isNotEmpty &&
        !book.coverPath!.contains('assets') &&
        !book.coverPath!.contains('default');
    final hasPages = book.pageCount != null && book.pageCount! > 0;
    final hasYear = book.publicationYear != null && book.publicationYear! > 0;
    final hasGenre = book.genre != null && book.genre!.isNotEmpty;
    final hasNotes = book.notes != null && book.notes!.isNotEmpty;

    return hasIsbn && hasCover && hasPages && hasYear && hasGenre && hasNotes;
  }

  /// Refreshes metadata (cover, pages, year, desc, isbn, etc.) for books that are missing information.
  ///
  /// Parámetros:
  /// - [ownerUserId]: Filtrar libros por usuario
  /// - [skipComplete]: Si es true, salta los libros que ya tienen toda la metadata completa (por defecto true)
  /// - [delayBetweenRequests]: Tiempo de espera entre peticiones para no saturar la API
  /// - [onProgress]: Callback opcional para reportar progreso (current, total, bookTitle)
  Future<CoverRefreshResult> refreshMissingMetadata({
    int? ownerUserId,
    bool skipComplete = true,
    Duration? delayBetweenRequests,
    void Function(int current, int total, String bookTitle)? onProgress,
  }) async {
    developer.log('[CoverRefreshService] Starting metadata refresh',
        name: 'CoverRefreshService');

    final delay = delayBetweenRequests ?? _defaultDelayBetweenRequests;

    final books =
        await _bookRepository.fetchActiveBooks(ownerUserId: ownerUserId);

    // Filter books that are missing metadata
    final targetBooks = books.where((book) {
      // Si skipComplete está activado, saltar libros completos
      if (skipComplete && _hasCompleteMetadata(book)) {
        return false;
      }

      final missingCover = book.coverPath == null || book.coverPath!.isEmpty;
      final hasPlaceholder = book.coverPath != null &&
          (book.coverPath!.contains('assets') ||
              book.coverPath!.contains('default') ||
              !book.coverPath!.startsWith('http') &&
                  !File(book.coverPath!).existsSync());

      final missingPages = book.pageCount == null || book.pageCount == 0;
      final missingYear =
          book.publicationYear == null || book.publicationYear == 0;
      final missingGenre = book.genre == null || book.genre!.isEmpty;
      final missingNotes = book.notes == null || book.notes!.isEmpty;
      final missingIsbn = book.isbn == null || book.isbn!.isEmpty;

      return missingCover ||
          hasPlaceholder ||
          missingPages ||
          missingYear ||
          missingGenre ||
          missingNotes ||
          missingIsbn;
    }).toList();

    developer.log(
      '[CoverRefreshService] Found ${targetBooks.length} books with missing metadata (skipComplete: $skipComplete)',
      name: 'CoverRefreshService',
    );

    int successCount = 0;
    int failedCount = 0;
    int skippedCount = 0;
    int currentIndex = 0;

    for (final book in targetBooks) {
      currentIndex++;

      // Reportar progreso si se proporcionó callback
      onProgress?.call(currentIndex, targetBooks.length, book.title);

      try {
        developer.log(
          '[CoverRefreshService] Processing ($currentIndex/${targetBooks.length}): ${book.title}',
          name: 'CoverRefreshService',
        );

        final candidate = await _findMetadata(book);

        if (!candidate.hasData) {
          skippedCount++;
          developer.log(
            '[CoverRefreshService] No metadata found for: ${book.title}',
            name: 'CoverRefreshService',
          );

          // Esperar antes de continuar con el siguiente
          if (currentIndex < targetBooks.length) {
            await Future.delayed(delay);
          }
          continue;
        }

        var updatedBook = book;
        bool changed = false;

        // 1. Process ISBN if missing and found
        if ((book.isbn == null || book.isbn!.isEmpty) &&
            candidate.isbn != null &&
            candidate.isbn!.isNotEmpty) {
          updatedBook = updatedBook.copyWith(isbn: Value(candidate.isbn));
          changed = true;
          developer.log(
            '[CoverRefreshService] Found ISBN for ${book.title}: ${candidate.isbn}',
            name: 'CoverRefreshService',
          );
        }

        // 2. Process Cover
        if (candidate.coverUrl != null && candidate.coverUrl!.isNotEmpty) {
          final currentIsPlaceholder = book.coverPath == null ||
              book.coverPath!.isEmpty ||
              book.coverPath!.contains('assets') ||
              book.coverPath!.contains('default');

          if (currentIsPlaceholder || book.coverPath != candidate.coverUrl) {
            final localPath =
                await _coverService.saveRemoteCover(candidate.coverUrl!);
            if (localPath != null && localPath != book.coverPath) {
              updatedBook = updatedBook.copyWith(coverPath: Value(localPath));
              changed = true;
            }
          }
        }

        // 3. Process Page Count if missing and found
        if ((book.pageCount == null || book.pageCount == 0) &&
            candidate.pageCount != null) {
          updatedBook =
              updatedBook.copyWith(pageCount: Value(candidate.pageCount));
          changed = true;
        }

        // 4. Process Publication Year if missing and found
        if ((book.publicationYear == null || book.publicationYear == 0) &&
            candidate.publicationYear != null) {
          updatedBook = updatedBook.copyWith(
              publicationYear: Value(candidate.publicationYear));
          changed = true;
        }

        // 5. Process Genre if missing and found
        if ((book.genre == null || book.genre!.isEmpty) &&
            candidate.genre != null) {
          updatedBook = updatedBook.copyWith(genre: Value(candidate.genre));
          changed = true;
        }

        // 6. Process Description (Notes) if missing and found
        if ((book.notes == null || book.notes!.isEmpty) &&
            candidate.description != null) {
          updatedBook =
              updatedBook.copyWith(notes: Value(candidate.description));
          changed = true;
        }

        if (changed) {
          await _bookRepository.updateBook(updatedBook);
          developer.log(
            '[CoverRefreshService] Updated metadata for: ${book.title}',
            name: 'CoverRefreshService',
          );
          successCount++;
        } else {
          skippedCount++;
        }

        // Esperar antes de la siguiente petición para no saturar la API
        if (currentIndex < targetBooks.length) {
          await Future.delayed(delay);
        }
      } catch (e) {
        developer.log(
          '[CoverRefreshService] Error processing ${book.title}: $e',
          name: 'CoverRefreshService',
        );
        failedCount++;

        // Esperar más tiempo después de un error
        if (currentIndex < targetBooks.length) {
          await Future.delayed(_delayAfterError);
        }
      }
    }

    developer.log(
      '[CoverRefreshService] Refresh complete: $successCount success, $failedCount failed, $skippedCount skipped',
      name: 'CoverRefreshService',
    );

    return CoverRefreshResult(
      totalProcessed: targetBooks.length,
      successCount: successCount,
      failedCount: failedCount,
      skippedCount: skippedCount,
    );
  }

  /// Deletes all downloaded covers to free up space
  Future<int> deleteAllCovers({int? ownerUserId}) async {
    developer.log('[CoverRefreshService] Deleting all covers',
        name: 'CoverRefreshService');

    final books =
        await _bookRepository.fetchActiveBooks(ownerUserId: ownerUserId);
    final booksWithCovers =
        books.where((book) => book.coverPath != null).toList();

    int deletedCount = 0;

    for (final book in booksWithCovers) {
      try {
        final path = book.coverPath!;
        // Only delete local files
        if (!path.startsWith('http')) {
          final file = File(path);
          if (await file.exists()) {
            await file.delete();
          }
        }

        // Update book record
        final updated = book.copyWith(coverPath: const Value(null));
        await _bookRepository.updateBook(updated);

        deletedCount++;
      } catch (e) {
        developer.log(
          '[CoverRefreshService] Failed to delete cover for ${book.title}: $e',
          name: 'CoverRefreshService',
        );
      }
    }

    return deletedCount;
  }

  Future<_MetadataCandidate> _findMetadata(Book book) async {
    // Strategy: accumulate best data from sources.
    // OpenLibrary is preferred for structured data + cover.
    // GoogleBooks is fallback.

    String? isbn;
    String? coverUrl;
    int? pageCount;
    int? publicationYear;
    String? genre;
    String? description;

    // --- 1. OpenLibrary ---
    try {
      // Si ya tenemos ISBN, buscar por ISBN primero
      if (book.isbn != null && book.isbn!.isNotEmpty) {
        final results =
            await _openLibraryClient.search(isbn: book.isbn, limit: 1);
        if (results.isNotEmpty) {
          final result = results.first;
          isbn ??= result.isbn;
          coverUrl ??= result.coverUrl;
          pageCount ??= result.pageCount;
          publicationYear ??= result.publishYear;
          if (result.subjects.isNotEmpty) {
            final genres = BookGenre.fromExternalCategories(result.subjects);
            if (genres.isNotEmpty) {
              genre ??= BookGenre.toCsv(genres);
            }
          }

          if (result.key != null ||
              result.isbn != null ||
              result.editionKey != null) {
            final detail = await _openLibraryClient.getSmartMetadata(
              isbn: result.isbn,
              workKey: result.key,
              editionKey: result.editionKey,
            );
            if (detail != null) {
              isbn ??= detail.isbn;
              description ??= detail.description;
              coverUrl ??= detail.coverUrl;
              pageCount ??= detail.pageCount;

              if (detail.publishDate != null) {
                final dateStr = detail.publishDate!;
                if (dateStr.length >= 4) {
                  publicationYear ??= int.tryParse(dateStr.substring(0, 4));
                }
              }

              if (detail.subjects.isNotEmpty) {
                final genres =
                    BookGenre.fromExternalCategories(detail.subjects);
                if (genres.isNotEmpty) {
                  genre ??= BookGenre.toCsv(genres);
                }
              }
            }
          }
        }
      }

      // Si no tenemos ISBN o falta información crucial, buscar por título
      if (isbn == null || coverUrl == null || pageCount == null) {
        final query =
            book.author != null ? '${book.title} ${book.author}' : book.title;
        final results = await _openLibraryClient.search(query: query, limit: 1);
        if (results.isNotEmpty) {
          final result = results.first;
          isbn ??= result.isbn;
          coverUrl ??= result.coverUrl;
          pageCount ??= result.pageCount;
          publicationYear ??= result.publishYear;
          if (genre == null && result.subjects.isNotEmpty) {
            final genres = BookGenre.fromExternalCategories(result.subjects);
            if (genres.isNotEmpty) {
              genre = BookGenre.toCsv(genres);
            }
          }

          if (result.key != null ||
              result.isbn != null ||
              result.editionKey != null) {
            final detail = await _openLibraryClient.getSmartMetadata(
              isbn: result.isbn,
              workKey: result.key,
              editionKey: result.editionKey,
            );
            if (detail != null) {
              isbn ??= detail.isbn;
              description ??= detail.description;
              coverUrl ??= detail.coverUrl;
              pageCount ??= detail.pageCount;

              if (detail.publishDate != null) {
                final dateStr = detail.publishDate!;
                if (dateStr.length >= 4) {
                  publicationYear ??= int.tryParse(dateStr.substring(0, 4));
                }
              }

              if (detail.subjects.isNotEmpty) {
                final genres =
                    BookGenre.fromExternalCategories(detail.subjects);
                if (genres.isNotEmpty) {
                  genre ??= BookGenre.toCsv(genres);
                }
              }
            }
          }
        }
      }
    } catch (e) {
      developer.log(
        '[CoverRefreshService] OpenLibrary error for ${book.title}: $e',
        name: 'CoverRefreshService',
      );
    }

    // --- 2. Google Books (Fallback & Enrichment) ---
    if (isbn == null ||
        coverUrl == null ||
        pageCount == null ||
        publicationYear == null ||
        genre == null ||
        description == null) {
      try {
        final results = await _googleBooksClient.search(
          query: book.title,
          isbn: book.isbn,
          maxResults: 1,
        );
        if (results.isNotEmpty) {
          final result = results.first;
          isbn ??= result.isbn;
          coverUrl ??= result.thumbnailUrl;
          pageCount ??= result.pageCount;
          description ??= result.description;

          // Parse year from publishedDate (YYYY-MM-DD or YYYY)
          if (publicationYear == null && result.publishedDate != null) {
            final dateStr = result.publishedDate!;
            if (dateStr.length >= 4) {
              publicationYear = int.tryParse(dateStr.substring(0, 4));
            }
          }

          if (genre == null && result.categories.isNotEmpty) {
            final genres = BookGenre.fromExternalCategories(result.categories);
            if (genres.isNotEmpty) {
              genre = BookGenre.toCsv(genres);
            }
          }
        }
      } catch (e) {
        developer.log(
          '[CoverRefreshService] GoogleBooks error for ${book.title}: $e',
          name: 'CoverRefreshService',
        );
      }
    }

    return _MetadataCandidate(
      isbn: isbn,
      coverUrl: coverUrl,
      pageCount: pageCount,
      publicationYear: publicationYear,
      genre: genre,
      description: description,
    );
  }
}
