import '../data/local/database.dart';

class ReadingRhythmHelper {
  /// Transforms raw books and timeline entries into a structured model for the chart.
  ///
  /// [books] is the list of all user books.
  /// [entries] is a map where key is bookId and value is list of timeline entries for that book.
  static ReadingRhythmData processData(
      List<Book> books, Map<int, List<ReadingTimelineEntry>> entries) {
    // 1. Filter books: only those with status 'reading', 'finished', 'abandoned', 'paused'
    // AND that have at least one timeline entry (or a readAt date for legacy books).
    final relevantBooks = books.where((b) {
      final status = b.readingStatus.toLowerCase();
      return ['reading', 'finished', 'abandoned', 'paused', 'rereading']
              .contains(status) ||
          b.isRead;
    }).toList();

    // 2. Sort by most recent activity.
    // We prioritize books with recent timeline entries. If no entries, use readAt or updatedAt.
    relevantBooks.sort((a, b) {
      final aLatest = _getLatestActivityDate(a, entries[a.id]);
      final bLatest = _getLatestActivityDate(b, entries[b.id]);
      return bLatest.compareTo(aLatest); // Descending
    });

    // 3. Take top 7
    final topBooks = relevantBooks.take(7).toList();

    // 4. Build chart rows
    List<RhythmRow> rows = [];
    DateTime? minDate;
    DateTime? maxDate;

    for (var book in topBooks) {
      final bookEntries = entries[book.id] ?? [];
      // Sort entries ascending for processing
      bookEntries.sort((a, b) => a.eventDate.compareTo(b.eventDate));

      final segments = _buildSegments(book, bookEntries);
      if (segments.isEmpty) continue; // Skip if no valid segments found

      // Update global min/max for the chart scale
      for (var seg in segments) {
        if (minDate == null || seg.start.isBefore(minDate)) minDate = seg.start;
        if (maxDate == null || seg.end.isAfter(maxDate)) maxDate = seg.end;
      }

      rows.add(RhythmRow(
        book: book,
        segments: segments,
      ));
    }

    // 5. Adjust minDate to start of month and endDate to today
    if (minDate != null) {
      minDate = DateTime(minDate.year, minDate.month, 1);
    }
    final endDate = DateTime.now();

    return ReadingRhythmData(
      rows: rows,
      startDate: minDate ?? endDate.subtract(const Duration(days: 30)),
      endDate: endDate,
      insight: _generateInsight(rows),
    );
  }

  static DateTime _getLatestActivityDate(
      Book book, List<ReadingTimelineEntry>? entries) {
    if (entries != null && entries.isNotEmpty) {
      // Return the date of the last entry
      return entries
          .map((e) => e.eventDate)
          .reduce((a, b) => a.isAfter(b) ? a : b);
    }
    // Fallback for legacy books
    return book.readAt ?? book.updatedAt;
  }

  static List<RhythmSegment> _buildSegments(
      Book book, List<ReadingTimelineEntry> entries) {
    List<RhythmSegment> segments = [];

    if (entries.isEmpty) {
      // Legacy handling: if book is read but has no entries, create a mock segment
      if (book.isRead && book.readAt != null) {
        // Assume it took a week if we don't know, or just a point in time
        final end = book.readAt!;
        final start = end.subtract(const Duration(
            days: 14)); // Arbitrary 2 weeks estimate for visualization
        segments.add(RhythmSegment(start: start, end: end, isPause: false));
      }
      return segments;
    }

    // --- Only use entries from the LAST reading session ---
    // Find the last 'start' or 'rereading' event to isolate the most recent read cycle.
    // This prevents multi-year gaps from appearing when a book is re-read.
    final lastSessionIndex = _findLastSessionStart(entries);
    final sessionEntries =
        lastSessionIndex >= 0 ? entries.sublist(lastSessionIndex) : entries;

    // Process actual entries
    // We look for pairs of start/resume -> pause/finish
    DateTime? currentStart;

    for (int i = 0; i < sessionEntries.length; i++) {
      final e = sessionEntries[i];
      final type = e.eventType.toLowerCase();

      if (type == 'start' || type == 'resume' || type == 'rereading') {
        currentStart ??= e.eventDate;
        // If we were already "started" (missing a pause), keep extending.
      } else if (type == 'pause' || type == 'finish' || type == 'abandoned') {
        if (currentStart != null) {
          segments.add(RhythmSegment(
            start: currentStart,
            end: e.eventDate,
            isPause: false,
          ));
          currentStart = null;
        } else {
          // A finish without a start — skip (strict: only start->end creates a bar)
        }
      } else if (type == 'progress') {
        // Progress implies reading is ongoing.
        currentStart ??= e.eventDate;
      }
    }

    // If still reading (currentStart is not null)
    if (currentStart != null) {
      segments.add(RhythmSegment(
        start: currentStart,
        end: DateTime.now(), // Still reading right now
        isPause: false,
      ));
    }

    return segments;
  }

  /// Returns the index of the last 'start' or 'rereading' event in the entries list.
  /// Entries must already be sorted ascending by date.
  static int _findLastSessionStart(List<ReadingTimelineEntry> entries) {
    for (int i = entries.length - 1; i >= 0; i--) {
      final type = entries[i].eventType.toLowerCase();
      if (type == 'start' || type == 'rereading') {
        return i;
      }
    }
    return -1; // No session-start found → use all entries
  }

  static String _generateInsight(List<RhythmRow> rows) {
    if (rows.isEmpty) {
      return "Empieza una nueva lectura para ver tu ritmo aquí.";
    }

    // Simple logic for demo purposes
    if (rows.length >= 3) {
      // Check for overlap
      bool hasOverlap = false;
      for (int i = 0; i < rows.length; i++) {
        for (int j = i + 1; j < rows.length; j++) {
          for (var seg1 in rows[i].segments) {
            for (var seg2 in rows[j].segments) {
              if (seg1.start.isBefore(seg2.end) &&
                  seg2.start.isBefore(seg1.end)) {
                hasOverlap = true;
                break;
              }
            }
            if (hasOverlap) break;
          }
          if (hasOverlap) break;
        }
        if (hasOverlap) break;
      }
      if (hasOverlap) return "Tiendes a leer varios libros en paralelo.";
    }

    return "Tu ritmo de lectura es único.";
  }
}

class ReadingRhythmData {
  final List<RhythmRow> rows;
  final DateTime startDate;
  final DateTime endDate;
  final String insight;

  ReadingRhythmData(
      {required this.rows,
      required this.startDate,
      required this.endDate,
      required this.insight});
}

class RhythmRow {
  final Book book;
  final List<RhythmSegment> segments;

  RhythmRow({required this.book, required this.segments});
}

class RhythmSegment {
  final DateTime start;
  final DateTime end;
  final bool isPause;

  RhythmSegment(
      {required this.start, required this.end, required this.isPause});
}
