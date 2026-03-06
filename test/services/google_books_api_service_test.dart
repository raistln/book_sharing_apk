import 'package:book_sharing_app/services/google_books_api_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockFlutterSecureStorage extends Mock implements FlutterSecureStorage {}

void main() {
  late _MockFlutterSecureStorage storage;
  late GoogleBooksApiService service;

  setUp(() {
    storage = _MockFlutterSecureStorage();
    service = GoogleBooksApiService(storage: storage);
  });

  group('GoogleBooksApiService', () {
    test('readApiKey returns trimmed key from storage', () async {
      when(() => storage.read(key: 'google_books_api_key'))
          .thenAnswer((_) async => '  test-key  ');

      final result = await service.readApiKey();

      expect(result, 'test-key');
      verify(() => storage.read(key: 'google_books_api_key')).called(1);
    });

    test('readApiKey returns null when no key', () async {
      when(() => storage.read(key: 'google_books_api_key'))
          .thenAnswer((_) async => null);

      final result = await service.readApiKey();

      expect(result, null);
      verify(() => storage.read(key: 'google_books_api_key')).called(1);
    });

    test('readApiKey returns null when empty key', () async {
      when(() => storage.read(key: 'google_books_api_key'))
          .thenAnswer((_) async => '');

      final result = await service.readApiKey();

      expect(result, null);
      verify(() => storage.read(key: 'google_books_api_key')).called(1);
    });

    test('saveApiKey writes trimmed key to storage', () async {
      when(() => storage.write(key: 'google_books_api_key', value: 'test-key'))
          .thenAnswer((_) async {});

      await service.saveApiKey('  test-key  ');

      verify(() => storage.write(key: 'google_books_api_key', value: 'test-key')).called(1);
    });

    test('saveApiKey throws on empty key', () async {
      expect(() => service.saveApiKey(''), throwsA(isA<ArgumentError>()));
    });
  });
}
