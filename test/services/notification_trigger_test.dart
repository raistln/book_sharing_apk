import 'package:book_sharing_app/data/local/database.dart';
import 'package:book_sharing_app/data/local/group_dao.dart';
import 'package:book_sharing_app/data/repositories/book_repository.dart';
import 'package:book_sharing_app/data/repositories/group_push_repository.dart';
import 'package:book_sharing_app/data/repositories/loan_repository.dart';
import 'package:book_sharing_app/data/repositories/notification_repository.dart';
import 'package:book_sharing_app/data/models/in_app_notification_type.dart';
import 'package:book_sharing_app/data/models/in_app_notification_status.dart';
import 'package:book_sharing_app/services/group_push_controller.dart';
import 'package:book_sharing_app/services/group_sync_controller.dart';
import 'package:book_sharing_app/services/loan_controller.dart';
import 'package:book_sharing_app/services/notification_service.dart';
import 'package:book_sharing_app/services/unified_sync_coordinator.dart';
import 'package:book_sharing_app/models/global_sync_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockLoanRepository extends Mock implements LoanRepository {}
class MockNotificationRepository extends Mock implements NotificationRepository {}
class MockNotificationClient extends Mock implements NotificationClient {}
class MockSyncCoordinator extends Mock implements UnifiedSyncCoordinator {}
class MockGroupPushRepository extends Mock implements GroupPushRepository {}
class MockGroupSyncController extends Mock implements GroupSyncController {}
class MockBookRepository extends Mock implements BookRepository {}
class MockGroupDao extends Mock implements GroupDao {}

class FakeLoan extends Fake implements Loan {
  @override
  int get id => 1;
  @override
  String get uuid => 'loan-uuid-123';
  @override
  int? get borrowerUserId => 101;
  @override
  int get lenderUserId => 100;
  @override
  int? get sharedBookId => 1;
  @override
  int? get bookId => null;
  @override
  String get status => 'requested';
  @override
  DateTime? get dueDate => null;
  @override
  DateTime get createdAt => DateTime.now();
  @override
  DateTime get updatedAt => DateTime.now();
}

class FakeSharedBook extends Fake implements SharedBook {
  @override
  int get id => 1;
  @override
  int get ownerUserId => 100;
  @override
  int get groupId => 1;
  @override
  int get bookId => 1;
}

class FakeLocalUser extends Fake implements LocalUser {
  @override
  int get id => 101;
  @override
  String get username => 'testuser';
}

class FakeGroup extends Fake implements Group {
  @override
  int get id => 1;
  @override
  String get name => 'Test Group';
  @override
  int get ownerUserId => 100;
}

class FakeGroupMember extends Fake implements GroupMember {
  FakeGroupMember(this.memberUserId, [this.groupId = 1]);
  @override
  final int memberUserId;
  @override
  final int groupId;
}

void main() {
  late MockLoanRepository mockLoanRepo;
  late MockNotificationRepository mockNotifRepo;
  late MockNotificationClient mockNotifClient;
  late MockSyncCoordinator mockSyncCoord;
  late MockGroupPushRepository mockGroupPushRepo;
  late MockGroupSyncController mockGroupSyncCont;
  late MockBookRepository mockBookRepo;
  late MockGroupDao mockGroupDao;

  late LoanController loanController;
  late GroupPushController groupPushController;

  setUpAll(() {
    registerFallbackValue(InAppNotificationType.loanRequested);
    registerFallbackValue(FakeLoan());
    registerFallbackValue(FakeSharedBook());
    registerFallbackValue(FakeLocalUser());
    registerFallbackValue(FakeGroup());
    registerFallbackValue(FakeGroupMember(0));
    registerFallbackValue(DateTime.now());
    registerFallbackValue(InAppNotificationStatus.unread);
    registerFallbackValue(SyncEvent.loanCreated);
  });

  setUp(() {
    mockLoanRepo = MockLoanRepository();
    mockNotifRepo = MockNotificationRepository();
    mockNotifClient = MockNotificationClient();
    mockSyncCoord = MockSyncCoordinator();
    mockGroupPushRepo = MockGroupPushRepository();
    mockGroupSyncCont = MockGroupSyncController();
    mockBookRepo = MockBookRepository();
    mockGroupDao = MockGroupDao();

    // Stubs for sync and other dependencies
    when(() => mockSyncCoord.syncOnCriticalEvent(any())).thenAnswer((_) async {});
    when(() => mockNotifClient.cancelMany(any())).thenAnswer((_) async {});
    when(() => mockNotifClient.cancel(any())).thenAnswer((_) async {});
    when(() => mockLoanRepo.findBookById(any())).thenAnswer((_) async => null);
    when(() => mockLoanRepo.findSharedBookById(any())).thenAnswer((_) async => null);

    loanController = LoanController(
      loanRepository: mockLoanRepo,
      notificationClient: mockNotifClient,
      notificationRepository: mockNotifRepo,
      syncCoordinator: mockSyncCoord,
    );

    groupPushController = GroupPushController(
      groupPushRepository: mockGroupPushRepo,
      groupSyncController: mockGroupSyncCont,
      notificationClient: mockNotifClient,
      bookRepository: mockBookRepo,
      groupDao: mockGroupDao,
      syncCoordinator: mockSyncCoord,
      notificationRepository: mockNotifRepo,
    );
  });

  group('Loan Notification Triggers', () {
    test('requestLoan triggers loanRequested notification', () async {
      final loan = FakeLoan();
      final sharedBook = FakeSharedBook();
      final borrower = FakeLocalUser();

      when(() => mockLoanRepo.requestLoan(
            sharedBook: any(named: 'sharedBook'),
            borrower: any(named: 'borrower'),
            dueDate: any(named: 'dueDate'),
          )).thenAnswer((_) async => loan);
      
      when(() => mockNotifRepo.createLoanNotification(
        type: any(named: 'type'),
        loan: any(named: 'loan'),
        targetUserId: any(named: 'targetUserId'),
        actorUserId: any(named: 'actorUserId'),
        title: any(named: 'title'),
        message: any(named: 'message'),
      )).thenAnswer((_) async => 1);

      await loanController.requestLoan(sharedBook: sharedBook, borrower: borrower);

      verify(() => mockNotifRepo.createLoanNotification(
            type: InAppNotificationType.loanRequested,
            loan: loan,
            targetUserId: sharedBook.ownerUserId,
            actorUserId: borrower.id,
            title: any(named: 'title'),
            message: any(named: 'message'),
          )).called(1);
    });

    test('acceptLoan triggers loanApproved notification', () async {
      final loan = FakeLoan();
      final owner = FakeLocalUser();

      when(() => mockLoanRepo.acceptLoan(
            loan: any(named: 'loan'),
            owner: any(named: 'owner'),
            dueDate: any(named: 'dueDate'),
          )).thenAnswer((_) async => loan);
      
      when(() => mockNotifRepo.markLoanNotifications(
        loanId: any(named: 'loanId'),
        status: any(named: 'status'),
      )).thenAnswer((_) async {});

      when(() => mockNotifRepo.createLoanNotification(
        type: any(named: 'type'),
        loan: any(named: 'loan'),
        targetUserId: any(named: 'targetUserId'),
        actorUserId: any(named: 'actorUserId'),
        title: any(named: 'title'),
        message: any(named: 'message'),
      )).thenAnswer((_) async => 1);

      await loanController.acceptLoan(loan: loan, owner: owner);

      verify(() => mockNotifRepo.createLoanNotification(
            type: InAppNotificationType.loanApproved,
            loan: loan,
            targetUserId: loan.borrowerUserId!,
            actorUserId: owner.id,
            title: any(named: 'title'),
            message: any(named: 'message'),
          )).called(1);
    });

    test('rejectLoan triggers loanRejected notification', () async {
      final loan = FakeLoan();
      final owner = FakeLocalUser();

      when(() => mockLoanRepo.rejectLoan(
            loan: any(named: 'loan'),
            owner: any(named: 'owner'),
          )).thenAnswer((_) async => loan);
      
      when(() => mockNotifRepo.markLoanNotifications(
        loanId: any(named: 'loanId'),
        status: any(named: 'status'),
      )).thenAnswer((_) async {});

      when(() => mockNotifRepo.createLoanNotification(
        type: any(named: 'type'),
        loan: any(named: 'loan'),
        targetUserId: any(named: 'targetUserId'),
        actorUserId: any(named: 'actorUserId'),
        title: any(named: 'title'),
        message: any(named: 'message'),
      )).thenAnswer((_) async => 1);

      await loanController.rejectLoan(loan: loan, owner: owner);

      verify(() => mockNotifRepo.createLoanNotification(
            type: InAppNotificationType.loanRejected,
            loan: loan,
            targetUserId: loan.borrowerUserId!,
            actorUserId: owner.id,
            title: any(named: 'title'),
            message: any(named: 'message'),
          )).called(1);
    });

    test('cancelLoan triggers loanCancelled notification', () async {
      final loan = FakeLoan();
      final borrower = FakeLocalUser();

      when(() => mockLoanRepo.cancelLoan(
            loan: any(named: 'loan'),
            borrower: any(named: 'borrower'),
          )).thenAnswer((_) async => loan);
      
      when(() => mockNotifRepo.markLoanNotifications(
        loanId: any(named: 'loanId'),
        status: any(named: 'status'),
      )).thenAnswer((_) async {});

      when(() => mockNotifRepo.createLoanNotification(
        type: any(named: 'type'),
        loan: any(named: 'loan'),
        targetUserId: any(named: 'targetUserId'),
        actorUserId: any(named: 'actorUserId'),
        title: any(named: 'title'),
        message: any(named: 'message'),
      )).thenAnswer((_) async => 1);

      await loanController.cancelLoan(loan: loan, borrower: borrower);

      verify(() => mockNotifRepo.createLoanNotification(
            type: InAppNotificationType.loanCancelled,
            loan: loan,
            targetUserId: loan.lenderUserId,
            actorUserId: borrower.id,
            title: any(named: 'title'),
            message: any(named: 'message'),
          )).called(1);
    });

    test('markReturned triggers loanReturned notification', () async {
      final loan = FakeLoan();
      final borrower = FakeLocalUser(); // borrower acts

      when(() => mockLoanRepo.markReturned(
            loan: any(named: 'loan'),
            actor: any(named: 'actor'),
          )).thenAnswer((_) async => loan);
      
      when(() => mockNotifRepo.markLoanNotifications(
        loanId: any(named: 'loanId'),
        status: any(named: 'status'),
      )).thenAnswer((_) async {});

      when(() => mockNotifRepo.createLoanNotification(
        type: any(named: 'type'),
        loan: any(named: 'loan'),
        targetUserId: any(named: 'targetUserId'),
        actorUserId: any(named: 'actorUserId'),
        title: any(named: 'title'),
        message: any(named: 'message'),
      )).thenAnswer((_) async => 1);

      await loanController.markReturned(loan: loan, actor: borrower);

      verify(() => mockNotifRepo.createLoanNotification(
            type: InAppNotificationType.loanReturned,
            loan: loan,
            targetUserId: loan.lenderUserId,
            actorUserId: borrower.id,
            title: any(named: 'title'),
            message: any(named: 'message'),
          )).called(1);
    });
  });

  group('Group Notification Triggers', () {
    test('updateGroup triggers groupUpdated notifications for all members', () async {
      final group = FakeGroup();
      final member1 = FakeGroupMember(102);
      final member2 = FakeGroupMember(103);

      when(() => mockGroupPushRepo.updateGroup(
        group: any(named: 'group'),
        name: any(named: 'name'),
        description: any(named: 'description'),
        accessToken: any(named: 'accessToken'),
      )).thenAnswer((_) async {});

      when(() => mockGroupSyncCont.markPendingChanges()).thenReturn(null);
      when(() => mockGroupDao.getMembersByGroupId(any())).thenAnswer((_) async => [member1, member2]);

      when(() => mockNotifRepo.createNotification(
        type: any(named: 'type'),
        targetUserId: any(named: 'targetUserId'),
        actorUserId: any(named: 'actorUserId'),
        title: any(named: 'title'),
        message: any(named: 'message'),
      )).thenAnswer((_) async => 1);

      await groupPushController.updateGroup(group: group, name: 'New Name');

      verify(() => mockNotifRepo.createNotification(
        type: InAppNotificationType.groupUpdated,
        targetUserId: member1.memberUserId,
        title: any(named: 'title'),
        message: any(named: 'message'),
      )).called(1);

      verify(() => mockNotifRepo.createNotification(
        type: InAppNotificationType.groupUpdated,
        targetUserId: member2.memberUserId,
        title: any(named: 'title'),
        message: any(named: 'message'),
      )).called(1);
    });

    test('addMember triggers groupMemberJoined notification for owner', () async {
      final group = FakeGroup();
      final user = FakeLocalUser();

      when(() => mockGroupPushRepo.addMember(
        group: any(named: 'group'),
        user: any(named: 'user'),
        role: any(named: 'role'),
      )).thenAnswer((_) async => FakeGroupMember(102));

      when(() => mockGroupSyncCont.markPendingChanges()).thenReturn(null);

      when(() => mockNotifRepo.createNotification(
        type: any(named: 'type'),
        targetUserId: any(named: 'targetUserId'),
        actorUserId: any(named: 'actorUserId'),
        title: any(named: 'title'),
        message: any(named: 'message'),
      )).thenAnswer((_) async => 1);

      await groupPushController.addMember(group: group, user: user, role: 'member');

      verify(() => mockNotifRepo.createNotification(
        type: InAppNotificationType.groupMemberJoined,
        targetUserId: group.ownerUserId,
        actorUserId: user.id,
        title: any(named: 'title'),
        message: any(named: 'message'),
      )).called(1);
    });
    
    test('deleteGroup triggers groupDeleted notifications for all members except owner', () async {
      final group = FakeGroup();
      final ownerMember = FakeGroupMember(group.ownerUserId);
      final member1 = FakeGroupMember(102);

      when(() => mockGroupPushRepo.deleteGroup(
        group: any(named: 'group'),
        accessToken: any(named: 'accessToken'),
      )).thenAnswer((_) async {});

      when(() => mockGroupDao.getMembersByGroupId(any())).thenAnswer((_) async => [ownerMember, member1]);

      when(() => mockNotifRepo.createNotification(
        type: any(named: 'type'),
        targetUserId: any(named: 'targetUserId'),
        actorUserId: any(named: 'actorUserId'),
        title: any(named: 'title'),
        message: any(named: 'message'),
      )).thenAnswer((_) async => 1);

      await groupPushController.deleteGroup(group: group);

      verify(() => mockNotifRepo.createNotification(
        type: InAppNotificationType.groupDeleted,
        targetUserId: member1.memberUserId,
        title: any(named: 'title'),
        message: any(named: 'message'),
      )).called(1);

      // Should NOT notify the owner
      verifyNever(() => mockNotifRepo.createNotification(
        type: InAppNotificationType.groupDeleted,
        targetUserId: group.ownerUserId,
        title: any(named: 'title'),
        message: any(named: 'message'),
      ));
    });

    test('removeMember triggers groupMemberLeft notification for owner', () async {
      final group = FakeGroup();
      final member = FakeGroupMember(102);
      final user = FakeLocalUser();

      when(() => mockGroupPushRepo.removeMember(
        member: any(named: 'member'),
        accessToken: any(named: 'accessToken'),
      )).thenAnswer((_) async {});

      when(() => mockGroupDao.findGroupById(any())).thenAnswer((_) async => group);
      when(() => mockGroupDao.findUserById(any())).thenAnswer((_) async => user);

      when(() => mockNotifRepo.createNotification(
        type: any(named: 'type'),
        targetUserId: any(named: 'targetUserId'),
        actorUserId: any(named: 'actorUserId'),
        title: any(named: 'title'),
        message: any(named: 'message'),
      )).thenAnswer((_) async => 1);

      await groupPushController.removeMember(member: member);

      verify(() => mockNotifRepo.createNotification(
        type: InAppNotificationType.groupMemberLeft,
        targetUserId: group.ownerUserId,
        actorUserId: user.id,
        title: any(named: 'title'),
        message: any(named: 'message'),
      )).called(1);
    });
  });
}
