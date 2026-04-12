import 'package:book_sharing_app/data/local/database.dart';
import 'package:book_sharing_app/data/local/group_dao.dart';
import 'package:book_sharing_app/data/local/user_dao.dart';
import 'package:book_sharing_app/data/local/book_dao.dart';
import 'package:drift/drift.dart' as drift;
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/test_helper.dart';

void main() {
  late AppDatabase database;
  late GroupDao groupDao;
  late UserDao userDao;
  late BookDao bookDao;

  late LocalUser user1;
  late LocalUser user2;
  late Group testGroup;
  late Book testBook;

  setUp(() async {
    database = createTestDatabase();
    groupDao = GroupDao(database);
    userDao = UserDao(database);
    bookDao = BookDao(database);

    user1 = await insertTestUser(userDao, username: 'alice', uuid: 'user-1');
    user2 = await insertTestUser(userDao, username: 'bob', uuid: 'user-2');
    testGroup = await insertTestGroup(groupDao, user1, uuid: 'group-1');
    testBook = await insertTestBook(bookDao, ownerUserId: user1.id, uuid: 'book-1');
  });

  tearDown(() async {
    await database.close();
  });

  // ─── findSharedBookByGroupBookAndOwner ───────────────────────────────────
  group('findSharedBookByGroupBookAndOwner', () {
    test('returns null when no matching shared book exists', () async {
      final result = await groupDao.findSharedBookByGroupBookAndOwner(
        groupId: testGroup.id,
        bookId: testBook.id,
        ownerUserId: user1.id,
      );
      expect(result, equals(null));
    });

    test('returns the shared book when it matches group, book and owner', () async {
      await insertTestSharedBook(groupDao,
          group: testGroup, book: testBook, owner: user1);

      final result = await groupDao.findSharedBookByGroupBookAndOwner(
        groupId: testGroup.id,
        bookId: testBook.id,
        ownerUserId: user1.id,
      );

      expect(result, isA<SharedBook>());
      expect(result!.bookId, testBook.id);
      expect(result.groupId, testGroup.id);
      expect(result.ownerUserId, user1.id);
    });

    test('returns null when owner does not match', () async {
      // user1 shares the book
      await insertTestSharedBook(groupDao,
          group: testGroup, book: testBook, owner: user1);

      // Query for user2 — should not find it
      final result = await groupDao.findSharedBookByGroupBookAndOwner(
        groupId: testGroup.id,
        bookId: testBook.id,
        ownerUserId: user2.id,
      );

      expect(result, equals(null));
    });

    test('returns null when group does not match', () async {
      await insertTestSharedBook(groupDao,
          group: testGroup, book: testBook, owner: user1);

      final result = await groupDao.findSharedBookByGroupBookAndOwner(
        groupId: 9999, // non-existent group
        bookId: testBook.id,
        ownerUserId: user1.id,
      );

      expect(result, equals(null));
    });

    test('two different owners can share the same book in the same group', () async {
      // book2 owned by user2 with same title as testBook
      final book2 = await insertTestBook(bookDao,
          ownerUserId: user2.id, uuid: 'book-2');

      // user1 shares their copy
      await insertTestSharedBook(groupDao,
          group: testGroup, book: testBook, owner: user1);

      // user2 shares their copy (different bookId, same title)
      await groupDao.insertSharedBook(
        SharedBooksCompanion.insert(
          uuid: 'shared-book-2',
          groupId: testGroup.id,
          groupUuid: testGroup.uuid,
          bookId: book2.id,
          bookUuid: book2.uuid,
          ownerUserId: user2.id,
          visibility: const drift.Value('group'),
          isAvailable: const drift.Value(true),
          isDirty: const drift.Value(false),
          isDeleted: const drift.Value(false),
          createdAt: drift.Value(DateTime(2024)),
          updatedAt: drift.Value(DateTime(2024)),
        ),
      );

      final result1 = await groupDao.findSharedBookByGroupBookAndOwner(
        groupId: testGroup.id,
        bookId: testBook.id,
        ownerUserId: user1.id,
      );
      final result2 = await groupDao.findSharedBookByGroupBookAndOwner(
        groupId: testGroup.id,
        bookId: book2.id,
        ownerUserId: user2.id,
      );

      expect(result1, isA<SharedBook>());
      expect(result2, isA<SharedBook>());
      expect(result1!.ownerUserId, user1.id);
      expect(result2!.ownerUserId, user2.id);
    });
  });

  // ─── findSharedBookByGroupAndBook (original generic check) ───────────────
  group('findSharedBookByGroupAndBook (generic, single-owner)', () {
    test('returns the first shared book regardless of owner', () async {
      await insertTestSharedBook(groupDao,
          group: testGroup, book: testBook, owner: user1);

      final result = await groupDao.findSharedBookByGroupAndBook(
        groupId: testGroup.id,
        bookId: testBook.id,
      );

      expect(result, isA<SharedBook>());
      expect(result!.ownerUserId, user1.id);
    });
  });
}
