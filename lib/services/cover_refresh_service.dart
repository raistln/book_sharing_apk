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
  });

  final int totalProcessed;
  final int successCount;
  final int failedCount;
}

class _MetadataCandidate {
  final String? coverUrl;
  final int? pageCount;
  final int? publicationYear;
  final String? genre; // CSV of BookGenre names
  final String? description;

  _MetadataCandidate({
    this.coverUrl,
    this.pageCount,
    this.publicationYear,
    this.genre,
    this.description,
  });

  bool get hasData =>
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

  /// Refreshes metadata (cover, pages, year, desc, etc.) for books that are missing information.
  Future<CoverRefreshResult> refreshMissingMetadata({int? ownerUserId}) async {
    developer.log('[CoverRefreshService] Starting metadata refresh',
        name: 'CoverRefreshService');

    final books =
        await _bookRepository.fetchActiveBooks(ownerUserId: ownerUserId);

    // Filter books that are missing metadata OR have potential for better metadata
    // We now include ALL books in the target list to check if we can improve their data,
    // especially covers which might be generic placeholders.
    final targetBooks = books.where((book) {
      final missingCover = book.coverPath == null || book.coverPath!.isEmpty;
      // Also target books that might have a placeholder cover (heuristic)
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

      return missingCover ||
          hasPlaceholder ||
          missingPages ||
          missingYear ||
          missingGenre ||
          missingNotes;
    }).toList();

    developer.log(
      '[CoverRefreshService] Found ${targetBooks.length} books with missing or improvable metadata',
      name: 'CoverRefreshService',
    );

    int successCount = 0;
    int failedCount = 0;

    for (final book in targetBooks) {
      try {
        final candidate = await _findMetadata(book);

        if (!candidate.hasData) {
          failedCount++;
          continue;
        }

        var updatedBook = book;
        bool changed = false;

        // 1. Process Cover
        // Update if missing OR if we found a valid URL and current is suspect/placeholder
        // We trust the API result to be better than a local placeholder
        if (candidate.coverUrl != null && candidate.coverUrl!.isNotEmpty) {
          final currentIsPlaceholder = book.coverPath == null ||
              book.coverPath!.isEmpty ||
              book.coverPath!.contains('assets') ||
              book.coverPath!.contains('default');

          // If we have a new URL, and we either don't have a cover OR the user requested refresh
          // (which implies they want to fix things), we try to download it.
          // To be safe, we only overwrite if current is null/empty/placeholder OR if we simply want to force refresh.
          // For now, let's be aggressive only on missing/placeholder, but technically the loop runs on "targetBooks".

          if (currentIsPlaceholder || book.coverPath != candidate.coverUrl) {
            // Avoid re-downloading if it looks like the SAME remote URL (unlikely exact string match but good check)
            final localPath =
                await _coverService.saveRemoteCover(candidate.coverUrl!);
            if (localPath != null && localPath != book.coverPath) {
              updatedBook = updatedBook.copyWith(coverPath: Value(localPath));
              changed = true;
            }
          }
        }

        // 2. Process Page Count if missing and found
        if ((book.pageCount == null || book.pageCount == 0) &&
            candidate.pageCount != null) {
          updatedBook =
              updatedBook.copyWith(pageCount: Value(candidate.pageCount));
          changed = true;
        }

        // 3. Process Publication Year if missing and found
        if ((book.publicationYear == null || book.publicationYear == 0) &&
            candidate.publicationYear != null) {
          updatedBook = updatedBook.copyWith(
              publicationYear: Value(candidate.publicationYear));
          changed = true;
        }

        // 4. Process Genre if missing and found
        if ((book.genre == null || book.genre!.isEmpty) &&
            candidate.genre != null) {
          updatedBook = updatedBook.copyWith(genre: Value(candidate.genre));
          changed = true;
        }

        // 5. Process Description (Notes) if missing and found
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
          // Found some data but maybe it wasn't relevant (e.g. cover found but download failed)
          failedCount++;
        }
      } catch (e) {
        developer.log(
          '[CoverRefreshService] Error processing ${book.title}: $e',
          name: 'CoverRefreshService',
        );
        failedCount++;
      }
    }

    developer.log(
      '[CoverRefreshService] Refresh complete: $successCount success, $failedCount failed',
      name: 'CoverRefreshService',
    );

    return CoverRefreshResult(
      totalProcessed: targetBooks.length,
      successCount: successCount,
      failedCount: failedCount,
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

    String? coverUrl;
    int? pageCount;
    int? publicationYear;
    String? genre;
    String? description;

    // --- 1. OpenLibrary ---
    try {
      if (book.isbn != null && book.isbn!.isNotEmpty) {
        final results =
            await _openLibraryClient.search(isbn: book.isbn, limit: 1);
        if (results.isNotEmpty) {
          final result = results.first;
          coverUrl ??= result.coverUrl;
          pageCount ??= result.pageCount;
          publicationYear ??= result.publishYear;
          if (result.subjects.isNotEmpty) {
            final genres = BookGenre.fromExternalCategories(result.subjects);
            if (genres.isNotEmpty) {
              genre ??= BookGenre.toCsv(genres);
            }
          }
        }
      }

      // If still missing crucial info, try title search on OL
      if (coverUrl == null || pageCount == null) {
        final query =
            book.author != null ? '${book.title} ${book.author}' : book.title;
        final results = await _openLibraryClient.search(query: query, limit: 1);
        if (results.isNotEmpty) {
          final result = results.first;
          coverUrl ??= result.coverUrl;
          pageCount ??= result.pageCount;
          publicationYear ??= result.publishYear;
          if (genre == null && result.subjects.isNotEmpty) {
            final genres = BookGenre.fromExternalCategories(result.subjects);
            if (genres.isNotEmpty) {
              genre = BookGenre.toCsv(genres);
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
    // always fetch from GB if description is missing
    if (coverUrl == null ||
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
      coverUrl: coverUrl,
      pageCount: pageCount,
      publicationYear: publicationYear,
      genre: genre,
      description: description,
    );
  }
}
