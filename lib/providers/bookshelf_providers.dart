import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/local/database.dart';
import '../models/bookshelf_models.dart';
import 'book_providers.dart';

// ─────────────────────────────────────────────
// Preferences persistence
// ─────────────────────────────────────────────

const _kThemeKey = 'bookshelf_theme';
const _kWallKey = 'bookshelf_wall';
const _kSortKey = 'bookshelf_sort';

// ─────────────────────────────────────────────
// State providers
// ─────────────────────────────────────────────

final bookshelfSortProvider =
    StateProvider<BookShelfSortOrder>((ref) => BookShelfSortOrder.recent);

final bookshelfThemeProvider =
    StateProvider<ShelfTheme>((ref) => ShelfTheme.classicWood);
final bookshelfWallProvider =
    StateProvider<WallTheme>((ref) => WallTheme.plaster);
final bookshelfFilterProvider =
    StateProvider<BookShelfFilter>((ref) => const BookShelfFilter());

final bookshelfSearchVisibleProvider = StateProvider<bool>((ref) => false);

// ─────────────────────────────────────────────
// Load saved preferences on first open
// ─────────────────────────────────────────────

final bookshelfPrefsLoaderProvider = FutureProvider<void>((ref) async {
  final prefs = await SharedPreferences.getInstance();

  final savedTheme = prefs.getString(_kThemeKey);
  if (savedTheme != null) {
    ref.read(bookshelfThemeProvider.notifier).state = ShelfTheme.values
        .firstWhere((t) => t.name == savedTheme,
            orElse: () => ShelfTheme.classicWood);
  }

  final savedWall = prefs.getString(_kWallKey);
  if (savedWall != null) {
    ref.read(bookshelfWallProvider.notifier).state = WallTheme.values
        .firstWhere((w) => w.name == savedWall,
            orElse: () => WallTheme.plaster);
  }

  final savedSort = prefs.getString(_kSortKey);
  if (savedSort != null) {
    ref.read(bookshelfSortProvider.notifier).state = BookShelfSortOrder.values
        .firstWhere((s) => s.name == savedSort,
            orElse: () => BookShelfSortOrder.recent);
  }
});

// ─────────────────────────────────────────────
// Save helpers (call after user changes)
// ─────────────────────────────────────────────

Future<void> saveBookshelfTheme(ShelfTheme theme) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString(_kThemeKey, theme.name);
}

Future<void> saveBookshelfWall(WallTheme wall) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString(_kWallKey, wall.name);
}

Future<void> saveBookshelfSort(BookShelfSortOrder sort) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString(_kSortKey, sort.name);
}

// ─────────────────────────────────────────────
// Data: Finished books for the bookshelf
// ─────────────────────────────────────────────

/// A simple wrapper joining a Book with its optional user review rating.
class BookWithRating {
  final Book book;
  final int? rating; // 1-4 scale

  const BookWithRating({required this.book, this.rating});
}

final _finishedBooksProvider =
    FutureProvider.autoDispose<List<BookWithRating>>((ref) async {
  final books = await ref.watch(bookListProvider.future);
  // Filter to finished books
  final finished = books.where((b) {
    return b.readingStatus.toLowerCase() == 'finished' || b.isRead;
  }).toList();

  // Fetch ratings
  final activeUser = ref.watch(activeUserProvider).value;
  final result = <BookWithRating>[];

  final bookDao = ref.read(bookDaoProvider);

  for (final book in finished) {
    int? rating;
    if (activeUser != null) {
      final review = await bookDao.findReviewForUser(
        bookId: book.id,
        authorUserId: activeUser.id,
      );
      rating = review?.rating;
    }
    result.add(BookWithRating(book: book, rating: rating));
  }

  return result;
});

// ─────────────────────────────────────────────
// Sorted + filtered books
// ─────────────────────────────────────────────

final sortedBookshelfBooksProvider =
    Provider.autoDispose<AsyncValue<List<BookWithRating>>>((ref) {
  final booksAsync = ref.watch(_finishedBooksProvider);
  final sortOrder = ref.watch(bookshelfSortProvider);
  final filter = ref.watch(bookshelfFilterProvider);

  return booksAsync.whenData((books) {
    var result = List<BookWithRating>.from(books);

    // Apply filter
    if (filter.searchQuery.isNotEmpty) {
      final query = filter.searchQuery.toLowerCase();
      result = result.where((bwr) {
        final b = bwr.book;
        return b.title.toLowerCase().contains(query) ||
            (b.author?.toLowerCase().contains(query) ?? false);
      }).toList();
    }

    if (filter.genres.isNotEmpty) {
      result = result.where((bwr) {
        final bookGenres = bwr.book.genre?.toLowerCase() ?? '';
        return filter.genres.any(
          (g) => bookGenres.contains(g.toLowerCase()),
        );
      }).toList();
    }

    if (filter.minRating != null) {
      result = result.where((bwr) {
        return bwr.rating != null && bwr.rating! >= filter.minRating!;
      }).toList();
    }

    // Apply sort
    switch (sortOrder) {
      case BookShelfSortOrder.recent:
        result.sort((a, b) {
          final aDate = a.book.readAt ?? a.book.updatedAt;
          final bDate = b.book.readAt ?? b.book.updatedAt;
          return bDate.compareTo(aDate);
        });
        break;
      case BookShelfSortOrder.alphabetical:
        result.sort(
          (a, b) => a.book.title.compareTo(b.book.title),
        );
        break;
      case BookShelfSortOrder.author:
        result.sort((a, b) {
          final aAuthor = a.book.author ?? '';
          final bAuthor = b.book.author ?? '';
          return aAuthor.compareTo(bAuthor);
        });
        break;
      case BookShelfSortOrder.pageCount:
        result.sort((a, b) {
          final aPages = a.book.pageCount ?? 0;
          final bPages = b.book.pageCount ?? 0;
          return bPages.compareTo(aPages);
        });
        break;
      case BookShelfSortOrder.rating:
        result.sort((a, b) {
          final aRating = a.rating ?? 0;
          final bRating = b.rating ?? 0;
          return bRating.compareTo(aRating);
        });
        break;
    }

    return result;
  });
});
