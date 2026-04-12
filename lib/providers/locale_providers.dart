import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/locale_persistence_service.dart';

final localePersistenceServiceProvider = Provider<LocalePersistenceService>(
  (ref) => LocalePersistenceService(),
);

class LocaleSettingsNotifier
    extends StateNotifier<AsyncValue<AppLanguagePreference>> {
  LocaleSettingsNotifier(this._service) : super(const AsyncValue.loading()) {
    _init();
  }

  final LocalePersistenceService _service;

  Future<void> _init() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _service.loadPreference());
  }

  Future<void> update(AppLanguagePreference preference) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _service.savePreference(preference);
      return preference;
    });
  }
}

final localeSettingsProvider = StateNotifierProvider<LocaleSettingsNotifier,
    AsyncValue<AppLanguagePreference>>(
  (ref) {
    final service = ref.watch(localePersistenceServiceProvider);
    return LocaleSettingsNotifier(service);
  },
);

final appLocaleProvider = Provider<Locale?>((ref) {
  final preferenceAsync = ref.watch(localeSettingsProvider);
  final preference = preferenceAsync.maybeWhen(
    data: (value) => value,
    orElse: () => AppLanguagePreference.system,
  );
  return localeFromPreference(preference);
});
