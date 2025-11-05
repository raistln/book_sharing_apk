import 'dart:convert';
import 'dart:typed_data';

import 'package:csv/csv.dart';
import 'package:intl/intl.dart';
import 'package:pdf/widgets.dart' as pw;

import '../data/local/database.dart';

enum BookExportFormat { csv, json, pdf }

class BookExportResult {
  const BookExportResult({required this.bytes, required this.mimeType, required this.fileName});

  final Uint8List bytes;
  final String mimeType;
  final String fileName;
}

class BookExportService {
  const BookExportService();

  Future<BookExportResult> export({
    required List<Book> books,
    required List<BookReview> reviews,
    required BookExportFormat format,
  }) async {
    switch (format) {
      case BookExportFormat.csv:
        return _toCsv(books, reviews);
      case BookExportFormat.json:
        return _toJson(books, reviews);
      case BookExportFormat.pdf:
        return await _toPdf(books, reviews);
    }
  }

  BookExportResult _toCsv(List<Book> books, List<BookReview> reviews) {
    final reviewMap = _reviewsByBookId(reviews);
    const headers = [
      'Título',
      'Autor',
      'ISBN',
      'Estado',
      'Actualizado',
      'Notas',
      'Total reseñas',
      'Promedio reseñas',
    ];

    final rows = <List<dynamic>>[];
    for (final book in books) {
      final bookReviews = reviewMap[book.id] ?? const <BookReview>[];
      final average = bookReviews.isEmpty
          ? null
          : (bookReviews.map((r) => r.rating).reduce((a, b) => a + b) /
              bookReviews.length)
              .toStringAsFixed(1);
      rows.add([
        book.title,
        book.author ?? '',
        book.isbn ?? '',
        book.status,
        DateFormat.yMd().add_Hm().format(book.updatedAt),
        book.notes ?? '',
        bookReviews.length,
        average ?? '',
      ]);
    }

    const csvConverter = ListToCsvConverter();
    final csvString = csvConverter.convert([headers, ...rows]);
    return BookExportResult(
      bytes: Uint8List.fromList(utf8.encode(csvString)),
      mimeType: 'text/csv',
      fileName: _fileName('biblioteca', 'csv'),
    );
  }

  BookExportResult _toJson(List<Book> books, List<BookReview> reviews) {
    final reviewMap = _reviewsByBookId(reviews);

    final payload = books.map((book) {
      final bookReviews = reviewMap[book.id] ?? const <BookReview>[];
      return {
        'title': book.title,
        'author': book.author,
        'isbn': book.isbn,
        'barcode': book.barcode,
        'status': book.status,
        'notes': book.notes,
        'updatedAt': book.updatedAt.toIso8601String(),
        'createdAt': book.createdAt.toIso8601String(),
        'reviews': bookReviews
            .map(
              (review) => {
                'rating': review.rating,
                'text': review.review,
                'updatedAt': review.updatedAt.toIso8601String(),
                'createdAt': review.createdAt.toIso8601String(),
              },
            )
            .toList(),
      };
    }).toList();

    final jsonString = const JsonEncoder.withIndent('  ').convert(payload);
    return BookExportResult(
      bytes: Uint8List.fromList(utf8.encode(jsonString)),
      mimeType: 'application/json',
      fileName: _fileName('biblioteca', 'json'),
    );
  }

  Future<BookExportResult> _toPdf(
    List<Book> books,
    List<BookReview> reviews,
  ) async {
    final reviewMap = _reviewsByBookId(reviews);
    final doc = pw.Document();
    final dateFormat = DateFormat.yMMMd();

    doc.addPage(
      pw.MultiPage(
        margin: const pw.EdgeInsets.all(32),
        build: (context) {
          return [
            pw.Header(
              child: pw.Text(
                'Mi Biblioteca',
                style: pw.TextStyle(
                  fontSize: 22,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ),
            pw.Paragraph(
              text:
                  'Exportado el ${DateFormat.yMMMMd().format(DateTime.now())}',
            ),
            ...books.map((book) {
              final bookReviews = reviewMap[book.id] ?? const <BookReview>[];
              final average = bookReviews.isEmpty
                  ? null
                  : bookReviews
                          .map((r) => r.rating)
                          .reduce((a, b) => a + b) /
                      bookReviews.length;

              return pw.Container(
                margin: const pw.EdgeInsets.only(bottom: 16),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      book.title,
                      style: pw.TextStyle(
                        fontSize: 16,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.SizedBox(height: 4),
                    pw.Text('Autor: ${book.author ?? 'Desconocido'}'),
                    if (book.isbn != null)
                      pw.Text('ISBN: ${book.isbn}'),
                    pw.Text('Estado: ${book.status}'),
                    pw.Text('Última actualización: ${
                      dateFormat.format(book.updatedAt)
                    }'),
                    if (book.notes?.isNotEmpty == true) ...[
                      pw.SizedBox(height: 4),
                      pw.Text('Notas: ${book.notes}'),
                    ],
                    pw.SizedBox(height: 4),
                    pw.Text(
                      bookReviews.isEmpty
                          ? 'Sin reseñas.'
                          : 'Reseñas (${bookReviews.length})'
                              '${average != null ? ' · Promedio ${average.toStringAsFixed(1)}' : ''}',
                    ),
                    if (bookReviews.isNotEmpty)
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: bookReviews
                            .map(
                              (review) => pw.Padding(
                                padding: const pw.EdgeInsets.only(top: 2),
                                child: pw.Bullet(
                                  text:
                                      '${review.rating}/5: ${review.review?.isNotEmpty == true ? review.review : 'Sin comentario'}',
                                ),
                              ),
                            )
                            .toList(),
                      ),
                  ],
                ),
              );
            }),
          ];
        },
      ),
    );

    final pdfBytes = await doc.save();
    return BookExportResult(
      bytes: pdfBytes,
      mimeType: 'application/pdf',
      fileName: _fileName('biblioteca', 'pdf'),
    );
  }

  Map<int, List<BookReview>> _reviewsByBookId(List<BookReview> reviews) {
    final map = <int, List<BookReview>>{};
    for (final review in reviews) {
      map.putIfAbsent(review.bookId, () => <BookReview>[]).add(review);
    }
    return map;
  }

  String _fileName(String base, String extension) {
    final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
    return '${base}_$timestamp.$extension';
  }
}
