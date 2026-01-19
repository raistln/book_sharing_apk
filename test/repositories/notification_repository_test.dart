import 'package:book_sharing_app/data/local/database.dart';
import 'package:book_sharing_app/data/local/user_dao.dart';
import 'package:book_sharing_app/data/local/notification_dao.dart';
import 'package:book_sharing_app/data/repositories/notification_repository.dart';
import 'package:book_sharing_app/data/models/in_app_notification_status.dart';
import 'package:book_sharing_app/data/models/in_app_notification_type.dart';
import 'package:flutter_test/flutter_test.dart';
import '../helpers/test_helper.dart';

void main() {
  group('NotificationRepository', () {
    late AppDatabase db;
    late NotificationDao notificationDao;
    late NotificationRepository repository;
    late UserDao userDao;
    late LocalUser testUser;

    setUp(() async {
      db = createTestDatabase();
      notificationDao = NotificationDao(db);
      userDao = UserDao(db);

      // Create a test user to satisfy foreign key constraints
      testUser = await insertTestUser(userDao, username: 'testuser');

      // Pass null for sync controller since we're testing repository logic only
      repository = NotificationRepository(
        notificationDao: notificationDao,
        notificationSyncController: null,
      );
    });

    tearDown(() async {
      await db.close();
    });

    test('createNotification adds a notification with correct status',
        () async {
      final id = await repository.createNotification(
        type: InAppNotificationType.loanRequested,
        targetUserId: testUser.id,
        title: 'Test Notification',
        message: 'Test Body',
      );

      expect(id, isPositive);

      final notif = await notificationDao.findById(id);
      expect(notif?.title, 'Test Notification');
      expect(notif?.status, InAppNotificationStatus.unread);
    });

    test('markAs updates the status using uuid', () async {
      final id = await repository.createNotification(
        type: InAppNotificationType.loanRequested,
        targetUserId: testUser.id,
        title: 'Test',
        message: 'Body',
      );

      final notification = (await notificationDao.findById(id))!;

      await repository.markAs(
        uuid: notification.uuid,
        status: InAppNotificationStatus.read,
      );

      final updated = await notificationDao.findById(id);
      expect(updated?.status, InAppNotificationStatus.read);
    });

    test('countUnread returns correctly', () async {
      await repository.createNotification(
        type: InAppNotificationType.loanRequested,
        targetUserId: testUser.id,
        status: InAppNotificationStatus.unread,
      );
      await repository.createNotification(
        type: InAppNotificationType.loanRequested,
        targetUserId: testUser.id,
        status: InAppNotificationStatus.unread,
      );

      final count = await repository.countUnread(testUser.id);
      expect(count, 2);
    });

    test('clearAllForUser soft deletes all notifications', () async {
      await repository.createNotification(
        type: InAppNotificationType.loanRequested,
        targetUserId: testUser.id,
      );

      await repository.clearAllForUser(testUser.id);

      final unreadCount = await repository.countUnread(testUser.id);
      expect(unreadCount, 0);

      final notifications =
          await notificationDao.watchForUser(testUser.id).first;
      expect(notifications, isEmpty);
    });
  });
}
