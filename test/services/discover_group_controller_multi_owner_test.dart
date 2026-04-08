library discover_group_controller_multi_owner_test;

/// Tests for the book-grouping logic in DiscoverGroupController.
///
/// Uses an in-memory SQLite database so that GroupDao behaves identically
/// to production — no mocking needed for the DAO layer.
import 'package:book_sharing_app/data/local/book_dao.dart';
import 'package:book_sharing_app/data/local/database.dart';
import 'package:book_sharing_app/data/local/group_dao.dart';
import 'package:book_sharing_app/data/local/user_dao.dart';
import 'package:book_sharing_app/services/discover_group_controller.dart';
import 'package:drift/drift.dart' as drift;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/test_helper.dart';

// ─── helpers ────────────────────────────────────────────────────────────────

Future<Book> _insertBookWithTitle(
  BookDao bookDao, {
  required int ownerUserId,
  required String uuid,
  required String title,
}) async {
  final now = DateTime(2024);
  final id = await bookDao.insertBook(
    BooksCompanion.insert(
      uuid: uuid,
      ownerUserId: drift.Value(ownerUserId),
      title: title,
      status: const drift.Value('available'),
      isPhysical: const drift.Value(true),
      isDirty: const drift.Value(false),
      isDeleted: const drift.Value(false),
      createdAt: drift.Value(now),
      updatedAt: drift.Value(now),
    ),
  );
  return (await bookDao.findById(id))!;
}

Future<void> _shareBook(
  GroupDao groupDao, {
  required Group testGroup,
  required Book book,
  required LocalUser owner,
  required String uuidSuffix,
  bool isAvailable = true,
}) async {
  final now = DateTime(2024);
  await groupDao.insertSharedBook(
    SharedBooksCompanion.insert(
      uuid: 'sb-$uuidSuffix',
      groupId: testGroup.id,
      groupUuid: testGroup.uuid,
      bookId: book.id,
      bookUuid: book.uuid,
      ownerUserId: owner.id,
      visibility: const drift.Value('group'),
      isAvailable: drift.Value(isAvailable),
      isDirty: const drift.Value(false),
      isDeleted: const drift.Value(false),
      createdAt: drift.Value(now),
      updatedAt: drift.Value(now),
    ),
  );
}

/// Build a controller and wait for its initial load microtask.
Future<DiscoverGroupController> _makeController(
  GroupDao groupDao,
  Group testGroup, {
  LocalUser? activeUser,
  List<Book> ownBooks = const [],
}) async {
  final controller = DiscoverGroupController(
    groupDao: groupDao,
    groupId: testGroup.id,
    activeUser: activeUser,
    ownBooks: ownBooks,
  );
  // Allow the internal microtask that calls loadInitial to finish
  await Future<void>.delayed(const Duration(milliseconds: 100));
  return controller;
}

// ─── tests ──────────────────────────────────────────────────────────────────

void main() {
  late AppDatabase db;
  late GroupDao groupDao;
  late UserDao userDao;
  late BookDao bookDao;

  late LocalUser alice;
  late LocalUser bob;
  late Group testGroup; // renamed from 'group' to avoid shadowing fluttertest group()

  setUp(() async {
    db = AppDatabase.test(NativeDatabase.memory());
    groupDao = GroupDao(db);
    userDao = UserDao(db);
    bookDao = BookDao(db);

    alice = await insertTestUser(userDao, username: 'alice', uuid: 'u-alice');
    bob = await insertTestUser(userDao, username: 'bob', uuid: 'u-bob');
    testGroup = await insertTestGroup(groupDao, alice, uuid: 'g-1');
  });

  tearDown(() async => db.close());

  // ─── basic grouping ──────────────────────────────────────────────────────

  group('title grouping', () {
    test('two copies with the same title collapse into one grouped entry', () async {
      final bookA = await _insertBookWithTitle(bookDao,
          ownerUserId: alice.id, uuid: 'b-A', title: 'Dune');
      final bookB = await _insertBookWithTitle(bookDao,
          ownerUserId: bob.id, uuid: 'b-B', title: 'Dune');

      await _shareBook(groupDao,
          testGroup: testGroup, book: bookA, owner: alice, uuidSuffix: 'A');
      await _shareBook(groupDao,
          testGroup: testGroup, book: bookB, owner: bob, uuidSuffix: 'B');

      final controller = await _makeController(groupDao, testGroup);

      expect(controller.state.groupedItems.length, 1,
          reason: 'Both "Dune" copies must be grouped');
      expect(controller.state.groupedItems.first.count, 2);
    });

    test('grouping is case-insensitive', () async {
      final bookA = await _insertBookWithTitle(bookDao,
          ownerUserId: alice.id, uuid: 'b-case-A', title: 'dune');
      final bookB = await _insertBookWithTitle(bookDao,
          ownerUserId: bob.id, uuid: 'b-case-B', title: 'DUNE');

      await _shareBook(groupDao,
          testGroup: testGroup, book: bookA, owner: alice, uuidSuffix: 'case-A');
      await _shareBook(groupDao,
          testGroup: testGroup, book: bookB, owner: bob, uuidSuffix: 'case-B');

      final controller = await _makeController(groupDao, testGroup);

      expect(controller.state.groupedItems.length, 1,
          reason: '"dune" and "DUNE" should be grouped');
      expect(controller.state.groupedItems.first.count, 2);
    });

    test('different titles produce separate groups', () async {
      final duneBook = await _insertBookWithTitle(bookDao,
          ownerUserId: alice.id, uuid: 'b-dune', title: 'Dune');
      final foundationBook = await _insertBookWithTitle(bookDao,
          ownerUserId: bob.id, uuid: 'b-foundation', title: 'Foundation');

      await _shareBook(groupDao,
          testGroup: testGroup, book: duneBook, owner: alice, uuidSuffix: 'dune');
      await _shareBook(groupDao,
          testGroup: testGroup,
          book: foundationBook,
          owner: bob,
          uuidSuffix: 'foundation');

      final controller = await _makeController(groupDao, testGroup);

      expect(controller.state.groupedItems.length, 2,
          reason: 'Two distinct titles → two groups');
      final titles = controller.state.groupedItems
          .map((g) => g.title.toLowerCase())
          .toSet();
      expect(titles, containsAll(['dune', 'foundation']));
    });

    test('empty database produces empty groupedItems', () async {
      final controller = await _makeController(groupDao, testGroup);
      expect(controller.state.groupedItems, isEmpty);
    });

    test('flat items count matches sum of all copies', () async {
      final bookA = await _insertBookWithTitle(bookDao,
          ownerUserId: alice.id, uuid: 'b-flat-A', title: 'Neuromancer');
      final bookB = await _insertBookWithTitle(bookDao,
          ownerUserId: bob.id, uuid: 'b-flat-B', title: 'Neuromancer');

      await _shareBook(groupDao,
          testGroup: testGroup, book: bookA, owner: alice, uuidSuffix: 'flat-A');
      await _shareBook(groupDao,
          testGroup: testGroup, book: bookB, owner: bob, uuidSuffix: 'flat-B');

      final controller = await _makeController(groupDao, testGroup);

      // items (flat) should have 2, grouped should have 1 with count=2
      expect(controller.state.items.length, 2);
      expect(controller.state.groupedItems.length, 1);
      expect(controller.state.groupedItems.first.count, 2);
    });
  });

  // ─── availability ────────────────────────────────────────────────────────

  group('availability in groups', () {
    test('isAnyAvailable is true if at least one copy is available', () async {
      final bookA = await _insertBookWithTitle(bookDao,
          ownerUserId: alice.id, uuid: 'b-avail-A', title: 'Neuromancer');
      final bookB = await _insertBookWithTitle(bookDao,
          ownerUserId: bob.id, uuid: 'b-avail-B', title: 'Neuromancer');

      await _shareBook(groupDao,
          testGroup: testGroup,
          book: bookA,
          owner: alice,
          uuidSuffix: 'avail-A',
          isAvailable: false);
      await _shareBook(groupDao,
          testGroup: testGroup,
          book: bookB,
          owner: bob,
          uuidSuffix: 'avail-B',
          isAvailable: true);

      final controller = await _makeController(groupDao, testGroup);
      await controller.setIncludeUnavailable(true);
      await Future<void>.delayed(const Duration(milliseconds: 100));

      final neuromancer = controller.state.groupedItems
          .firstWhere((g) => g.title.toLowerCase() == 'neuromancer');
      expect(neuromancer.isAnyAvailable, isTrue);
    });
  });

  // ─── owner integrity ─────────────────────────────────────────────────────

  group('owner identity preserved in grouped copies', () {
    test('each copy retains its own ownerUserId', () async {
      final bookA = await _insertBookWithTitle(bookDao,
          ownerUserId: alice.id, uuid: 'b-own-A', title: 'The Road');
      final bookB = await _insertBookWithTitle(bookDao,
          ownerUserId: bob.id, uuid: 'b-own-B', title: 'The Road');

      await _shareBook(groupDao,
          testGroup: testGroup, book: bookA, owner: alice, uuidSuffix: 'own-A');
      await _shareBook(groupDao,
          testGroup: testGroup, book: bookB, owner: bob, uuidSuffix: 'own-B');

      final controller = await _makeController(groupDao, testGroup);
      final grouped = controller.state.groupedItems;
      expect(grouped.length, 1);

      final ownerIds = grouped.first.allCopies
          .map((c) => c.sharedBook.ownerUserId)
          .toSet();
      expect(ownerIds, containsAll([alice.id, bob.id]));
    });
  });
}
