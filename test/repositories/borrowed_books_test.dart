import 'package:book_sharing_app/data/local/book_dao.dart';
import 'package:book_sharing_app/data/local/database.dart';
import 'package:book_sharing_app/data/local/group_dao.dart';
import 'package:book_sharing_app/data/local/user_dao.dart';
import 'package:drift/drift.dart' as drift;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Borrowed Books Integration via BookDao', () {
    late AppDatabase db;
    late BookDao bookDao;
    late UserDao userDao;
    late GroupDao groupDao;

    late LocalUser owner;
    late LocalUser borrower;

    setUp(() async {
      db = AppDatabase.test(NativeDatabase.memory());
      bookDao = BookDao(db);
      userDao = UserDao(db);
      groupDao = GroupDao(db);

      owner = await _insertUser(userDao, username: 'owner_user');
      borrower = await _insertUser(userDao, username: 'borrower_user');
    });

    tearDown(() async {
      await db.close();
    });

    test(
        'watchBooksIncludingLoans only includes approved or active loans from clubs/groups',
        () async {
      // 1. Setup Group
      final group = await _insertGroup(groupDao, name: 'Library Club');
      await _insertMember(groupDao, group: group, userId: owner.id);
      await _insertMember(groupDao, group: group, userId: borrower.id);

      // 2. Add books owned by 'owner'
      final book1 =
          await _insertBook(bookDao, owner: owner, title: 'Book 1 (Requested)');
      final book2 =
          await _insertBook(bookDao, owner: owner, title: 'Book 2 (Approved)');
      final book3 =
          await _insertBook(bookDao, owner: owner, title: 'Book 3 (Active)');
      final book4 =
          await _insertBook(bookDao, owner: owner, title: 'Book 4 (Finished)');

      // 3. Share the books in the group
      final sb1Id =
          await _insertSharedBook(groupDao, group: group, book: book1);
      final sb2Id =
          await _insertSharedBook(groupDao, group: group, book: book2);
      final sb3Id =
          await _insertSharedBook(groupDao, group: group, book: book3);
      final sb4Id =
          await _insertSharedBook(groupDao, group: group, book: book4);

      // 4. Create loans for the 'borrower' with different statuses
      await _insertLoan(groupDao,
          sharedBookId: sb1Id,
          lenderUserId: owner.id,
          borrowerUserId: borrower.id,
          status: 'requested');
      await _insertLoan(groupDao,
          sharedBookId: sb2Id,
          lenderUserId: owner.id,
          borrowerUserId: borrower.id,
          status: 'approved');
      await _insertLoan(groupDao,
          sharedBookId: sb3Id,
          lenderUserId: owner.id,
          borrowerUserId: borrower.id,
          status: 'active');
      // For Finished we often set the loan status to 'completed' or 'returned', but the shelf relies on the Book's own readingStatus being 'finished' while the loan *might* be still active historically, but if returned it's not in the active list.
      // The user wants it to appear on the bookshelf even when read. The bookshelf filters active books (owned or borrowed) and checks readingStatus == finished.
      // If a loan is completed, does the borrower still "own" it in the library? Actually, the watchBooksIncludingLoans method only fetches books where loan is active/approved. Once returned/completed, it might disappear from the borrower's library unless we also include 'completed' loans, or keep it in timeline.
      await _insertLoan(groupDao,
          sharedBookId: sb4Id,
          lenderUserId: owner.id,
          borrowerUserId: borrower.id,
          status: 'completed'); // to test exclusion

      // 5. Watch books for borrower
      final booksStream = bookDao.watchBooksIncludingLoans(borrower.id);
      final booksList = await booksStream.first;

      // Extract titles for easier checking
      final titles = booksList.map((b) => b.title).toList();

      // Assertions
      // Borrower shouldn't see 'Book 1' because it's only 'requested', not approved yet.
      expect(titles.contains('Book 1 (Requested)'), isFalse,
          reason: 'Requested loans should not appear in library');

      // Borrower should see 'Book 2' (approved) and 'Book 3' (active)
      expect(titles.contains('Book 2 (Approved)'), isTrue,
          reason: 'Approved loans should appear in library');
      expect(titles.contains('Book 3 (Active)'), isTrue,
          reason: 'Active loans should appear in library');

      // Borrower shouldn't see 'Book 4' because the loan is completed (so it's no longer actively 'borrowed' in the main library).
      // Wait, if it's not in the library, how does it appear on the bookshelf?
      expect(titles.contains('Book 4 (Finished)'), isFalse,
          reason:
              'Completed loans no longer appear as active books in the library unless requested');
    });

    test(
        'watchBooksIncludingLoans includes completed loans ONLY IF book is finished/read',
        () async {
      // 1. Setup Group
      final group = await _insertGroup(groupDao, name: 'Archive Club');
      await _insertMember(groupDao, group: group, userId: owner.id);
      await _insertMember(groupDao, group: group, userId: borrower.id);

      // 2. Add books
      final bookFinished = await _insertBook(bookDao,
          owner: owner,
          title: 'Finished Book',
          readingStatus: 'finished',
          isRead: true);
      final bookNotFinished = await _insertBook(bookDao,
          owner: owner,
          title: 'Not Finished Book',
          readingStatus: 'pending',
          isRead: false);

      // 3. Share
      final sbFinishedId =
          await _insertSharedBook(groupDao, group: group, book: bookFinished);
      final sbNotFinishedId = await _insertSharedBook(groupDao,
          group: group, book: bookNotFinished);

      // 4. Create COMPLETED loans
      await _insertLoan(groupDao,
          sharedBookId: sbFinishedId,
          lenderUserId: owner.id,
          borrowerUserId: borrower.id,
          status: 'completed');
      await _insertLoan(groupDao,
          sharedBookId: sbNotFinishedId,
          lenderUserId: owner.id,
          borrowerUserId: borrower.id,
          status: 'completed');

      // 5. Watch
      final booksList =
          await bookDao.watchBooksIncludingLoans(borrower.id).first;
      final titles = booksList.map((b) => b.title).toList();

      // Current expectation: This will FAIL until we update the DAO.
      expect(titles.contains('Finished Book'), isTrue,
          reason:
              'Finished borrowed books should persist in library for bookshelf/stats');
      expect(titles.contains('Not Finished Book'), isFalse,
          reason:
              'Returned books that were not read should not clutter the library');
    });
  });
}

// Helpers
Future<LocalUser> _insertUser(UserDao userDao,
    {required String username}) async {
  final now = DateTime.now();
  final userId = await userDao.insertUser(
    LocalUsersCompanion.insert(
      uuid: 'user-$username',
      username: username,
      remoteId: drift.Value('remote-$username'),
      isDirty: const drift.Value(false),
      isDeleted: const drift.Value(false),
      createdAt: drift.Value(now),
      updatedAt: drift.Value(now),
    ),
  );
  return (await userDao.getById(userId))!;
}

Future<Book> _insertBook(BookDao bookDao,
    {required LocalUser owner,
    required String title,
    String readingStatus = 'pending',
    bool isRead = false}) async {
  final now = DateTime.now();
  final bookId = await bookDao.insertBook(
    BooksCompanion.insert(
      uuid: 'book-$title',
      title: title,
      readingStatus: drift.Value(readingStatus),
      isRead: drift.Value(isRead),
      status: const drift.Value('available'),
      ownerUserId: drift.Value(owner.id),
      isDirty: const drift.Value(false),
      isDeleted: const drift.Value(false),
      createdAt: drift.Value(now),
      updatedAt: drift.Value(now),
    ),
  );
  return (await bookDao.findById(bookId))!;
}

Future<Group> _insertGroup(GroupDao groupDao, {required String name}) async {
  final now = DateTime.now();
  final groupId = await groupDao.insertGroup(
    GroupsCompanion.insert(
      uuid: 'group-$name',
      name: name,
      remoteId: drift.Value('remote-$name'),
      isDirty: const drift.Value(false),
      isDeleted: const drift.Value(false),
      createdAt: drift.Value(now),
      updatedAt: drift.Value(now),
    ),
  );
  return (await groupDao.findGroupById(groupId))!;
}

Future<void> _insertMember(GroupDao groupDao,
    {required Group group, required int userId}) async {
  final now = DateTime.now();
  await groupDao.insertMember(
    GroupMembersCompanion.insert(
      uuid: 'member-${group.id}-$userId',
      groupId: group.id,
      groupUuid: group.uuid,
      memberUserId: userId,
      remoteId: drift.Value('remote-member-${group.id}-$userId'),
      isDirty: const drift.Value(false),
      isDeleted: const drift.Value(false),
      createdAt: drift.Value(now),
      updatedAt: drift.Value(now),
    ),
  );
}

Future<int> _insertSharedBook(GroupDao groupDao,
    {required Group group, required Book book}) async {
  final now = DateTime.now();
  final sbId = await groupDao.insertSharedBook(
    SharedBooksCompanion.insert(
      uuid: 'sb-${group.id}-${book.id}',
      groupId: group.id,
      groupUuid: group.uuid,
      bookId: book.id,
      bookUuid: book.uuid,
      ownerUserId: book.ownerUserId!,
      isAvailable: const drift.Value(true),
      visibility: const drift.Value('group'),
      isDirty: const drift.Value(false),
      isDeleted: const drift.Value(false),
      createdAt: drift.Value(now),
      updatedAt: drift.Value(now),
    ),
  );
  return sbId;
}

Future<void> _insertLoan(GroupDao groupDao,
    {required int sharedBookId,
    required int lenderUserId,
    required int borrowerUserId,
    required String status}) async {
  final now = DateTime.now();
  await groupDao.insertLoan(
    LoansCompanion.insert(
      uuid: 'loan-$sharedBookId-$borrowerUserId',
      sharedBookId: drift.Value(sharedBookId),
      lenderUserId: lenderUserId,
      borrowerUserId: drift.Value(borrowerUserId),
      status: drift.Value(status),
      isDirty: const drift.Value(false),
      isDeleted: const drift.Value(false),
      createdAt: drift.Value(now),
      updatedAt: drift.Value(now),
    ),
  );
}
