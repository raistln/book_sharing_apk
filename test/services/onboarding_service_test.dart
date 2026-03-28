import 'package:book_sharing_app/services/onboarding_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('OnboardingService', () {
    test('can be instantiated', () {
      final service = OnboardingService();
      expect(service, isNotNull);
    });
  });
}
