import 'package:book_sharing_app/models/book_genre.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('BookGenre', () {
    test('primaryHex returns correct colors', () {
      expect(BookGenre.fantasy.primaryHex, '#7B5EA7');
      expect(BookGenre.scienceFiction.primaryHex, '#3D5A99');
      expect(BookGenre.horror.primaryHex, '#8B2020');
      expect(BookGenre.romance.primaryHex, '#C47A8A');
      expect(BookGenre.children.primaryHex, '#E07B39');
    });

    test('label returns correct labels', () {
      expect(BookGenre.fantasy.label, 'Fantasía');
      expect(BookGenre.scienceFiction.label, 'Ciencia Ficción');
      expect(BookGenre.horror.label, 'Terror');
      expect(BookGenre.romance.label, 'Romance');
      expect(BookGenre.children.label, 'Infantil');
    });

    test('fromString returns correct genre from name', () {
      expect(BookGenre.fromString('fantasy'), BookGenre.fantasy);
      expect(BookGenre.fromString('scienceFiction'), BookGenre.scienceFiction);
      expect(BookGenre.fromString('horror'), BookGenre.horror);
    });

    test('fromString returns correct genre from label', () {
      expect(BookGenre.fromString('Fantasía'), BookGenre.fantasy);
      expect(BookGenre.fromString('Ciencia Ficción'), BookGenre.scienceFiction);
      expect(BookGenre.fromString('Terror'), BookGenre.horror);
    });

    test('fromString returns classic as fallback for invalid string', () {
      expect(BookGenre.fromString('invalid'), BookGenre.classic);
      expect(BookGenre.fromString(''), null);
      expect(BookGenre.fromString(null), null);
    });

    test('fromCsv parses CSV correctly', () {
      expect(BookGenre.fromCsv('fantasy,horror'), [BookGenre.fantasy, BookGenre.horror]);
      expect(BookGenre.fromCsv('Fantasía,Terror'), [BookGenre.fantasy, BookGenre.horror]);
      expect(BookGenre.fromCsv(''), []);
      expect(BookGenre.fromCsv(null), []);
    });

    test('toCsv encodes list correctly', () {
      expect(BookGenre.toCsv([BookGenre.fantasy, BookGenre.horror]), 'fantasy,horror');
      expect(BookGenre.toCsv([]), '');
    });

    test('allowedFromJson parses JSON array', () {
      expect(BookGenre.allowedFromJson('["fantasy","horror"]'), {BookGenre.fantasy, BookGenre.horror});
      expect(BookGenre.allowedFromJson('[]'), const <BookGenre>{});
      expect(BookGenre.allowedFromJson(null), const <BookGenre>{});
      expect(BookGenre.allowedFromJson('invalid'), const <BookGenre>{});
    });

    test('encodeToJson encodes list to JSON', () {
      expect(BookGenre.encodeToJson([BookGenre.fantasy, BookGenre.horror]), '["fantasy","horror"]');
      expect(BookGenre.encodeToJson([]), '[]');
    });

    test('fromExternalCategory maps external categories', () {
      expect(BookGenre.fromExternalCategory('fantasy'), BookGenre.fantasy);
      expect(BookGenre.fromExternalCategory('science fiction'), BookGenre.scienceFiction);
      expect(BookGenre.fromExternalCategory('thriller'), BookGenre.thrillerSuspense);
      expect(BookGenre.fromExternalCategory('unknown'), isNull);
    });

    test('fromExternalCategories maps list of categories', () {
      expect(BookGenre.fromExternalCategories(['fantasy', 'horror']), [BookGenre.fantasy, BookGenre.horror]);
      expect(BookGenre.fromExternalCategories([]), []);
      expect(BookGenre.fromExternalCategories(null), []);
    });
  });
}
