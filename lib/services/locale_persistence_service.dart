import 'package:shared_preferences/shared_preferences.dart';

/// Preferencias de idioma que el usuario puede seleccionar.
enum LocalePreference { system, spanish, english }

/// Servicio para persistir la preferencia de idioma usando SharedPreferences.
class LocalePersistenceService {
  static const _key = 'locale_preference';

  Future<LocalePreference> loadPreference() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getInt(_key);
    if (stored == null) {
      return LocalePreference.system;
    }
    if (stored < 0 || stored >= LocalePreference.values.length) {
      return LocalePreference.system;
    }
    return LocalePreference.values[stored];
  }

  Future<void> savePreference(LocalePreference preference) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_key, preference.index);
  }
}
