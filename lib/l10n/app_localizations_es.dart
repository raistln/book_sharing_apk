// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'Book Sharing App';

  @override
  String get retry => 'Reintentar';

  @override
  String get settingsAppearance => 'Apariencia';

  @override
  String get settingsLanguageTitle => 'Idioma';

  @override
  String get settingsLanguageDescription =>
      'Elige el idioma de la app o usa el del sistema.';

  @override
  String get settingsLanguageLoadError =>
      'No pudimos cargar la preferencia de idioma.';

  @override
  String get themePreferenceLoadError =>
      'No pudimos cargar la preferencia de tema.';

  @override
  String get themeSystem => 'Usar tema del sistema';

  @override
  String get themeLight => 'Modo claro';

  @override
  String get themeDark => 'Modo oscuro';

  @override
  String get languageSystem => 'Sistema';

  @override
  String get languageSpanish => 'Español';

  @override
  String get languageEnglish => 'English';
}
