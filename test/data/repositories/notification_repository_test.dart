import 'package:book_sharing_app/data/local/notification_dao.dart';
import 'package:book_sharing_app/data/local/database.dart';
import 'package:book_sharing_app/data/repositories/notification_repository.dart';
import 'package:book_sharing_app/data/models/in_app_notification_type.dart';
import 'package:book_sharing_app/models/global_sync_state.dart';
import 'package:book_sharing_app/services/unified_sync_coordinator.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:uuid/uuid.dart';

class _MockNotificationDao extends Mock implements NotificationDao {}

class _MockUnifiedSyncCoordinator extends Mock implements UnifiedSyncCoordinator {}

class _MockUuid extends Mock implements Uuid {}

void main() {
  late _MockNotificationDao notificationDao;
  late _MockUnifiedSyncCoordinator syncCoordinator;
  late _MockUuid uuid;
  late NotificationRepository repository;

  setUpAll(() {
    registerFallbackValue(const InAppNotificationsCompanion());
    registerFallbackValue(SyncEntity.notifications);
  });

  setUp(() {
    notificationDao = _MockNotificationDao();
    syncCoordinator = _MockUnifiedSyncCoordinator();
    uuid = _MockUuid();
    repository = NotificationRepository(
      notificationDao: notificationDao,
      syncCoordinator: syncCoordinator,
      uuid: uuid,
    );
  });

  group('NotificationRepository', () {
    test('createNotification creates a notification and schedules sync', () async {
      when(() => uuid.v4()).thenReturn('test-uuid');
      when(() => notificationDao.insert(any())).thenAnswer((_) async => 1);

      final result = await repository.createNotification(
        type: InAppNotificationType.loanRequested,
        targetUserId: 1,
        actorUserId: 2,
        title: 'Test Notification',
        message: 'Test Message',
      );

      expect(result, 1);
      verify(() => notificationDao.insert(any())).called(1);
      verify(() => syncCoordinator.markPendingChanges(SyncEntity.notifications)).called(1);
    });

    test('countUnread delegates to notificationDao', () async {
      when(() => notificationDao.countUnread(1)).thenAnswer((_) async => 5);

      final result = await repository.countUnread(1);

      expect(result, 5);
      verify(() => notificationDao.countUnread(1)).called(1);
    });
  });
}
