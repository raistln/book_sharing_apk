import 'package:flutter/widgets.dart';

abstract class AppLocalizations {
  const AppLocalizations();

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static const supportedLocales = <Locale>[
    Locale('es'),
    Locale('en'),
  ];

  static AppLocalizations of(BuildContext context) {
    final localization = Localizations.of<AppLocalizations>(
      context,
      AppLocalizations,
    );
    if (localization == null) {
      return const AppLocalizationsEs();
    }
    return localization;
  }

  String get appTitle;
  String get retry;
  String get settingsAppearance;
  String get settingsLanguageTitle;
  String get settingsLanguageDescription;
  String get settingsLanguageLoadError;
  String get themePreferenceLoadError;
  String get themeSystem;
  String get themeLight;
  String get themeDark;
  String get languageSystem;
  String get languageSpanish;
  String get languageEnglish;
}

class AppLocalizationsEs extends AppLocalizations {
  const AppLocalizationsEs();

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

class AppLocalizationsEn extends AppLocalizations {
  const AppLocalizationsEn();

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

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) =>
      const ['es', 'en'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async {
    switch (locale.languageCode) {
      case 'en':
        return const AppLocalizationsEn();
      case 'es':
      default:
        return const AppLocalizationsEs();
    }
  }

  @override
  bool shouldReload(LocalizationsDelegate<AppLocalizations> old) => false;
}
