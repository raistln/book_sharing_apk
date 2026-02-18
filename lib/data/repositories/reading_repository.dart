import 'package:drift/drift.dart' as drift;
import 'package:uuid/uuid.dart';

import '../local/database.dart';
import '../local/reading_session_dao.dart';
import '../local/book_dao.dart';
import '../local/timeline_entry_dao.dart';

/// Estadísticas de lectura semanales
class WeeklyReadingStats {
  final Duration totalDuration;
  final int totalPages;
  final double pagesPerDay; // Promedio de páginas por día

  const WeeklyReadingStats({
    required this.totalDuration,
    required this.totalPages,
    required this.pagesPerDay,
  });
}

/// Estadísticas de lectura mensuales
class MonthlyReadingStats {
  final Duration totalDuration;
  final int totalPages;
  final int booksFinished;

  const MonthlyReadingStats({
    required this.totalDuration,
    required this.totalPages,
    required this.booksFinished,
  });
}

class ReadingRepository {
  ReadingRepository(
    this._readingSessionDao,
    this._bookDao,
    this._timelineEntryDao,
  );

  final ReadingSessionDao _readingSessionDao;
  final BookDao _bookDao;
  final TimelineEntryDao _timelineEntryDao;
  final _uuid = const Uuid();

  /// Cierra todas las sesiones activas (Zombie Killer).
  Future<void> closeAllActiveSessions() async {
    final activeSessions = await _readingSessionDao.getAllActiveSessions();
    final now = DateTime.now();

    print(
        '[ReadingRepository] 🧟 Zombie Killer: Cerrando ${activeSessions.length} sesiones activas');

    for (final session in activeSessions) {
      await _readingSessionDao.updateSession(
        ReadingSessionsCompanion(
          id: drift.Value(session.id),
          endTime: drift.Value(session.startTime),
          durationSeconds: const drift.Value(0),
          pagesRead: const drift.Value(0),
          updatedAt: drift.Value(now),
          isDirty: const drift.Value(true),
        ),
      );
    }

    print('[ReadingRepository] 🧟 Zombie Killer: Sesiones cerradas');
  }

  /// Inicia una nueva sesión de lectura para un libro.
  Future<ReadingSession> startSession({
    required int bookId,
    required String bookUuid,
    int? startPage,
  }) async {
    final now = DateTime.now();

    print(
        '[ReadingRepository] ▶️  startSession: bookId=$bookId, startPage=$startPage');

    // Cerrar sesión zombie si existe
    final existing = await _readingSessionDao.findActiveSessionForBook(bookId);
    if (existing != null) {
      print(
          '[ReadingRepository] 🧟 startSession: Cerrando sesión zombie ${existing.id}');

      final endTime = now.difference(existing.startTime).inHours > 12
          ? existing.startTime
          : now;

      await _readingSessionDao.updateSession(
        ReadingSessionsCompanion(
          id: drift.Value(existing.id),
          endTime: drift.Value(endTime),
          durationSeconds: drift.Value(
            endTime.difference(existing.startTime).inSeconds,
          ),
          pagesRead: const drift.Value(0),
          updatedAt: drift.Value(now),
          isDirty: const drift.Value(true),
        ),
      );
    }

    // Actualizar estado del libro
    final book = await _bookDao.findById(bookId);
    if (book != null &&
        book.readingStatus != 'reading' &&
        book.readingStatus != 'rereading') {
      await _bookDao.updateReadingStatus(bookId, 'reading');
    }

    // Determinar página inicial
    int? initialPage = startPage;
    if (initialPage == null) {
      final lastProgress = await getLatestProgress(bookId);
      initialPage = lastProgress?.currentPage ?? 0;
      print(
          '[ReadingRepository] 📖 startSession: Página inicial desde timeline: $initialPage');
    }

    final session = ReadingSessionsCompanion.insert(
      uuid: _uuid.v4(),
      bookId: bookId,
      bookUuid: bookUuid,
      startTime: now,
      startPage: drift.Value(initialPage),
      isDirty: const drift.Value(true),
      createdAt: drift.Value(now),
      updatedAt: drift.Value(now),
    );

    final id = await _readingSessionDao.insertSession(session);

    print('[ReadingRepository] ✅ startSession: Sesión creada con id=$id');

    return (await _readingSessionDao.getSessionsForBook(bookId))
        .firstWhere((s) => s.id == id);
  }

  /// Elimina una sesión (cancelada por el usuario).
  Future<void> deleteSession(int sessionId) async {
    print(
        '[ReadingRepository] 🗑️  deleteSession: Eliminando sesión $sessionId');
    await _readingSessionDao.deleteSession(sessionId);
  }

  /// Cierra una sesión con contexto completo.
  Future<void> endSessionWithContext({
    required ReadingSession session,
    required int endPage,
    String? notes,
    String? mood,
    required int userId,
  }) async {
    final now = DateTime.now();
    final startTime = session.startTime;

    final duration = now.difference(startTime);
    final startPage = session.startPage ?? 0;
    final pagesRead = (endPage - startPage).clamp(0, 99999);

    print('[ReadingRepository] 💾 endSessionWithContext INICIO:');
    print('  session.id = ${session.id}');
    print('  bookId = ${session.bookId}');
    print('  startPage = $startPage');
    print('  endPage = $endPage');
    print('  pagesRead = $pagesRead');
    print(
        '  duration = ${duration.inMinutes} minutos (${duration.inSeconds} segundos)');
    print('  notes = "$notes"');
    print('  mood = "$mood"');
    print('  userId = $userId');

    // 1. Actualizar sesión en DB
    try {
      await _readingSessionDao.updateSession(
        ReadingSessionsCompanion(
          id: drift.Value(session.id),
          endTime: drift.Value(now),
          durationSeconds: drift.Value(duration.inSeconds),
          endPage: drift.Value(endPage),
          pagesRead: drift.Value(pagesRead),
          notes: drift.Value(notes),
          mood: drift.Value(mood),
          isDirty: const drift.Value(true),
          updatedAt: drift.Value(now),
        ),
      );
      print('[ReadingRepository] ✅ Sesión actualizada en DB correctamente');
    } catch (e, st) {
      print('[ReadingRepository] ❌ ERROR al actualizar sesión: $e');
      print('[ReadingRepository] StackTrace: $st');
      rethrow;
    }

    // 2. Calcular porcentaje
    final book = await _bookDao.findById(session.bookId);
    int? percentage;
    if (book != null && book.pageCount != null && book.pageCount! > 0) {
      percentage = ((endPage / book.pageCount!) * 100).clamp(0, 100).round();
    }

    print(
        '[ReadingRepository] 📊 book.pageCount = ${book?.pageCount}, percentage = $percentage');

    // 3. Crear entrada en Timeline
    try {
      print('[ReadingRepository] 📝 Intentando crear timeline entry...');
      print('  → bookId: ${session.bookId}');
      print('  → ownerUserId: $userId');
      print('  → eventType: "progress"');
      print('  → currentPage: $endPage');
      print('  → percentageRead: $percentage');
      print('  → note: "$notes"');

      final timelineEntry = await _timelineEntryDao.createEntry(
        bookId: session.bookId,
        ownerUserId: userId,
        eventType: 'progress',
        currentPage: endPage,
        percentageRead: percentage,
        note: notes,
        eventDate: now,
      );

      print('[ReadingRepository] ✅ Timeline entry creada exitosamente:');
      print('  → id: ${timelineEntry.id}');
      print('  → uuid: ${timelineEntry.uuid}');
      print('  → currentPage: ${timelineEntry.currentPage}');
      print('  → note: "${timelineEntry.note}"');
      print('  → eventDate: ${timelineEntry.eventDate}');
    } catch (e, st) {
      print('[ReadingRepository] ❌ ERROR CRÍTICO al crear timeline entry:');
      print('  Error: $e');
      print('  StackTrace: $st');
      print('  → ¿El userId=$userId existe en local_users?');
      print('  → ¿El bookId=${session.bookId} existe en books?');
    }

    // 4. Actualizar libro
    try {
      await _bookDao.updateBookFields(
        bookId: session.bookId,
        entry: BooksCompanion(
          readAt: drift.Value(now),
          updatedAt: drift.Value(now),
          isDirty: const drift.Value(true),
        ),
      );
      print('[ReadingRepository] ✅ Libro actualizado');
    } catch (e, st) {
      print('[ReadingRepository] ❌ ERROR al actualizar libro: $e');
      print('[ReadingRepository] StackTrace: $st');
    }

    print('[ReadingRepository] 💾 endSessionWithContext COMPLETO\n');
  }

  /// Marca un libro como terminado.
  Future<void> finishBook({
    required int bookId,
    required int userId,
    required int finalPage,
    String? notes,
  }) async {
    final now = DateTime.now();

    print('[ReadingRepository] 🏁 finishBook INICIO:');
    print('  bookId = $bookId');
    print('  finalPage = $finalPage');
    print('  notes = "$notes"');
    print('  userId = $userId');

    // 1. Actualizar estado del libro
    try {
      await _bookDao.updateReadingStatus(bookId, 'finished');
      await _bookDao.toggleReadStatus(bookId, true);
      print('[ReadingRepository] ✅ Estado del libro actualizado a "finished"');
    } catch (e, st) {
      print('[ReadingRepository] ❌ ERROR al actualizar estado: $e');
      print('[ReadingRepository] StackTrace: $st');
    }

    // 2. Crear entrada 'finish' en timeline
    try {
      print(
          '[ReadingRepository] 📝 Intentando crear timeline entry "finish"...');

      final timelineEntry = await _timelineEntryDao.createEntry(
        bookId: bookId,
        ownerUserId: userId,
        eventType: 'finish',
        currentPage: finalPage,
        percentageRead: 100,
        note: notes,
        eventDate: now,
      );

      print('[ReadingRepository] ✅ Timeline entry "finish" creada:');
      print('  → id: ${timelineEntry.id}');
      print('  → uuid: ${timelineEntry.uuid}');
      print('  → note: "${timelineEntry.note}"');
    } catch (e, st) {
      print('[ReadingRepository] ❌ ERROR al crear timeline entry "finish":');
      print('  Error: $e');
      print('  StackTrace: $st');
    }

    print('[ReadingRepository] 🏁 finishBook COMPLETO\n');
  }

  /// Registra progreso manual desde la timeline sin usar cronómetro.
  /// Crea una sesión de 0 segundos para que las estadísticas capturen el progreso.
  Future<void> recordManualProgress({
    required Book book,
    required int userId,
    required int currentPage,
    String? note,
    DateTime? eventDate,
  }) async {
    final now = eventDate ?? DateTime.now();

    print('[ReadingRepository] 📝 recordManualProgress:');
    print('  bookId = ${book.id}');
    print('  currentPage = $currentPage');
    print('  userId = $userId');

    // 1. Obtener último progreso para calcular páginas leídas
    final lastProgress = await _timelineEntryDao.getLatestEntry(book.id);
    final previousPage = lastProgress?.currentPage ?? 0;
    final pagesRead = (currentPage - previousPage).clamp(0, 99999);

    print('  previousPage = $previousPage, pagesRead = $pagesRead');

    // 2. Crear sesión de 0 segundos para stats
    await _readingSessionDao.insertSession(
      ReadingSessionsCompanion.insert(
        uuid: _uuid.v4(),
        bookId: book.id,
        bookUuid: book.uuid,
        startTime: now,
        endTime: drift.Value(now),
        durationSeconds: const drift.Value(0),
        startPage: drift.Value(previousPage),
        endPage: drift.Value(currentPage),
        pagesRead: drift.Value(pagesRead),
        notes: drift.Value(note),
        isDirty: const drift.Value(true),
        createdAt: drift.Value(now),
        updatedAt: drift.Value(now),
      ),
    );

    // 3. Crear entrada en timeline
    // (Opcional: Si el que llama ya crea la entrada, esto podría sobrar,
    // pero es mejor centralizarlo aquí para asegurar consistencia)
    final percentage = book.pageCount != null && book.pageCount! > 0
        ? ((currentPage / book.pageCount!) * 100).clamp(0, 100).round()
        : null;

    await _timelineEntryDao.createEntry(
      bookId: book.id,
      ownerUserId: userId,
      eventType: 'progress',
      currentPage: currentPage,
      percentageRead: percentage,
      note: note,
      eventDate: now,
    );

    // 4. Actualizar libro
    await _bookDao.updateBookFields(
      bookId: book.id,
      entry: BooksCompanion(
        readAt: drift.Value(now),
        updatedAt: drift.Value(now),
        isDirty: const drift.Value(true),
      ),
    );

    print('[ReadingRepository] ✅ recordManualProgress COMPLETO\n');
  }

  /// Actualiza la página actual de una sesión activa.
  Future<void> updateSessionProgress({
    required int sessionId,
    required int currentPage,
  }) async {
    await _readingSessionDao.updateSession(
      ReadingSessionsCompanion(
        id: drift.Value(sessionId),
        endPage: drift.Value(currentPage),
        updatedAt: drift.Value(DateTime.now()),
        isDirty: const drift.Value(true),
      ),
    );
  }

  /// Obtiene la sesión activa para un libro (endTime IS NULL).
  Future<ReadingSession?> getActiveSession(int bookId) {
    return _readingSessionDao.findActiveSessionForBook(bookId);
  }

  /// Stream reactivo de la sesión activa para un libro.
  Stream<ReadingSession?> watchActiveSession(int bookId) {
    return _readingSessionDao.watchActiveSessionForBook(bookId);
  }

  /// Obtiene todas las sesiones de un libro.
  Future<List<ReadingSession>> getBookSessions(int bookId) {
    return _readingSessionDao.getSessionsForBook(bookId);
  }

  /// Obtiene el último progreso registrado para un libro.
  Future<ReadingTimelineEntry?> getLatestProgress(int bookId) {
    return _timelineEntryDao.getLatestEntry(bookId);
  }

  /// Stream del último progreso de un libro.
  Stream<ReadingTimelineEntry?> watchLatestProgress(int bookId) {
    return _timelineEntryDao.watchEntriesForBook(bookId).map((entries) {
      if (entries.isEmpty) return null;
      return entries.first;
    });
  }

  /// Obtiene las estadísticas de lectura de la semana actual.
  ///
  /// Retorna:
  /// - Tiempo total de lectura
  /// - Páginas totales leídas
  /// - Promedio de páginas por día (páginas totales / 7 días)
  Future<WeeklyReadingStats> getWeeklyStats() async {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final startOfPeriod = DateTime(
      startOfWeek.year,
      startOfWeek.month,
      startOfWeek.day,
    );

    print(
        '[ReadingRepository] 📊 getWeeklyStats: Calculando desde $startOfPeriod hasta $now');

    final sessions = await _readingSessionDao.getSessionsInPeriod(
      startOfPeriod,
      now,
    );

    Duration totalDuration = Duration.zero;
    int totalPages = 0;

    for (final session in sessions) {
      if (session.durationSeconds != null) {
        totalDuration += Duration(seconds: session.durationSeconds!);
      } else if (session.endTime != null) {
        totalDuration += session.endTime!.difference(session.startTime);
      }

      if (session.pagesRead != null) {
        totalPages += session.pagesRead!;
      }
    }

    // Calcular promedio de páginas por día (dividir entre 7 días de la semana)
    final pagesPerDay = totalPages / 7.0;

    print('[ReadingRepository] 📊 Weekly Stats: ${sessions.length} sesiones, '
        '${totalDuration.inMinutes}min, $totalPages páginas, ${pagesPerDay.toStringAsFixed(1)} páginas/día');

    return WeeklyReadingStats(
      totalDuration: totalDuration,
      totalPages: totalPages,
      pagesPerDay: pagesPerDay,
    );
  }

  /// Obtiene las estadísticas de lectura del mes actual.
  ///
  /// Retorna:
  /// - Tiempo total de lectura
  /// - Páginas totales leídas
  /// - Libros terminados
  Future<MonthlyReadingStats> getMonthlyStats() async {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);

    print(
        '[ReadingRepository] 📊 getMonthlyStats: Calculando desde $startOfMonth hasta $now');

    // 1. Sesiones del mes
    final sessions = await _readingSessionDao.getSessionsInPeriod(
      startOfMonth,
      now,
    );

    Duration totalDuration = Duration.zero;
    int totalPages = 0;

    for (final session in sessions) {
      if (session.durationSeconds != null) {
        totalDuration += Duration(seconds: session.durationSeconds!);
      } else if (session.endTime != null) {
        totalDuration += session.endTime!.difference(session.startTime);
      }

      if (session.pagesRead != null) {
        totalPages += session.pagesRead!;
      }
    }

    // 2. Libros terminados en el mes
    final booksFinished = await _timelineEntryDao.countFinishedBooksInPeriod(
      startOfMonth,
      now,
    );

    print('[ReadingRepository] 📊 Monthly Stats: ${sessions.length} sesiones, '
        '${totalDuration.inMinutes}min, $totalPages páginas, $booksFinished libros terminados');

    return MonthlyReadingStats(
      totalDuration: totalDuration,
      totalPages: totalPages,
      booksFinished: booksFinished,
    );
  }
}
