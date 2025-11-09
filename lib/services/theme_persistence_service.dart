import 'package:shared_preferences/shared_preferences.dart';

/// Preferencias de tema que el usuario puede seleccionar.
enum ThemePreference { system, light, dark }

/// Servicio simple para persistir la preferencia de tema usando SharedPreferences.
class ThemePersistenceService {
  static const _key = 'theme_preference';

  Future<ThemePreference> loadPreference() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getInt(_key);
    if (stored == null) {
      return ThemePreference.system;
    }
    if (stored < 0 || stored >= ThemePreference.values.length) {
      return ThemePreference.system;
    }
    return ThemePreference.values[stored];
  }

  Future<void> savePreference(ThemePreference preference) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_key, preference.index);
  }
}
