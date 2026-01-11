import 'package:book_sharing_app/data/local/book_dao.dart';
import 'package:book_sharing_app/data/local/database.dart';
import 'package:book_sharing_app/data/local/group_dao.dart';
import 'package:book_sharing_app/data/local/user_dao.dart';
import 'package:book_sharing_app/data/local/notification_dao.dart';
import 'package:book_sharing_app/data/repositories/loan_repository.dart';
import 'package:book_sharing_app/data/repositories/notification_repository.dart';
import 'package:book_sharing_app/models/global_sync_state.dart';
import 'package:book_sharing_app/services/loan_controller.dart';
import 'package:book_sharing_app/services/notification_service.dart';
import 'package:book_sharing_app/services/unified_sync_coordinator.dart';
import 'package:drift/drift.dart' as drift;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:uuid/uuid.dart';

// Mock classes for external dependencies
class MockNotificationClient extends Mock implements NotificationClient {}

class MockUnifiedSyncCoordinator extends Mock
    implements UnifiedSyncCoordinator {}

void main() {
  group('LoanController', () {
    late AppDatabase db;
    late GroupDao groupDao;
    late BookDao bookDao;
    late UserDao userDao;
    late NotificationDao notificationDao;
    late LoanRepository loanRepository;
    late NotificationRepository notificationRepository;
    late LoanController loanController;
    late MockNotificationClient mockNotificationClient;
    late MockUnifiedSyncCoordinator mockSyncCoordinator;

    late LocalUser owner;
    late LocalUser borrower;
    late Group testGroup;
    late Book book;
    late SharedBook sharedBook;

    setUpAll(() {
      registerFallbackValue(NotificationType.loanDueSoon);
      registerFallbackValue(SyncEvent.loanCreated);
      registerFallbackValue(SyncEntity.books);
      registerFallbackValue(SyncPriority.high);
    });

    setUp(() async {
      db = AppDatabase.test(NativeDatabase.memory());
      groupDao = GroupDao(db);
      bookDao = BookDao(db);
      userDao = UserDao(db);
      notificationDao = NotificationDao(db);
      loanRepository = LoanRepository(
        groupDao: groupDao,
        bookDao: bookDao,
        userDao: userDao,
        uuid: const Uuid(),
      );
      notificationRepository = NotificationRepository(
        notificationDao: notificationDao,
      );

      // Create mocks
      mockNotificationClient = MockNotificationClient();
      mockSyncCoordinator = MockUnifiedSyncCoordinator();

      // Stub sync coordinator methods
      when(() => mockSyncCoordinator.syncOnCriticalEvent(any<SyncEvent>()))
          .thenAnswer((_) async {});
      when(() => mockSyncCoordinator.markPendingChanges(any(),
          priority: any(named: 'priority'))).thenReturn(null);

      // Stub notification client methods
      when(() => mockNotificationClient.cancelMany(any()))
          .thenAnswer((_) async {});
      when(() => mockNotificationClient.schedule(
            id: any(named: 'id'),
            type: any(named: 'type'),
            title: any(named: 'title'),
            body: any(named: 'body'),
            scheduledAt: any(named: 'scheduledAt'),
            payload: any(named: 'payload'),
          )).thenAnswer((_) async {});
      when(() => mockNotificationClient.showImmediate(
            id: any(named: 'id'),
            type: any(named: 'type'),
            title: any(named: 'title'),
            body: any(named: 'body'),
            payload: any(named: 'payload'),
            androidActions: any(named: 'androidActions'),
          )).thenAnswer((_) async {});

      // Create controller
      loanController = LoanController(
        loanRepository: loanRepository,
        notificationClient: mockNotificationClient,
        notificationRepository: notificationRepository,
        syncCoordinator: mockSyncCoordinator,
      );

      // Setup test data using same pattern as loan_repository_test
      owner = await _insertUser(userDao, username: 'owner');
      borrower = await _insertUser(userDao, username: 'borrower');
      testGroup = await _insertGroup(groupDao, owner);
      book = await _insertBook(bookDao, ownerUserId: owner.id, uuid: 'book-1');
      sharedBook = await _insertSharedBook(
        groupDao,
        group: testGroup,
        book: book,
        owner: owner,
      );
    });

    tearDown(() async {
      await db.close();
    });

    test('requestLoan creates pending loan successfully', () async {
      final loan = await loanController.requestLoan(
        sharedBook: sharedBook,
        borrower: borrower,
      );

      expect(loan.status, 'requested');
      expect(loan.borrowerUserId, borrower.id);
      expect(loan.lenderUserId, owner.id);
      expect(loanController.state.isLoading, false);
      expect(loanController.state.lastSuccess, isNotNull);

      // Verify critical event was triggered
      verify(() =>
              mockSyncCoordinator.syncOnCriticalEvent(SyncEvent.loanCreated))
          .called(1);
    });

    test('acceptLoan changes status to active', () async {
      final pending = await loanRepository.requestLoan(
        sharedBook: sharedBook,
        borrower: borrower,
      );

      final accepted = await loanController.acceptLoan(
        loan: pending,
        owner: owner,
      );

      expect(accepted.status, 'active');
      expect(loanController.state.lastSuccess, contains('aceptado'));

      final updatedShared = await groupDao.findSharedBookById(sharedBook.id);
      expect(updatedShared?.isAvailable, isFalse);
    });

    test('rejectLoan changes status to rejected', () async {
      final pending = await loanRepository.requestLoan(
        sharedBook: sharedBook,
        borrower: borrower,
      );

      final rejected = await loanController.rejectLoan(
        loan: pending,
        owner: owner,
      );

      expect(rejected.status, 'rejected');
      expect(loanController.state.lastSuccess, contains('rechazada'));

      final refreshedShared = await groupDao.findSharedBookById(sharedBook.id);
      expect(refreshedShared?.isAvailable, isTrue);
    });

    test('cancelLoan changes status to cancelled', () async {
      final pending = await loanRepository.requestLoan(
        sharedBook: sharedBook,
        borrower: borrower,
      );

      final cancelled = await loanController.cancelLoan(
        loan: pending,
        borrower: borrower,
      );

      expect(cancelled.status, 'cancelled');
      expect(loanController.state.lastSuccess, contains('cancelada'));
    });

    test('markReturned requires double confirmation', () async {
      final pending = await loanRepository.requestLoan(
        sharedBook: sharedBook,
        borrower: borrower,
      );
      final accepted = await loanRepository.acceptLoan(
        loan: pending,
        owner: owner,
      );

      // Borrower confirms first
      final borrowerConfirmation = await loanController.markReturned(
        loan: accepted,
        actor: borrower,
      );
      expect(borrowerConfirmation.status, 'active');
      expect(borrowerConfirmation.borrowerReturnedAt, isNotNull);

      // Owner confirms and loan closes
      final returned = await loanController.markReturned(
        loan: borrowerConfirmation,
        actor: owner,
      );
      expect(returned.status, 'completed');
      expect(loanController.state.lastSuccess, contains('devuelto'));

      final updatedShared = await groupDao.findSharedBookById(sharedBook.id);
      expect(updatedShared?.isAvailable, isTrue);
    });

    test('createManualLoan creates active loan for external borrower',
        () async {
      final dueDate = DateTime.now().add(const Duration(days: 14));

      final manualLoan = await loanController.createManualLoan(
        sharedBook: sharedBook,
        owner: owner,
        borrowerName: 'External Person',
        dueDate: dueDate,
        borrowerContact: 'external@example.com',
      );

      expect(manualLoan.status, 'active');
      expect(manualLoan.externalBorrowerName, 'External Person');
      expect(manualLoan.externalBorrowerContact, 'external@example.com');
      expect(manualLoan.borrowerUserId, isNull);
      expect(loanController.state.lastSuccess, contains('manual'));
    });

    test('dismissError clears error state', () {
      loanController.state = loanController.state.copyWith(
        lastError: () => 'Test error',
      );

      loanController.dismissError();

      expect(loanController.state.lastError, isNull);
    });

    test('dismissSuccess clears success state', () {
      loanController.state = loanController.state.copyWith(
        lastSuccess: () => 'Test success',
      );

      loanController.dismissSuccess();

      expect(loanController.state.lastSuccess, isNull);
    });
  });
}

// Helper functions copied from loan_repository_test.dart
Future<LocalUser> _insertUser(UserDao userDao,
    {required String username}) async {
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

Future<Book> _insertBook(BookDao bookDao,
    {required int ownerUserId, required String uuid}) async {
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
