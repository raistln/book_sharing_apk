import 'package:flutter_test/flutter_test.dart';
import 'package:book_sharing_app/providers/book_providers.dart';
import 'package:book_sharing_app/data/local/database.dart';

ReadingTimelineEntry _entry({
  required int id,
  required String eventType,
  required DateTime eventDate,
  int? currentPage,
  int? percentageRead,
}) {
  final now = DateTime.now();
  return ReadingTimelineEntry(
    id: id,
    uuid: 'uuid-$id',
    bookId: 1,
    bookUuid: null,
    ownerUserId: 1,
    eventType: eventType,
    eventDate: eventDate,
    currentPage: currentPage,
    percentageRead: percentageRead,
    note: null,
    remoteId: null,
    syncedAt: null,
    isDirty: false,
    isDeleted: false, // ← campo que faltaba
    createdAt: now,
    updatedAt: now,
  );
}

void main() {
  group('BookReadingStats.fromTimeline', () {
    test('devuelve null para lista vacía', () {
      final stats = BookReadingStats.fromTimeline([]);
      expect(stats, isNull);
    });

    test('calcula stats correctamente con start y finish', () {
      final entries = [
        _entry(
          id: 1,
          eventType: 'start',
          eventDate: DateTime(2026, 4, 10),
          currentPage: 0,
        ),
        _entry(
          id: 2,
          eventType: 'progress',
          eventDate: DateTime(2026, 4, 15),
          currentPage: 50,
        ),
        _entry(
          id: 3,
          eventType: 'finish',
          eventDate: DateTime(2026, 4, 20),
          currentPage: 300,
        ),
      ];

      final stats = BookReadingStats.fromTimeline(entries);
      expect(stats, isNotNull);
      expect(stats!.startDate, DateTime(2026, 4, 10));
      expect(stats.finishDate, DateTime(2026, 4, 20));
      expect(stats.totalDays, 10);
      expect(stats.totalPages, 300);
      expect(stats.pagesPerDay, 30.0);
    });

    test('sin finish, totalDays se calcula hasta hoy', () {
      final start = DateTime.now().subtract(const Duration(days: 5));
      final entries = [
        _entry(
          id: 1,
          eventType: 'start',
          eventDate: start,
          currentPage: 0,
        ),
        _entry(
          id: 2,
          eventType: 'progress',
          eventDate: DateTime.now().subtract(const Duration(days: 1)),
          currentPage: 80,
        ),
      ];

      final stats = BookReadingStats.fromTimeline(entries);
      expect(stats, isNotNull);
      expect(stats!.finishDate, isNull);
      expect(stats.totalDays, greaterThanOrEqualTo(4));
      expect(stats.totalDays, lessThanOrEqualTo(6));
      expect(stats.totalPages, 80);
    });

    test('sin páginas registradas, pagesPerDay es 0', () {
      final entries = [
        _entry(
          id: 1,
          eventType: 'start',
          eventDate: DateTime(2026, 4, 1),
        ),
        _entry(
          id: 2,
          eventType: 'finish',
          eventDate: DateTime(2026, 4, 10),
        ),
      ];

      final stats = BookReadingStats.fromTimeline(entries);
      expect(stats, isNotNull);
      expect(stats!.totalPages, 0);
      expect(stats.pagesPerDay, 0.0);
    });

    test('usa la última entrada con página como referencia final', () {
      final entries = [
        _entry(
          id: 1,
          eventType: 'start',
          eventDate: DateTime(2026, 4, 1),
          currentPage: 10, // empezó en página 10
        ),
        _entry(
          id: 2,
          eventType: 'progress',
          eventDate: DateTime(2026, 4, 5),
          currentPage: 110,
        ),
        _entry(
          id: 3,
          eventType: 'finish',
          eventDate: DateTime(2026, 4, 11),
          // sin currentPage — la lógica debe usar la última entrada que sí tiene página
        ),
      ];

      final stats = BookReadingStats.fromTimeline(entries);
      expect(stats, isNotNull);
      // totalPages = 110 - 10 = 100, totalDays = 10, pagesPerDay = 10.0
      expect(stats!.totalPages, 100);
      expect(stats.totalDays, 10);
      expect(stats.pagesPerDay, 10.0);
    });
  });
}
