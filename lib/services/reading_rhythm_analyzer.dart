import 'package:flutter/material.dart';

import '../data/local/database.dart';

/// Generates narrative, human-readable insights about reading rhythm
class ReadingRhythmAnalyzer {
  /// Generate a reading insight for a book based on its timeline
  static Future<ReadingInsight?> generateInsight({
    required Book book,
    required List<ReadingTimelineEntry> timeline,
    required double userAveragePagesPerDay,
  }) async {
    if (timeline.isEmpty) return null;

    // Calculate rhythm metrics
    final rhythm = _analyzeRhythm(timeline, book.pageCount);

    // No meaningful data yet
    if (rhythm.daysReading == 0 || rhythm.pagesRead == 0) {
      return const ReadingInsight(
        text: "Acabas de empezar este libro",
        icon: Icons.auto_stories,
        color: Colors.blue,
      );
    }

    // Detect patterns
    final pace = _comparePace(rhythm.pagesPerDay, userAveragePagesPerDay);
    final hasLongPauses = rhythm.longestGapDays > 14;
    final hasFrequentUpdates = rhythm.totalEntries > 5;
    final isNearlyFinished = rhythm.percentageComplete > 80;

    // Generate insight based on patterns
    if (isNearlyFinished) {
      return const ReadingInsight(
        text: "Estás a punto de terminar este libro",
        icon: Icons.celebration_outlined,
        color: Colors.amber,
      );
    }

    if (hasLongPauses) {
      return const ReadingInsight(
        text: "Este libro parece invitar a pausas y reflexión",
        icon: Icons.self_improvement,
        color: Colors.purple,
      );
    }

    if (pace == PaceType.fast) {
      if (hasFrequentUpdates) {
        return const ReadingInsight(
          text: "Has devorado este libro con entusiasmo",
          icon: Icons.local_fire_department_outlined,
          color: Colors.orange,
        );
      } else {
        return const ReadingInsight(
          text: "Una lectura vertiginosa, difícil de soltar",
          icon: Icons.flash_on_outlined,
          color: Colors.orange,
        );
      }
    }

    if (pace == PaceType.slow) {
      return const ReadingInsight(
        text: "Estás saboreando este libro con calma, sin prisas",
        icon: Icons.spa_outlined,
        color: Colors.teal,
      );
    }

    // Default: steady pace
    return const ReadingInsight(
      text: "Llevas un ritmo constante con este libro",
      icon: Icons.trending_flat,
      color: Colors.blue,
    );
  }

  /// Analyze reading rhythm from timeline
  static ReadingRhythm _analyzeRhythm(
    List<ReadingTimelineEntry> timeline,
    int? totalPages,
  ) {
    if (timeline.isEmpty) {
      return const ReadingRhythm(
        pagesRead: 0,
        daysReading: 0,
        pagesPerDay: 0,
        percentageComplete: 0,
        totalEntries: 0,
        longestGapDays: 0,
      );
    }

    // Sort by date (oldest first)
    final sorted = List<ReadingTimelineEntry>.from(timeline)
      ..sort((a, b) => a.eventDate.compareTo(b.eventDate));

    // For analysis, we only care about the LATEST session
    // Find the last 'start' event
    final lastStartIndex = sorted.lastIndexWhere((e) => e.eventType == 'start');
    final sessionEntries =
        lastStartIndex >= 0 ? sorted.sublist(lastStartIndex) : sorted;

    final firstEntry = sessionEntries.first;
    final lastEntry = sessionEntries.last;

    // Calculate pages read
    final startPage = firstEntry.currentPage ?? 0;
    final currentPage = lastEntry.currentPage ?? 0;
    final pagesRead = (currentPage - startPage).abs();

    // Calculate days reading
    final daysReading =
        lastEntry.eventDate.difference(firstEntry.eventDate).inDays;
    final effectiveDays = daysReading > 0 ? daysReading : 1;

    // Calculate pages per day
    final pagesPerDay = pagesRead / effectiveDays;

    // Calculate percentage complete
    final percentageComplete = lastEntry.percentageRead ?? 0;

    // Find longest gap between entries
    int longestGapDays = 0;
    for (int i = 1; i < sorted.length; i++) {
      final gap =
          sorted[i].eventDate.difference(sorted[i - 1].eventDate).inDays;
      if (gap > longestGapDays) {
        longestGapDays = gap;
      }
    }

    return ReadingRhythm(
      pagesRead: pagesRead,
      daysReading: daysReading,
      pagesPerDay: pagesPerDay,
      percentageComplete: percentageComplete,
      totalEntries: sessionEntries.length,
      longestGapDays: longestGapDays,
    );
  }

  /// Compare pace with user average
  static PaceType _comparePace(double currentPace, double userAverage) {
    if (userAverage == 0) return PaceType.normal;

    final ratio = currentPace / userAverage;

    if (ratio < 0.5) return PaceType.slow;
    if (ratio > 1.5) return PaceType.fast;
    return PaceType.normal;
  }

  /// Calculate user's historical average pages per day
  static Future<double> calculateUserAveragePagesPerDay({
    required List<Book> finishedBooks,
    required Future<List<ReadingTimelineEntry>> Function(int bookId)
        getTimeline,
  }) async {
    if (finishedBooks.isEmpty) return 0;

    double totalPagesPerDay = 0;
    int validBooks = 0;

    for (final book in finishedBooks) {
      final timeline = await getTimeline(book.id);
      if (timeline.isEmpty) continue;

      final rhythm = _analyzeRhythm(timeline, book.pageCount);
      if (rhythm.pagesPerDay > 0) {
        totalPagesPerDay += rhythm.pagesPerDay;
        validBooks++;
      }
    }

    return validBooks > 0 ? totalPagesPerDay / validBooks : 0;
  }
}

/// Model for reading insight
class ReadingInsight {
  final String text;
  final IconData icon;
  final Color color;

  const ReadingInsight({
    required this.text,
    required this.icon,
    required this.color,
  });
}

/// Model for reading rhythm metrics
class ReadingRhythm {
  final int pagesRead;
  final int daysReading;
  final double pagesPerDay;
  final int percentageComplete;
  final int totalEntries;
  final int longestGapDays;

  const ReadingRhythm({
    required this.pagesRead,
    required this.daysReading,
    required this.pagesPerDay,
    required this.percentageComplete,
    required this.totalEntries,
    required this.longestGapDays,
  });
}

/// Pace classification
enum PaceType {
  slow,
  normal,
  fast,
}
