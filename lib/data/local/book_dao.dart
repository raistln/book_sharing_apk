import 'package:drift/drift.dart';

import 'database.dart';

part 'book_dao.g.dart';

@DriftAccessor(tables: [Books, BookReviews])
class BookDao extends DatabaseAccessor<AppDatabase> with _$BookDaoMixin {
  BookDao(super.db);

  Stream<List<Book>> watchActiveBooks() {
    return (select(books)
          ..where((tbl) =>
              tbl.isDeleted.equals(false) | tbl.isDeleted.isNull()))
        .watch();
  }

  Future<int> insertBook(BooksCompanion entry) => into(books).insert(entry);

  Future<bool> updateBook(BooksCompanion entry) => update(books).replace(entry);

  Future<void> softDeleteBook({required int bookId, required DateTime timestamp}) {
    return (update(books)..where((tbl) => tbl.id.equals(bookId))).write(
      BooksCompanion(
        isDeleted: const Value(true),
        updatedAt: Value(timestamp),
        isDirty: const Value(true),
      ),
    );
  }

  Future<Book?> findById(int id) {
    return (select(books)..where((tbl) => tbl.id.equals(id))).getSingleOrNull();
  }

  Stream<List<BookReview>> watchReviewsForBook(int bookId) {
    return (select(bookReviews)
          ..where((tbl) =>
              tbl.bookId.equals(bookId) &
              (tbl.isDeleted.equals(false) | tbl.isDeleted.isNull())))
        .watch();
  }

  Future<int> insertReview(BookReviewsCompanion entry) =>
      into(bookReviews).insert(entry);

  Future<void> softDeleteReviewsForBook({
    required int bookId,
    required DateTime timestamp,
  }) {
    return (update(bookReviews)..where((tbl) => tbl.bookId.equals(bookId))).write(
      BookReviewsCompanion(
        isDeleted: const Value(true),
        updatedAt: Value(timestamp),
        isDirty: const Value(true),
      ),
    );
  }
}
