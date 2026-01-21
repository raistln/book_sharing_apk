import 'package:drift/drift.dart';

import 'database.dart';

part 'book_dao.g.dart';

@DriftAccessor(tables: [LocalUsers, Books, BookReviews])
class BookDao extends DatabaseAccessor<AppDatabase> with _$BookDaoMixin {
  BookDao(super.db);

  Stream<List<Book>> watchActiveBooks({int? ownerUserId}) {
    final query = select(books)
      ..where(
        (tbl) => tbl.isDeleted.equals(false) | tbl.isDeleted.isNull(),
      );

    if (ownerUserId != null) {
      query.where((tbl) => tbl.ownerUserId.equals(ownerUserId));
    }

    return query.watch();
  }

  Future<List<Book>> getActiveBooks({int? ownerUserId}) {
    final query = select(books)
      ..where(
        (tbl) => tbl.isDeleted.equals(false) | tbl.isDeleted.isNull(),
      );

    if (ownerUserId != null) {
      query.where((tbl) => tbl.ownerUserId.equals(ownerUserId));
    }

    return query.get();
  }

  Future<Book?> findByUuid(String uuid) {
    return (select(books)..where((tbl) => tbl.uuid.equals(uuid)))
        .getSingleOrNull();
  }

  Future<Book?> findByRemoteId(String remoteId) {
    return (select(books)..where((tbl) => tbl.remoteId.equals(remoteId)))
        .getSingleOrNull();
  }

  Future<int> insertBook(BooksCompanion entry) => into(books).insert(entry);

  Future<bool> updateBook(BooksCompanion entry) => update(books).replace(entry);

  Future<int> updateBookFields(
      {required int bookId, required BooksCompanion entry}) {
    return (update(books)..where((tbl) => tbl.id.equals(bookId))).write(entry);
  }

  Future<List<Book>> getDirtyBooks() {
    return (select(books)..where((tbl) => tbl.isDirty.equals(true))).get();
  }

  Future<void> softDeleteBook(
      {required int bookId, required DateTime timestamp}) {
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

  Stream<Book?> watchBookById(int id) {
    return (select(books)..where((tbl) => tbl.id.equals(id)))
        .watchSingleOrNull();
  }

  Future<void> toggleReadStatus(int bookId, bool isRead) async {
    await (update(books)..where((b) => b.id.equals(bookId))).write(
      BooksCompanion(
        isRead: Value(isRead),
        readAt: Value(isRead ? DateTime.now() : null),
        isDirty: const Value(true),
      ),
    );
  }

  Future<void> updateReadingStatus(int bookId, String status) async {
    await (update(books)..where((b) => b.id.equals(bookId))).write(
      BooksCompanion(
        readingStatus: Value(status),
        isDirty: const Value(true),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  /// Find a book by ISBN (excluding deleted books)
  Future<Book?> findByIsbn(String isbn, {int? ownerUserId}) {
    final query = select(books)
      ..where((tbl) =>
          tbl.isbn.equals(isbn) &
          (tbl.isDeleted.equals(false) | tbl.isDeleted.isNull()));

    if (ownerUserId != null) {
      query.where((tbl) => tbl.ownerUserId.equals(ownerUserId));
    }

    return query.getSingleOrNull();
  }

  /// Find a book by title and author (excluding deleted books)
  Future<Book?> findByTitleAndAuthor(String title, String author,
      {int? ownerUserId}) {
    final query = select(books)
      ..where((tbl) =>
          tbl.title.equals(title) &
          tbl.author.equals(author) &
          (tbl.isDeleted.equals(false) | tbl.isDeleted.isNull()));

    if (ownerUserId != null) {
      query.where((tbl) => tbl.ownerUserId.equals(ownerUserId));
    }

    return query.getSingleOrNull();
  }

  Stream<List<BookReview>> watchReviewsForBook(int bookId) {
    return (select(bookReviews)
          ..where((tbl) =>
              tbl.bookId.equals(bookId) &
              (tbl.isDeleted.equals(false) | tbl.isDeleted.isNull())))
        .watch();
  }

  Future<List<BookReview>> getReviewsForBook(int bookId) {
    return (select(bookReviews)
          ..where(
            (tbl) =>
                tbl.bookId.equals(bookId) &
                (tbl.isDeleted.equals(false) | tbl.isDeleted.isNull()),
          ))
        .get();
  }

  Future<List<BookReview>> getActiveReviews() {
    return (select(bookReviews)
          ..where(
            (tbl) => tbl.isDeleted.equals(false) | tbl.isDeleted.isNull(),
          ))
        .get();
  }

  Future<int> insertReview(BookReviewsCompanion entry) =>
      into(bookReviews).insert(entry);

  Future<BookReview?> findReviewForUser({
    required int bookId,
    required int authorUserId,
  }) {
    return (select(bookReviews)
          ..where(
            (tbl) =>
                tbl.bookId.equals(bookId) &
                tbl.authorUserId.equals(authorUserId),
          ))
        .getSingleOrNull();
  }

  Future<BookReview?> findReviewByRemoteId(String remoteId) {
    return (select(bookReviews)..where((tbl) => tbl.remoteId.equals(remoteId)))
        .getSingleOrNull();
  }

  Future<int> updateReview({
    required int reviewId,
    required BookReviewsCompanion entry,
  }) {
    return (update(bookReviews)..where((tbl) => tbl.id.equals(reviewId)))
        .write(entry);
  }

  Future<int> updateReviewFields({
    required int reviewId,
    required BookReviewsCompanion entry,
  }) {
    return (update(bookReviews)..where((tbl) => tbl.id.equals(reviewId)))
        .write(entry);
  }

  Future<List<BookReview>> getDirtyReviews() {
    return (select(bookReviews)..where((tbl) => tbl.isDirty.equals(true)))
        .get();
  }

  Future<void> softDeleteReviewsForBook({
    required int bookId,
    required DateTime timestamp,
  }) {
    return (update(bookReviews)..where((tbl) => tbl.bookId.equals(bookId)))
        .write(
      BookReviewsCompanion(
        isDeleted: const Value(true),
        updatedAt: Value(timestamp),
        isDirty: const Value(true),
      ),
    );
  }
}
