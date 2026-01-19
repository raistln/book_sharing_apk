import 'package:book_sharing_app/data/local/book_dao.dart';
import 'package:book_sharing_app/data/local/database.dart';
import 'package:book_sharing_app/data/local/group_dao.dart';
import 'package:book_sharing_app/data/local/user_dao.dart';
import 'package:book_sharing_app/data/repositories/loan_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:uuid/uuid.dart';
import '../helpers/test_helper.dart';

void main() {
  group('LoanRepository', () {
    late AppDatabase db;
    late GroupDao groupDao;
    late BookDao bookDao;
    late UserDao userDao;
    late LoanRepository loanRepository;
    late MockSupabaseLoanService mockSupabaseLoanService;

    late LocalUser owner;
    late LocalUser borrower;
    late Group testGroup;
    late Book book;
    late SharedBook sharedBook;

    setUpAll(() {
      setupTestFallbacks();
    });

    setUp(() async {
      db = createTestDatabase();
      groupDao = GroupDao(db);
      bookDao = BookDao(db);
      userDao = UserDao(db);
      mockSupabaseLoanService = MockSupabaseLoanService();

      // Stub RPC methods
      when(() => mockSupabaseLoanService.acceptLoan(
            loanId: any(named: 'loanId'),
            lenderUserId: any(named: 'lenderUserId'),
          )).thenAnswer((_) async => {});

      loanRepository = LoanRepository(
        groupDao: groupDao,
        bookDao: bookDao,
        userDao: userDao,
        supabaseLoanService: mockSupabaseLoanService,
        uuid: const Uuid(),
      );

      // Setup test data
      owner = await insertTestUser(userDao, username: 'owner');
      borrower = await insertTestUser(userDao, username: 'borrower');
      testGroup = await insertTestGroup(groupDao, owner);
      book =
          await insertTestBook(bookDao, ownerUserId: owner.id, uuid: 'book-1');
      sharedBook = await insertTestSharedBook(
        groupDao,
        group: testGroup,
        book: book,
        owner: owner,
      );
    });

    tearDown(() async {
      await db.close();
    });

    test('requestLoan inserts a loan with requested status', () async {
      final loan = await loanRepository.requestLoan(
        sharedBook: sharedBook,
        borrower: borrower,
      );

      expect(loan.status, 'requested');
      expect(loan.borrowerUserId, borrower.id);
      expect(loan.lenderUserId, owner.id);
      expect(loan.isDirty, isTrue);
    });

    test('requestLoan fails if book is already lent', () async {
      // First loan request
      final loan1 = await loanRepository.requestLoan(
        sharedBook: sharedBook,
        borrower: borrower,
      );

      // Accept it to make it 'active'
      await loanRepository.acceptLoan(loan: loan1, owner: owner);

      // Try to request again with a different borrower
      final otherBorrower = await insertTestUser(userDao, username: 'other');

      expect(
        () => loanRepository.requestLoan(
          sharedBook: sharedBook,
          borrower: otherBorrower,
        ),
        throwsA(isA<LoanException>().having(
            (e) => e.message, 'message', contains('ya se encuentra prestado'))),
      );
    });

    test('acceptLoan transitions status from requested to active', () async {
      final requested = await loanRepository.requestLoan(
        sharedBook: sharedBook,
        borrower: borrower,
      );

      final accepted = await loanRepository.acceptLoan(
        loan: requested,
        owner: owner,
      );

      expect(accepted.status, 'active');

      final updatedShared = await groupDao.findSharedBookById(sharedBook.id);
      expect(updatedShared?.isAvailable, isFalse);
    });

    test('rejectLoan transitions status from requested to rejected', () async {
      final requested = await loanRepository.requestLoan(
        sharedBook: sharedBook,
        borrower: borrower,
      );

      final rejected = await loanRepository.rejectLoan(
        loan: requested,
        owner: owner,
      );

      expect(rejected.status, 'rejected');

      final updatedShared = await groupDao.findSharedBookById(sharedBook.id);
      expect(updatedShared?.isAvailable, isTrue);
    });

    test('markReturned requires double confirmation for normal loans',
        () async {
      final requested = await loanRepository.requestLoan(
        sharedBook: sharedBook,
        borrower: borrower,
      );
      final active = await loanRepository.acceptLoan(
        loan: requested,
        owner: owner,
      );

      // Borrower confirms first
      final halfReturned = await loanRepository.markReturned(
        loan: active,
        actor: borrower,
      );

      expect(halfReturned.status, 'active');
      expect(halfReturned.borrowerReturnedAt, isNotNull);
      expect(halfReturned.lenderReturnedAt, isNull);

      // Owner confirms second
      final fullyReturned = await loanRepository.markReturned(
        loan: halfReturned,
        actor: owner,
      );

      expect(fullyReturned.status, 'completed');
      expect(fullyReturned.lenderReturnedAt, isNotNull);

      final updatedShared = await groupDao.findSharedBookById(sharedBook.id);
      expect(updatedShared?.isAvailable, isTrue);
    });
  });
}
