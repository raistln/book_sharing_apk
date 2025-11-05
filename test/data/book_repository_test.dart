import 'package:book_sharing_app/data/local/book_dao.dart';
import 'package:book_sharing_app/data/local/database.dart';
import 'package:book_sharing_app/data/repositories/book_repository.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;
  late BookDao dao;
  late BookRepository repository;
  late LocalUser user;
  late Book book;

  setUp(() async {
    db = AppDatabase.test(NativeDatabase.memory());
    dao = BookDao(db);
    repository = BookRepository(dao);

    final userId = await db.into(db.localUsers).insert(
          LocalUsersCompanion.insert(
            uuid: 'user-uuid',
            username: 'alice',
          ),
        );
    user = await (db.select(db.localUsers)..where((tbl) => tbl.id.equals(userId))).getSingle();

    final bookId = await repository.addBook(
      title: 'Test Book',
      author: 'Author',
      status: 'available',
      owner: user,
    );
    book = (await repository.findById(bookId))!;
  });

  tearDown(() async {
    await db.close();
  });

  test('addReview inserts once and updates on subsequent calls for same user', () async {
    final firstId = await repository.addReview(
      book: book,
      rating: 4,
      review: 'Buen libro',
      author: user,
    );

    final firstReview = await dao.findReviewForUser(
      bookId: book.id,
      authorUserId: user.id,
    );

    expect(firstReview, isNotNull);
    expect(firstReview!.id, firstId);
    expect(firstReview.rating, 4);
    expect(firstReview.review, 'Buen libro');

    final secondId = await repository.addReview(
      book: book,
      rating: 2,
      review: 'Cambio de opinión',
      author: user,
    );

    expect(secondId, firstId, reason: 'Debe reutilizar la misma reseña');

    final updatedReview = await dao.findReviewForUser(
      bookId: book.id,
      authorUserId: user.id,
    );

    expect(updatedReview, isNotNull);
    expect(updatedReview!.rating, 2);
    expect(updatedReview.review, 'Cambio de opinión');
    expect(updatedReview.isDeleted, isFalse);

    final allReviews = await (db.select(db.bookReviews)..where((tbl) => tbl.bookId.equals(book.id))).get();
    expect(allReviews, hasLength(1));
  });
}
