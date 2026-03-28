import 'package:book_sharing_app/data/local/database.dart';
import 'package:book_sharing_app/data/local/group_dao.dart';
import 'package:book_sharing_app/data/local/notification_dao.dart';
import 'package:book_sharing_app/data/local/user_dao.dart';
import 'package:book_sharing_app/data/repositories/supabase_notification_sync_repository.dart';
import 'package:book_sharing_app/services/supabase_notification_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockNotificationDao extends Mock implements NotificationDao {}

class _MockUserDao extends Mock implements UserDao {}

class _MockGroupDao extends Mock implements GroupDao {}

class _MockSupabaseNotificationService extends Mock implements SupabaseNotificationService {}

void main() {
  late _MockNotificationDao notificationDao;
  late _MockUserDao userDao;
  late _MockGroupDao groupDao;
  late _MockSupabaseNotificationService notificationService;
  late SupabaseNotificationSyncRepository repository;

  setUp(() {
    notificationDao = _MockNotificationDao();
    userDao = _MockUserDao();
    groupDao = _MockGroupDao();
    notificationService = _MockSupabaseNotificationService();
    repository = SupabaseNotificationSyncRepository(
      notificationDao: notificationDao,
      userDao: userDao,
      groupDao: groupDao,
      notificationService: notificationService,
    );
  });

  group('SupabaseNotificationSyncRepository', () {
    test('syncFromRemote returns early when user has no remoteId', () async {
      final user = LocalUser(
        id: 1,
        uuid: 'user-1',
        username: 'testuser',
        remoteId: null, // No remoteId
        isDirty: false,
        isDeleted: false,
        syncedAt: null,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await repository.syncFromRemote(target: user);

      verifyNever(() => notificationService.fetchNotifications(targetUserId: any(named: 'targetUserId'), accessToken: any(named: 'accessToken')));
    });
  });
}
