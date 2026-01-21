import 'dart:convert';
import 'dart:typed_data';

import 'package:book_sharing_app/data/local/database.dart';
import 'package:book_sharing_app/data/local/user_dao.dart';
import 'package:book_sharing_app/services/book_import_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import '../helpers/test_helper.dart';

void main() {
  group('BookImportService', () {
    late MockBookRepository mockBookRepository;
    late BookImportService service;
    late LocalUser testOwner;

    setUp(() async {
      mockBookRepository = MockBookRepository();
      service = BookImportService(mockBookRepository);

      // Create test owner
      final db = createTestDatabase();
      final userDao = UserDao(db);
      testOwner = await insertTestUser(userDao, username: 'testowner');
      await db.close();

      // Stub repository methods
      when(() => mockBookRepository.fetchActiveBooks(
          ownerUserId: any(named: 'ownerUserId'))).thenAnswer((_) async => []);
      when(() => mockBookRepository.addBook(
            title: any(named: 'title'),
            author: any(named: 'author'),
            isbn: any(named: 'isbn'),
            status: any(named: 'status'),
            description: any(named: 'description'),
            readingStatus: any(named: 'readingStatus'),
            barcode: any(named: 'barcode'),
            owner: any(named: 'owner'),
          )).thenAnswer((_) async => 1); // Return a valid book ID
    });

    group('importFromCsv', () {
      test('parses valid CSV correctly', () async {
        const csvData = '''Título,Autor,ISBN
El Quijote,Cervantes,978-1234567890
Cien años de soledad,García Márquez,978-0987654321''';

        final bytes = Uint8List.fromList(utf8.encode(csvData));
        final result = await service.importFromCsv(bytes, owner: testOwner);

        expect(result.successCount, 2);
        expect(result.failureCount, 0);
        expect(result.errors, isEmpty);

        verify(() => mockBookRepository.addBook(
              title: 'El Quijote',
              author: 'Cervantes',
              isbn: '978-1234567890',
              status: 'available',
              description: null,
              readingStatus: 'pending',
              barcode: null,
              owner: testOwner,
            )).called(1);
      });

      test('handles malformed CSV gracefully', () async {
        const csvData = '''Título
"Libro sin cerrar comillas
Libro normal''';

        final bytes = Uint8List.fromList(utf8.encode(csvData));
        final result = await service.importFromCsv(bytes, owner: testOwner);

        // Should handle parsing errors gracefully
        expect(result.errors, isNotEmpty);
      });

      test('rejects CSV without title column', () async {
        const csvData = '''Autor,ISBN
Cervantes,978-1234567890''';

        final bytes = Uint8List.fromList(utf8.encode(csvData));
        final result = await service.importFromCsv(bytes, owner: testOwner);

        expect(result.successCount, 0);
        expect(result.errors, contains(contains('columna "Título"')));
      });

      test('skips rows with empty title', () async {
        const csvData = '''Título,Autor
,Cervantes
El Quijote,Cervantes''';

        final bytes = Uint8List.fromList(utf8.encode(csvData));
        final result = await service.importFromCsv(bytes, owner: testOwner);

        expect(result.successCount, 1);
        expect(result.failureCount, 1);
        expect(result.errors.first, contains('título es obligatorio'));
      });

      test('normalizes status to available or archived', () async {
        const csvData = '''Título,Estado
Libro Disponible,available
Libro Archivado,archived
Libro Prestado,loaned''';

        final bytes = Uint8List.fromList(utf8.encode(csvData));
        final result = await service.importFromCsv(bytes, owner: testOwner);

        expect(result.successCount, 3);

        // Verify that 'loaned' was normalized to 'available'
        verify(() => mockBookRepository.addBook(
              title: 'Libro Prestado',
              author: null,
              isbn: null,
              status: 'available', // Should be normalized
              description: null,
              readingStatus: 'pending',
              barcode: null,
              owner: testOwner,
            )).called(1);
      });

      test('detects duplicate books by ISBN', () async {
        // Setup existing books
        when(() => mockBookRepository
                .fetchActiveBooks(ownerUserId: any(named: 'ownerUserId')))
            .thenAnswer((_) async => [
                  Book(
                    id: 1,
                    uuid: 'book-1',
                    ownerUserId: testOwner.id,
                    title: 'Existing Book',
                    description: null,
                    isbn: '978-1234567890',
                    readingStatus: 'pending',
                    status: 'available',
                    isRead: false,
                    isBorrowedExternal: false,
                    isDirty: false,
                    isDeleted: false,
                    createdAt: DateTime.now(),
                    updatedAt: DateTime.now(),
                    isPhysical: true,
                    pageCount: null,
                    publicationYear: null,
                  ),
                ]);

        const csvData = '''Título,ISBN
New Book,978-1234567890''';

        final bytes = Uint8List.fromList(utf8.encode(csvData));
        final result = await service.importFromCsv(bytes, owner: testOwner);

        expect(result.successCount, 0);
        expect(result.failureCount, 1);
        expect(result.errors.first, contains('duplicado'));
        expect(result.errors.first, contains('ISBN'));
      });
    });

    group('importFromJson', () {
      test('parses valid JSON correctly', () async {
        final jsonData = [
          {
            'title': 'El Quijote',
            'author': 'Cervantes',
            'isbn': '978-1234567890'
          },
          {'title': 'Cien años de soledad', 'author': 'García Márquez'},
        ];

        final bytes = Uint8List.fromList(utf8.encode(jsonEncode(jsonData)));
        final result = await service.importFromJson(bytes, owner: testOwner);

        expect(result.successCount, 2);
        expect(result.failureCount, 0);
        expect(result.errors, isEmpty);
      });

      test('validates required title field', () async {
        final jsonData = [
          {'author': 'Cervantes', 'isbn': '978-1234567890'},
          {'title': 'Valid Book'},
        ];

        final bytes = Uint8List.fromList(utf8.encode(jsonEncode(jsonData)));
        final result = await service.importFromJson(bytes, owner: testOwner);

        expect(result.successCount, 1);
        expect(result.failureCount, 1);
        expect(result.errors.first, contains('título es obligatorio'));
      });

      test('handles empty JSON array', () async {
        final jsonData = [];

        final bytes = Uint8List.fromList(utf8.encode(jsonEncode(jsonData)));
        final result = await service.importFromJson(bytes, owner: testOwner);

        expect(result.successCount, 0);
        expect(result.failureCount, 0);
        expect(result.errors, contains('El archivo JSON está vacío'));
      });

      test('handles invalid JSON format', () async {
        const invalidJson = '{not valid json}';

        final bytes = Uint8List.fromList(utf8.encode(invalidJson));
        final result = await service.importFromJson(bytes, owner: testOwner);

        expect(result.successCount, 0);
        expect(result.errors, isNotEmpty);
        expect(result.errors.first, contains('Error'));
      });

      test('detects duplicate books by title and author', () async {
        when(() => mockBookRepository
                .fetchActiveBooks(ownerUserId: any(named: 'ownerUserId')))
            .thenAnswer((_) async => [
                  Book(
                    id: 1,
                    uuid: 'book-1',
                    ownerUserId: testOwner.id,
                    title: 'El Quijote',
                    description: null,
                    author: 'Cervantes',
                    status: 'available',
                    readingStatus: 'pending',
                    isRead: false,
                    isBorrowedExternal: false,
                    isDirty: false,
                    isDeleted: false,
                    createdAt: DateTime.now(),
                    updatedAt: DateTime.now(),
                    isPhysical: true,
                    pageCount: null,
                    publicationYear: null,
                  ),
                ]);

        final jsonData = [
          {'title': 'El Quijote', 'author': 'Cervantes'},
        ];

        final bytes = Uint8List.fromList(utf8.encode(jsonEncode(jsonData)));
        final result = await service.importFromJson(bytes, owner: testOwner);

        expect(result.successCount, 0);
        expect(result.failureCount, 1);
        expect(result.errors.first, contains('duplicado'));
      });
    });
  });
}
