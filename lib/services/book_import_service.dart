import 'dart:convert';

import 'package:csv/csv.dart';
import 'package:flutter/foundation.dart';

import '../data/local/database.dart';
import '../data/repositories/book_repository.dart';

class BookImportResult {
  const BookImportResult({
    required this.successCount,
    required this.failureCount,
    required this.errors,
  });

  final int successCount;
  final int failureCount;
  final List<String> errors;
}

class BookImportService {
  BookImportService(this._bookRepository);

  final BookRepository _bookRepository;

  Future<BookImportResult> importFromCsv(Uint8List fileData) async {
    try {
      var csvString = utf8.decode(fileData);
      debugPrint('CSV String: $csvString');

      csvString = csvString.replaceAll('\r\n', '\n');
      if (csvString.trim().isEmpty) {
        return const BookImportResult(
          successCount: 0,
          failureCount: 0,
          errors: ['El archivo CSV está vacío o solo contiene encabezados'],
        );
      }

      const csvParser = CsvToListConverter(
        shouldParseNumbers: false,
        convertEmptyTo: null,
        eol: '\n',
      );

      final rawData = csvParser.convert(csvString);
      debugPrint('Parsed CSV data: $rawData');

      if (rawData.isEmpty || rawData.first.isEmpty) {
        return const BookImportResult(
          successCount: 0,
          failureCount: 0,
          errors: ['El archivo CSV está vacío o solo contiene encabezados'],
        );
      }

      final data = rawData.map<List<dynamic>>((row) => List<dynamic>.from(row)).toList();

      final rawHeaders = List<dynamic>.from(data.first);
      final headerIndex = <String, int>{};
      for (var i = 0; i < rawHeaders.length; i++) {
        final headerValue = rawHeaders[i];
        if (headerValue == null) continue;
        var normalized = headerValue.toString().trim().toLowerCase();
        if (normalized.isEmpty) continue;
        if (normalized.startsWith('\ufeff')) {
          normalized = normalized.substring(1);
        }
        headerIndex.putIfAbsent(normalized, () => i);
      }

      const titleAliases = ['título', 'titulo', 'title'];
      const authorAliases = ['autor', 'author'];
      const isbnAliases = ['isbn'];
      const statusAliases = ['estado', 'status'];
      const notesAliases = ['notas', 'notes'];
      const barcodeAliases = ['barcode', 'código de barras', 'codigo de barras'];

      final hasTitleColumn = titleAliases.any(headerIndex.containsKey);
      if (!hasTitleColumn) {
        return const BookImportResult(
          successCount: 0,
          failureCount: 0,
          errors: ['El archivo CSV debe contener una columna "Título"'],
        );
      }

      final hasDataRows = data.length > 1 &&
          data.skip(1).any((row) =>
              row.any((value) => value != null && value.toString().trim().isNotEmpty));

      if (!hasDataRows) {
        return const BookImportResult(
          successCount: 0,
          failureCount: 0,
          errors: ['El archivo CSV está vacío o solo contiene encabezados'],
        );
      }

      String? valueFor(List<dynamic> row, List<String> aliases) {
        for (final alias in aliases) {
          final index = headerIndex[alias];
          if (index != null && index < row.length) {
            final raw = row[index];
            if (raw == null) {
              return null;
            }
            return raw.toString().trim();
          }
        }
        return null;
      }

      int successCount = 0;
      int failureCount = 0;
      final errors = <String>[];

      Iterable<Book> existingBooks = const [];
      try {
        existingBooks = await _bookRepository.fetchActiveBooks();
      } catch (error, stackTrace) {
        debugPrint('No se pudieron obtener libros existentes para evitar duplicados: $error');
        debugPrint('$stackTrace');
      }
      final tracker = _BookDuplicateTracker(existingBooks);

      for (var rowIndex = 1; rowIndex < data.length; rowIndex++) {
        final row = data[rowIndex];
        final hasValues =
            row.any((value) => value != null && value.toString().trim().isNotEmpty);
        if (!hasValues) {
          continue;
        }

        try {
          final title = valueFor(row, titleAliases);
          if (title == null || title.isEmpty) {
            failureCount++;
            errors.add('Fila ${rowIndex + 1}: El título es obligatorio');
            continue;
          }

          final author = valueFor(row, authorAliases);
          final isbn = valueFor(row, isbnAliases);
          final notes = valueFor(row, notesAliases);
          final statusValue = valueFor(row, statusAliases);
          final barcodeValue = valueFor(row, barcodeAliases);

          final sanitizedTitle = _BookDuplicateTracker.sanitize(title)!;
          final sanitizedAuthor = _BookDuplicateTracker.sanitize(author);
          final sanitizedIsbn = _BookDuplicateTracker.sanitize(isbn);
          final sanitizedNotes = _BookDuplicateTracker.sanitize(notes);
          final sanitizedStatus =
              _BookDuplicateTracker.sanitize(statusValue) ?? 'available';
          final sanitizedBarcode = _BookDuplicateTracker.sanitize(barcodeValue);

          final duplicateReason = tracker.findDuplicate(
            title: sanitizedTitle,
            author: sanitizedAuthor,
            isbn: sanitizedIsbn,
            barcode: sanitizedBarcode,
          );
          if (duplicateReason != null) {
            failureCount++;
            errors.add(
              'Fila ${rowIndex + 1}: Libro duplicado (${duplicateReason}).',
            );
            continue;
          }

          await _bookRepository.addBook(
            title: sanitizedTitle,
            author: sanitizedAuthor,
            isbn: sanitizedIsbn,
            status: sanitizedStatus,
            notes: sanitizedNotes,
            barcode: sanitizedBarcode,
          );
          tracker.register(
            title: sanitizedTitle,
            author: sanitizedAuthor,
            isbn: sanitizedIsbn,
            barcode: sanitizedBarcode,
          );
          successCount++;
        } catch (e) {
          failureCount++;
          errors.add('Error en fila ${rowIndex + 1}: $e');
        }
      }

      return BookImportResult(
        successCount: successCount,
        failureCount: failureCount,
        errors: errors,
      );
    } catch (e) {
      return BookImportResult(
        successCount: 0,
        failureCount: 0,
        errors: ['Error al procesar el archivo: $e'],
      );
    }
  }

  Future<BookImportResult> importFromJson(Uint8List fileData) async {
    try {
      final jsonString = utf8.decode(fileData);
      final List<dynamic> jsonData = jsonDecode(jsonString);
      
      if (jsonData.isEmpty) {
        return const BookImportResult(
          successCount: 0,
          failureCount: 0,
          errors: ['El archivo JSON está vacío'],
        );
      }

      int successCount = 0;
      int failureCount = 0;
      final errors = <String>[];

      Iterable<Book> existingBooks = const [];
      try {
        existingBooks = await _bookRepository.fetchActiveBooks();
      } catch (error, stackTrace) {
        debugPrint('No se pudieron obtener libros existentes para evitar duplicados: $error');
        debugPrint('$stackTrace');
      }
      final tracker = _BookDuplicateTracker(existingBooks);

      for (int i = 0; i < jsonData.length; i++) {
        try {
          final bookData = jsonData[i] as Map<String, dynamic>;

          final rawTitle = bookData['title']?.toString();
          final sanitizedTitle = _BookDuplicateTracker.sanitize(rawTitle);
          if (sanitizedTitle == null) {
            failureCount++;
            errors.add('Elemento ${i + 1}: El título es obligatorio');
            continue;
          }

          final sanitizedAuthor =
              _BookDuplicateTracker.sanitize(bookData['author']?.toString());
          final sanitizedIsbn =
              _BookDuplicateTracker.sanitize(bookData['isbn']?.toString());
          final sanitizedBarcode =
              _BookDuplicateTracker.sanitize(bookData['barcode']?.toString());
          final sanitizedStatus =
              _BookDuplicateTracker.sanitize(bookData['status']?.toString()) ??
                  'available';
          final sanitizedNotes =
              _BookDuplicateTracker.sanitize(bookData['notes']?.toString());

          final duplicateReason = tracker.findDuplicate(
            title: sanitizedTitle,
            author: sanitizedAuthor,
            isbn: sanitizedIsbn,
            barcode: sanitizedBarcode,
          );
          if (duplicateReason != null) {
            failureCount++;
            errors.add(
              'Elemento ${i + 1}: Libro duplicado (${duplicateReason}).',
            );
            continue;
          }

          await _bookRepository.addBook(
            title: sanitizedTitle,
            author: sanitizedAuthor,
            isbn: sanitizedIsbn,
            barcode: sanitizedBarcode,
            status: sanitizedStatus,
            notes: sanitizedNotes,
          );
          tracker.register(
            title: sanitizedTitle,
            author: sanitizedAuthor,
            isbn: sanitizedIsbn,
            barcode: sanitizedBarcode,
          );
          successCount++;
        } catch (e) {
          failureCount++;
          errors.add('Error en elemento ${i + 1}: $e');
        }
      }

      return BookImportResult(
        successCount: successCount,
        failureCount: failureCount,
        errors: errors,
      );
    } catch (e) {
      return BookImportResult(
        successCount: 0,
        failureCount: 0,
        errors: ['Error al procesar el archivo JSON: $e'],
      );
    }
  }
}

class _BookDuplicateTracker {
  _BookDuplicateTracker(Iterable<Book> existing) {
    for (final book in existing) {
      register(
        title: book.title,
        author: book.author,
        isbn: book.isbn,
        barcode: book.barcode,
      );
    }
  }

  final _isbns = <String>{};
  final _barcodes = <String>{};
  final _titleAuthorKeys = <String>{};

  static String? sanitize(String? value) {
    if (value == null) return null;
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  String _normalize(String value) => value.trim().toLowerCase();

  String _titleAuthorKey(String title, String? author) {
    final normalizedAuthor = author == null ? '' : _normalize(author);
    return '${_normalize(title)}::$normalizedAuthor';
  }

  String? findDuplicate({
    required String title,
    String? author,
    String? isbn,
    String? barcode,
  }) {
    final sanitizedBarcode = sanitize(barcode);
    if (sanitizedBarcode != null) {
      final normalizedBarcode = _normalize(sanitizedBarcode);
      if (_barcodes.contains(normalizedBarcode)) {
        return 'código de barras "$sanitizedBarcode"';
      }
    }

    final sanitizedIsbn = sanitize(isbn);
    if (sanitizedIsbn != null) {
      final normalizedIsbn = _normalize(sanitizedIsbn);
      if (_isbns.contains(normalizedIsbn)) {
        return 'ISBN "$sanitizedIsbn"';
      }
    }

    final key = _titleAuthorKey(title, sanitize(author));
    if (_titleAuthorKeys.contains(key)) {
      final sanitizedAuthor = sanitize(author);
      return sanitizedAuthor == null
          ? 'título "$title"'
          : 'título y autor "$title" / "$sanitizedAuthor"';
    }

    return null;
  }

  void register({
    required String title,
    String? author,
    String? isbn,
    String? barcode,
  }) {
    final sanitizedTitle = sanitize(title);
    if (sanitizedTitle == null) {
      return;
    }

    final sanitizedIsbn = sanitize(isbn);
    if (sanitizedIsbn != null) {
      _isbns.add(_normalize(sanitizedIsbn));
    }

    final sanitizedBarcode = sanitize(barcode);
    if (sanitizedBarcode != null) {
      _barcodes.add(_normalize(sanitizedBarcode));
    }

    final sanitizedAuthor = sanitize(author);
    _titleAuthorKeys.add(_titleAuthorKey(sanitizedTitle, sanitizedAuthor));
  }
}
