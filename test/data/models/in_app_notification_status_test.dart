import 'package:book_sharing_app/data/models/in_app_notification_status.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('InAppNotificationStatus', () {
    test('constants have correct values', () {
      expect(InAppNotificationStatus.unread, 'unread');
      expect(InAppNotificationStatus.read, 'read');
      expect(InAppNotificationStatus.dismissed, 'dismissed');
    });

    test('isValid returns true for valid values', () {
      expect(InAppNotificationStatus.isValid('unread'), isTrue);
      expect(InAppNotificationStatus.isValid('read'), isTrue);
      expect(InAppNotificationStatus.isValid('dismissed'), isTrue);
    });

    test('isValid returns false for invalid values', () {
      expect(InAppNotificationStatus.isValid('invalid'), isFalse);
      expect(InAppNotificationStatus.isValid(''), isFalse);
      expect(InAppNotificationStatus.isValid('READ'), isFalse);
    });
  });
}
