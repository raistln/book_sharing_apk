import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('BookProviders', () {
    test('can create container', () {
      final container = ProviderContainer();
      expect(container, isNotNull);
      container.dispose();
    });
  });
}
