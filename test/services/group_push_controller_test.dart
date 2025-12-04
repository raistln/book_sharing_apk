import 'package:book_sharing_app/data/local/database.dart';
import 'package:book_sharing_app/data/local/group_dao.dart';
import 'package:book_sharing_app/data/repositories/group_push_repository.dart';
import 'package:book_sharing_app/data/repositories/book_repository.dart';
import 'package:book_sharing_app/models/global_sync_state.dart';
import 'package:book_sharing_app/services/group_push_controller.dart';
import 'package:book_sharing_app/services/group_sync_controller.dart';
import 'package:book_sharing_app/services/notification_service.dart';
import 'package:book_sharing_app/services/unified_sync_coordinator.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mocktail/mocktail.dart';

// Mock classes
class MockGroupPushRepository extends Mock implements GroupPushRepository {}
class MockGroupSyncController extends Mock implements GroupSyncController {}
class MockNotificationClient extends Mock implements NotificationClient {}
class MockBookRepository extends Mock implements BookRepository {}
class MockUnifiedSyncCoordinator extends Mock implements UnifiedSyncCoordinator {}

class FakeGroup extends Fake implements Group {}

void main() {
  group('GroupPushController', () {
    late AppDatabase db;
    late GroupDao groupDao;
    late GroupPushController groupPushController;
    late MockGroupPushRepository mockGroupPushRepository;
    late MockGroupSyncController mockGroupSyncController;
    late MockNotificationClient mockNotificationClient;
    late MockBookRepository mockBookRepository;
    late MockUnifiedSyncCoordinator mockSyncCoordinator;

    setUpAll(() {
      registerFallbackValue(ImageSource.gallery);
      registerFallbackValue(NotificationType.loanDueSoon);
      registerFallbackValue(FakeGroup());
      registerFallbackValue(SyncEvent.groupInvitationAccepted);
      registerFallbackValue(SyncEntity.groups);
      registerFallbackValue(SyncPriority.medium);
    });

    setUp(() async {
      db = AppDatabase.test(NativeDatabase.memory());
      groupDao = GroupDao(db);

      // Create mocks
      mockGroupPushRepository = MockGroupPushRepository();
      mockGroupSyncController = MockGroupSyncController();
      mockNotificationClient = MockNotificationClient();
      mockBookRepository = MockBookRepository();
      mockSyncCoordinator = MockUnifiedSyncCoordinator();

      // Stub sync methods
      when(() => mockGroupSyncController.markPendingChanges()).thenAnswer((_) async {});
      when(() => mockGroupSyncController.mounted).thenReturn(true);

      // Stub sync coordinator methods
      when(() => mockSyncCoordinator.syncOnCriticalEvent(any()))
          .thenAnswer((_) async {});
      when(() => mockSyncCoordinator.markPendingChanges(any(), priority: any(named: 'priority')))
          .thenReturn(null);

      // Stub notification methods
      when(() => mockNotificationClient.cancel(any(that: isA<String>()))).thenAnswer((_) async {});
      when(() => mockNotificationClient.showImmediate(
        id: any(named: 'id'),
        type: any(named: 'type'),
        title: any(named: 'title'),
        body: any(named: 'body'),
        payload: any(named: 'payload'),
        androidActions: any(named: 'androidActions'),
      )).thenAnswer((_) async {});

      // Create controller
      groupPushController = GroupPushController(
        groupPushRepository: mockGroupPushRepository,
        groupSyncController: mockGroupSyncController,
        notificationClient: mockNotificationClient,
        bookRepository: mockBookRepository,
        groupDao: groupDao,
        syncCoordinator: mockSyncCoordinator,
      );
    });

    tearDown(() async {
      await db.close();
    });

    test('dismissError clears error state', () {
      // Simulate error state
      groupPushController.state = groupPushController.state.copyWith(
        lastError: () => 'Test error',
      );

      groupPushController.dismissError();

      expect(groupPushController.state.lastError, isNull);
    });

    test('dismissSuccess clears success state', () {
      // Simulate success state
      groupPushController.state = groupPushController.state.copyWith(
        lastSuccess: () => 'Test success',
      );

      groupPushController.dismissSuccess();

      expect(groupPushController.state.lastSuccess, isNull);
    });
  });
}
