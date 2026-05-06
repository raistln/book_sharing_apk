import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/locale_persistence_service.dart';

export '../services/locale_persistence_service.dart';

final localePersistenceServiceProvider =
    Provider<LocalePersistenceService>((ref) {
  return LocalePersistenceService();
});

class LocaleSettingsNotifier extends StateNotifier<AsyncValue<LocalePreference>> {
  LocaleSettingsNotifier(this._service) : super(const AsyncValue.loading()) {
    _init();
  }

  final LocalePersistenceService _service;

  Future<void> _init() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _service.loadPreference());
  }

  Future<void> update(LocalePreference preference) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _service.savePreference(preference);
      return preference;
    });
  }
}

final localeSettingsProvider =
    StateNotifierProvider<LocaleSettingsNotifier, AsyncValue<LocalePreference>>(
        (ref) {
  final service = ref.watch(localePersistenceServiceProvider);
  return LocaleSettingsNotifier(service);
});

/// Provides the active [Locale] based on user preference.
/// Returns null when the preference is 'system', allowing Flutter to use
/// the platform locale. Falls back to English if system locale is not supported.
final appLocaleProvider = Provider<Locale?>((ref) {
  final preferenceAsync = ref.watch(localeSettingsProvider);
  final preference = preferenceAsync.maybeWhen(
    data: (value) => value,
    orElse: () => LocalePreference.system,
  );

  switch (preference) {
    case LocalePreference.spanish:
      return const Locale('es');
    case LocalePreference.english:
      return const Locale('en');
    case LocalePreference.system:
      return null; // Let Flutter resolve from platform locale
  }
});
