// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Book Sharing App';

  @override
  String get retry => 'Retry';

  @override
  String get settingsAppearance => 'Appearance';

  @override
  String get settingsLanguageTitle => 'Language';

  @override
  String get settingsLanguageDescription =>
      'Choose the app language or use the system one.';

  @override
  String get settingsLanguageLoadError =>
      'We couldn\'t load the language preference.';

  @override
  String get themePreferenceLoadError =>
      'We couldn\'t load the theme preference.';

  @override
  String get themeSystem => 'Use system theme';

  @override
  String get themeLight => 'Light mode';

  @override
  String get themeDark => 'Dark mode';

  @override
  String get languageSystem => 'System';

  @override
  String get languageSpanish => 'Spanish';

  @override
  String get languageEnglish => 'English';
}
