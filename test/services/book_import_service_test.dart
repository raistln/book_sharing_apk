import 'dart:convert';
import 'dart:typed_data';

import 'package:book_sharing_app/data/repositories/book_repository.dart';
import 'package:book_sharing_app/services/book_import_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockBookRepository extends Mock implements BookRepository {}

void main() {
  late MockBookRepository mockBookRepository;
  late BookImportService bookImportService;

  setUp(() {
    mockBookRepository = MockBookRepository();
    bookImportService = BookImportService(mockBookRepository);
    when(() => mockBookRepository.fetchActiveBooks())
        .thenAnswer((_) async => []);
  });

  group('importFromCsv', () {
    test('imports data exported by BookExportService', () async {
      const csvString = 'Título,Autor,ISBN,Estado,Actualizado,Notas,Total reseñas,Promedio reseñas\n'
          'Book 1,Author 1,1234567890,available,2024-01-01 10:00,Note 1,2,4.5\n'
          'Book 2,,,loaned,2024-02-15 18:30,,0,\n';
      final csvBytes = Uint8List.fromList(utf8.encode(csvString));

      final capturedCalls = <Map<String, dynamic>>[];

      when(() => mockBookRepository.addBook(
            title: any(named: 'title'),
            author: any(named: 'author'),
            isbn: any(named: 'isbn'),
            status: any(named: 'status'),
            notes: any(named: 'notes'),
            barcode: any(named: 'barcode'),
          )).thenAnswer((invocation) async {
        capturedCalls.add({
          'title': invocation.namedArguments[#title] as String,
          'author': invocation.namedArguments[#author] as String?,
          'isbn': invocation.namedArguments[#isbn] as String?,
          'status': invocation.namedArguments[#status] as String,
          'notes': invocation.namedArguments[#notes] as String?,
          'barcode': invocation.namedArguments[#barcode] as String?,
        });
        return 1;
      });

      final result = await bookImportService.importFromCsv(csvBytes);

      expect(result.successCount, 2);
      expect(result.failureCount, 0);
      expect(result.errors, isEmpty);
      expect(capturedCalls, [
        {
          'title': 'Book 1',
          'author': 'Author 1',
          'isbn': '1234567890',
          'status': 'available',
          'notes': 'Note 1',
          'barcode': null,
        },
        {
          'title': 'Book 2',
          'author': null,
          'isbn': null,
          'status': 'loaned',
          'notes': null,
          'barcode': null,
        },
      ]);
    });

    test('returns message when CSV only has headers', () async {
      const csvString = 'Título,Autor,ISBN,Estado,Actualizado,Notas,Total reseñas,Promedio reseñas\n';
      final csvBytes = Uint8List.fromList(utf8.encode(csvString));

      final result = await bookImportService.importFromCsv(csvBytes);

      expect(result.successCount, 0);
      expect(result.failureCount, 0);
      expect(result.errors, ['El archivo CSV está vacío o solo contiene encabezados']);
      verifyNever(() => mockBookRepository.addBook(
            title: any(named: 'title'),
            author: any(named: 'author'),
            isbn: any(named: 'isbn'),
            status: any(named: 'status'),
            notes: any(named: 'notes'),
            barcode: any(named: 'barcode'),
          ));
    });

    test('returns error when CSV lacks title column', () async {
      const csvString = 'Autor,ISBN\nAuthor 1,1234567890\n';
      final csvBytes = Uint8List.fromList(utf8.encode(csvString));

      final result = await bookImportService.importFromCsv(csvBytes);

      expect(result.successCount, 0);
      expect(result.failureCount, 0);
      expect(result.errors, ['El archivo CSV debe contener una columna "Título"']);
    });

    test('skips rows without values', () async {
      const csvString = 'Título,Autor,ISBN,Estado,Actualizado,Notas,Total reseñas,Promedio reseñas\n'
          'Book 1,Author 1,1234567890,available,2024-01-01 10:00,Note 1,2,4.5\n'
          ',,,,,,,\n';
      final csvBytes = Uint8List.fromList(utf8.encode(csvString));

      when(() => mockBookRepository.addBook(
            title: any(named: 'title'),
            author: any(named: 'author'),
            isbn: any(named: 'isbn'),
            status: any(named: 'status'),
            notes: any(named: 'notes'),
            barcode: any(named: 'barcode'),
          )).thenAnswer((_) async => 1);

      final result = await bookImportService.importFromCsv(csvBytes);

      expect(result.successCount, 1);
      expect(result.failureCount, 0);
      expect(result.errors, isEmpty);
      verify(() => mockBookRepository.addBook(
            title: 'Book 1',
            author: 'Author 1',
            isbn: '1234567890',
            status: 'available',
            notes: 'Note 1',
            barcode: null,
          )).called(1);
    });
  });

  group('importFromJson', () {
    test('imports data exported by BookExportService', () async {
      final jsonPayload = [
        {
          'title': 'Book 1',
          'author': 'Author 1',
          'isbn': '1234567890',
          'barcode': 'ABC123',
          'status': 'available',
          'notes': 'Note 1',
          'updatedAt': '2024-01-01T10:00:00.000Z',
          'createdAt': '2024-01-01T09:00:00.000Z',
          'reviews': [
            {
              'rating': 4,
              'text': 'Great book',
              'updatedAt': '2024-01-01T10:00:00.000Z',
              'createdAt': '2024-01-01T09:30:00.000Z',
            }
          ],
        },
        {
          'title': 'Book 2',
          'author': null,
          'isbn': null,
          'barcode': null,
          'status': 'loaned',
          'notes': null,
          'updatedAt': '2024-02-01T10:00:00.000Z',
          'createdAt': '2024-02-01T09:00:00.000Z',
          'reviews': [],
        }
      ];

      final jsonBytes = Uint8List.fromList(utf8.encode(jsonEncode(jsonPayload)));

      final capturedCalls = <Map<String, dynamic>>[];

      when(() => mockBookRepository.addBook(
            title: any(named: 'title'),
            author: any(named: 'author'),
            isbn: any(named: 'isbn'),
            status: any(named: 'status'),
            notes: any(named: 'notes'),
            barcode: any(named: 'barcode'),
          )).thenAnswer((invocation) async {
        capturedCalls.add({
          'title': invocation.namedArguments[#title] as String,
          'author': invocation.namedArguments[#author] as String?,
          'isbn': invocation.namedArguments[#isbn] as String?,
          'status': invocation.namedArguments[#status] as String,
          'notes': invocation.namedArguments[#notes] as String?,
          'barcode': invocation.namedArguments[#barcode] as String?,
        });
        return 1;
      });

      final result = await bookImportService.importFromJson(jsonBytes);

      expect(result.successCount, 2);
      expect(result.failureCount, 0);
      expect(result.errors, isEmpty);
      expect(capturedCalls, [
        {
          'title': 'Book 1',
          'author': 'Author 1',
          'isbn': '1234567890',
          'status': 'available',
          'notes': 'Note 1',
          'barcode': 'ABC123',
        },
        {
          'title': 'Book 2',
          'author': null,
          'isbn': null,
          'status': 'loaned',
          'notes': null,
          'barcode': null,
        },
      ]);
    });

    test('returns message when JSON list is empty', () async {
      final jsonBytes = Uint8List.fromList(utf8.encode('[]'));

      final result = await bookImportService.importFromJson(jsonBytes);

      expect(result.successCount, 0);
      expect(result.failureCount, 0);
      expect(result.errors, ['El archivo JSON está vacío']);
    });

    test('returns error when JSON is invalid', () async {
      final jsonBytes = Uint8List.fromList(utf8.encode('invalid json'));

      final result = await bookImportService.importFromJson(jsonBytes);

      expect(result.successCount, 0);
      expect(result.failureCount, 0);
      expect(result.errors.first, startsWith('Error al procesar el archivo JSON:'));
    });

    test('records failure when JSON item lacks title', () async {
      final payload = [
        {
          'author': 'Author 1',
        }
      ];
      final jsonBytes = Uint8List.fromList(utf8.encode(jsonEncode(payload)));

      when(() => mockBookRepository.addBook(
            title: any(named: 'title'),
            author: any(named: 'author'),
            isbn: any(named: 'isbn'),
            status: any(named: 'status'),
            notes: any(named: 'notes'),
            barcode: any(named: 'barcode'),
          )).thenAnswer((_) async => 1);

      final result = await bookImportService.importFromJson(jsonBytes);

      expect(result.successCount, 0);
      expect(result.failureCount, 1);
      expect(result.errors, ['Elemento 1: El título es obligatorio']);
      verifyNever(() => mockBookRepository.addBook(
            title: any(named: 'title'),
            author: any(named: 'author'),
            isbn: any(named: 'isbn'),
            status: any(named: 'status'),
            notes: any(named: 'notes'),
            barcode: any(named: 'barcode'),
          ));
    });
  });
}
