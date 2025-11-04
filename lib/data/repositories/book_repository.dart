import 'package:drift/drift.dart';

import '../local/book_dao.dart';
import '../local/database.dart';

class BookRepository {
  BookRepository(this._dao);

  final BookDao _dao;

  Stream<List<Book>> watchAll() => _dao.watchAllBooks();

  Stream<List<BookReview>> watchReviews(int bookId) =>
      _dao.watchReviewsForBook(bookId);

  Future<int> addBook({
    required String title,
    String? author,
    String? isbn,
    String? barcode,
    String? coverPath,
    String status = 'available',
    String? notes,
  }) {
    final now = DateTime.now();
    return _dao.insertBook(
      BooksCompanion.insert(
        title: title,
        author: Value(author),
        isbn: Value(isbn),
        barcode: Value(barcode),
        coverPath: Value(coverPath),
        status: Value(status),
        notes: Value(notes),
        createdAt: Value(now),
        updatedAt: Value(now),
      ),
    );
  }

  Future<int> addReview({
    required int bookId,
    required int rating,
    String? review,
  }) {
    return _dao.insertReview(
      BookReviewsCompanion.insert(
        bookId: bookId,
        rating: rating,
        review: Value(review),
        createdAt: Value(DateTime.now()),
      ),
    );
  }

  Future<bool> updateBook(Book book) {
    final updated = book.copyWith(updatedAt: DateTime.now());
    return _dao.updateBook(updated.toCompanion(true));
  }

  Future<int> deleteBook(int id) => _dao.deleteBook(id);

  Future<Book?> findById(int id) => _dao.findById(id);
}
