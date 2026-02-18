import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';
import 'package:book_sharing_app/data/local/database.dart';
import 'package:book_sharing_app/dev/reading_session_diagnostics.dart';

void main() {
  test('Run Reading Session Diagnostics', () async {
    print('Iniciando diagnóstico desde Flutter Test...');

    final dbFile = File('book_sharing.sqlite');
    if (!dbFile.existsSync()) {
      print('Error: No se encontró el archivo book_sharing.sqlite');
      return;
    }

    final db = AppDatabase.test(NativeDatabase(dbFile));

    try {
      final diagnostics = ReadingSessionDiagnostics(db);
      await diagnostics.runFullDiagnostic();
    } catch (e) {
      print('Error durante el diagnóstico: $e');
    } finally {
      await db.close();
    }
  });
}
