import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import 'database.dart';

/// DAO for managing reading timeline entries
class TimelineEntryDao {
  TimelineEntryDao(this.db);

  final AppDatabase db;
  final _uuid = const Uuid();

  /// Count books finished in a period
  Future<int> countFinishedBooksInPeriod(DateTime start, DateTime end) async {
    final query = db.selectOnly(db.readingTimelineEntries)
      ..where(db.readingTimelineEntries.eventType.equals('finish') &
          db.readingTimelineEntries.eventDate.isBiggerOrEqualValue(start) &
          db.readingTimelineEntries.eventDate.isSmallerOrEqualValue(end))
      ..addColumns([db.readingTimelineEntries.id.count()]);

    final result = await query.getSingle();
    return result.read(db.readingTimelineEntries.id.count()) ?? 0;
  }

  /// Get all timeline entries for a specific book, ordered by event date (most recent first)
  Stream<List<ReadingTimelineEntry>> watchEntriesForBook(int bookId) {
    return (db.select(db.readingTimelineEntries)
          ..where((entry) => entry.bookId.equals(bookId))
          ..orderBy([
            (entry) => OrderingTerm(
                  expression: entry.eventDate,
                  mode: OrderingMode.desc,
                ),
          ]))
        .watch();
  }

  /// Get timeline entries for a book as a future
  Future<List<ReadingTimelineEntry>> getEntriesForBook(int bookId) {
    return (db.select(db.readingTimelineEntries)
          ..where((entry) => entry.bookId.equals(bookId))
          ..orderBy([
            (entry) => OrderingTerm(
                  expression: entry.eventDate,
                  mode: OrderingMode.desc,
                ),
          ]))
        .get();
  }

  /// Create a new timeline entry
  Future<ReadingTimelineEntry> createEntry({
    required int bookId,
    required int ownerUserId,
    required String eventType,
    int? currentPage,
    int? percentageRead,
    String? note,
    DateTime? eventDate,
    String? remoteId,
  }) async {
    final now = DateTime.now();
    final entry = ReadingTimelineEntriesCompanion.insert(
      uuid: _uuid.v4(),
      bookId: bookId,
      ownerUserId: ownerUserId,
      eventType: eventType,
      currentPage: Value(currentPage),
      percentageRead: Value(percentageRead),
      note: Value(note),
      eventDate: Value(eventDate ?? now),
      remoteId: Value(remoteId),
      syncedAt: Value(remoteId != null ? now : null),
      isDirty: Value(remoteId == null),
      createdAt: Value(now),
      updatedAt: Value(now),
    );

    final id = await db.into(db.readingTimelineEntries).insert(entry);
    return (db.select(db.readingTimelineEntries)..where((e) => e.id.equals(id)))
        .getSingle();
  }

  /// Update an existing timeline entry
  Future<bool> updateEntry({
    required int entryId,
    int? currentPage,
    int? percentageRead,
    String? note,
    DateTime? eventDate,
  }) async {
    final update = ReadingTimelineEntriesCompanion(
      currentPage: Value(currentPage),
      percentageRead: Value(percentageRead),
      note: Value(note),
      eventDate: eventDate != null ? Value(eventDate) : const Value.absent(),
      updatedAt: Value(DateTime.now()),
    );

    final rowsAffected = await (db.update(db.readingTimelineEntries)
          ..where((entry) => entry.id.equals(entryId)))
        .write(update);

    return rowsAffected > 0;
  }

  /// Delete a timeline entry
  Future<bool> deleteEntry(int entryId) async {
    final rowsAffected = await (db.delete(db.readingTimelineEntries)
          ..where((entry) => entry.id.equals(entryId)))
        .go();

    return rowsAffected > 0;
  }

  /// Get the most recent entry for a book
  Future<ReadingTimelineEntry?> getLatestEntry(int bookId) {
    return (db.select(db.readingTimelineEntries)
          ..where((entry) => entry.bookId.equals(bookId))
          ..orderBy([
            (entry) => OrderingTerm(
                  expression: entry.eventDate,
                  mode: OrderingMode.desc,
                ),
          ])
          ..limit(1))
        .getSingleOrNull();
  }

  /// Get the first entry (start event) for a book
  Future<ReadingTimelineEntry?> getFirstEntry(int bookId) {
    return (db.select(db.readingTimelineEntries)
          ..where((entry) => entry.bookId.equals(bookId))
          ..where((entry) => entry.eventType.equals('start'))
          ..orderBy([
            (entry) => OrderingTerm(
                  expression: entry.eventDate,
                  mode: OrderingMode.asc,
                ),
          ])
          ..limit(1))
        .getSingleOrNull();
  }

  /// Get all finish events for a book (for rereading tracking)
  Future<List<ReadingTimelineEntry>> getFinishEvents(int bookId) {
    return (db.select(db.readingTimelineEntries)
          ..where((entry) => entry.bookId.equals(bookId))
          ..where((entry) => entry.eventType.equals('finish'))
          ..orderBy([
            (entry) => OrderingTerm(
                  expression: entry.eventDate,
                  mode: OrderingMode.desc,
                ),
          ]))
        .get();
  }

  /// Count total entries for a book
  Future<int> countEntriesForBook(int bookId) async {
    final query = db.selectOnly(db.readingTimelineEntries)
      ..where(db.readingTimelineEntries.bookId.equals(bookId))
      ..addColumns([db.readingTimelineEntries.id.count()]);

    final result = await query.getSingle();
    return result.read(db.readingTimelineEntries.id.count()) ?? 0;
  }

  /// Find entry by remote ID
  Future<ReadingTimelineEntry?> findByRemoteId(String remoteId) {
    return (db.select(db.readingTimelineEntries)
          ..where((t) => t.remoteId.equals(remoteId)))
        .getSingleOrNull();
  }

  /// Get all dirty entries (not synced)
  Future<List<ReadingTimelineEntry>> getDirtyEntries() {
    return (db.select(db.readingTimelineEntries)
          ..where((t) => t.isDirty.equals(true)))
        .get();
  }

  /// Update entry fields
  Future<void> updateEntryFields(
      int id, ReadingTimelineEntriesCompanion entry) async {
    await (db.update(db.readingTimelineEntries)..where((t) => t.id.equals(id)))
        .write(entry);
  }
}
