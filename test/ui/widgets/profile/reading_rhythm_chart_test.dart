import 'package:book_sharing_app/data/local/database.dart';
import 'package:book_sharing_app/ui/widgets/profile/reading_rhythm_chart.dart';
import 'package:book_sharing_app/utils/reading_rhythm_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() {
  group('ReadingRhythmChart', () {
    final now = DateTime(2024, 1, 24, 15, 0);

    setUpAll(() async {
      await initializeDateFormatting('es');
    });

    Book createBook(int id, String title) {
      return Book(
        id: id,
        uuid: 'book-$id',
        title: title,
        status: 'available',
        readingStatus: 'reading',
        isRead: false,
        createdAt: now.subtract(const Duration(days: 30)),
        updatedAt: now,
        isPhysical: true,
        isBorrowedExternal: false,
        isDirty: false,
        isDeleted: false,
      );
    }

    final mockData = ReadingRhythmData(
      rows: [
        RhythmRow(
          book: createBook(1, 'Book 1'),
          segments: [
            RhythmSegment(
                start: now.subtract(const Duration(days: 5)),
                end: now,
                isPause: false)
          ],
        ),
        RhythmRow(
          book: createBook(2, 'Book 2'),
          segments: [
            RhythmSegment(
                start: now.subtract(const Duration(days: 3)),
                end: now,
                isPause: false)
          ],
        ),
      ],
      startDate: now.subtract(const Duration(days: 10)),
      endDate: now,
      insight: 'Test Insight',
    );

    testWidgets('Renders insight and rows', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: ReadingRhythmChart(
            data: mockData,
            onBookTap: (_) {},
          ),
        ),
      ));

      expect(find.text('Test Insight'), findsOneWidget);
      expect(find.text('Book 1'), findsOneWidget);
      expect(find.text('Book 2'), findsOneWidget);
    });

    testWidgets('Tapping a row calls onBookTap', (WidgetTester tester) async {
      Book? tappedBook;
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: ReadingRhythmChart(
            data: mockData,
            onBookTap: (book) => tappedBook = book,
          ),
        ),
      ));

      await tester.pumpAndSettle();
      await tester.tap(find.byType(InkWell).first);
      await tester.pumpAndSettle();

      expect(tappedBook, isNotNull);
      expect(tappedBook!.id, 1);
    });

    testWidgets('Renders empty state message when no data',
        (WidgetTester tester) async {
      final emptyData = ReadingRhythmData(
        rows: [],
        startDate: now,
        endDate: now,
        insight: '',
      );

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: ReadingRhythmChart(
            data: emptyData,
            onBookTap: (_) {},
          ),
        ),
      ));

      expect(
        find.textContaining('El silencio antes de la historia...'),
        findsOneWidget,
      );
    });
  });
}
