import 'package:book_sharing_app/services/notification_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('NotificationService', () {
    test('instance is not null', () {
      final service = NotificationService.instance;
      expect(service, isNotNull);
    });
  });
}
