import 'package:drift/drift.dart';

import 'database.dart';

part 'book_dao.g.dart';

@DriftAccessor(tables: [Books, BookReviews])
class BookDao extends DatabaseAccessor<AppDatabase> with _$BookDaoMixin {
  BookDao(AppDatabase db) : super(db);

  Stream<List<Book>> watchAllBooks() => select(books).watch();

  Future<int> insertBook(BooksCompanion entry) => into(books).insert(entry);

  Future<bool> updateBook(BooksCompanion entry) => update(books).replace(entry);

  Future<int> deleteBook(int id) {
    return (delete(books)..where((tbl) => tbl.id.equals(id))).go();
  }

  Future<Book?> findById(int id) {
    return (select(books)..where((tbl) => tbl.id.equals(id))).getSingleOrNull();
  }

  Stream<List<BookReview>> watchReviewsForBook(int bookId) {
    return (select(bookReviews)..where((tbl) => tbl.bookId.equals(bookId))).watch();
  }

  Future<int> insertReview(BookReviewsCompanion entry) => into(bookReviews).insert(entry);
}
