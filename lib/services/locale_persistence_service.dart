import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppLanguagePreference { system, spanish, english }

class LocalePersistenceService {
  static const _key = 'app_language_preference';

  Future<AppLanguagePreference> loadPreference() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getInt(_key);
    if (stored == null) {
      return AppLanguagePreference.system;
    }
    if (stored < 0 || stored >= AppLanguagePreference.values.length) {
      return AppLanguagePreference.system;
    }
    return AppLanguagePreference.values[stored];
  }

  Future<void> savePreference(AppLanguagePreference preference) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_key, preference.index);
  }
}

Locale? localeFromPreference(AppLanguagePreference preference) {
  switch (preference) {
    case AppLanguagePreference.system:
      return null;
    case AppLanguagePreference.spanish:
      return const Locale('es');
    case AppLanguagePreference.english:
      return const Locale('en');
  }
}
