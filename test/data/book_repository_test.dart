import 'package:book_sharing_app/data/local/book_dao.dart';
import 'package:book_sharing_app/data/local/database.dart';
import 'package:book_sharing_app/data/local/group_dao.dart';
import 'package:book_sharing_app/data/repositories/book_repository.dart';
import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;
  late BookDao dao;
  late GroupDao groupDao;
  late BookRepository repository;
  late LocalUser user;
  late Book book;

  setUp(() async {
    db = AppDatabase.test(NativeDatabase.memory());
    dao = BookDao(db);
    groupDao = GroupDao(db);
    repository = BookRepository(
      dao,
      groupDao: groupDao,
    );

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

  Future<int> insertGroup({required int ownerUserId, String uuid = 'group-uuid'}) {
    return groupDao.insertGroup(
      GroupsCompanion.insert(
        uuid: uuid,
        name: 'Grupo $uuid',
        ownerUserId: Value(ownerUserId),
        isDirty: const Value(false),
        isDeleted: const Value(false),
      ),
    );
  }

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

  test('addBook auto shares into owner groups', () async {
    final groupId = await insertGroup(ownerUserId: user.id, uuid: 'group-share');

    final newBookId = await repository.addBook(
      title: 'Libro compartido',
      status: 'available',
      owner: user,
    );

    final sharedEntries = await groupDao.findSharedBooksByBookId(newBookId);
    expect(sharedEntries, hasLength(1));

    final sharedBook = sharedEntries.single;
    expect(sharedBook.groupId, groupId);
    expect(sharedBook.bookId, newBookId);
    expect(sharedBook.ownerUserId, user.id);
    expect(sharedBook.isDeleted, isFalse);
    expect(sharedBook.isAvailable, isTrue);
    expect(sharedBook.isDirty, isTrue);
  });

  test('updateBook updates shared availability and soft deletes when private', () async {
    await insertGroup(ownerUserId: user.id, uuid: 'group-status');

    final bookId = await repository.addBook(
      title: 'Estado compartido',
      status: 'available',
      owner: user,
    );

    var sharedEntries = await groupDao.findSharedBooksByBookId(bookId);
    expect(sharedEntries, hasLength(1));
    final sharedId = sharedEntries.single.id;

    final insertedBook = (await repository.findById(bookId))!;
    final loanedBook = insertedBook.copyWith(status: 'loaned');
    await repository.updateBook(loanedBook);

    sharedEntries = await groupDao.findSharedBooksByBookId(bookId);
    expect(sharedEntries, hasLength(1));
    var sharedBook = sharedEntries.single;
    expect(sharedBook.id, sharedId);
    expect(sharedBook.isAvailable, isFalse);
    expect(sharedBook.isDeleted, isFalse);
    expect(sharedBook.isDirty, isTrue);

    final refreshedBook = (await repository.findById(bookId))!;
    final privateBook = refreshedBook.copyWith(status: 'private');
    await repository.updateBook(privateBook);

    sharedEntries = await groupDao.findSharedBooksByBookId(bookId);
    expect(sharedEntries, hasLength(1));
    sharedBook = sharedEntries.single;
    expect(sharedBook.id, sharedId);
    expect(sharedBook.isDeleted, isTrue);
    expect(sharedBook.isDirty, isTrue);
  });
}
