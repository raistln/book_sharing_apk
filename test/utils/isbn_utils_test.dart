import 'package:book_sharing_app/utils/isbn_utils.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('IsbnUtils', () {
    test('normalize removes non ISBN characters and uppercases', () {
      expect(IsbnUtils.normalize('978-0-123-45678-9'), '9780123456789');
      expect(IsbnUtils.normalize('0-123-45678-X'), '012345678X');
      expect(IsbnUtils.normalize('  9780123456789  '), '9780123456789');
      expect(IsbnUtils.normalize(null), null);
      expect(IsbnUtils.normalize(''), null);
      expect(IsbnUtils.normalize('abc'), null);
    });

    test('expandCandidates returns normalized and converted ISBNs', () {
      expect(IsbnUtils.expandCandidates('978-0-123-45678-9'), ['9780123456789', '0123456789']);
      expect(IsbnUtils.expandCandidates('012345678X'), ['012345678X']);
      expect(IsbnUtils.expandCandidates(null), []);
      expect(IsbnUtils.expandCandidates(''), []);
    });

    test('isIsbn13 validates ISBN-13', () {
      expect(IsbnUtils.isIsbn13('9780123456789'), true);
      expect(IsbnUtils.isIsbn13('9790123456789'), true);
      expect(IsbnUtils.isIsbn13('978012345678'), false);
      expect(IsbnUtils.isIsbn13('978012345678X'), false);
      expect(IsbnUtils.isIsbn13(null), false);
      expect(IsbnUtils.isIsbn13(''), false);
    });

    test('isIsbn10 validates ISBN-10', () {
      expect(IsbnUtils.isIsbn10('0123456789'), true);
      expect(IsbnUtils.isIsbn10('012345678X'), true);
      expect(IsbnUtils.isIsbn10('012345678'), false);
      expect(IsbnUtils.isIsbn10('012345678Y'), false);
      expect(IsbnUtils.isIsbn10(null), false);
      expect(IsbnUtils.isIsbn10(''), false);
    });

    test('toIsbn10 converts ISBN-13 starting with 978 to ISBN-10', () {
      expect(IsbnUtils.toIsbn10('9780123456789'), '0123456789');
      expect(IsbnUtils.toIsbn10('978-0-123-45678-9'), '0123456789');
      expect(IsbnUtils.toIsbn10('9790123456789'), null);
      expect(IsbnUtils.toIsbn10('978012345678'), null);
      expect(IsbnUtils.toIsbn10(null), null);
    });
  });
}
