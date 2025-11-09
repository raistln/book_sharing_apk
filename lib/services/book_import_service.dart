import 'dart:convert';

import 'package:csv/csv.dart';
import 'package:flutter/foundation.dart';

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

          final sanitizedStatus =
              (statusValue == null || statusValue.isEmpty) ? 'available' : statusValue;
          final sanitizedBarcode =
              (barcodeValue == null || barcodeValue.isEmpty) ? null : barcodeValue;

          await _bookRepository.addBook(
            title: title,
            author: author?.isEmpty == true ? null : author,
            isbn: isbn?.isEmpty == true ? null : isbn,
            status: sanitizedStatus,
            notes: notes?.isEmpty == true ? null : notes,
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

      for (int i = 0; i < jsonData.length; i++) {
        try {
          final bookData = jsonData[i] as Map<String, dynamic>;
          
          if (bookData['title'] == null || bookData['title'].toString().trim().isEmpty) {
            failureCount++;
            errors.add('Elemento ${i + 1}: El título es obligatorio');
            continue;
          }

          await _bookRepository.addBook(
            title: bookData['title'].toString().trim(),
            author: bookData['author']?.toString().trim(),
            isbn: bookData['isbn']?.toString().trim(),
            barcode: bookData['barcode']?.toString().trim(),
            status: bookData['status']?.toString().trim() ?? 'available',
            notes: bookData['notes']?.toString().trim(),
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
