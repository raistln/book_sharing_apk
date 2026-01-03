import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/theme_persistence_service.dart';

export '../services/theme_persistence_service.dart';

final themePersistenceServiceProvider =
    Provider<ThemePersistenceService>((ref) {
  return ThemePersistenceService();
});

class ThemeSettingsNotifier extends StateNotifier<AsyncValue<ThemePreference>> {
  ThemeSettingsNotifier(this._service) : super(const AsyncValue.loading()) {
    _init();
  }

  final ThemePersistenceService _service;

  Future<void> _init() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _service.loadPreference());
  }

  Future<void> update(ThemePreference preference) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _service.savePreference(preference);
      return preference;
    });
  }
}

final themeSettingsProvider =
    StateNotifierProvider<ThemeSettingsNotifier, AsyncValue<ThemePreference>>(
        (ref) {
  final service = ref.watch(themePersistenceServiceProvider);
  return ThemeSettingsNotifier(service);
});

final themeModeProvider = Provider<ThemeMode>((ref) {
  final preferenceAsync = ref.watch(themeSettingsProvider);
  final preference = preferenceAsync.maybeWhen(
    data: (value) => value,
    orElse: () => ThemePreference.system,
  );

  switch (preference) {
    case ThemePreference.light:
      return ThemeMode.light;
    case ThemePreference.dark:
      return ThemeMode.dark;
    case ThemePreference.system:
      return ThemeMode.system;
  }
});

ThemeData _buildTheme({required Brightness brightness}) {
  final colorScheme = ColorScheme.fromSeed(
    seedColor: const Color(0xFF4A148C),
    brightness: brightness,
  );

  final baseTextTheme = ThemeData(brightness: brightness).textTheme;
  final serifTextTheme = baseTextTheme.copyWith(
    displayLarge: baseTextTheme.displayLarge?.copyWith(fontFamily: 'Georgia'),
    displayMedium: baseTextTheme.displayMedium?.copyWith(fontFamily: 'Georgia'),
    displaySmall: baseTextTheme.displaySmall?.copyWith(fontFamily: 'Georgia'),
    headlineLarge: baseTextTheme.headlineLarge?.copyWith(fontFamily: 'Georgia'),
    headlineMedium:
        baseTextTheme.headlineMedium?.copyWith(fontFamily: 'Georgia'),
    headlineSmall: baseTextTheme.headlineSmall?.copyWith(fontFamily: 'Georgia'),
    titleLarge: baseTextTheme.titleLarge?.copyWith(fontFamily: 'Georgia'),
    titleMedium: baseTextTheme.titleMedium?.copyWith(fontFamily: 'Georgia'),
    titleSmall: baseTextTheme.titleSmall?.copyWith(fontFamily: 'Georgia'),
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,
    brightness: brightness,
    textTheme: serifTextTheme,
    visualDensity: VisualDensity.adaptivePlatformDensity,
  );
}

final lightThemeProvider = Provider<ThemeData>((ref) {
  return _buildTheme(brightness: Brightness.light);
});

final darkThemeProvider = Provider<ThemeData>((ref) {
  return _buildTheme(brightness: Brightness.dark);
});
