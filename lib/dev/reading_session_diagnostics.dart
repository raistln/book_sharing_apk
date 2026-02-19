import 'dart:io';
import 'package:drift/drift.dart' as drift;
import 'package:drift/native.dart';
import 'package:book_sharing_app/data/local/database.dart';
import 'package:book_sharing_app/data/local/reading_session_dao.dart';
import 'package:book_sharing_app/data/local/timeline_entry_dao.dart';

/// DIAGNÓSTICO: Ejecutar esto después de guardar una sesión para ver qué pasó
class ReadingSessionDiagnostics {
  final AppDatabase db;
  final ReadingSessionDao sessionDao;
  final TimelineEntryDao timelineDao;

  ReadingSessionDiagnostics(this.db)
      : sessionDao = ReadingSessionDao(db),
        timelineDao = TimelineEntryDao(db);

  /// Revisar las últimas 5 sesiones guardadas
  Future<void> checkRecentSessions() async {
    await (db.select(db.readingSessions)
          ..orderBy([
            (t) => drift.OrderingTerm(
                expression: t.createdAt, mode: drift.OrderingMode.desc)
          ])
          ..limit(5))
        .get();
  }

  /// Revisar las últimas 10 entradas de timeline
  Future<void> checkRecentTimeline() async {
    await (db.select(db.readingTimelineEntries)
          ..orderBy([
            (t) => drift.OrderingTerm(
                expression: t.createdAt, mode: drift.OrderingMode.desc)
          ])
          ..limit(10))
        .get();
  }

  /// Verificar si existe el usuario activo
  Future<void> checkActiveUser(int userId) async {
    await (db.select(db.localUsers)..where((t) => t.id.equals(userId)))
        .getSingleOrNull();
  }

  /// Diagnóstico completo
  Future<void> runFullDiagnostic({int? userId}) async {
    await checkRecentSessions();
    await checkRecentTimeline();
    if (userId != null) {
      await checkActiveUser(userId);
    }
  }
}

void main() async {
  // Para que funcione fuera de Flutter (Standalone)
  // Intentamos abrir la base de datos directamente
  final dbFile = File('book_sharing.sqlite');
  if (!dbFile.existsSync()) {
    return;
  }

  final db = AppDatabase.test(NativeDatabase(dbFile));

  try {
    final diagnostics = ReadingSessionDiagnostics(db);
    await diagnostics.runFullDiagnostic();
  } catch (e) {
    // Error silenciado como se pidió quitar prints
  } finally {
    await db.close();
  }
}
