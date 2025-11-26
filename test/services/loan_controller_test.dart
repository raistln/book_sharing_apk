import 'package:book_sharing_app/data/local/book_dao.dart';
import 'package:book_sharing_app/data/local/database.dart';
import 'package:book_sharing_app/data/local/group_dao.dart';
import 'package:book_sharing_app/data/local/notification_dao.dart';
import 'package:book_sharing_app/data/local/user_dao.dart';
import 'package:book_sharing_app/data/repositories/loan_repository.dart';
import 'package:book_sharing_app/data/repositories/notification_repository.dart';
import 'package:book_sharing_app/data/repositories/supabase_group_repository.dart';
import 'package:book_sharing_app/data/repositories/user_repository.dart';
import 'package:book_sharing_app/services/group_sync_controller.dart';
import 'package:book_sharing_app/services/loan_controller.dart';
import 'package:book_sharing_app/services/notification_service.dart';
import 'package:book_sharing_app/services/supabase_config_service.dart';
import 'package:book_sharing_app/services/supabase_group_service.dart';
import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;
  late GroupDao groupDao;
  late UserDao userDao;
  late BookDao bookDao;
  late LoanRepository loanRepository;
  late NotificationDao notificationDao;
  late NotificationRepository notificationRepository;
  late GroupSyncController syncController;
  late _FakeNotificationClient notificationClient;
  late LoanController controller;
  late LocalUser owner;
  late LocalUser borrower;
  late int groupId;
  late int sharedBookId;

  Future<void> seedCoreData() async {
    final ownerId = await userDao.insertUser(
      LocalUsersCompanion.insert(
        uuid: 'owner-uuid',
        username: 'Owner',
        remoteId: const Value('owner-remote'),
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

    final bookId = await bookDao.insertBook(
      BooksCompanion.insert(
        uuid: 'book-uuid',
        ownerUserId: Value(ownerId),
        title: 'Book',
        status: const Value('available'),
        isDirty: const Value(false),
        isDeleted: const Value(false),
      ),
    );

    groupId = await groupDao.insertGroup(
      GroupsCompanion.insert(
        uuid: 'group-uuid',
        name: 'Grupo',
        ownerUserId: Value(ownerId),
        ownerRemoteId: const Value('owner-remote'),
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
        ownerRemoteId: const Value('owner-remote'),
        isAvailable: const Value(true),
        isDirty: const Value(false),
        isDeleted: const Value(false),
      ),
    );

  }

  Future<Loan> createPendingLoan({required Duration dueOffset}) async {
    final sharedBook = (await groupDao.findSharedBookById(sharedBookId))!;
    final dueDate = DateTime.now().add(dueOffset);
    return loanRepository.requestLoan(
      sharedBook: sharedBook,
      borrower: borrower,
      dueDate: dueDate,
    );
  }

  setUp(() async {
    db = AppDatabase.test(NativeDatabase.memory());
    groupDao = GroupDao(db);
    userDao = UserDao(db);
    bookDao = BookDao(db);
    notificationDao = NotificationDao(db);
    loanRepository = LoanRepository(
      groupDao: groupDao,
      bookDao: bookDao,
      userDao: userDao,
    );
    notificationRepository = NotificationRepository(notificationDao: notificationDao);

    final syncRepository = SupabaseGroupSyncRepository(
      groupDao: groupDao,
      userDao: userDao,
      bookDao: bookDao,
      groupService: _FakeSupabaseGroupService(),
    );
    final userRepository = UserRepository(userDao);

    syncController = GroupSyncController(
      groupRepository: syncRepository,
      userRepository: userRepository,
      configService: _FakeSupabaseConfigService(
        const SupabaseConfig(
          url: 'https://example.supabase.co',
          anonKey: 'anon-key',
        ),
      ),
    );

    notificationClient = _FakeNotificationClient();
    controller = LoanController(
      loanRepository: loanRepository,
      groupSyncController: syncController,
      notificationClient: notificationClient,
      notificationRepository: notificationRepository,
    );

    await seedCoreData();
  });

  tearDown(() async {
    await db.close();
  });

  test('acceptLoan schedules future due notifications', () async {
    final loan = await createPendingLoan(dueOffset: const Duration(days: 2));

    final accepted = await controller.acceptLoan(loan: loan, owner: owner);

    final dueSoonId = NotificationIds.loanDueSoon(accepted.uuid);
    final expiredId = NotificationIds.loanExpired(accepted.uuid);

    expect(notificationClient.cancelledIds.toSet(), {dueSoonId, expiredId});
    expect(notificationClient.immediate, isEmpty);
    expect(notificationClient.scheduled, hasLength(2));

    final scheduledById = {
      for (final entry in notificationClient.scheduled) entry.id: entry,
    };

    final dueSoon = scheduledById[dueSoonId]!;
    final expired = scheduledById[expiredId]!;

    expect(dueSoon.type, NotificationType.loanDueSoon);
    expect(expired.type, NotificationType.loanExpired);

    final expectedDueSoon = accepted.dueDate!.subtract(const Duration(hours: 24));
    expect(
      dueSoon.when.difference(expectedDueSoon).abs(),
      lessThan(const Duration(seconds: 5)),
    );
    expect(
      expired.when.difference(accepted.dueDate!).abs(),
      lessThan(const Duration(seconds: 5)),
    );

    expect(dueSoon.payload, {
      NotificationPayloadKeys.loanId: accepted.uuid,
      NotificationPayloadKeys.sharedBookId: sharedBookId.toString(),
      NotificationPayloadKeys.groupId: groupId.toString(),
    });
    expect(expired.payload, {
      NotificationPayloadKeys.loanId: accepted.uuid,
      NotificationPayloadKeys.sharedBookId: sharedBookId.toString(),
      NotificationPayloadKeys.groupId: groupId.toString(),
    });
    expect(syncController.state.hasPendingChanges, isTrue);
    expect(controller.state.lastSuccess, 'Préstamo aceptado.');
  });

  test('acceptLoan shows immediate expiration when due date passed', () async {
    final loan = await createPendingLoan(dueOffset: -const Duration(hours: 3));

    final accepted = await controller.acceptLoan(loan: loan, owner: owner);

    expect(notificationClient.scheduled, isEmpty);
    expect(notificationClient.immediate, hasLength(1));

    final expired = notificationClient.immediate.single;
    expect(expired.id, NotificationIds.loanExpired(accepted.uuid));
    expect(expired.type, NotificationType.loanExpired);
    expect(expired.payload, {
      NotificationPayloadKeys.loanId: accepted.uuid,
      NotificationPayloadKeys.sharedBookId: sharedBookId.toString(),
      NotificationPayloadKeys.groupId: groupId.toString(),
    });
  });

  test('cancelLoan clears previously scheduled notifications', () async {
    final loan = await createPendingLoan(dueOffset: const Duration(days: 3));

    final dueSoonId = NotificationIds.loanDueSoon(loan.uuid);
    final expiredId = NotificationIds.loanExpired(loan.uuid);

    await notificationClient.schedule(
      id: dueSoonId,
      type: NotificationType.loanDueSoon,
      title: 'Préstamo próximo a vencer',
      body: 'Recordatorio de préstamo',
      scheduledAt: DateTime.now().add(const Duration(hours: 1)),
      payload: const {},
    );
    await notificationClient.schedule(
      id: expiredId,
      type: NotificationType.loanExpired,
      title: 'Préstamo vencido',
      body: 'El préstamo ha vencido',
      scheduledAt: DateTime.now().add(const Duration(hours: 2)),
      payload: const {},
    );

    final result = await controller.cancelLoan(loan: loan, borrower: borrower);

    expect(result.status, 'cancelled');
    expect(notificationClient.cancelledIds.toSet(), {dueSoonId, expiredId});
    expect(controller.state.lastSuccess, 'Solicitud cancelada.');
  });

  test('rejectLoan cancels scheduled notifications', () async {
    final loan = await createPendingLoan(dueOffset: const Duration(days: 2));

    final dueSoonId = NotificationIds.loanDueSoon(loan.uuid);
    final expiredId = NotificationIds.loanExpired(loan.uuid);

    await notificationClient.schedule(
      id: dueSoonId,
      type: NotificationType.loanDueSoon,
      title: 'Préstamo próximo a vencer',
      body: 'Recordatorio de préstamo',
      scheduledAt: DateTime.now().add(const Duration(hours: 1)),
      payload: const {},
    );
    await notificationClient.schedule(
      id: expiredId,
      type: NotificationType.loanExpired,
      title: 'Préstamo vencido',
      body: 'El préstamo ha vencido',
      scheduledAt: DateTime.now().add(const Duration(hours: 2)),
      payload: const {},
    );

    final result = await controller.rejectLoan(loan: loan, owner: owner);

    expect(result.status, 'rejected');
    expect(notificationClient.cancelledIds.toSet(), {dueSoonId, expiredId});
    expect(controller.state.lastSuccess, 'Solicitud rechazada.');
  });

  test('markReturned cancels scheduled notifications after double confirmation', () async {
    final loan = await createPendingLoan(dueOffset: const Duration(days: 4));
    final accepted = await controller.acceptLoan(loan: loan, owner: owner);

    final dueSoonId = NotificationIds.loanDueSoon(accepted.uuid);
    final expiredId = NotificationIds.loanExpired(accepted.uuid);

    // Borrower confirms first.
    final borrowerConfirmation = await controller.markReturned(loan: accepted, actor: borrower);

    // Clear cancellations originating from previous steps.
    notificationClient.cancelledIds.clear();

    final result = await controller.markReturned(loan: borrowerConfirmation, actor: owner);

    expect(result.status, 'returned');
    expect(notificationClient.cancelledIds.toSet(), {dueSoonId, expiredId});
    expect(controller.state.lastSuccess, 'Préstamo marcado como devuelto.');
  });

  test('expireLoan cancels scheduled notifications', () async {
    final loan = await createPendingLoan(dueOffset: const Duration(days: 5));
    final accepted = await controller.acceptLoan(loan: loan, owner: owner);

    final dueSoonId = NotificationIds.loanDueSoon(accepted.uuid);
    final expiredId = NotificationIds.loanExpired(accepted.uuid);

    // Clear cancellations originating from the acceptance flow.
    notificationClient.cancelledIds.clear();

    final result = await controller.expireLoan(loan: accepted);

    expect(result.status, 'expired');
    expect(notificationClient.cancelledIds.toSet(), {dueSoonId, expiredId});
    expect(controller.state.lastSuccess, 'Préstamo marcado como expirado.');
  });

}

class _FakeNotificationClient implements NotificationClient {
  final List<_ScheduledNotification> scheduled = [];
  final List<_ImmediateNotification> immediate = [];
  final List<int> cancelledIds = [];

  @override
  Future<void> cancel(int id) async {
    cancelledIds.add(id);
  }

  @override
  Future<void> cancelMany(Iterable<int> ids) async {
    cancelledIds.addAll(ids);
  }

  @override
  Future<void> schedule({
    required int id,
    required NotificationType type,
    required String title,
    required String body,
    required DateTime scheduledAt,
    Map<String, String>? payload,
  }) async {
    scheduled.add(_ScheduledNotification(
      id: id,
      type: type,
      when: scheduledAt,
      payload: payload ?? const {},
    ));
  }

  @override
  Future<void> showImmediate({
    required int id,
    required NotificationType type,
    required String title,
    required String body,
    Map<String, String>? payload,
    List<AndroidNotificationAction>? androidActions,
  }) async {
    immediate.add(_ImmediateNotification(
      id: id,
      type: type,
      payload: payload ?? const {},
    ));
  }

  void reset() {
    scheduled.clear();
    immediate.clear();
    cancelledIds.clear();
  }
}

class _ScheduledNotification {
  _ScheduledNotification({
    required this.id,
    required this.type,
    required this.when,
    required this.payload,
  });

  final int id;
  final NotificationType type;
  final DateTime when;
  final Map<String, String> payload;
}

class _ImmediateNotification {
  _ImmediateNotification({
    required this.id,
    required this.type,
    required this.payload,
  });

  final int id;
  final NotificationType type;
  final Map<String, String> payload;
}

class _FakeSupabaseConfigService extends SupabaseConfigService {
  _FakeSupabaseConfigService(this._config);

  final SupabaseConfig _config;

  @override
  Future<SupabaseConfig> loadConfig() async => _config;
}

class _FakeSupabaseGroupService extends SupabaseGroupService {
  _FakeSupabaseGroupService()
      : super(
          configLoader: () async => const SupabaseConfig(
            url: 'https://example.supabase.co',
            anonKey: 'anon-key',
          ),
        );

  @override
  Future<List<SupabaseGroupRecord>> fetchGroups({String? accessToken}) async => [];
}
