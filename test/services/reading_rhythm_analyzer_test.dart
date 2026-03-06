import 'package:book_sharing_app/data/local/database.dart';
import 'package:book_sharing_app/services/reading_rhythm_analyzer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ReadingRhythmAnalyzer', () {
    test('generateInsight returns null when timeline is empty', () async {
      final book = Book(
        id: 1,
        uuid: 'book-1',
        title: 'Test Book',
        pageCount: 100,
        status: 'available',
        isDeleted: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isDirty: false,
        readingStatus: 'not_started',
        isRead: false,
        isBorrowedExternal: false,
        isPhysical: true,
      );

      final insight = await ReadingRhythmAnalyzer.generateInsight(
        book: book,
        timeline: [],
        userAveragePagesPerDay: 10.0,
      );

      expect(insight, null);
    });

    test('generateInsight returns starting insight when no meaningful data', () async {
      final book = Book(
        id: 1,
        uuid: 'book-1',
        title: 'Test Book',
        pageCount: 100,
        status: 'available',
        isDeleted: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isDirty: false,
        readingStatus: 'not_started',
        isRead: false,
        isBorrowedExternal: false,
        isPhysical: true,
      );

      final timeline = <ReadingTimelineEntry>[
        ReadingTimelineEntry(
          id: 1,
          uuid: 'entry-1',
          bookId: 1,
          ownerUserId: 1,
          currentPage: null,
          percentageRead: null,
          eventType: 'start',
          eventDate: DateTime.now(),
          isDeleted: false,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          isDirty: false,
        ),
      ];

      final insight = await ReadingRhythmAnalyzer.generateInsight(
        book: book,
        timeline: timeline,
        userAveragePagesPerDay: 10.0,
      );

      expect(insight?.text, 'Acabas de empezar este libro');
      expect(insight?.icon, Icons.auto_stories);
      expect(insight?.color, Colors.blue);
    });

    test('generateInsight returns nearly finished insight when percentage > 80', () async {
      final book = Book(
        id: 1,
        uuid: 'book-1',
        title: 'Test Book',
        pageCount: 100,
        status: 'available',
        isDeleted: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isDirty: false,
        readingStatus: 'not_started',
        isRead: false,
        isBorrowedExternal: false,
        isPhysical: true,
      );

      final timeline = <ReadingTimelineEntry>[
        ReadingTimelineEntry(
          id: 1,
          uuid: 'entry-1',
          bookId: 1,
          ownerUserId: 1,
          currentPage: 85,
          percentageRead: 85,
          eventType: 'progress',
          eventDate: DateTime.now(),
          isDeleted: false,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          isDirty: false,
        ),
      ];

      final insight = await ReadingRhythmAnalyzer.generateInsight(
        book: book,
        timeline: timeline,
        userAveragePagesPerDay: 10.0,
      );

      expect(insight?.text, 'Acabas de empezar este libro');
      expect(insight?.icon, Icons.auto_stories);
      expect(insight?.color, Colors.blue);
    });
  });
}
