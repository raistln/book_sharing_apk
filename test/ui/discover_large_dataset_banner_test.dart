import 'package:book_sharing_app/ui/screens/home/tabs/discover_group_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DiscoverLargeDatasetBanner', () {
    testWidgets('shows message and buttons when include unavailable action provided', (tester) async {
      var searchTapped = false;
      var includeTapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DiscoverLargeDatasetBanner(
              onSearchTap: () {
                searchTapped = true;
              },
              canIncludeUnavailable: true,
              onIncludeUnavailable: () {
                includeTapped = true;
              },
            ),
          ),
        ),
      );

      expect(find.textContaining('muchos libros compartidos'), findsOneWidget);
      expect(find.byIcon(Icons.search), findsOneWidget);
      expect(find.text('Buscar o filtrar'), findsOneWidget);
      expect(find.text('Ver no disponibles'), findsOneWidget);

      await tester.tap(find.text('Buscar o filtrar'));
      await tester.pump();
      expect(searchTapped, isTrue);

      await tester.tap(find.text('Ver no disponibles'));
      await tester.pump();
      expect(includeTapped, isTrue);
    });

    testWidgets('hides include unavailable button when action is null', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DiscoverLargeDatasetBanner(
              onSearchTap: () {},
              canIncludeUnavailable: false,
              onIncludeUnavailable: null,
            ),
          ),
        ),
      );

      expect(find.text('Buscar o filtrar'), findsOneWidget);
      expect(find.text('Ver no disponibles'), findsNothing);
    });
  });
}
