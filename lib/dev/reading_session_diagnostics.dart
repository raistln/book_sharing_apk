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
    print('\n========== DIAGNÓSTICO DE SESIONES ==========');

    final sessions = await (db.select(db.readingSessions)
          ..orderBy([
            (t) => drift.OrderingTerm(
                expression: t.createdAt, mode: drift.OrderingMode.desc)
          ])
          ..limit(5))
        .get();

    print('Total de sesiones recientes: ${sessions.length}');

    for (final session in sessions) {
      print('\n--- Sesión ID: ${session.id} ---');
      print('  UUID: ${session.uuid}');
      print('  Book ID: ${session.bookId}');
      print('  Start Time: ${session.startTime}');
      print('  End Time: ${session.endTime}');
      print('  Duration: ${session.durationSeconds} segundos');
      print('  Start Page: ${session.startPage}');
      print('  End Page: ${session.endPage}');
      print('  Pages Read: ${session.pagesRead}');
      print('  Notes: "${session.notes}"');
      print('  Mood: ${session.mood}');
      print('  isDirty: ${session.isDirty}');
      print('  Created At: ${session.createdAt}');
    }

    print('\n==============================================\n');
  }

  /// Revisar las últimas 10 entradas de timeline
  Future<void> checkRecentTimeline() async {
    print('\n========== DIAGNÓSTICO DE TIMELINE ==========');

    final entries = await (db.select(db.readingTimelineEntries)
          ..orderBy([
            (t) => drift.OrderingTerm(
                expression: t.createdAt, mode: drift.OrderingMode.desc)
          ])
          ..limit(10))
        .get();

    print('Total de entradas recientes: ${entries.length}');

    for (final entry in entries) {
      print('\n--- Timeline ID: ${entry.id} ---');
      print('  UUID: ${entry.uuid}');
      print('  Book ID: ${entry.bookId}');
      print('  Owner User ID: ${entry.ownerUserId}');
      print('  Event Type: ${entry.eventType}');
      print('  Current Page: ${entry.currentPage}');
      print('  Percentage: ${entry.percentageRead}%');
      print('  Note: "${entry.note}"');
      print('  Event Date: ${entry.eventDate}');
      print('  isDirty: ${entry.isDirty}');
      print('  Created At: ${entry.createdAt}');
    }

    print('\n==============================================\n');
  }

  /// Verificar si existe el usuario activo
  Future<void> checkActiveUser(int userId) async {
    print('\n========== DIAGNÓSTICO DE USUARIO ==========');

    final user = await (db.select(db.localUsers)
          ..where((t) => t.id.equals(userId)))
        .getSingleOrNull();

    if (user != null) {
      print('✓ Usuario encontrado:');
      print('  ID: ${user.id}');
      print('  UUID: ${user.uuid}');
      print('  Username: ${user.username}');
    } else {
      print('✗ ERROR: Usuario con ID $userId NO existe en la base de datos');
      print('  Esto causará que todas las inserciones en timeline fallen.');
    }

    print('\n==============================================\n');
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

/// EJEMPLO DE USO:
///
/// En la pantalla después de guardar una sesión, ejecuta:
///
/// ```dart
/// final db = ref.read(appDatabaseProvider);
/// final diagnostics = ReadingSessionDiagnostics(db);
/// await diagnostics.runFullDiagnostic(userId: activeUser.id);
/// ```
///
/// Luego revisa la consola para ver si:
/// 1. La sesión se guardó con endTime, durationSeconds, pagesRead, notes
/// 2. Se creó una entrada en timeline con el note
/// 3. El usuario existe

void main() async {
  print('Iniciando diagnóstico manual...');

  // Para que funcione fuera de Flutter (Standalone)
  // Intentamos abrir la base de datos directamente
  final dbFile = File('book_sharing.sqlite');
  if (!dbFile.existsSync()) {
    print(
        'Error: No se encontró el archivo book_sharing.sqlite en el directorio actual.');
    print('Asegúrese de estar en la raíz del proyecto.');
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
}
