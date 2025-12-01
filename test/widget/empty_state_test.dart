import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:book_sharing_app/ui/widgets/empty_state.dart';

void _doNothing() {}

void main() {
  group('EmptyState Widget', () {
    testWidgets('displays title, message, and action button', (tester) async {
      const title = 'No Books Found';
      const message = 'Start by adding your first book';
      const actionText = 'Add Book';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: const EmptyState(
              icon: Icons.book,
              title: title,
              message: message,
              action: EmptyStateAction(
                label: actionText,
                onPressed: _doNothing,
              ),
            ),
          ),
        ),
      );

      // Verify icon
      expect(find.byIcon(Icons.book), findsOneWidget);
      
      // Verify title
      expect(find.text(title), findsOneWidget);
      
      // Verify message
      expect(find.text(message), findsOneWidget);
      
      // Verify action button
      expect(find.text(actionText), findsOneWidget);
    });

    testWidgets('calls onAction when action button is tapped', (tester) async {
      const actionText = 'Add Book';
      bool actionCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EmptyState(
              icon: Icons.book,
              title: 'No Books Found',
              message: 'Start by adding your first book',
              action: EmptyStateAction(
                label: actionText,
                onPressed: () => actionCalled = true,
              ),
            ),
          ),
        ),
      );

      // Tap the action button
      await tester.tap(find.text(actionText));
      await tester.pump();

      // Verify onAction was called
      expect(actionCalled, isTrue);
    });

    testWidgets('renders correctly without action button', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EmptyState(
              icon: Icons.book,
              title: 'No Books Found',
              message: 'Start by adding your first book',
            ),
          ),
        ),
      );

      // Verify title and message are present
      expect(find.text('No Books Found'), findsOneWidget);
      expect(find.text('Start by adding your first book'), findsOneWidget);
      
      // Verify no action button is present
      expect(find.text('Add Book'), findsNothing);
    });

    testWidgets('renders with both primary and secondary actions', (tester) async {
      bool primaryActionCalled = false;
      bool secondaryActionCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EmptyState(
              icon: Icons.book,
              title: 'No Books Found',
              message: 'Start by adding your first book',
              action: EmptyStateAction(
                label: 'Add Book',
                onPressed: () => primaryActionCalled = true,
              ),
              secondaryAction: EmptyStateAction(
                label: 'Import Books',
                variant: EmptyStateActionVariant.text,
                onPressed: () => secondaryActionCalled = true,
              ),
            ),
          ),
        ),
      );

      // Verify both action buttons are present
      expect(find.text('Add Book'), findsOneWidget);
      expect(find.text('Import Books'), findsOneWidget);

      // Tap primary action
      await tester.tap(find.text('Add Book'));
      await tester.pump();
      expect(primaryActionCalled, isTrue);
      expect(secondaryActionCalled, isFalse);

      // Reset and tap secondary action
      primaryActionCalled = false;
      await tester.tap(find.text('Import Books'));
      await tester.pump();
      expect(secondaryActionCalled, isTrue);
      expect(primaryActionCalled, isFalse);
    });

    testWidgets('applies correct styling and layout', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: const EmptyState(
              icon: Icons.book,
              title: 'No Books Found',
              message: 'Start by adding your first book',
              action: EmptyStateAction(
                label: 'Add Book',
                onPressed: _doNothing,
              ),
            ),
          ),
        ),
      );

      // Find the Column that contains the content
      final columnFinder = find.byType(Column);
      expect(columnFinder, findsOneWidget);
      
      // Verify the icon has the correct size
      final iconFinder = find.byIcon(Icons.book);
      expect(iconFinder, findsOneWidget);
      
      final icon = tester.widget<Icon>(iconFinder);
      expect(icon.size, 72);
    });

    testWidgets('supports custom icon color', (tester) async {
      const customColor = Colors.red;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: const EmptyState(
              icon: Icons.book,
              title: 'No Books Found',
              message: 'Start by adding your first book',
              iconColor: customColor,
            ),
          ),
        ),
      );

      final iconFinder = find.byIcon(Icons.book);
      expect(iconFinder, findsOneWidget);
      
      final icon = tester.widget<Icon>(iconFinder);
      expect(icon.color, customColor);
    });
  });
}
