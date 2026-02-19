import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:book_sharing_app/ui/widgets/library/library_search_bar.dart';

void main() {
  group('LibrarySearchBar Widget', () {
    late TextEditingController controller;

    setUp(() {
      controller = TextEditingController();
    });

    tearDown(() {
      controller.dispose();
    });

    testWidgets('displays search input field', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LibrarySearchBar(
              controller: controller,
              onChanged: (_) {},
            ),
          ),
        ),
      );

      // Verify search field is present
      expect(find.byType(TextField), findsOneWidget);

      // Verify search hint text
      expect(find.text('Buscar por título o autor...'), findsOneWidget);

      // Verify search icon
      expect(find.byIcon(Icons.search), findsOneWidget);
    });

    testWidgets('calls onChanged when text is entered', (tester) async {
      String? changedQuery;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LibrarySearchBar(
              controller: controller,
              onChanged: (query) => changedQuery = query,
            ),
          ),
        ),
      );

      // Enter search text
      await tester.enterText(find.byType(TextField), 'Harry Potter');
      await tester.pump();

      // Verify onChanged was called
      expect(changedQuery, 'Harry Potter');
    });

    testWidgets('shows clear button when text is entered', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LibrarySearchBar(
              controller: controller,
              onChanged: (query) {},
            ),
          ),
        ),
      );

      // Initially no clear button
      expect(find.byIcon(Icons.clear), findsNothing);

      // Enter search text
      await tester.enterText(find.byType(TextField), 'test');
      await tester.pump();

      // Clear button should appear
      expect(find.byIcon(Icons.clear), findsOneWidget);
    });

    testWidgets('clears text when clear button is tapped', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LibrarySearchBar(
              controller: controller,
              onChanged: (query) {},
            ),
          ),
        ),
      );

      // Enter search text
      await tester.enterText(find.byType(TextField), 'test query');
      await tester.pump();

      // Verify text is entered
      expect(find.text('test query'), findsOneWidget);

      // Tap clear button
      await tester.tap(find.byIcon(Icons.clear));
      await tester.pump();

      // Verify text is cleared
      expect(find.text('test query'), findsNothing);
      expect(controller.text, isEmpty);
    });

    testWidgets('applies correct styling and decoration', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LibrarySearchBar(
              controller: controller,
              onChanged: (_) {},
            ),
          ),
        ),
      );

      // Verify it's wrapped in an InputDecorator
      final inputDecoratorFinder = find.byType(InputDecorator);
      expect(inputDecoratorFinder, findsOneWidget);
    });

    testWidgets('handles keyboard submission', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LibrarySearchBar(
              controller: controller,
              onChanged: (_) {},
            ),
          ),
        ),
      );

      // Enter search text
      await tester.enterText(find.byType(TextField), 'test search');
      await tester.pump();

      // Submit using keyboard
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();

      // Verify the text is still in the controller
      expect(controller.text, 'test search');
    });

    testWidgets('updates controller text externally', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LibrarySearchBar(
              controller: controller,
              onChanged: (query) {},
            ),
          ),
        ),
      );

      // Update controller text programmatically
      controller.text = 'external text';
      await tester.pump();

      // Verify the text is displayed
      expect(find.text('external text'), findsOneWidget);
      expect(controller.text, 'external text');
    });

    testWidgets('handles empty text correctly', (tester) async {
      String? changedQuery;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LibrarySearchBar(
              controller: controller,
              onChanged: (query) => changedQuery = query,
            ),
          ),
        ),
      );

      // Enter text and then clear it
      await tester.enterText(find.byType(TextField), 'test');
      await tester.pump();

      expect(changedQuery, 'test');

      // Clear the text
      await tester.tap(find.byIcon(Icons.clear));
      await tester.pump();

      // Verify onChanged was called with empty string
      expect(changedQuery, '');
      expect(find.text('test'), findsNothing);
    });
  });
}
