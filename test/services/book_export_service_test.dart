import 'dart:convert';

import 'package:book_sharing_app/data/local/database.dart';
import 'package:book_sharing_app/services/book_export_service.dart';
import 'package:flutter_test/flutter_test.dart';

Book _createBook({
  required int id,
  required String title,
  DateTime? createdAt,
  DateTime? updatedAt,
  String? author,
  String? isbn,
  String status = 'available',
  String? notes,
}) {
  final now = DateTime(2024, 01, 01, 12, 00, 00);
  return Book(
    id: id,
    uuid: 'book-uuid-$id',
    remoteId: null,
    ownerUserId: null,
    ownerRemoteId: null,
    title: title,
    author: author,
    isbn: isbn,
    barcode: null,
    coverPath: null,
    status: status,
    notes: notes,
    isDirty: false,
    isDeleted: false,
    syncedAt: null,
    createdAt: createdAt ?? now,
    updatedAt: updatedAt ?? now,
  );
}

BookReview _createReview({
  required int id,
  required int bookId,
  required int rating,
  String? review,
  DateTime? createdAt,
  DateTime? updatedAt,
}) {
  final now = DateTime(2024, 01, 01, 12, 00, 00);
  return BookReview(
    id: id,
    uuid: 'review-uuid-$id',
    remoteId: null,
    bookId: bookId,
    bookUuid: 'book-uuid-$bookId',
    authorUserId: 1000 + id,
    authorRemoteId: null,
    rating: rating,
    review: review,
    isDirty: false,
    isDeleted: false,
    syncedAt: null,
    createdAt: createdAt ?? now,
    updatedAt: updatedAt ?? now,
  );
}

void main() {
  const service = BookExportService();

  final book = _createBook(
    id: 1,
    title: 'Clean Code',
    author: 'Robert C. Martin',
    isbn: '9780132350884',
    notes: 'Recomendado',
  );

  final reviews = [
    _createReview(id: 1, bookId: 1, rating: 5, review: 'Excelente'),
    _createReview(id: 2, bookId: 1, rating: 3, review: 'Bueno'),
  ];

  group('BookExportService', () {
    test('exports CSV with headers and averages', () async {
      final result = await service.export(
        books: [book],
        reviews: reviews,
        format: BookExportFormat.csv,
      );

      expect(result.mimeType, 'text/csv');
      expect(result.fileName, endsWith('.csv'));

      final csv = utf8.decode(result.bytes);
      final lines = const LineSplitter().convert(csv);
      expect(lines.length, 2);
      expect(
        lines.first,
        'Título,Autor,ISBN,Estado,Actualizado,Notas,Total reseñas,Promedio reseñas',
      );
      expect(lines[1], contains('Clean Code'));
      expect(lines[1], contains(',2,'));
      expect(lines[1], contains('4.0'));
    });

    test('exports JSON with nested reviews', () async {
      final result = await service.export(
        books: [book],
        reviews: reviews,
        format: BookExportFormat.json,
      );

      expect(result.mimeType, 'application/json');
      expect(result.fileName, endsWith('.json'));

      final json = jsonDecode(utf8.decode(result.bytes)) as List<dynamic>;
      expect(json, hasLength(1));
      final entry = json.first as Map<String, dynamic>;
      expect(entry['title'], 'Clean Code');
      expect(entry['author'], 'Robert C. Martin');
      expect(entry['reviews'], hasLength(2));

      final firstReview = entry['reviews'][0] as Map<String, dynamic>;
      expect(firstReview['rating'], 5);
      expect(firstReview['text'], 'Excelente');
    });

    test('exports PDF bytes', () async {
      final result = await service.export(
        books: [book],
        reviews: reviews,
        format: BookExportFormat.pdf,
      );

      expect(result.mimeType, 'application/pdf');
      expect(result.fileName, endsWith('.pdf'));
      expect(result.bytes, isNotEmpty);
      expect(String.fromCharCodes(result.bytes.take(4)), equals('%PDF'));
    });

    test('handles empty reviews gracefully', () async {
      final bookOnly = _createBook(
        id: 2,
        title: 'Libro sin reseñas',
        author: 'Autor',
        isbn: '1234567890',
      );

      final result = await service.export(
        books: [bookOnly],
        reviews: const [],
        format: BookExportFormat.csv,
      );

      final csv = utf8.decode(result.bytes);
      final lines = const LineSplitter().convert(csv);
      expect(lines, hasLength(2));
      expect(lines[1], contains('Libro sin reseñas'));
      expect(lines[1], contains(',0,'));
    });
  });
}
