import 'package:book_sharing_app/data/local/book_dao.dart';
import 'package:book_sharing_app/data/local/database.dart';
import 'package:book_sharing_app/data/local/group_dao.dart';
import 'package:book_sharing_app/data/local/user_dao.dart';
import 'package:book_sharing_app/data/repositories/loan_repository.dart';
import 'package:drift/drift.dart' as drift;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uuid/uuid.dart';

void main() {
  group('LoanRepository', () {
    late AppDatabase db;
    late GroupDao groupDao;
    late BookDao bookDao;
    late UserDao userDao;
    late LoanRepository repository;

    late LocalUser owner;
    late LocalUser borrower;
    late Group group;
    late Book book;
    late SharedBook sharedBook;

    setUp(() async {
      db = AppDatabase.test(NativeDatabase.memory());
      groupDao = GroupDao(db);
      bookDao = BookDao(db);
      userDao = UserDao(db);
      repository = LoanRepository(
        groupDao: groupDao,
        bookDao: bookDao,
        userDao: userDao,
        uuid: const Uuid(),
      );

      owner = await _insertUser(userDao, username: 'owner');
      borrower = await _insertUser(userDao, username: 'borrower');

      group = await _insertGroup(groupDao, owner);
      book = await _insertBook(bookDao, ownerUserId: owner.id, uuid: 'book-1');
      sharedBook = await _insertSharedBook(
        groupDao,
        group: group,
        book: book,
        owner: owner,
      );
    });

    tearDown(() async {
      await db.close();
    });

    test('requestLoan creates pending loan for borrower and owner', () async {
      final loan = await repository.requestLoan(
        sharedBook: sharedBook,
        borrower: borrower,
      );

      expect(loan.status, 'pending');
      expect(loan.fromUserId, borrower.id);
      expect(loan.toUserId, owner.id);

      final stored = await groupDao.findLoanById(loan.id);
      expect(stored, isNotNull);
      expect(stored!.status, 'pending');

      final refreshedShared = await groupDao.findSharedBookById(sharedBook.id);
      expect(refreshedShared?.isAvailable, isTrue);
    });

    test('requestLoan throws when borrower owns the book', () async {
      expect(
        () => repository.requestLoan(sharedBook: sharedBook, borrower: owner),
        throwsA(isA<LoanException>()),
      );
    });

    test('acceptLoan marks shared book unavailable and book as loaned', () async {
      final pending = await repository.requestLoan(
        sharedBook: sharedBook,
        borrower: borrower,
      );

      final accepted = await repository.acceptLoan(loan: pending, owner: owner);
      expect(accepted.status, 'accepted');

      final updatedShared = await groupDao.findSharedBookById(sharedBook.id);
      expect(updatedShared?.isAvailable, isFalse);

      final updatedBook = await bookDao.findById(book.id);
      expect(updatedBook?.status, 'loaned');
    });

    test('cancelLoan sets status to cancelled with timestamp', () async {
      final pending = await repository.requestLoan(
        sharedBook: sharedBook,
        borrower: borrower,
      );

      final cancelled = await repository.cancelLoan(loan: pending, borrower: borrower);
      expect(cancelled.status, 'cancelled');
      expect(cancelled.cancelledAt, isNotNull);

      final refreshed = await groupDao.findLoanById(cancelled.id);
      expect(refreshed?.status, 'cancelled');
    });

    test('rejectLoan sets status to rejected', () async {
      final pending = await repository.requestLoan(
        sharedBook: sharedBook,
        borrower: borrower,
      );

      final rejected = await repository.rejectLoan(loan: pending, owner: owner);
      expect(rejected.status, 'rejected');

      final refreshedShared = await groupDao.findSharedBookById(sharedBook.id);
      expect(refreshedShared?.isAvailable, isTrue);
    });

    test('markReturned frees shared book and book inventory', () async {
      final pending = await repository.requestLoan(
        sharedBook: sharedBook,
        borrower: borrower,
      );
      final accepted = await repository.acceptLoan(loan: pending, owner: owner);

      final returned = await repository.markReturned(loan: accepted, actor: owner);
      expect(returned.status, 'returned');

      final updatedShared = await groupDao.findSharedBookById(sharedBook.id);
      expect(updatedShared?.isAvailable, isTrue);

      final updatedBook = await bookDao.findById(book.id);
      expect(updatedBook?.status, 'available');
    });

    test('expireLoan marks loan as expired and frees inventory', () async {
      final pending = await repository.requestLoan(
        sharedBook: sharedBook,
        borrower: borrower,
      );
      final accepted = await repository.acceptLoan(loan: pending, owner: owner);

      final expired = await repository.expireLoan(loan: accepted);
      expect(expired.status, 'expired');

      final updatedShared = await groupDao.findSharedBookById(sharedBook.id);
      expect(updatedShared?.isAvailable, isTrue);

      final updatedBook = await bookDao.findById(book.id);
      expect(updatedBook?.status, 'available');
    });
  });
}

Future<LocalUser> _insertUser(UserDao userDao, {required String username}) async {
  final now = DateTime(2024, 1, 1, 12);
  final remoteId = 'remote-$username';
  final userId = await userDao.insertUser(
    LocalUsersCompanion.insert(
      uuid: 'user-$username',
      username: username,
      remoteId: drift.Value(remoteId),
      isDirty: const drift.Value(false),
      isDeleted: const drift.Value(false),
      createdAt: drift.Value(now),
      updatedAt: drift.Value(now),
    ),
  );
  return (await userDao.getById(userId))!;
}

Future<Group> _insertGroup(GroupDao groupDao, LocalUser owner) async {
  final now = DateTime(2024, 1, 1, 12);
  final groupId = await groupDao.insertGroup(
    GroupsCompanion.insert(
      uuid: 'group-1',
      remoteId: const drift.Value('group-remote-1'),
      name: 'Club de lectura',
      ownerUserId: drift.Value(owner.id),
      ownerRemoteId: drift.Value(owner.remoteId ?? 'remote-owner'),
      isDirty: const drift.Value(false),
      isDeleted: const drift.Value(false),
      syncedAt: drift.Value(now),
      createdAt: drift.Value(now),
      updatedAt: drift.Value(now),
    ),
  );
  return (await groupDao.findGroupById(groupId))!;
}

Future<Book> _insertBook(BookDao bookDao, {required int ownerUserId, required String uuid}) async {
  final now = DateTime(2024, 1, 1, 12);
  final bookId = await bookDao.insertBook(
    BooksCompanion.insert(
      uuid: uuid,
      remoteId: const drift.Value('book-remote-1'),
      ownerUserId: drift.Value(ownerUserId),
      ownerRemoteId: const drift.Value('remote-owner'),
      title: 'Clean Code',
      author: const drift.Value('Robert C. Martin'),
      status: const drift.Value('available'),
      isDirty: const drift.Value(false),
      isDeleted: const drift.Value(false),
      syncedAt: drift.Value(now),
      createdAt: drift.Value(now),
      updatedAt: drift.Value(now),
    ),
  );
  return (await bookDao.findById(bookId))!;
}

Future<SharedBook> _insertSharedBook(
  GroupDao groupDao, {
  required Group group,
  required Book book,
  required LocalUser owner,
}) async {
  final now = DateTime(2024, 1, 1, 12);
  final sharedId = await groupDao.insertSharedBook(
    SharedBooksCompanion.insert(
      uuid: 'shared-${book.uuid}',
      remoteId: drift.Value('shared-remote-${book.id}'),
      groupId: group.id,
      groupUuid: group.uuid,
      bookId: book.id,
      bookUuid: book.uuid,
      ownerUserId: owner.id,
      ownerRemoteId: drift.Value(owner.remoteId ?? 'remote-owner'),
      visibility: const drift.Value('group'),
      isAvailable: const drift.Value(true),
      isDirty: const drift.Value(false),
      isDeleted: const drift.Value(false),
      syncedAt: drift.Value(now),
      createdAt: drift.Value(now),
      updatedAt: drift.Value(now),
    ),
  );
  return (await groupDao.findSharedBookById(sharedId))!;
}
