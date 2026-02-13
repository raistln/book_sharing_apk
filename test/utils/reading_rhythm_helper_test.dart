import 'package:book_sharing_app/data/local/database.dart';
import 'package:book_sharing_app/utils/reading_rhythm_helper.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ReadingRhythmHelper', () {
    final now = DateTime(2024, 1, 24, 15, 0);

    Book createBook(int id, String title,
        {String status = 'reading', bool isRead = false, DateTime? readAt}) {
      return Book(
        id: id,
        uuid: 'book-$id',
        title: title,
        status: 'available', // Added
        readingStatus: status,
        isRead: isRead,
        readAt: readAt, // Added
        createdAt: now.subtract(const Duration(days: 30)),
        updatedAt: now,
        isPhysical: true,
        isBorrowedExternal: false,
        isDirty: false,
        isDeleted: false,
      );
    }

    ReadingTimelineEntry createEntry(
        int id, int bookId, String type, DateTime date) {
      return ReadingTimelineEntry(
        id: id,
        uuid: 'entry-$id',
        bookId: bookId,
        ownerUserId: 1,
        eventType: type,
        eventDate: date,
        isDirty: false,
        isDeleted: false,
        createdAt: date,
        updatedAt: date,
      );
    }

    test('Selected last 7 active/read books', () {
      final books = List.generate(
          10,
          (i) => createBook(i, 'Book $i',
              status: 'finished', isRead: true, readAt: now));
      // Add entries for some to influence sorting if needed, but ProcessData sorts by activity
      // For simplicity, let's assume they have no entries.
      final result = ReadingRhythmHelper.processData(books, {});

      expect(result.rows.length, 7);
      // Logic takes last 7 based on activity.
    });

    test('Processes continuous reading segments correctly', () {
      final book = createBook(1, 'Test Book');
      final entries = [
        createEntry(1, 1, 'start', now.subtract(const Duration(days: 5))),
        createEntry(2, 1, 'progress', now.subtract(const Duration(days: 4))),
        createEntry(3, 1, 'finish', now.subtract(const Duration(days: 3))),
      ];

      final result = ReadingRhythmHelper.processData([book], {1: entries});

      expect(result.rows.length, 1);
      final segments = result.rows.first.segments;
      expect(segments.length, 1);
      expect(segments.first.start, now.subtract(const Duration(days: 5)));
      expect(segments.first.end, now.subtract(const Duration(days: 3)));
    });

    test('Handles pauses and multiple segments', () {
      final book = createBook(1, 'Test Book');
      final entries = [
        createEntry(1, 1, 'start', now.subtract(const Duration(days: 10))),
        createEntry(2, 1, 'pause', now.subtract(const Duration(days: 8))),
        createEntry(3, 1, 'resume', now.subtract(const Duration(days: 5))),
        createEntry(4, 1, 'finish', now.subtract(const Duration(days: 2))),
      ];

      final result = ReadingRhythmHelper.processData([book], {1: entries});

      expect(result.rows.first.segments.length, 2);
      expect(result.rows.first.segments[0].start,
          now.subtract(const Duration(days: 10)));
      expect(result.rows.first.segments[0].end,
          now.subtract(const Duration(days: 8)));
      expect(result.rows.first.segments[1].start,
          now.subtract(const Duration(days: 5)));
      expect(result.rows.first.segments[1].end,
          now.subtract(const Duration(days: 2)));
    });

    test('Handles implicit starts from progress events', () {
      final book = createBook(1, 'Test Book');
      final entries = [
        createEntry(1, 1, 'progress', now.subtract(const Duration(days: 5))),
        createEntry(2, 1, 'finish', now.subtract(const Duration(days: 2))),
      ];

      final result = ReadingRhythmHelper.processData([book], {1: entries});

      expect(result.rows.first.segments.length, 1);
      expect(result.rows.first.segments.first.start,
          now.subtract(const Duration(days: 5)));
    });

    test('Identifies parallel reading overlap for insights', () {
      final book1 = createBook(1, 'Book 1');
      final book2 = createBook(2, 'Book 2');
      final book3 = createBook(3, 'Book 3');

      final entries1 = [
        createEntry(1, 1, 'start', now.subtract(const Duration(days: 10))),
        createEntry(2, 1, 'finish', now.subtract(const Duration(days: 2)))
      ];
      final entries2 = [
        createEntry(3, 2, 'start', now.subtract(const Duration(days: 9))),
        createEntry(4, 2, 'finish', now.subtract(const Duration(days: 3)))
      ];
      final entries3 = [
        createEntry(5, 3, 'start', now.subtract(const Duration(days: 8))),
        createEntry(6, 3, 'finish', now.subtract(const Duration(days: 4)))
      ];

      final result = ReadingRhythmHelper.processData([
        book1,
        book2,
        book3
      ], {
        1: entries1,
        2: entries2,
        3: entries3,
      });

      expect(result.insight, contains("paralelo"));
    });
  });
}
