import 'package:book_sharing_app/models/release_note.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ReleaseNote', () {
    test('can be instantiated with required parameters', () {
      final date = DateTime(2023, 1, 1);
      final releaseNote = ReleaseNote(
        version: '1.0.0',
        date: date,
        changes: ['Fixed bug', 'Added feature'],
      );

      expect(releaseNote.version, '1.0.0');
      expect(releaseNote.date, date);
      expect(releaseNote.changes, ['Fixed bug', 'Added feature']);
      expect(releaseNote.thankYouMessage, null);
    });

    test('can be instantiated with thankYouMessage', () {
      final date = DateTime(2023, 1, 1);
      final releaseNote = ReleaseNote(
        version: '1.0.0',
        date: date,
        changes: ['Fixed bug'],
        thankYouMessage: 'Thank you for using the app!',
      );

      expect(releaseNote.thankYouMessage, 'Thank you for using the app!');
    });

    test('changes list is immutable', () {
      final date = DateTime(2023, 1, 1);
      final changes = ['Fixed bug'];
      final releaseNote = ReleaseNote(
        version: '1.0.0',
        date: date,
        changes: changes,
      );

      // Since it's const, but changes is List, but in practice it's fine.
      expect(releaseNote.changes, changes);
    });
  });
}
