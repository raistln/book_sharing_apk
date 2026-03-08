import '../data/local/database.dart';
import '../data/local/timeline_entry_dao.dart';
import '../data/local/book_dao.dart';
import '../models/reading_status.dart';
import '../models/global_sync_state.dart';
import 'unified_sync_coordinator.dart';

/// Service for managing reading timeline and automatic event creation
class ReadingTimelineService {
  ReadingTimelineService({
    required this.timelineDao,
    required this.bookDao,
    this.syncCoordinator,
  });

  final TimelineEntryDao timelineDao;
  final BookDao bookDao;
  final UnifiedSyncCoordinator? syncCoordinator;

  /// Handle reading status change and create appropriate timeline events
  Future<void> onReadingStatusChanged({
    required Book book,
    required ReadingStatus oldStatus,
    required ReadingStatus newStatus,
    required int userId,
  }) async {
    // Prevent redundant events
    if (oldStatus == newStatus) return;

    final now = DateTime.now();

    switch (newStatus) {
      case ReadingStatus.reading:
        await _createStartEvent(book, userId, now);
        // Safety net: si por alguna razón llega aquí con is_read=true
        // (datos externos, migración, etc.), lo corregimos.
        if (book.isRead) {
          await bookDao.toggleReadStatus(book.id, false);
        }
        break;

      case ReadingStatus.paused:
        await _createPauseEvent(book, userId, now);
        break;

      case ReadingStatus.finished:
        await _createFinishEvent(book, userId, now);
        await bookDao.toggleReadStatus(book.id, true);
        break;

      case ReadingStatus.abandoned:
        // Si abandona una relectura, is_read se mantiene true (ya lo leyó una vez).
        // Si abandona una lectura inicial, is_read debe quedar false.
        if (!book.isRead) {
          await bookDao.toggleReadStatus(book.id, false);
        }
        break;

      case ReadingStatus.rereading:
        await _createStartEvent(book, userId, now, isRereading: true);
        // isRead permanece true: ya lo leyó al menos una vez.
        await bookDao.toggleReadStatus(book.id, true);
        break;

      case ReadingStatus.pending:
        // Resetear a pendiente limpia el flag is_read.
        await bookDao.toggleReadStatus(book.id, false);
        break;
    }

    syncCoordinator?.markPendingChanges(SyncEntity.books);
    syncCoordinator?.markPendingChanges(SyncEntity.timeline);
  }

  /// Create a start event
  Future<void> _createStartEvent(
    Book book,
    int userId,
    DateTime eventDate, {
    bool isRereading = false,
  }) async {
    final existingStart = await timelineDao.getFirstEntry(book.id);

    if (isRereading || existingStart == null) {
      await timelineDao.createEntry(
        bookId: book.id,
        ownerUserId: userId,
        eventType: 'start',
        currentPage: 0,
        percentageRead: 0,
        eventDate: eventDate,
      );
    }
  }

  /// Create a pause event
  Future<void> _createPauseEvent(
    Book book,
    int userId,
    DateTime eventDate,
  ) async {
    final latest = await timelineDao.getLatestEntry(book.id);

    await timelineDao.createEntry(
      bookId: book.id,
      ownerUserId: userId,
      eventType: 'pause',
      currentPage: latest?.currentPage,
      percentageRead: latest?.percentageRead,
      eventDate: eventDate,
    );
  }

  /// Create a finish event
  Future<void> _createFinishEvent(
    Book book,
    int userId,
    DateTime eventDate,
  ) async {
    final totalPages = book.pageCount ?? 0;

    await timelineDao.createEntry(
      bookId: book.id,
      ownerUserId: userId,
      eventType: 'finish',
      currentPage: totalPages > 0 ? totalPages : null,
      percentageRead: 100,
      eventDate: eventDate,
    );
  }

  /// Add a manual progress update
  Future<ReadingTimelineEntry> addProgressUpdate({
    required Book book,
    required int userId,
    int? currentPage,
    String? note,
    DateTime? eventDate,
  }) async {
    int? percentageRead;
    if (currentPage != null && book.pageCount != null && book.pageCount! > 0) {
      percentageRead = ((currentPage / book.pageCount!) * 100).round();
      percentageRead = percentageRead.clamp(0, 100);
    }

    final entry = await timelineDao.createEntry(
      bookId: book.id,
      ownerUserId: userId,
      eventType: 'progress',
      currentPage: currentPage,
      percentageRead: percentageRead,
      note: note,
      eventDate: eventDate ?? DateTime.now(),
    );

    // Si añade progreso mientras estaba en pausa, reanudar al estado activo correcto.
    // is_read=true → estaba releyendo; is_read=false → estaba leyendo por primera vez.
    if (book.readingStatus == 'paused') {
      final resumeStatus = book.isRead ? 'rereading' : 'reading';
      await bookDao.updateReadingStatus(book.id, resumeStatus);
    }

    syncCoordinator?.markPendingChanges(SyncEntity.books);
    syncCoordinator?.markPendingChanges(SyncEntity.timeline);

    return entry;
  }

  /// Get current reading progress for a book
  Future<ReadingProgress> getCurrentProgress(int bookId) async {
    final latest = await timelineDao.getLatestEntry(bookId);
    final firstEntry = await timelineDao.getFirstEntry(bookId);
    final entries = await timelineDao.getEntriesForBook(bookId);

    return ReadingProgress(
      currentPage: latest?.currentPage ?? 0,
      percentageRead: latest?.percentageRead ?? 0,
      startDate: firstEntry?.eventDate,
      lastUpdateDate: latest?.eventDate,
      totalEntries: entries.length,
    );
  }

  /// Check if a book has any timeline data
  Future<bool> hasTimelineData(int bookId) async {
    final count = await timelineDao.countEntriesForBook(bookId);
    return count > 0;
  }
}

/// Model for current reading progress
class ReadingProgress {
  final int currentPage;
  final int percentageRead;
  final DateTime? startDate;
  final DateTime? lastUpdateDate;
  final int totalEntries;

  ReadingProgress({
    required this.currentPage,
    required this.percentageRead,
    this.startDate,
    this.lastUpdateDate,
    required this.totalEntries,
  });

  bool get hasStarted => startDate != null;

  Duration? get timeSinceStart {
    if (startDate == null) return null;
    return DateTime.now().difference(startDate!);
  }

  Duration? get timeSinceLastUpdate {
    if (lastUpdateDate == null) return null;
    return DateTime.now().difference(lastUpdateDate!);
  }
}
