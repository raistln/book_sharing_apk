import 'package:book_sharing_app/providers/theme_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late ProviderContainer container;

  setUp(() {
    container = ProviderContainer();
  });

  tearDown(() {
    container.dispose();
  });

  group('themeModeProvider', () {
    test('returns ThemeMode.system by default', () {
      final themeMode = container.read(themeModeProvider);
      expect(themeMode, ThemeMode.system);
    });
  });

  group('lightThemeProvider', () {
    test('returns ThemeData with light brightness', () {
      final theme = container.read(lightThemeProvider);
      expect(theme.brightness, Brightness.light);
    });
  });

  group('darkThemeProvider', () {
    test('returns ThemeData with dark brightness', () {
      final theme = container.read(darkThemeProvider);
      expect(theme.brightness, Brightness.dark);
    });
  });
}
