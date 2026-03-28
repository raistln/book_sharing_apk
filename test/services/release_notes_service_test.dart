import 'package:book_sharing_app/services/release_notes_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ReleaseNotesService', () {
    test('can be instantiated', () {
      final service = ReleaseNotesService();
      expect(service, isNotNull);
    });
  });
}
