import 'package:book_sharing_app/services/inactivity_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('InactivityManager', () {
    test('can be instantiated', () {
      final manager = InactivityManager(onTimeout: () {});
      expect(manager, isNotNull);
    });
  });
}
