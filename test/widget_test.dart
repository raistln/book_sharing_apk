// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:book_sharing_app/app.dart';
import 'package:book_sharing_app/ui/screens/splash_screen.dart';

void main() {
  testWidgets('BookSharingApp muestra la pantalla de splash inicial',
      (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: BookSharingApp()));

    // El primer frame debe mostrar la pantalla de splash.
    expect(find.byType(SplashScreen), findsOneWidget);

    // Verificamos que el MaterialApp configure el tema y navegación básica.
    final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(materialApp.debugShowCheckedModeBanner, isFalse);
  });
}
