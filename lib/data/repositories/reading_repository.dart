import 'package:drift/drift.dart' as drift;
import 'package:uuid/uuid.dart';

import '../local/database.dart';
import '../local/reading_session_dao.dart';
import '../local/book_dao.dart';
import '../local/timeline_entry_dao.dart';

class ReadingStats {
  final Duration weeklyDuration;
  final int weeklyPages;
  final int weeklyBooksFinished;

  const ReadingStats({
    required this.weeklyDuration,
    required this.weeklyPages,
    required this.weeklyBooksFinished,
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

  /// Close all active sessions (Zombie Killer)
  /// This is called on app startup/unlock to ensure no sessions are running from previous crashes/closes.
  Future<void> closeAllActiveSessions() async {
    final activeSessions = await _readingSessionDao.getAllActiveSessions();
    final now = DateTime.now();

    for (final session in activeSessions) {
      // If the session is very old (> 12 hours), we might want to discard it or cap it.
      // Current logic: Close it with 0 duration effectively (endTime = startTime) so it doesn't skew stats.
      // Or we could let it be 0 duration by setting endTime = startTime.
      // User complaint: "Start with 40 mins... crazy".

      // Let's close it with endTime = startTime to have 0 duration.
      await _readingSessionDao.updateSession(
        ReadingSessionsCompanion(
          id: drift.Value(session.id),
          endTime: drift.Value(session.startTime), // 0 duration
          updatedAt: drift.Value(now),
          isDirty: const drift.Value(true),
        ),
      );
    }
  }

  /// Start a new reading session for a book
  /// If there's already an active session, it returns that one instead of creating a new one.
  Future<ReadingSession> startSession({
    required int bookId,
    required String bookUuid,
    int? startPage,
  }) async {
    final now = DateTime.now();

    // Check for existing active session
    final existing = await _readingSessionDao.findActiveSessionForBook(bookId);
    if (existing != null) {
      // Close any existing zombie session to ensure we start fresh
      // If the session is very old (e.g. > 12 hours), we assume it was abandoned
      // and close it with 0 duration to avoid polluting stats.
      var endTime = now;
      if (now.difference(existing.startTime).inHours > 12) {
        endTime = existing.startTime;
      }

      await _readingSessionDao.updateSession(
        ReadingSessionsCompanion(
          id: drift.Value(existing.id),
          endTime: drift.Value(endTime),
          // We don't know the end page, so we keep it open or assume no progress
          // Ideally we would want to know where it ended, but for a zombie session
          // it's safer to just close it.
          updatedAt: drift.Value(now),
        ),
      );
    }

    // Update book status to 'reading' if it's not already active (reading or rereading)
    final book = await _bookDao.findById(bookId);
    if (book != null &&
        book.readingStatus != 'reading' &&
        book.readingStatus != 'rereading') {
      await _bookDao.updateReadingStatus(bookId, 'reading');
    }

    // Get the current progress from the book if startPage is not provided
    int? initialPage = startPage;
    if (initialPage == null) {
      // Try to get last progress from timeline
      final lastProgress = await getLatestProgress(bookId);
      if (lastProgress != null) {
        initialPage = lastProgress.currentPage;
      } else {
        initialPage = 0;
      }
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

    return (await _readingSessionDao.getSessionsForBook(
      bookId,
    ))
        .firstWhere((s) => s.id == id);
  }

  /// End an active session
  /// Note: To update timeline and stats, prefer using [endSessionWithContext]
  Future<void> endSession({
    required int sessionId,
    required int endPage,
    String? notes,
    String? mood,
  }) async {
    final now = DateTime.now();

    await _readingSessionDao.updateSession(
      ReadingSessionsCompanion(
        id: drift.Value(sessionId),
        endTime: drift.Value(now),
        endPage: drift.Value(endPage),
        notes: drift.Value(notes),
        mood: drift.Value(mood),
        isDirty: const drift.Value(true),
        updatedAt: drift.Value(now),
      ),
    );
  }

  /// Delete a session (e.g. cancelled by user)
  Future<void> deleteSession(int sessionId) async {
    await _readingSessionDao.deleteSession(sessionId);
  }

  /// End session with full context
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
    // If endPage < startPage (user went back), pagesRead is 0 for this session stats
    final pagesRead = (endPage - startPage).clamp(0, 99999);

    // 1. Update Session
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

    // 2. Update Book Progress
    final book = await _bookDao.findById(session.bookId);
    int? percentage;
    if (book != null && book.pageCount != null && book.pageCount! > 0) {
      percentage = ((endPage / book.pageCount!) * 100).clamp(0, 100).round();
    }

    // 3. Create Timeline Entry
    await _timelineEntryDao.createEntry(
      bookId: session.bookId,
      ownerUserId: userId,
      eventType: 'progress',
      currentPage: endPage,
      percentageRead: percentage,
      note: notes,
      eventDate: now,
    );

    // 4. Update Book's last activity and progress status if needed
    await _bookDao.updateBookFields(
      bookId: session.bookId,
      entry: BooksCompanion(
        readAt: drift.Value(now),
        updatedAt: drift.Value(now),
        isDirty: const drift.Value(true),
      ),
    );
  }

  /// Finish book (mark as completed)
  Future<void> finishBook({
    required int bookId,
    required int userId,
    required int finalPage,
    String? notes,
  }) async {
    final now = DateTime.now();

    // 1. Update Book Status
    await _bookDao.updateReadingStatus(bookId, 'finished');
    await _bookDao.toggleReadStatus(
      bookId,
      true,
    ); // Mark as read (legacy/compatibility)

    // 2. Create Timeline Entry for Finish
    await _timelineEntryDao.createEntry(
      bookId: bookId,
      ownerUserId: userId,
      eventType: 'finish',
      currentPage: finalPage,
      percentageRead: 100,
      note: notes,
      eventDate: now,
    );
  }

  /// Update an active session (e.g. periodically saving progress)
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

  /// Get active session for a book
  Future<ReadingSession?> getActiveSession(int bookId) {
    return _readingSessionDao.findActiveSessionForBook(bookId);
  }

  /// Watch active session for a book (stream)
  Stream<ReadingSession?> watchActiveSession(int bookId) {
    return _readingSessionDao.watchActiveSessionForBook(bookId);
  }

  /// Get all sessions for a book
  Future<List<ReadingSession>> getBookSessions(int bookId) {
    return _readingSessionDao.getSessionsForBook(bookId);
  }

  /// Get latest progress for a book
  Future<ReadingTimelineEntry?> getLatestProgress(int bookId) {
    return _timelineEntryDao.getLatestEntry(bookId);
  }

  /// Watch latest progress for a book
  Stream<ReadingTimelineEntry?> watchLatestProgress(int bookId) {
    return _timelineEntryDao.watchEntriesForBook(bookId).map((entries) {
      if (entries.isEmpty) return null;
      return entries.first;
    });
  }

  /// Get weekly reading stats
  Future<ReadingStats> getWeeklyStats() async {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final startOfPeriod = DateTime(
      startOfWeek.year,
      startOfWeek.month,
      startOfWeek.day,
    );
    final endOfPeriod = now;

    // 1. Get sessions
    final sessions = await _readingSessionDao.getSessionsInPeriod(
      startOfPeriod,
      endOfPeriod,
    );

    Duration totalDuration = Duration.zero;
    int totalPages = 0;

    for (final session in sessions) {
      if (session.endTime != null) {
        totalDuration += session.endTime!.difference(session.startTime);
      }
      if (session.pagesRead != null) {
        totalPages += session.pagesRead!;
      }
    }

    // 2. Get finished books
    final finishedBooks = await _timelineEntryDao.countFinishedBooksInPeriod(
      startOfPeriod,
      endOfPeriod,
    );

    return ReadingStats(
      weeklyDuration: totalDuration,
      weeklyPages: totalPages,
      weeklyBooksFinished: finishedBooks,
    );
  }
}
