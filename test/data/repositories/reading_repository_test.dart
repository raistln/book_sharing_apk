import 'package:book_sharing_app/data/local/book_dao.dart';
import 'package:book_sharing_app/data/local/database.dart';
import 'package:book_sharing_app/data/local/reading_session_dao.dart';
import 'package:book_sharing_app/data/local/timeline_entry_dao.dart';
import 'package:book_sharing_app/data/repositories/reading_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockReadingSessionDao extends Mock implements ReadingSessionDao {}

class _MockBookDao extends Mock implements BookDao {}

class _MockTimelineEntryDao extends Mock implements TimelineEntryDao {}

void main() {
  late _MockReadingSessionDao readingSessionDao;
  late _MockBookDao bookDao;
  late _MockTimelineEntryDao timelineEntryDao;
  late ReadingRepository repository;

  setUpAll(() {
    registerFallbackValue(const ReadingSessionsCompanion());
    registerFallbackValue(const BooksCompanion());
    registerFallbackValue(const ReadingTimelineEntriesCompanion());
  });

  setUp(() {
    readingSessionDao = _MockReadingSessionDao();
    bookDao = _MockBookDao();
    timelineEntryDao = _MockTimelineEntryDao();
    repository = ReadingRepository(readingSessionDao, bookDao, timelineEntryDao);
  });

  group('ReadingRepository', () {
    test('getWeeklyStats calculates correct stats', () async {
      final now = DateTime(2024, 10, 15);

      final sessions = <ReadingSession>[
        ReadingSession(
          id: 1,
          uuid: 'session-1',
          bookId: 1,
          bookUuid: 'book-1',
          startTime: now.subtract(const Duration(hours: 2)),
          endTime: now.subtract(const Duration(hours: 1)),
          durationSeconds: 3600,
          startPage: 10,
          endPage: 20,
          pagesRead: 10,
          notes: null,
          mood: null,
          isDeleted: false,
          isDirty: false,
          createdAt: now,
          updatedAt: now,
        ),
      ];

      when(() => readingSessionDao.getSessionsInPeriod(any(), any()))
          .thenAnswer((_) async => sessions);

      final result = await repository.getWeeklyStats();

      expect(result.totalDuration, const Duration(seconds: 3600));
      expect(result.totalPages, 10);
      expect(result.pagesPerDay, 10 / 7.0);
    });

    test('getMonthlyStats calculates correct stats', () async {
      final now = DateTime(2024, 10, 15);

      final sessions = <ReadingSession>[
        ReadingSession(
          id: 1,
          uuid: 'session-1',
          bookId: 1,
          bookUuid: 'book-1',
          startTime: now.subtract(const Duration(hours: 2)),
          endTime: now.subtract(const Duration(hours: 1)),
          durationSeconds: 3600,
          startPage: 10,
          endPage: 20,
          pagesRead: 10,
          notes: null,
          mood: null,
          isDeleted: false,
          isDirty: false,
          createdAt: now,
          updatedAt: now,
        ),
      ];

      when(() => readingSessionDao.getSessionsInPeriod(any(), any()))
          .thenAnswer((_) async => sessions);
      when(() => timelineEntryDao.countFinishedBooksInPeriod(any(), any()))
          .thenAnswer((_) async => 2);

      final result = await repository.getMonthlyStats();

      expect(result.totalDuration, const Duration(seconds: 3600));
      expect(result.totalPages, 10);
      expect(result.booksFinished, 2);
      verify(() => timelineEntryDao.countFinishedBooksInPeriod(any(), any())).called(1);
    });

    test('getActiveSession delegates to readingSessionDao', () async {
      final session = ReadingSession(
        id: 1,
        uuid: 'session-1',
        bookId: 1,
        bookUuid: 'book-1',
        startTime: DateTime.now(),
        endTime: null,
        durationSeconds: null,
        startPage: 10,
        endPage: null,
        pagesRead: null,
        notes: null,
        mood: null,
        isDeleted: false,
        isDirty: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      when(() => readingSessionDao.findActiveSessionForBook(1))
          .thenAnswer((_) async => session);

      final result = await repository.getActiveSession(1);

      expect(result, session);
      verify(() => readingSessionDao.findActiveSessionForBook(1)).called(1);
    });

    test('getLatestProgress delegates to timelineEntryDao', () async {
      final entry = ReadingTimelineEntry(
        id: 1,
        uuid: 'timeline-1',
        bookId: 1,
        ownerUserId: 1,
        eventType: 'progress',
        currentPage: 50,
        percentageRead: 50,
        note: null,
        eventDate: DateTime.now(),
        isDeleted: false,
        isDirty: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      when(() => timelineEntryDao.getLatestEntry(1))
          .thenAnswer((_) async => entry);

      final result = await repository.getLatestProgress(1);

      expect(result, entry);
      verify(() => timelineEntryDao.getLatestEntry(1)).called(1);
    });
  });
}
