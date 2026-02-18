import 'package:drift/drift.dart';

import 'database.dart';

part 'reading_session_dao.g.dart';

@DriftAccessor(tables: [ReadingSessions])
class ReadingSessionDao extends DatabaseAccessor<AppDatabase>
    with _$ReadingSessionDaoMixin {
  ReadingSessionDao(super.db);

  /// Watch all sessions for a specific book
  Stream<List<ReadingSession>> watchSessionsForBook(int bookId) {
    return (select(readingSessions)
          ..where((t) => t.bookId.equals(bookId))
          ..orderBy([
            (t) =>
                OrderingTerm(expression: t.startTime, mode: OrderingMode.desc)
          ]))
        .watch();
  }

  /// Get all sessions for a specific book
  Future<List<ReadingSession>> getSessionsForBook(int bookId) {
    return (select(readingSessions)
          ..where((t) => t.bookId.equals(bookId))
          ..orderBy([
            (t) =>
                OrderingTerm(expression: t.startTime, mode: OrderingMode.desc)
          ]))
        .get();
  }

  /// Get the latest session for a book (potentially active)
  Future<ReadingSession?> getLastSessionForBook(int bookId) {
    return (select(readingSessions)
          ..where((t) => t.bookId.equals(bookId))
          ..orderBy([
            (t) =>
                OrderingTerm(expression: t.startTime, mode: OrderingMode.desc)
          ])
          ..limit(1))
        .getSingleOrNull();
  }

  /// Find an active session (endTime is null) for a book
  Future<ReadingSession?> findActiveSessionForBook(int bookId) {
    return (select(readingSessions)
          ..where((t) => t.bookId.equals(bookId) & t.endTime.isNull()))
        .getSingleOrNull();
  }

  /// Watch for an active session (endTime is null) for a book
  Stream<ReadingSession?> watchActiveSessionForBook(int bookId) {
    return (select(readingSessions)
          ..where((t) => t.bookId.equals(bookId) & t.endTime.isNull()))
        .watchSingleOrNull();
  }

  /// Get all active sessions (endTime is null)
  Future<List<ReadingSession>> getAllActiveSessions() {
    return (select(readingSessions)..where((t) => t.endTime.isNull())).get();
  }

  /// Get sessions within a date range
  Future<List<ReadingSession>> getSessionsInPeriod(
      DateTime start, DateTime end) {
    return (select(readingSessions)
          ..where((t) =>
              t.startTime.isBiggerOrEqualValue(start) &
              t.startTime.isSmallerOrEqualValue(end)))
        .get();
  }

  /// Get a session by ID
  Future<ReadingSession?> findById(int id) {
    return (select(readingSessions)..where((t) => t.id.equals(id)))
        .getSingleOrNull();
  }

  /// Insert a new session
  Future<int> insertSession(ReadingSessionsCompanion session) {
    return into(readingSessions).insert(session);
  }

  /// Update an existing session
  ///
  /// FIX CRÍTICO: Cambiar de replace() a write()
  /// - replace() requiere TODOS los campos (uuid, bookId, bookUuid, startTime, etc.)
  /// - write() solo actualiza los campos presentes en el Companion
  Future<bool> updateSession(ReadingSessionsCompanion session) async {
    // Validar que el ID esté presente
    if (session.id.present) {
      final rowsAffected = await (update(readingSessions)
            ..where((t) => t.id.equals(session.id.value)))
          .write(session); // ← CAMBIO: replace() → write()

      return rowsAffected > 0;
    }
    return false;
  }

  /// Delete a session
  Future<int> deleteSession(int id) {
    return (delete(readingSessions)..where((t) => t.id.equals(id))).go();
  }
}
