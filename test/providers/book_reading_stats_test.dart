import 'package:flutter_test/flutter_test.dart';
import 'package:book_sharing_app/providers/book_providers.dart';
import 'package:book_sharing_app/data/local/database.dart';

void main() {
  group('BookReadingStats', () {
    test('calculate returns null for empty sessions', () {
      final stats = BookReadingStats.calculate([]);
      expect(stats, isNull);
    });

    test('calculates stats correctly for single session', () {
      final sessions = [
        ReadingSession(
          id: 1,
          uuid: 'uuid1',
          bookId: 1,
          bookUuid: 'bookUuid',
          startTime: DateTime(2026, 4, 10, 10, 0),
          endTime: DateTime(2026, 4, 10, 11, 0),
          pagesRead: 30,
          isDirty: false,
          isDeleted: false,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ];

      final stats = BookReadingStats.calculate(sessions);
      expect(stats, isNotNull);
      expect(stats!.startDate, DateTime(2026, 4, 10, 10, 0));
      expect(stats.endDate, DateTime(2026, 4, 10, 11, 0));
      expect(stats.pagesPerDay, 30.0);
      expect(stats.maxPagesInSameDay, 30);
    });

    test('calculates max pages per day across multiple sessions on same day', () {
      final sessions = [
        ReadingSession(
          id: 1,
          uuid: 'uuid1',
          bookId: 1,
          bookUuid: 'bookUuid',
          startTime: DateTime(2026, 4, 10, 10, 0),
          endTime: DateTime(2026, 4, 10, 11, 0),
          pagesRead: 20,
          isDirty: false,
          isDeleted: false,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        ReadingSession(
          id: 2,
          uuid: 'uuid2',
          bookId: 1,
          bookUuid: 'bookUuid',
          startTime: DateTime(2026, 4, 10, 15, 0),
          endTime: DateTime(2026, 4, 10, 16, 0),
          pagesRead: 15,
          isDirty: false,
          isDeleted: false,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        ReadingSession(
          id: 3,
          uuid: 'uuid3',
          bookId: 1,
          bookUuid: 'bookUuid',
          startTime: DateTime(2026, 4, 11, 10, 0),
          endTime: DateTime(2026, 4, 11, 11, 0),
          pagesRead: 25, // Less than the total of day 10
          isDirty: false,
          isDeleted: false,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ];

      final stats = BookReadingStats.calculate(sessions);
      expect(stats, isNotNull);
      expect(stats!.startDate, DateTime(2026, 4, 10, 10, 0));
      expect(stats.endDate, DateTime(2026, 4, 11, 11, 0));
      // Total pages: 20+15+25 = 60. Over 2 days. So 30 pages/day.
      expect(stats.pagesPerDay, 30.0);
      // Max pages in same day: day 10 had 35 pages.
      expect(stats.maxPagesInSameDay, 35);
    });
  });
}
