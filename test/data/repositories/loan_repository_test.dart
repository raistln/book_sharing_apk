import 'package:book_sharing_app/data/local/book_dao.dart';
import 'package:book_sharing_app/data/local/database.dart';
import 'package:book_sharing_app/data/local/group_dao.dart';
import 'package:book_sharing_app/data/local/user_dao.dart';
import 'package:book_sharing_app/data/repositories/loan_repository.dart';
import 'package:book_sharing_app/services/supabase_loan_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockGroupDao extends Mock implements GroupDao {}

class _MockBookDao extends Mock implements BookDao {}

class _MockUserDao extends Mock implements UserDao {}

class _MockAppDatabase extends Mock implements AppDatabase {}

class _MockSupabaseLoanService extends Mock implements SupabaseLoanService {}

void main() {
  late _MockGroupDao groupDao;
  late _MockBookDao bookDao;
  late _MockUserDao userDao;
  late _MockAppDatabase mockDatabase;
  late _MockSupabaseLoanService supabaseLoanService;
  late LoanRepository repository;

  setUpAll(() {
    registerFallbackValue(const LoansCompanion());
    registerFallbackValue(const SharedBooksCompanion());
    registerFallbackValue(const BooksCompanion());
    registerFallbackValue(const GroupsCompanion());
  });

  setUp(() {
    groupDao = _MockGroupDao();
    bookDao = _MockBookDao();
    userDao = _MockUserDao();
    mockDatabase = _MockAppDatabase();
    supabaseLoanService = _MockSupabaseLoanService();
    repository = LoanRepository(
      groupDao: groupDao,
      bookDao: bookDao,
      userDao: userDao,
      supabaseLoanService: supabaseLoanService,
    );

    when(() => groupDao.attachedDatabase).thenReturn(mockDatabase);
    when(() => mockDatabase.transaction(any())).thenAnswer((invocation) async {
      final action = invocation.positionalArguments[0] as Future Function();
      return await action();
    });
  });

  group('LoanRepository', () {
    test('getAllLoanDetails delegates to groupDao', () async {
      final loanDetails = <LoanDetail>[];
      when(() => groupDao.getAllLoanDetails()).thenAnswer((_) async => loanDetails);

      final result = await repository.getAllLoanDetails();

      expect(result, loanDetails);
      verify(() => groupDao.getAllLoanDetails()).called(1);
    });

    test('findLoanById delegates to groupDao', () async {
      final loan = Loan(
        id: 1,
        uuid: 'loan-1',
        sharedBookId: 1,
        borrowerUserId: 2,
        lenderUserId: 1,
        status: 'requested',
        requestedAt: DateTime.now(),
        approvedAt: null,
        dueDate: null,
        returnedAt: null,
        borrowerReturnedAt: null,
        lenderReturnedAt: null,
        wasRead: null,
        markedReadAt: null,
        externalBorrowerName: null,
        externalBorrowerContact: null,
        isDirty: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isDeleted: false,
        syncedAt: null,
      );

      when(() => groupDao.findLoanById(1)).thenAnswer((_) async => loan);

      final result = await repository.findLoanById(1);

      expect(result, loan);
      verify(() => groupDao.findLoanById(1)).called(1);
    });
  });
}
