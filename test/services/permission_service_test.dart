import 'package:book_sharing_app/services/permission_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PermissionService', () {
    test('can be instantiated', () {
      final service = PermissionService();
      expect(service, isNotNull);
    });
  });
}
