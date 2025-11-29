import 'dart:developer' as developer;
import 'dart:io';

import 'package:drift/drift.dart' show Value;

import '../data/local/database.dart';
import '../data/repositories/book_repository.dart';
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

  /// Refreshes covers for all books that don't have one
  Future<CoverRefreshResult> refreshMissingCovers({int? ownerUserId}) async {
    developer.log('[CoverRefreshService] Starting cover refresh', name: 'CoverRefreshService');

    final books = await _bookRepository.fetchActiveBooks(ownerUserId: ownerUserId);
    final booksWithoutCovers = books.where((book) => book.coverPath == null).toList();

    developer.log(
      '[CoverRefreshService] Found ${booksWithoutCovers.length} books without covers',
      name: 'CoverRefreshService',
    );

    int successCount = 0;
    int failedCount = 0;

    for (final book in booksWithoutCovers) {
      try {
        final coverUrl = await _findCoverUrl(book);
        if (coverUrl == null) {
          developer.log(
            '[CoverRefreshService] No cover found for: ${book.title}',
            name: 'CoverRefreshService',
          );
          failedCount++;
          continue;
        }

        final coverPath = await _coverService.saveRemoteCover(coverUrl);
        if (coverPath == null) {
          developer.log(
            '[CoverRefreshService] Failed to download cover for: ${book.title}',
            name: 'CoverRefreshService',
          );
          failedCount++;
          continue;
        }

        // Update book with new cover
        final updated = book.copyWith(coverPath: Value(coverPath));
        await _bookRepository.updateBook(updated);

        developer.log(
          '[CoverRefreshService] Successfully downloaded cover for: ${book.title}',
          name: 'CoverRefreshService',
        );
        successCount++;
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
      totalProcessed: booksWithoutCovers.length,
      successCount: successCount,
      failedCount: failedCount,
    );
  }

  /// Deletes all downloaded covers to free up space
  Future<int> deleteAllCovers({int? ownerUserId}) async {
    developer.log('[CoverRefreshService] Deleting all covers', name: 'CoverRefreshService');

    final books = await _bookRepository.fetchActiveBooks(ownerUserId: ownerUserId);
    final booksWithCovers = books.where((book) => book.coverPath != null).toList();

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

  Future<String?> _findCoverUrl(Book book) async {
    // Try OpenLibrary first (faster, no API key needed)
    if (book.isbn != null && book.isbn!.isNotEmpty) {
      try {
        final results = await _openLibraryClient.search(isbn: book.isbn, limit: 1);
        if (results.isNotEmpty && results.first.coverUrl != null) {
          return results.first.coverUrl;
        }
      } catch (e) {
        developer.log(
          '[CoverRefreshService] OpenLibrary search failed for ${book.title}: $e',
          name: 'CoverRefreshService',
        );
      }
    }

    // Try by title if ISBN failed or not available
    try {
      final query = book.author != null ? '${book.title} ${book.author}' : book.title;
      final results = await _openLibraryClient.search(query: query, limit: 1);
      if (results.isNotEmpty && results.first.coverUrl != null) {
        return results.first.coverUrl;
      }
    } catch (e) {
      developer.log(
        '[CoverRefreshService] OpenLibrary title search failed for ${book.title}: $e',
        name: 'CoverRefreshService',
      );
    }

    // Try Google Books as fallback
    try {
      final results = await _googleBooksClient.search(
        query: book.title,
        isbn: book.isbn,
        maxResults: 1,
      );
      if (results.isNotEmpty && results.first.thumbnailUrl != null) {
        return results.first.thumbnailUrl;
      }
    } catch (e) {
      developer.log(
        '[CoverRefreshService] Google Books search failed for ${book.title}: $e',
        name: 'CoverRefreshService',
      );
    }

    return null;
  }
}
