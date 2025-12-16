import 'package:book_sharing_app/data/local/book_dao.dart';
import 'package:book_sharing_app/data/local/database.dart';
import 'package:book_sharing_app/data/local/group_dao.dart';
import 'package:book_sharing_app/data/local/user_dao.dart';
import 'package:book_sharing_app/data/repositories/book_repository.dart';
import 'package:book_sharing_app/data/repositories/loan_repository.dart';
import 'package:book_sharing_app/services/stats_service.dart';
import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;
  late BookDao bookDao;
  late GroupDao groupDao;
  late UserDao userDao;
  late BookRepository bookRepository;
  late LoanRepository loanRepository;
  late StatsService statsService;
  late LocalUser owner;
  late LocalUser borrower;
  late int bookId;
  late int sharedBookId;
  late int groupId;

  setUp(() async {
    db = AppDatabase.test(NativeDatabase.memory());
    bookDao = BookDao(db);
    groupDao = GroupDao(db);
    userDao = UserDao(db);
    bookRepository = BookRepository(
      bookDao,
      groupDao: groupDao,
    );
    loanRepository = LoanRepository(
      groupDao: groupDao,
      bookDao: bookDao,
      userDao: userDao,
    );
    statsService = StatsService(bookRepository, loanRepository);

    final ownerId = await userDao.insertUser(
      LocalUsersCompanion.insert(
        uuid: 'owner-uuid',
        username: 'Owner',
        isDirty: const Value(false),
        isDeleted: const Value(false),
      ),
    );
    final borrowerId = await userDao.insertUser(
      LocalUsersCompanion.insert(
        uuid: 'borrower-uuid',
        username: 'Borrower',
        isDirty: const Value(false),
        isDeleted: const Value(false),
      ),
    );

    owner = (await userDao.getById(ownerId))!;
    borrower = (await userDao.getById(borrowerId))!;

    bookId = await bookDao.insertBook(
      BooksCompanion.insert(
        uuid: 'book-uuid',
        title: 'Book Title',
        status: const Value('available'),
        ownerUserId: Value(ownerId),
        isDirty: const Value(false),
        isDeleted: const Value(false),
      ),
    );

    groupId = await groupDao.insertGroup(
      GroupsCompanion.insert(
        uuid: 'group-uuid',
        name: 'Grupo',
        ownerUserId: Value(ownerId),
        isDirty: const Value(false),
        isDeleted: const Value(false),
      ),
    );

    sharedBookId = await groupDao.insertSharedBook(
      SharedBooksCompanion.insert(
        uuid: 'shared-book-uuid',
        groupId: groupId,
        groupUuid: 'group-uuid',
        bookId: bookId,
        bookUuid: 'book-uuid',
        ownerUserId: ownerId,
        isAvailable: const Value(true),
        isDirty: const Value(false),
        isDeleted: const Value(false),
      ),
    );
  });

  tearDown(() async {
    await db.close();
  });

  Future<Loan> seedLoan({
    required String uuid,
    required String status,
    LocalUser? borrowerOverride,
    DateTime? dueDate,
  }) async {
    final borrowerUser = borrowerOverride ?? borrower;

    final loanId = await groupDao.insertLoan(
      LoansCompanion.insert(
        uuid: uuid,
        sharedBookId: Value(sharedBookId),
        borrowerUserId: Value(borrowerUser.id),
        lenderUserId: owner.id,
        status: Value(status),
        requestedAt: Value(DateTime(2024, 1, 1)),
        dueDate: dueDate != null ? Value(dueDate) : const Value.absent(),
        isDirty: const Value(false),
        isDeleted: const Value(false),
        createdAt: Value(DateTime(2024, 1, 1)),
        updatedAt: Value(DateTime(2024, 1, 1)),
      ),
    );

    return (await groupDao.findLoanById(loanId))!;
  }

  test('loadSummary aggregates active loans and top books correctly', () async {
    final otherBookId = await bookDao.insertBook(
      BooksCompanion.insert(
        uuid: 'book-uuid-2',
        title: 'Other Book',
        status: const Value('available'),
        ownerUserId: Value(owner.id),
        isDirty: const Value(false),
        isDeleted: const Value(false),
      ),
    );

    final otherSharedBookId = await groupDao.insertSharedBook(
      SharedBooksCompanion.insert(
        uuid: 'shared-book-uuid-2',
        groupId: groupId,
        groupUuid: 'group-uuid',
        bookId: otherBookId,
        bookUuid: 'book-uuid-2',
        ownerUserId: owner.id,
        isAvailable: const Value(true),
        isDirty: const Value(false),
        isDeleted: const Value(false),
      ),
    );

    final secondBorrowerId = await userDao.insertUser(
      LocalUsersCompanion.insert(
        uuid: 'borrower-uuid-2',
        username: 'Borrower 2',
        isDirty: const Value(false),
        isDeleted: const Value(false),
      ),
    );
    final secondBorrower = (await userDao.getById(secondBorrowerId))!;

    await seedLoan(
      uuid: 'loan-active',
      status: 'active',
      dueDate: DateTime(2024, 2, 1),
    );

    await seedLoan(
      uuid: 'loan-requested',
      status: 'requested',
      borrowerOverride: borrower,
      dueDate: DateTime(2024, 1, 15),
    );

    await groupDao.insertLoan(
      LoansCompanion.insert(
        uuid: 'loan-returned',
        sharedBookId: Value(sharedBookId),
        borrowerUserId: Value(borrower.id),
        lenderUserId: owner.id,
        status: const Value('returned'),
        requestedAt: Value(DateTime(2024, 1, 5)),
        returnedAt: Value(DateTime(2024, 1, 20)),
        isDirty: const Value(false),
        isDeleted: const Value(false),
        createdAt: Value(DateTime(2024, 1, 5)),
        updatedAt: Value(DateTime(2024, 1, 20)),
      ),
    );

    await groupDao.insertLoan(
      LoansCompanion.insert(
        uuid: 'loan-expired',
        sharedBookId: Value(otherSharedBookId),
        borrowerUserId: Value(secondBorrower.id),
        lenderUserId: owner.id,
        status: const Value('expired'),
        requestedAt: Value(DateTime(2024, 1, 10)),
        dueDate: Value(DateTime(2024, 1, 25)),
        isDirty: const Value(false),
        isDeleted: const Value(false),
        createdAt: Value(DateTime(2024, 1, 10)),
        updatedAt: Value(DateTime(2024, 1, 25)),
      ),
    );

    final summary = await statsService.loadSummary();

    expect(summary.totalBooks, 2);
    expect(summary.totalLoans, 4);
    expect(summary.activeLoans, 2);
    expect(summary.returnedLoans, 1);
    expect(summary.expiredLoans, 1);

    final activeLoanByUuid = {for (final loan in summary.activeLoanDetails) loan.loanUuid: loan};
    final activeLoan = activeLoanByUuid['loan-active'];
    final requestedLoan = activeLoanByUuid['loan-requested'];

    expect(activeLoan, isNotNull);
    expect(activeLoan!.bookTitle, 'Book Title');
    expect(activeLoan.borrowerName, 'Borrower');
    expect(activeLoan.status, 'active');
    expect(activeLoan.groupId, groupId);
    expect(activeLoan.sharedBookId, sharedBookId);
    expect(activeLoan.dueDate, DateTime(2024, 2, 1));

    expect(requestedLoan, isNotNull);
    expect(requestedLoan!.status, 'requested');
    expect(requestedLoan.groupId, groupId);
    expect(requestedLoan.sharedBookId, sharedBookId);

    expect(summary.topBooks, hasLength(2));
    final topByTitle = {for (final entry in summary.topBooks) entry.title: entry};
    expect(topByTitle['Book Title']?.loanCount, 2);
    expect(topByTitle['Other Book']?.loanCount, 1);
  });

  test('loadSummary resolves unknown book title gracefully', () async {
    await bookDao.softDeleteBook(bookId: bookId, timestamp: DateTime(2024, 1, 1));

    await groupDao.insertLoan(
      LoansCompanion.insert(
        uuid: 'loan-without-book',
        sharedBookId: Value(sharedBookId),
        borrowerUserId: Value(borrower.id),
        lenderUserId: owner.id,
        status: const Value('active'),
        requestedAt: Value(DateTime(2024, 1, 1)),
        isDirty: const Value(false),
        isDeleted: const Value(false),
        createdAt: Value(DateTime(2024, 1, 1)),
        updatedAt: Value(DateTime(2024, 1, 1)),
      ),
    );

    final summary = await statsService.loadSummary();

    expect(summary.activeLoanDetails, hasLength(1));
    final loan = summary.activeLoanDetails.single;
    expect(loan.bookTitle, 'Libro sin título');
  });
}
