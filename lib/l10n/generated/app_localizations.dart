import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of S
/// returned by `S.of(context)`.
///
/// Applications need to include `S.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: S.localizationsDelegates,
///   supportedLocales: S.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the S.supportedLocales
/// property.
abstract class S {
  S(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static S of(BuildContext context) {
    return Localizations.of<S>(context, S)!;
  }

  static const LocalizationsDelegate<S> delegate = _SDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es')
  ];

  /// No description provided for @appTitle.
  ///
  /// In es, this message translates to:
  /// **'PassTheBook'**
  String get appTitle;

  /// No description provided for @tabReading.
  ///
  /// In es, this message translates to:
  /// **'Leyendo'**
  String get tabReading;

  /// No description provided for @tabLibrary.
  ///
  /// In es, this message translates to:
  /// **'Biblioteca'**
  String get tabLibrary;

  /// No description provided for @tabLoans.
  ///
  /// In es, this message translates to:
  /// **'Préstamos'**
  String get tabLoans;

  /// No description provided for @tabGroups.
  ///
  /// In es, this message translates to:
  /// **'Grupos'**
  String get tabGroups;

  /// No description provided for @tooltipBulletin.
  ///
  /// In es, this message translates to:
  /// **'Boletín Literario'**
  String get tooltipBulletin;

  /// No description provided for @tooltipBookshelf.
  ///
  /// In es, this message translates to:
  /// **'Estantería Virtual'**
  String get tooltipBookshelf;

  /// No description provided for @tooltipNotifications.
  ///
  /// In es, this message translates to:
  /// **'Notificaciones'**
  String get tooltipNotifications;

  /// No description provided for @tooltipProfile.
  ///
  /// In es, this message translates to:
  /// **'Perfil'**
  String get tooltipProfile;

  /// No description provided for @tooltipSettings.
  ///
  /// In es, this message translates to:
  /// **'Ajustes'**
  String get tooltipSettings;

  /// No description provided for @tooltipEdit.
  ///
  /// In es, this message translates to:
  /// **'Editar'**
  String get tooltipEdit;

  /// No description provided for @tooltipSave.
  ///
  /// In es, this message translates to:
  /// **'Guardar'**
  String get tooltipSave;

  /// No description provided for @tooltipLoanHistory.
  ///
  /// In es, this message translates to:
  /// **'Historial de préstamos'**
  String get tooltipLoanHistory;

  /// No description provided for @tooltipSortBooks.
  ///
  /// In es, this message translates to:
  /// **'Ordenar libros'**
  String get tooltipSortBooks;

  /// No description provided for @tooltipViewList.
  ///
  /// In es, this message translates to:
  /// **'Ver lista'**
  String get tooltipViewList;

  /// No description provided for @tooltipViewGrid.
  ///
  /// In es, this message translates to:
  /// **'Ver cuadrícula'**
  String get tooltipViewGrid;

  /// No description provided for @tooltipRefreshCovers.
  ///
  /// In es, this message translates to:
  /// **'Actualizar portadas'**
  String get tooltipRefreshCovers;

  /// No description provided for @tooltipExportLibrary.
  ///
  /// In es, this message translates to:
  /// **'Exportar biblioteca'**
  String get tooltipExportLibrary;

  /// No description provided for @tooltipRead.
  ///
  /// In es, this message translates to:
  /// **'Leído'**
  String get tooltipRead;

  /// No description provided for @addBook.
  ///
  /// In es, this message translates to:
  /// **'Añadir libro'**
  String get addBook;

  /// No description provided for @debugResetPin.
  ///
  /// In es, this message translates to:
  /// **'Debug: reset PIN'**
  String get debugResetPin;

  /// No description provided for @snackBookAdded.
  ///
  /// In es, this message translates to:
  /// **'Libro añadido a tu biblioteca.'**
  String get snackBookAdded;

  /// No description provided for @snackBookUpdated.
  ///
  /// In es, this message translates to:
  /// **'Libro actualizado correctamente.'**
  String get snackBookUpdated;

  /// No description provided for @snackBookDeleted.
  ///
  /// In es, this message translates to:
  /// **'Libro eliminado.'**
  String get snackBookDeleted;

  /// No description provided for @snackPinCleared.
  ///
  /// In es, this message translates to:
  /// **'PIN borrado (solo debug).'**
  String get snackPinCleared;

  /// No description provided for @residenceRequired.
  ///
  /// In es, this message translates to:
  /// **'Lugar de residencia necesario'**
  String get residenceRequired;

  /// No description provided for @residenceRequiredMessage.
  ///
  /// In es, this message translates to:
  /// **'Para recibir boletines literarios de tu zona, por favor rellena tu lugar de residencia en tu perfil.'**
  String get residenceRequiredMessage;

  /// No description provided for @notNow.
  ///
  /// In es, this message translates to:
  /// **'Ahora no'**
  String get notNow;

  /// No description provided for @goToProfile.
  ///
  /// In es, this message translates to:
  /// **'Ir al Perfil'**
  String get goToProfile;

  /// No description provided for @noBulletinPlaceholder.
  ///
  /// In es, this message translates to:
  /// **'No se han registrado eventos literarios destacados en la provincia de {province} para este mes. ¡Suscríbete a nuestras notificaciones para enterarte de las novedades!'**
  String noBulletinPlaceholder(String province);

  /// No description provided for @errorLoadingBulletin.
  ///
  /// In es, this message translates to:
  /// **'Error al cargar el boletín: {error}'**
  String errorLoadingBulletin(String error);

  /// No description provided for @readingHeader.
  ///
  /// In es, this message translates to:
  /// **'Leyendo'**
  String get readingHeader;

  /// No description provided for @activityHeader.
  ///
  /// In es, this message translates to:
  /// **'Actividad'**
  String get activityHeader;

  /// No description provided for @chartRhythm.
  ///
  /// In es, this message translates to:
  /// **'Ritmo'**
  String get chartRhythm;

  /// No description provided for @chartCalendar.
  ///
  /// In es, this message translates to:
  /// **'Calendario'**
  String get chartCalendar;

  /// No description provided for @noActiveReading.
  ///
  /// In es, this message translates to:
  /// **'Sin lecturas activas'**
  String get noActiveReading;

  /// No description provided for @goToLibrary.
  ///
  /// In es, this message translates to:
  /// **'Ve a tu biblioteca para empezar'**
  String get goToLibrary;

  /// No description provided for @statusPaused.
  ///
  /// In es, this message translates to:
  /// **'Pausado'**
  String get statusPaused;

  /// No description provided for @readingNow.
  ///
  /// In es, this message translates to:
  /// **'Leyendo ahora'**
  String get readingNow;

  /// No description provided for @libraryHeader.
  ///
  /// In es, this message translates to:
  /// **'Biblioteca'**
  String get libraryHeader;

  /// No description provided for @tabMyBooks.
  ///
  /// In es, this message translates to:
  /// **'Mis libros'**
  String get tabMyBooks;

  /// No description provided for @tabBorrowedBooks.
  ///
  /// In es, this message translates to:
  /// **'Me prestaron'**
  String get tabBorrowedBooks;

  /// No description provided for @emptyMyBooksMessage.
  ///
  /// In es, this message translates to:
  /// **'Añade tus libros para gestionarlos aquí.'**
  String get emptyMyBooksMessage;

  /// No description provided for @emptyBorrowedBooksMessage.
  ///
  /// In es, this message translates to:
  /// **'Aquí aparecerán los libros que te presten amigos, ya sea por la app o fuera de ella.'**
  String get emptyBorrowedBooksMessage;

  /// No description provided for @noFilterResults.
  ///
  /// In es, this message translates to:
  /// **'No hay coincidencias con los filtros.'**
  String get noFilterResults;

  /// No description provided for @sortTitleAZ.
  ///
  /// In es, this message translates to:
  /// **'Título (A-Z)'**
  String get sortTitleAZ;

  /// No description provided for @sortTitleZA.
  ///
  /// In es, this message translates to:
  /// **'Título (Z-A)'**
  String get sortTitleZA;

  /// No description provided for @sortAuthorAZ.
  ///
  /// In es, this message translates to:
  /// **'Autor (A-Z)'**
  String get sortAuthorAZ;

  /// No description provided for @sortAuthorZA.
  ///
  /// In es, this message translates to:
  /// **'Autor (Z-A)'**
  String get sortAuthorZA;

  /// No description provided for @sortNewest.
  ///
  /// In es, this message translates to:
  /// **'Más recientes'**
  String get sortNewest;

  /// No description provided for @sortOldest.
  ///
  /// In es, this message translates to:
  /// **'Más antiguos'**
  String get sortOldest;

  /// No description provided for @genreFilter.
  ///
  /// In es, this message translates to:
  /// **'Género'**
  String get genreFilter;

  /// No description provided for @allGenres.
  ///
  /// In es, this message translates to:
  /// **'Todos los géneros'**
  String get allGenres;

  /// No description provided for @loansHeader.
  ///
  /// In es, this message translates to:
  /// **'Préstamos'**
  String get loansHeader;

  /// No description provided for @loan.
  ///
  /// In es, this message translates to:
  /// **'préstamo'**
  String get loan;

  /// No description provided for @loans.
  ///
  /// In es, this message translates to:
  /// **'préstamos'**
  String get loans;

  /// No description provided for @requests.
  ///
  /// In es, this message translates to:
  /// **'solicitudes'**
  String get requests;

  /// No description provided for @incomingRequests.
  ///
  /// In es, this message translates to:
  /// **'Solicitudes Recibidas ({count})'**
  String incomingRequests(int count);

  /// No description provided for @outgoingRequests.
  ///
  /// In es, this message translates to:
  /// **'Solicitudes Enviadas ({count})'**
  String outgoingRequests(int count);

  /// No description provided for @lentByYou.
  ///
  /// In es, this message translates to:
  /// **'Prestados por ti'**
  String get lentByYou;

  /// No description provided for @borrowedFromOthers.
  ///
  /// In es, this message translates to:
  /// **'Te prestaron'**
  String get borrowedFromOthers;

  /// No description provided for @recentLoans.
  ///
  /// In es, this message translates to:
  /// **'Recientes'**
  String get recentLoans;

  /// No description provided for @manualLoan.
  ///
  /// In es, this message translates to:
  /// **'Préstamo Manual'**
  String get manualLoan;

  /// No description provided for @loanRequestedBy.
  ///
  /// In es, this message translates to:
  /// **'Solicitado por {name}'**
  String loanRequestedBy(String name);

  /// No description provided for @lentByWithName.
  ///
  /// In es, this message translates to:
  /// **'De {name}'**
  String lentByWithName(String name);

  /// No description provided for @loanRequestedTo.
  ///
  /// In es, this message translates to:
  /// **'Solicitado a {name}'**
  String loanRequestedTo(String name);

  /// No description provided for @reject.
  ///
  /// In es, this message translates to:
  /// **'Rechazar'**
  String get reject;

  /// No description provided for @accept.
  ///
  /// In es, this message translates to:
  /// **'Aceptar'**
  String get accept;

  /// No description provided for @cancelRequest.
  ///
  /// In es, this message translates to:
  /// **'Cancelar solicitud'**
  String get cancelRequest;

  /// No description provided for @acceptLoanTitle.
  ///
  /// In es, this message translates to:
  /// **'Aceptar Préstamo'**
  String get acceptLoanTitle;

  /// No description provided for @selectDueDate.
  ///
  /// In es, this message translates to:
  /// **'Selecciona una fecha de vencimiento:'**
  String get selectDueDate;

  /// No description provided for @indefinite.
  ///
  /// In es, this message translates to:
  /// **'Indefinido'**
  String get indefinite;

  /// No description provided for @cancel.
  ///
  /// In es, this message translates to:
  /// **'Cancelar'**
  String get cancel;

  /// No description provided for @confirm.
  ///
  /// In es, this message translates to:
  /// **'Confirmar'**
  String get confirm;

  /// No description provided for @youLent.
  ///
  /// In es, this message translates to:
  /// **'Prestaste'**
  String get youLent;

  /// No description provided for @theyLentYou.
  ///
  /// In es, this message translates to:
  /// **'Te prestaron'**
  String get theyLentYou;

  /// No description provided for @bookFallback.
  ///
  /// In es, this message translates to:
  /// **'Libro'**
  String get bookFallback;

  /// No description provided for @someoneFallback.
  ///
  /// In es, this message translates to:
  /// **'Alguien'**
  String get someoneFallback;

  /// No description provided for @ownerFallback.
  ///
  /// In es, this message translates to:
  /// **'Propietario'**
  String get ownerFallback;

  /// No description provided for @book.
  ///
  /// In es, this message translates to:
  /// **'libro'**
  String get book;

  /// No description provided for @booksCount.
  ///
  /// In es, this message translates to:
  /// **'{count, plural, =1{1 libro} other{{count} libros}}'**
  String booksCount(num count);

  /// No description provided for @fromLabel.
  ///
  /// In es, this message translates to:
  /// **'De:'**
  String get fromLabel;

  /// No description provided for @toLabel.
  ///
  /// In es, this message translates to:
  /// **'A:'**
  String get toLabel;

  /// No description provided for @lendBookManually.
  ///
  /// In es, this message translates to:
  /// **'Prestar libro manualmente'**
  String get lendBookManually;

  /// No description provided for @lendBookManuallyDesc.
  ///
  /// In es, this message translates to:
  /// **'Registra un préstamo de tu biblioteca a alguien sin la app'**
  String get lendBookManuallyDesc;

  /// No description provided for @registerReceivedBook.
  ///
  /// In es, this message translates to:
  /// **'Registrar libro recibido'**
  String get registerReceivedBook;

  /// No description provided for @registerReceivedBookDesc.
  ///
  /// In es, this message translates to:
  /// **'Registra un libro que alguien te prestó'**
  String get registerReceivedBookDesc;

  /// No description provided for @loanStatusRequested.
  ///
  /// In es, this message translates to:
  /// **'Solicitado'**
  String get loanStatusRequested;

  /// No description provided for @loanStatusActive.
  ///
  /// In es, this message translates to:
  /// **'En curso'**
  String get loanStatusActive;

  /// No description provided for @loanStatusReturned.
  ///
  /// In es, this message translates to:
  /// **'Devuelto'**
  String get loanStatusReturned;

  /// No description provided for @loanStatusCancelled.
  ///
  /// In es, this message translates to:
  /// **'Cancelado'**
  String get loanStatusCancelled;

  /// No description provided for @loanStatusRejected.
  ///
  /// In es, this message translates to:
  /// **'Rechazado'**
  String get loanStatusRejected;

  /// No description provided for @loanStatusCompleted.
  ///
  /// In es, this message translates to:
  /// **'Completado'**
  String get loanStatusCompleted;

  /// No description provided for @loanStatusExpired.
  ///
  /// In es, this message translates to:
  /// **'Expirado'**
  String get loanStatusExpired;

  /// No description provided for @profileTitle.
  ///
  /// In es, this message translates to:
  /// **'Perfil'**
  String get profileTitle;

  /// No description provided for @profileEditTitle.
  ///
  /// In es, this message translates to:
  /// **'Editar Perfil'**
  String get profileEditTitle;

  /// No description provided for @statsBooks.
  ///
  /// In es, this message translates to:
  /// **'Libros'**
  String get statsBooks;

  /// No description provided for @statsRead.
  ///
  /// In es, this message translates to:
  /// **'Leídos'**
  String get statsRead;

  /// No description provided for @statsReading.
  ///
  /// In es, this message translates to:
  /// **'Leyendo'**
  String get statsReading;

  /// No description provided for @aboutMe.
  ///
  /// In es, this message translates to:
  /// **'Sobre mí'**
  String get aboutMe;

  /// No description provided for @favoriteBook.
  ///
  /// In es, this message translates to:
  /// **'Libro favorito'**
  String get favoriteBook;

  /// No description provided for @favoriteGenre.
  ///
  /// In es, this message translates to:
  /// **'Género favorito'**
  String get favoriteGenre;

  /// No description provided for @locationLabel.
  ///
  /// In es, this message translates to:
  /// **'Ubicación'**
  String get locationLabel;

  /// No description provided for @contactLabel.
  ///
  /// In es, this message translates to:
  /// **'Contacto'**
  String get contactLabel;

  /// No description provided for @biographyHeader.
  ///
  /// In es, this message translates to:
  /// **'Biografía'**
  String get biographyHeader;

  /// No description provided for @quickAccess.
  ///
  /// In es, this message translates to:
  /// **'Accesos rápidos'**
  String get quickAccess;

  /// No description provided for @myReadBooks.
  ///
  /// In es, this message translates to:
  /// **'Mis libros leídos'**
  String get myReadBooks;

  /// No description provided for @wishlist.
  ///
  /// In es, this message translates to:
  /// **'Lista de deseos'**
  String get wishlist;

  /// No description provided for @notSpecified.
  ///
  /// In es, this message translates to:
  /// **'No especificado'**
  String get notSpecified;

  /// No description provided for @nameFromRegistration.
  ///
  /// In es, this message translates to:
  /// **'Nombre (desde registro)'**
  String get nameFromRegistration;

  /// No description provided for @emailLabel.
  ///
  /// In es, this message translates to:
  /// **'Correo'**
  String get emailLabel;

  /// No description provided for @residenceLabel.
  ///
  /// In es, this message translates to:
  /// **'Lugar de residencia (Provincia)'**
  String get residenceLabel;

  /// No description provided for @favoriteBookLabel.
  ///
  /// In es, this message translates to:
  /// **'Libro favorito'**
  String get favoriteBookLabel;

  /// No description provided for @favoriteGenreLabel.
  ///
  /// In es, this message translates to:
  /// **'Género favorito'**
  String get favoriteGenreLabel;

  /// No description provided for @biographyNotesLabel.
  ///
  /// In es, this message translates to:
  /// **'Biografía / Notas'**
  String get biographyNotesLabel;

  /// No description provided for @selectValidProvince.
  ///
  /// In es, this message translates to:
  /// **'Seleccione una provincia válida de la lista'**
  String get selectValidProvince;

  /// No description provided for @settingsLibrary.
  ///
  /// In es, this message translates to:
  /// **'Biblioteca'**
  String get settingsLibrary;

  /// No description provided for @settingsLibraryDesc.
  ///
  /// In es, this message translates to:
  /// **'Importa o exporta tu biblioteca de libros.'**
  String get settingsLibraryDesc;

  /// No description provided for @exportLibrary.
  ///
  /// In es, this message translates to:
  /// **'Exportar biblioteca'**
  String get exportLibrary;

  /// No description provided for @exportLibraryDesc.
  ///
  /// In es, this message translates to:
  /// **'Guarda tu lista de libros en CSV, JSON o PDF'**
  String get exportLibraryDesc;

  /// No description provided for @exportLoanHistory.
  ///
  /// In es, this message translates to:
  /// **'Exportar historial de préstamos'**
  String get exportLoanHistory;

  /// No description provided for @exportLoanHistoryDesc.
  ///
  /// In es, this message translates to:
  /// **'Genera un informe de tus préstamos (CSV)'**
  String get exportLoanHistoryDesc;

  /// No description provided for @importBooks.
  ///
  /// In es, this message translates to:
  /// **'Importar libros'**
  String get importBooks;

  /// No description provided for @importBooksDesc.
  ///
  /// In es, this message translates to:
  /// **'Importa libros desde un archivo CSV o JSON'**
  String get importBooksDesc;

  /// No description provided for @settingsStorage.
  ///
  /// In es, this message translates to:
  /// **'Almacenamiento'**
  String get settingsStorage;

  /// No description provided for @deleteAllCovers.
  ///
  /// In es, this message translates to:
  /// **'Borrar todas las portadas'**
  String get deleteAllCovers;

  /// No description provided for @deleteAllCoversDesc.
  ///
  /// In es, this message translates to:
  /// **'Libera espacio eliminando las imágenes descargadas.'**
  String get deleteAllCoversDesc;

  /// No description provided for @resetLocalDatabase.
  ///
  /// In es, this message translates to:
  /// **'Resetear base de datos local'**
  String get resetLocalDatabase;

  /// No description provided for @resetLocalDatabaseDesc.
  ///
  /// In es, this message translates to:
  /// **'Elimina todos los datos locales y comienza desde cero.'**
  String get resetLocalDatabaseDesc;

  /// No description provided for @settingsBackup.
  ///
  /// In es, this message translates to:
  /// **'Copias de seguridad'**
  String get settingsBackup;

  /// No description provided for @settingsSecurity.
  ///
  /// In es, this message translates to:
  /// **'Ajustes de seguridad'**
  String get settingsSecurity;

  /// No description provided for @settingsSecurityDesc.
  ///
  /// In es, this message translates to:
  /// **'Gestiona tu PIN y controla el bloqueo automático por inactividad.'**
  String get settingsSecurityDesc;

  /// No description provided for @changePin.
  ///
  /// In es, this message translates to:
  /// **'Cambiar PIN'**
  String get changePin;

  /// No description provided for @changePinDesc.
  ///
  /// In es, this message translates to:
  /// **'Vuelve a definir el código de acceso.'**
  String get changePinDesc;

  /// No description provided for @deletePinAndSwitchUser.
  ///
  /// In es, this message translates to:
  /// **'Eliminar PIN y cambiar de usuario'**
  String get deletePinAndSwitchUser;

  /// No description provided for @deletePinAndSwitchUserDesc.
  ///
  /// In es, this message translates to:
  /// **'Vuelve al inicio para configurar otra cuenta.'**
  String get deletePinAndSwitchUserDesc;

  /// No description provided for @deletePinConfirmTitle.
  ///
  /// In es, this message translates to:
  /// **'¿Eliminar PIN y salir de la cuenta?'**
  String get deletePinConfirmTitle;

  /// No description provided for @deletePinConfirmMessage.
  ///
  /// In es, this message translates to:
  /// **'Se eliminarán TODOS los datos locales (libros, grupos, préstamos) y tendrás que iniciar sesión o configurar un nuevo usuario.'**
  String get deletePinConfirmMessage;

  /// No description provided for @deletePinTip.
  ///
  /// In es, this message translates to:
  /// **'💡 Tip: Exporta tu biblioteca antes de continuar. Si tienes backups automáticos, búscalos en Descargas/BookSharing/backups.'**
  String get deletePinTip;

  /// No description provided for @deleteAll.
  ///
  /// In es, this message translates to:
  /// **'Eliminar todo'**
  String get deleteAll;

  /// No description provided for @dataDeleted.
  ///
  /// In es, this message translates to:
  /// **'Datos eliminados. Reinicia la app para configurar un nuevo usuario.'**
  String get dataDeleted;

  /// No description provided for @settingsAppearance.
  ///
  /// In es, this message translates to:
  /// **'Apariencia'**
  String get settingsAppearance;

  /// No description provided for @settingsLanguage.
  ///
  /// In es, this message translates to:
  /// **'Idioma'**
  String get settingsLanguage;

  /// No description provided for @settingsLanguageDesc.
  ///
  /// In es, this message translates to:
  /// **'Selecciona en qué idioma se muestra la app.'**
  String get settingsLanguageDesc;

  /// No description provided for @languageSystem.
  ///
  /// In es, this message translates to:
  /// **'Sistema'**
  String get languageSystem;

  /// No description provided for @languageSpanish.
  ///
  /// In es, this message translates to:
  /// **'Español'**
  String get languageSpanish;

  /// No description provided for @languageEnglish.
  ///
  /// In es, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @settingsExternalIntegrations.
  ///
  /// In es, this message translates to:
  /// **'Integraciones externas'**
  String get settingsExternalIntegrations;

  /// No description provided for @settingsMoreComingSoon.
  ///
  /// In es, this message translates to:
  /// **'Más configuraciones próximamente'**
  String get settingsMoreComingSoon;

  /// No description provided for @settingsMoreComingSoonDesc.
  ///
  /// In es, this message translates to:
  /// **'Pronto podrás gestionar copias de seguridad, sincronización y preferencias.'**
  String get settingsMoreComingSoonDesc;

  /// No description provided for @settingsOpenLibraryCredit.
  ///
  /// In es, this message translates to:
  /// **'Datos bibliográficos proporcionados por Open Library (Internet Archive). Contenido bajo licencia ODC-By.'**
  String get settingsOpenLibraryCredit;

  /// No description provided for @donationTitle.
  ///
  /// In es, this message translates to:
  /// **'Invítame a un café'**
  String get donationTitle;

  /// No description provided for @donationMessage.
  ///
  /// In es, this message translates to:
  /// **'Si esta app te resulta útil, puedes apoyar su desarrollo con una donación.'**
  String get donationMessage;

  /// No description provided for @donationButton.
  ///
  /// In es, this message translates to:
  /// **'Invítame a un café'**
  String get donationButton;

  /// No description provided for @donationLinkInvalid.
  ///
  /// In es, this message translates to:
  /// **'El enlace de donación no es válido.'**
  String get donationLinkInvalid;

  /// No description provided for @donationLinkError.
  ///
  /// In es, this message translates to:
  /// **'No se pudo abrir el enlace de donación.'**
  String get donationLinkError;

  /// No description provided for @donationLinkOpenError.
  ///
  /// In es, this message translates to:
  /// **'Error al abrir el enlace: {error}'**
  String donationLinkOpenError(String error);

  /// No description provided for @syncStatus.
  ///
  /// In es, this message translates to:
  /// **'Estado de sincronización'**
  String get syncStatus;

  /// No description provided for @syncingWithSupabase.
  ///
  /// In es, this message translates to:
  /// **'Sincronizando con Supabase...'**
  String get syncingWithSupabase;

  /// No description provided for @lastSync.
  ///
  /// In es, this message translates to:
  /// **'Última sincronización: {date}'**
  String lastSync(String date);

  /// No description provided for @notSyncedYet.
  ///
  /// In es, this message translates to:
  /// **'Aún no se ha sincronizado con Supabase.'**
  String get notSyncedYet;

  /// No description provided for @syncErrorRecent.
  ///
  /// In es, this message translates to:
  /// **'Se encontraron errores recientemente'**
  String get syncErrorRecent;

  /// No description provided for @syncLastError.
  ///
  /// In es, this message translates to:
  /// **'Último error de sincronización'**
  String get syncLastError;

  /// No description provided for @pendingChanges.
  ///
  /// In es, this message translates to:
  /// **'Hay cambios pendientes por sincronizar.'**
  String get pendingChanges;

  /// No description provided for @manualSync.
  ///
  /// In es, this message translates to:
  /// **'Sincronización manual'**
  String get manualSync;

  /// No description provided for @manualSyncDesc.
  ///
  /// In es, this message translates to:
  /// **'Fuerza la subida y bajada de libros, préstamos y clubes con Supabase. Normalmente esto ocurre de forma automática en segundo plano.'**
  String get manualSyncDesc;

  /// No description provided for @syncing.
  ///
  /// In es, this message translates to:
  /// **'Sincronizando...'**
  String get syncing;

  /// No description provided for @syncNow.
  ///
  /// In es, this message translates to:
  /// **'Sincronizar ahora'**
  String get syncNow;

  /// No description provided for @syncComplete.
  ///
  /// In es, this message translates to:
  /// **'Sincronización completada.'**
  String get syncComplete;

  /// No description provided for @syncError.
  ///
  /// In es, this message translates to:
  /// **'Error de sincronización: {error}'**
  String syncError(String error);

  /// No description provided for @resetDatabaseTitle.
  ///
  /// In es, this message translates to:
  /// **'⚠️ Resetear base de datos local'**
  String get resetDatabaseTitle;

  /// No description provided for @resetDatabaseWarning.
  ///
  /// In es, this message translates to:
  /// **'Esto eliminará TODOS los datos locales:'**
  String get resetDatabaseWarning;

  /// No description provided for @resetDatabaseItem1.
  ///
  /// In es, this message translates to:
  /// **'• Libros registrados'**
  String get resetDatabaseItem1;

  /// No description provided for @resetDatabaseItem2.
  ///
  /// In es, this message translates to:
  /// **'• Grupos y membresías'**
  String get resetDatabaseItem2;

  /// No description provided for @resetDatabaseItem3.
  ///
  /// In es, this message translates to:
  /// **'• Préstamos y notificaciones'**
  String get resetDatabaseItem3;

  /// No description provided for @resetDatabaseItem4.
  ///
  /// In es, this message translates to:
  /// **'• Configuración local'**
  String get resetDatabaseItem4;

  /// No description provided for @resetDatabaseCloudNote.
  ///
  /// In es, this message translates to:
  /// **'Los datos en la nube (Supabase) NO se eliminarán.'**
  String get resetDatabaseCloudNote;

  /// No description provided for @resetDatabaseRestartNote.
  ///
  /// In es, this message translates to:
  /// **'Después de resetear, la app se reiniciará automáticamente.'**
  String get resetDatabaseRestartNote;

  /// No description provided for @resetAll.
  ///
  /// In es, this message translates to:
  /// **'Resetear todo'**
  String get resetAll;

  /// No description provided for @resettingDatabase.
  ///
  /// In es, this message translates to:
  /// **'Reseteando base de datos...'**
  String get resettingDatabase;

  /// No description provided for @databaseResetSuccess.
  ///
  /// In es, this message translates to:
  /// **'Base de datos reseteada. Reiniciando app...'**
  String get databaseResetSuccess;

  /// No description provided for @databaseResetError.
  ///
  /// In es, this message translates to:
  /// **'Error al resetear la base de datos: {error}'**
  String databaseResetError(String error);

  /// No description provided for @deleteCoversConfirmTitle.
  ///
  /// In es, this message translates to:
  /// **'¿Borrar todas las portadas?'**
  String get deleteCoversConfirmTitle;

  /// No description provided for @deleteCoversConfirmMessage.
  ///
  /// In es, this message translates to:
  /// **'Se eliminarán todas las imágenes de portada descargadas. Podrás volver a descargarlas manualmente desde la biblioteca.'**
  String get deleteCoversConfirmMessage;

  /// No description provided for @delete.
  ///
  /// In es, this message translates to:
  /// **'Eliminar'**
  String get delete;

  /// No description provided for @coversDeleted.
  ///
  /// In es, this message translates to:
  /// **'Se eliminaron {count} portadas.'**
  String coversDeleted(int count);

  /// No description provided for @coversDeleteError.
  ///
  /// In es, this message translates to:
  /// **'Error al borrar portadas: {error}'**
  String coversDeleteError(String error);

  /// No description provided for @googleBooksApi.
  ///
  /// In es, this message translates to:
  /// **'Google Books API'**
  String get googleBooksApi;

  /// No description provided for @googleBooksApiConfigured.
  ///
  /// In es, this message translates to:
  /// **'API key configurada. Puedes buscar libros en Google Books.'**
  String get googleBooksApiConfigured;

  /// No description provided for @googleBooksApiNotConfigured.
  ///
  /// In es, this message translates to:
  /// **'Configura una API key para buscar libros en Google Books.'**
  String get googleBooksApiNotConfigured;

  /// No description provided for @changeApiKey.
  ///
  /// In es, this message translates to:
  /// **'Cambiar API key'**
  String get changeApiKey;

  /// No description provided for @configureApiKey.
  ///
  /// In es, this message translates to:
  /// **'Configurar API key'**
  String get configureApiKey;

  /// No description provided for @removeLabel.
  ///
  /// In es, this message translates to:
  /// **'Eliminar'**
  String get removeLabel;

  /// No description provided for @howToGetApiKey.
  ///
  /// In es, this message translates to:
  /// **'¿Cómo obtener una API key?'**
  String get howToGetApiKey;

  /// No description provided for @apiKeyInstructions.
  ///
  /// In es, this message translates to:
  /// **'1. Ve a Google Cloud Console\n2. Crea un nuevo proyecto o selecciona uno existente\n3. Habilita la \"Books API\"\n4. Crea credenciales tipo \"API key\"\n5. Copia la clave y pégala aquí'**
  String get apiKeyInstructions;

  /// No description provided for @configureGoogleBooksApiKey.
  ///
  /// In es, this message translates to:
  /// **'Configurar API key de Google Books'**
  String get configureGoogleBooksApiKey;

  /// No description provided for @apiKeyInputHint.
  ///
  /// In es, this message translates to:
  /// **'Introduce tu API key de Google Books para poder buscar libros.'**
  String get apiKeyInputHint;

  /// No description provided for @apiKeySaved.
  ///
  /// In es, this message translates to:
  /// **'API key guardada correctamente.'**
  String get apiKeySaved;

  /// No description provided for @apiKeySaveError.
  ///
  /// In es, this message translates to:
  /// **'Error al guardar API key: {error}'**
  String apiKeySaveError(String error);

  /// No description provided for @deleteApiKeyConfirmTitle.
  ///
  /// In es, this message translates to:
  /// **'¿Eliminar API key de Google Books?'**
  String get deleteApiKeyConfirmTitle;

  /// No description provided for @deleteApiKeyConfirmMessage.
  ///
  /// In es, this message translates to:
  /// **'Se eliminará la API key guardada. La búsqueda de libros en Google Books dejará de funcionar hasta que configures una nueva key.'**
  String get deleteApiKeyConfirmMessage;

  /// No description provided for @apiKeyDeleted.
  ///
  /// In es, this message translates to:
  /// **'API key eliminada.'**
  String get apiKeyDeleted;

  /// No description provided for @apiKeyDeleteError.
  ///
  /// In es, this message translates to:
  /// **'Error al eliminar API key: {error}'**
  String apiKeyDeleteError(String error);

  /// No description provided for @exportLoansError.
  ///
  /// In es, this message translates to:
  /// **'Error al exportar préstamos: {error}'**
  String exportLoansError(String error);

  /// No description provided for @activeSessionRequired.
  ///
  /// In es, this message translates to:
  /// **'Debes tener una sesión activa.'**
  String get activeSessionRequired;

  /// No description provided for @themeSystem.
  ///
  /// In es, this message translates to:
  /// **'Usar tema del sistema'**
  String get themeSystem;

  /// No description provided for @themeLight.
  ///
  /// In es, this message translates to:
  /// **'Modo claro'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In es, this message translates to:
  /// **'Modo oscuro'**
  String get themeDark;

  /// No description provided for @themeLoadError.
  ///
  /// In es, this message translates to:
  /// **'No pudimos cargar la preferencia de tema.'**
  String get themeLoadError;

  /// No description provided for @retry.
  ///
  /// In es, this message translates to:
  /// **'Reintentar'**
  String get retry;

  /// No description provided for @genreFantasy.
  ///
  /// In es, this message translates to:
  /// **'Fantasía'**
  String get genreFantasy;

  /// No description provided for @genreScienceFiction.
  ///
  /// In es, this message translates to:
  /// **'Ciencia Ficción'**
  String get genreScienceFiction;

  /// No description provided for @genreHorror.
  ///
  /// In es, this message translates to:
  /// **'Terror'**
  String get genreHorror;

  /// No description provided for @genreThrillerSuspense.
  ///
  /// In es, this message translates to:
  /// **'Thriller / Suspense'**
  String get genreThrillerSuspense;

  /// No description provided for @genreCrimeMystery.
  ///
  /// In es, this message translates to:
  /// **'Crimen / Misterio'**
  String get genreCrimeMystery;

  /// No description provided for @genreRomance.
  ///
  /// In es, this message translates to:
  /// **'Romance'**
  String get genreRomance;

  /// No description provided for @genreHistorical.
  ///
  /// In es, this message translates to:
  /// **'Histórica'**
  String get genreHistorical;

  /// No description provided for @genreLiteraryFiction.
  ///
  /// In es, this message translates to:
  /// **'Ficción Literaria'**
  String get genreLiteraryFiction;

  /// No description provided for @genreNonFiction.
  ///
  /// In es, this message translates to:
  /// **'No Ficción'**
  String get genreNonFiction;

  /// No description provided for @genreBiographyMemoir.
  ///
  /// In es, this message translates to:
  /// **'Biografía / Memorias'**
  String get genreBiographyMemoir;

  /// No description provided for @genreEssay.
  ///
  /// In es, this message translates to:
  /// **'Ensayo'**
  String get genreEssay;

  /// No description provided for @genrePhilosophy.
  ///
  /// In es, this message translates to:
  /// **'Filosofía'**
  String get genrePhilosophy;

  /// No description provided for @genrePoetry.
  ///
  /// In es, this message translates to:
  /// **'Poesía'**
  String get genrePoetry;

  /// No description provided for @genreComicsGraphicNovel.
  ///
  /// In es, this message translates to:
  /// **'Cómic / Novela Gráfica'**
  String get genreComicsGraphicNovel;

  /// No description provided for @genreYoungAdult.
  ///
  /// In es, this message translates to:
  /// **'Juvenil (YA)'**
  String get genreYoungAdult;

  /// No description provided for @genreChildren.
  ///
  /// In es, this message translates to:
  /// **'Infantil'**
  String get genreChildren;

  /// No description provided for @genreTechnicalEducational.
  ///
  /// In es, this message translates to:
  /// **'Técnico / Educativo'**
  String get genreTechnicalEducational;

  /// No description provided for @genreSelfHelp.
  ///
  /// In es, this message translates to:
  /// **'Autoayuda'**
  String get genreSelfHelp;

  /// No description provided for @genrePoliticsSociety.
  ///
  /// In es, this message translates to:
  /// **'Política / Sociedad'**
  String get genrePoliticsSociety;

  /// No description provided for @genreReligionSpirituality.
  ///
  /// In es, this message translates to:
  /// **'Religión / Espiritualidad'**
  String get genreReligionSpirituality;

  /// No description provided for @genreHumor.
  ///
  /// In es, this message translates to:
  /// **'Humor'**
  String get genreHumor;

  /// No description provided for @genreAdventure.
  ///
  /// In es, this message translates to:
  /// **'Aventura'**
  String get genreAdventure;

  /// No description provided for @genreDystopian.
  ///
  /// In es, this message translates to:
  /// **'Distopía'**
  String get genreDystopian;

  /// No description provided for @genreClassic.
  ///
  /// In es, this message translates to:
  /// **'Clásico'**
  String get genreClassic;

  /// No description provided for @evocEmptyLibraryTitle.
  ///
  /// In es, this message translates to:
  /// **'Tu biblioteca aguarda en silencio'**
  String get evocEmptyLibraryTitle;

  /// No description provided for @evocEmptyLibraryMessage.
  ///
  /// In es, this message translates to:
  /// **'Las estanterías esperan sus primeros habitantes. Cada gran colección comienza con un solo libro.'**
  String get evocEmptyLibraryMessage;

  /// No description provided for @evocEmptyLibraryAction.
  ///
  /// In es, this message translates to:
  /// **'Añadir primer libro'**
  String get evocEmptyLibraryAction;

  /// No description provided for @evocEmptySharedLibraryTitle.
  ///
  /// In es, this message translates to:
  /// **'El archivo colectivo está vacío'**
  String get evocEmptySharedLibraryTitle;

  /// No description provided for @evocEmptySharedLibraryMessage.
  ///
  /// In es, this message translates to:
  /// **'Aún no hay libros compartidos en este círculo de lectores. Sé el primero en contribuir al conocimiento común.'**
  String get evocEmptySharedLibraryMessage;

  /// No description provided for @evocEmptyLoansTitle.
  ///
  /// In es, this message translates to:
  /// **'Sin historias en tránsito'**
  String get evocEmptyLoansTitle;

  /// No description provided for @evocEmptyLoansMessage.
  ///
  /// In es, this message translates to:
  /// **'Los libros descansan en sus estantes. Inicia un nuevo viaje compartiendo una lectura.'**
  String get evocEmptyLoansMessage;

  /// No description provided for @evocEmptyLoansAction.
  ///
  /// In es, this message translates to:
  /// **'Registrar préstamo'**
  String get evocEmptyLoansAction;

  /// No description provided for @evocEmptyPendingLoansTitle.
  ///
  /// In es, this message translates to:
  /// **'No hay solicitudes pendientes'**
  String get evocEmptyPendingLoansTitle;

  /// No description provided for @evocEmptyPendingLoansMessage.
  ///
  /// In es, this message translates to:
  /// **'El buzón de peticiones está vacío. Ningún lector aguarda por el momento.'**
  String get evocEmptyPendingLoansMessage;

  /// No description provided for @evocEmptyGroupsTitle.
  ///
  /// In es, this message translates to:
  /// **'Aún no formas parte de ningún círculo'**
  String get evocEmptyGroupsTitle;

  /// No description provided for @evocEmptyGroupsMessage.
  ///
  /// In es, this message translates to:
  /// **'Los círculos de lectura son comunidades donde las historias fluyen. Únete a uno o crea el tuyo propio.'**
  String get evocEmptyGroupsMessage;

  /// No description provided for @evocEmptyGroupsAction.
  ///
  /// In es, this message translates to:
  /// **'Crear círculo'**
  String get evocEmptyGroupsAction;

  /// No description provided for @evocEmptyReviewsTitle.
  ///
  /// In es, this message translates to:
  /// **'Sin reseñas todavía'**
  String get evocEmptyReviewsTitle;

  /// No description provided for @evocEmptyReviewsMessage.
  ///
  /// In es, this message translates to:
  /// **'Este libro aguarda su primera impresión. ¿Qué te pareció su historia?'**
  String get evocEmptyReviewsMessage;

  /// No description provided for @evocEmptyReviewsAction.
  ///
  /// In es, this message translates to:
  /// **'Escribir primera reseña'**
  String get evocEmptyReviewsAction;

  /// No description provided for @evocWelcomeTitle.
  ///
  /// In es, this message translates to:
  /// **'Bienvenido a tu biblioteca personal'**
  String get evocWelcomeTitle;

  /// No description provided for @evocWelcomeMessage.
  ///
  /// In es, this message translates to:
  /// **'Un lugar donde las historias encuentran hogar y viajan entre lectores.'**
  String get evocWelcomeMessage;

  /// No description provided for @evocEnteringArchive.
  ///
  /// In es, this message translates to:
  /// **'Entrando al archivo...'**
  String get evocEnteringArchive;

  /// No description provided for @evocLoadingBooks.
  ///
  /// In es, this message translates to:
  /// **'Reuniendo los volúmenes...'**
  String get evocLoadingBooks;

  /// No description provided for @evocSyncingLibrary.
  ///
  /// In es, this message translates to:
  /// **'Sincronizando el catálogo...'**
  String get evocSyncingLibrary;

  /// No description provided for @evocArchiveButton.
  ///
  /// In es, this message translates to:
  /// **'El Gran Archivo de {groupName}'**
  String evocArchiveButton(String groupName);

  /// No description provided for @evocArchiveButtonShort.
  ///
  /// In es, this message translates to:
  /// **'El Gran Archivo'**
  String get evocArchiveButtonShort;

  /// No description provided for @evocLoanConfirmed.
  ///
  /// In es, this message translates to:
  /// **'El libro ha iniciado su viaje'**
  String get evocLoanConfirmed;

  /// No description provided for @evocLoanReturned.
  ///
  /// In es, this message translates to:
  /// **'El libro ha regresado a casa'**
  String get evocLoanReturned;

  /// No description provided for @evocBookAdded.
  ///
  /// In es, this message translates to:
  /// **'Un nuevo volumen se une a tu colección'**
  String get evocBookAdded;

  /// No description provided for @evocBookRemoved.
  ///
  /// In es, this message translates to:
  /// **'El libro ha sido retirado del catálogo'**
  String get evocBookRemoved;

  /// No description provided for @evocBookNotFound.
  ///
  /// In es, this message translates to:
  /// **'Este volumen parece haberse extraviado'**
  String get evocBookNotFound;

  /// No description provided for @evocConnectionError.
  ///
  /// In es, this message translates to:
  /// **'No se puede alcanzar el archivo remoto en este momento'**
  String get evocConnectionError;

  /// No description provided for @evocSyncError.
  ///
  /// In es, this message translates to:
  /// **'Hubo un problema al sincronizar el catálogo'**
  String get evocSyncError;

  /// No description provided for @evocReadStatus.
  ///
  /// In es, this message translates to:
  /// **'Leído'**
  String get evocReadStatus;

  /// No description provided for @evocUnreadStatus.
  ///
  /// In es, this message translates to:
  /// **'Por leer'**
  String get evocUnreadStatus;

  /// No description provided for @evocReadingStatus.
  ///
  /// In es, this message translates to:
  /// **'Leyendo'**
  String get evocReadingStatus;

  /// No description provided for @evocLoanRequest.
  ///
  /// In es, this message translates to:
  /// **'{requester} solicita \"{bookTitle}\" de tu biblioteca'**
  String evocLoanRequest(String requester, String bookTitle);

  /// No description provided for @evocLoanAccepted.
  ///
  /// In es, this message translates to:
  /// **'Tu solicitud de \"{bookTitle}\" ha sido aceptada'**
  String evocLoanAccepted(String bookTitle);

  /// No description provided for @evocLoanReturnReminder.
  ///
  /// In es, this message translates to:
  /// **'\"{bookTitle}\" debe regresar en {daysLeft} {daysLeft, plural, =1{día} other{días}}'**
  String evocLoanReturnReminder(String bookTitle, int daysLeft);

  /// No description provided for @evocLoanOverdue.
  ///
  /// In es, this message translates to:
  /// **'\"{bookTitle}\" ha excedido su tiempo de préstamo'**
  String evocLoanOverdue(String bookTitle);

  /// No description provided for @readingStatusPending.
  ///
  /// In es, this message translates to:
  /// **'Pendiente'**
  String get readingStatusPending;

  /// No description provided for @readingStatusReading.
  ///
  /// In es, this message translates to:
  /// **'Leyendo'**
  String get readingStatusReading;

  /// No description provided for @readingStatusPaused.
  ///
  /// In es, this message translates to:
  /// **'Pausado'**
  String get readingStatusPaused;

  /// No description provided for @readingStatusFinished.
  ///
  /// In es, this message translates to:
  /// **'Terminado'**
  String get readingStatusFinished;

  /// No description provided for @readingStatusAbandoned.
  ///
  /// In es, this message translates to:
  /// **'Abandonado'**
  String get readingStatusAbandoned;

  /// No description provided for @readingStatusRereading.
  ///
  /// In es, this message translates to:
  /// **'Releyendo'**
  String get readingStatusRereading;

  /// No description provided for @bookStatusAvailable.
  ///
  /// In es, this message translates to:
  /// **'Disponible'**
  String get bookStatusAvailable;

  /// No description provided for @bookStatusLoaned.
  ///
  /// In es, this message translates to:
  /// **'Prestado'**
  String get bookStatusLoaned;

  /// No description provided for @bookStatusPrivate.
  ///
  /// In es, this message translates to:
  /// **'Privado'**
  String get bookStatusPrivate;

  /// No description provided for @bookStatusArchived.
  ///
  /// In es, this message translates to:
  /// **'Archivado'**
  String get bookStatusArchived;

  /// No description provided for @searchBooks.
  ///
  /// In es, this message translates to:
  /// **'Buscar libros...'**
  String get searchBooks;

  /// No description provided for @readFilter.
  ///
  /// In es, this message translates to:
  /// **'Leídos'**
  String get readFilter;

  /// No description provided for @unreadFilter.
  ///
  /// In es, this message translates to:
  /// **'No leídos'**
  String get unreadFilter;

  /// No description provided for @allFilter.
  ///
  /// In es, this message translates to:
  /// **'Todos'**
  String get allFilter;

  /// No description provided for @save.
  ///
  /// In es, this message translates to:
  /// **'Guardar'**
  String get save;

  /// No description provided for @close.
  ///
  /// In es, this message translates to:
  /// **'Cerrar'**
  String get close;

  /// No description provided for @ok.
  ///
  /// In es, this message translates to:
  /// **'Aceptar'**
  String get ok;

  /// No description provided for @yes.
  ///
  /// In es, this message translates to:
  /// **'Sí'**
  String get yes;

  /// No description provided for @no.
  ///
  /// In es, this message translates to:
  /// **'No'**
  String get no;

  /// No description provided for @error.
  ///
  /// In es, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @errorStateLabel.
  ///
  /// In es, this message translates to:
  /// **'Error'**
  String get errorStateLabel;

  /// No description provided for @loading.
  ///
  /// In es, this message translates to:
  /// **'Cargando...'**
  String get loading;

  /// No description provided for @errorGeneric.
  ///
  /// In es, this message translates to:
  /// **'Error: {error}'**
  String errorGeneric(String error);

  /// No description provided for @errorImporting.
  ///
  /// In es, this message translates to:
  /// **'Error al importar: {error}'**
  String errorImporting(Object error);

  /// No description provided for @notificationLoanDueSoonTitle.
  ///
  /// In es, this message translates to:
  /// **'Préstamo por vencer'**
  String get notificationLoanDueSoonTitle;

  /// No description provided for @notificationLoanDueSoonBody.
  ///
  /// In es, this message translates to:
  /// **'Tu préstamo vence en menos de una semana.'**
  String get notificationLoanDueSoonBody;

  /// No description provided for @notificationLoanDueSoonBodyWithTitle.
  ///
  /// In es, this message translates to:
  /// **'El préstamo de \"{title}\" vence pronto.'**
  String notificationLoanDueSoonBodyWithTitle(String title);

  /// No description provided for @notificationLoanExpiredTitle.
  ///
  /// In es, this message translates to:
  /// **'Préstamo vencido'**
  String get notificationLoanExpiredTitle;

  /// No description provided for @notificationLoanExpiredBody.
  ///
  /// In es, this message translates to:
  /// **'Tu préstamo ha llegado a su fecha límite.'**
  String get notificationLoanExpiredBody;

  /// No description provided for @notificationLoanExpiredBodyWithTitle.
  ///
  /// In es, this message translates to:
  /// **'El préstamo de \"{title}\" ha expirado.'**
  String notificationLoanExpiredBodyWithTitle(String title);

  /// No description provided for @notificationLoanRequestTitle.
  ///
  /// In es, this message translates to:
  /// **'Nueva solicitud de préstamo'**
  String get notificationLoanRequestTitle;

  /// No description provided for @notificationLoanRequestFallback.
  ///
  /// In es, this message translates to:
  /// **'{name} solicitó un préstamo.'**
  String notificationLoanRequestFallback(String name);

  /// No description provided for @notificationLoanRequestWithTitle.
  ///
  /// In es, this message translates to:
  /// **'{name} quiere pedir prestado \"{title}\".'**
  String notificationLoanRequestWithTitle(String name, String title);

  /// No description provided for @notificationLoanCancelledTitle.
  ///
  /// In es, this message translates to:
  /// **'Solicitud de préstamo cancelada'**
  String get notificationLoanCancelledTitle;

  /// No description provided for @notificationLoanCancelledFallback.
  ///
  /// In es, this message translates to:
  /// **'{name} canceló la solicitud de préstamo.'**
  String notificationLoanCancelledFallback(String name);

  /// No description provided for @notificationLoanCancelledWithTitle.
  ///
  /// In es, this message translates to:
  /// **'{name} canceló la solicitud para \"{title}\".'**
  String notificationLoanCancelledWithTitle(String name, String title);

  /// No description provided for @notificationLoanRejectedTitle.
  ///
  /// In es, this message translates to:
  /// **'Solicitud de préstamo rechazada'**
  String get notificationLoanRejectedTitle;

  /// No description provided for @notificationLoanRejectedFallback.
  ///
  /// In es, this message translates to:
  /// **'{name} rechazó tu solicitud de préstamo.'**
  String notificationLoanRejectedFallback(String name);

  /// No description provided for @notificationLoanRejectedWithTitle.
  ///
  /// In es, this message translates to:
  /// **'{name} rechazó tu solicitud para \"{title}\".'**
  String notificationLoanRejectedWithTitle(String name, String title);

  /// No description provided for @notificationLoanAcceptedTitle.
  ///
  /// In es, this message translates to:
  /// **'Préstamo aceptado'**
  String get notificationLoanAcceptedTitle;

  /// No description provided for @notificationLoanAcceptedFallback.
  ///
  /// In es, this message translates to:
  /// **'{name} aceptó tu solicitud de préstamo.'**
  String notificationLoanAcceptedFallback(String name);

  /// No description provided for @notificationLoanAcceptedWithTitle.
  ///
  /// In es, this message translates to:
  /// **'{name} aceptó tu solicitud para \"{title}\".'**
  String notificationLoanAcceptedWithTitle(String name, String title);

  /// No description provided for @notificationLoanReturnedTitle.
  ///
  /// In es, this message translates to:
  /// **'Préstamo marcado como devuelto'**
  String get notificationLoanReturnedTitle;

  /// No description provided for @notificationLoanReturnedFallback.
  ///
  /// In es, this message translates to:
  /// **'{name} marcó el préstamo como devuelto.'**
  String notificationLoanReturnedFallback(String name);

  /// No description provided for @notificationLoanReturnedWithTitle.
  ///
  /// In es, this message translates to:
  /// **'{name} marcó como devuelto \"{title}\".'**
  String notificationLoanReturnedWithTitle(String name, String title);

  /// No description provided for @notificationReturnReminderTitle.
  ///
  /// In es, this message translates to:
  /// **'Confirmación pendiente'**
  String get notificationReturnReminderTitle;

  /// No description provided for @notificationReturnReminderFallback.
  ///
  /// In es, this message translates to:
  /// **'Recordatorio para confirmar devolución.'**
  String get notificationReturnReminderFallback;

  /// No description provided for @notificationReturnReminderWithTitle.
  ///
  /// In es, this message translates to:
  /// **'Recordatorio: Por favor confirma la devolución de \"{title}\".'**
  String notificationReturnReminderWithTitle(String title);

  /// No description provided for @loanManualRegistered.
  ///
  /// In es, this message translates to:
  /// **'Préstamo manual registrado.'**
  String get loanManualRegistered;

  /// No description provided for @loanExternalRegistered.
  ///
  /// In es, this message translates to:
  /// **'Préstamo externo registrado.'**
  String get loanExternalRegistered;

  /// No description provided for @loanRequestSent.
  ///
  /// In es, this message translates to:
  /// **'Solicitud enviada.'**
  String get loanRequestSent;

  /// No description provided for @loanRequestCancelled.
  ///
  /// In es, this message translates to:
  /// **'Solicitud cancelada.'**
  String get loanRequestCancelled;

  /// No description provided for @loanRequestRejected.
  ///
  /// In es, this message translates to:
  /// **'Solicitud rechazada.'**
  String get loanRequestRejected;

  /// No description provided for @loanRequestAccepted.
  ///
  /// In es, this message translates to:
  /// **'Préstamo aceptado.'**
  String get loanRequestAccepted;

  /// No description provided for @loanMarkedReturned.
  ///
  /// In es, this message translates to:
  /// **'Préstamo marcado como devuelto.'**
  String get loanMarkedReturned;

  /// No description provided for @loanMarkedExpired.
  ///
  /// In es, this message translates to:
  /// **'Préstamo marcado como expirado.'**
  String get loanMarkedExpired;

  /// No description provided for @loanReturnConfirmed.
  ///
  /// In es, this message translates to:
  /// **'Devolución confirmada.'**
  String get loanReturnConfirmed;

  /// No description provided for @loanReminderSent.
  ///
  /// In es, this message translates to:
  /// **'Recordatorio enviado.'**
  String get loanReminderSent;

  /// No description provided for @errorLoanDueDatePast.
  ///
  /// In es, this message translates to:
  /// **'La fecha de devolución no puede ser anterior a hoy.'**
  String get errorLoanDueDatePast;

  /// No description provided for @errorLoanCancelledByOther.
  ///
  /// In es, this message translates to:
  /// **'El usuario canceló la solicitud antes de que pudieras aceptarla.'**
  String get errorLoanCancelledByOther;

  /// No description provided for @errorLoanAlreadyActive.
  ///
  /// In es, this message translates to:
  /// **'Este libro ya ha sido prestado a otra persona.'**
  String get errorLoanAlreadyActive;

  /// No description provided for @errorLoanInvalidState.
  ///
  /// In es, this message translates to:
  /// **'La solicitud ya no es válida (quizás ya fue aceptada o rechazada).'**
  String get errorLoanInvalidState;

  /// No description provided for @groupCreated.
  ///
  /// In es, this message translates to:
  /// **'Grupo creado.'**
  String get groupCreated;

  /// No description provided for @groupUpdated.
  ///
  /// In es, this message translates to:
  /// **'Grupo actualizado.'**
  String get groupUpdated;

  /// No description provided for @groupDeleted.
  ///
  /// In es, this message translates to:
  /// **'Grupo eliminado.'**
  String get groupDeleted;

  /// No description provided for @ownershipTransferred.
  ///
  /// In es, this message translates to:
  /// **'Propiedad transferida.'**
  String get ownershipTransferred;

  /// No description provided for @memberAdded.
  ///
  /// In es, this message translates to:
  /// **'Miembro añadido.'**
  String get memberAdded;

  /// No description provided for @roleUpdated.
  ///
  /// In es, this message translates to:
  /// **'Rol actualizado.'**
  String get roleUpdated;

  /// No description provided for @memberRemoved.
  ///
  /// In es, this message translates to:
  /// **'Miembro eliminado.'**
  String get memberRemoved;

  /// No description provided for @invitationCreated.
  ///
  /// In es, this message translates to:
  /// **'Invitación creada.'**
  String get invitationCreated;

  /// No description provided for @invitationCancelled.
  ///
  /// In es, this message translates to:
  /// **'Invitación cancelada.'**
  String get invitationCancelled;

  /// No description provided for @invitationAccepted.
  ///
  /// In es, this message translates to:
  /// **'Invitación aceptada.'**
  String get invitationAccepted;

  /// No description provided for @invitationUpdated.
  ///
  /// In es, this message translates to:
  /// **'Invitación actualizada.'**
  String get invitationUpdated;

  /// No description provided for @joinedGroup.
  ///
  /// In es, this message translates to:
  /// **'Te uniste al grupo.'**
  String get joinedGroup;

  /// No description provided for @notificationGroupUpdatedTitle.
  ///
  /// In es, this message translates to:
  /// **'Grupo \"{name}\" actualizado'**
  String notificationGroupUpdatedTitle(String name);

  /// No description provided for @notificationGroupUpdatedMessage.
  ///
  /// In es, this message translates to:
  /// **'Se han realizado cambios en los detalles del grupo.'**
  String get notificationGroupUpdatedMessage;

  /// No description provided for @notificationGroupDeletedTitle.
  ///
  /// In es, this message translates to:
  /// **'Grupo eliminado'**
  String get notificationGroupDeletedTitle;

  /// No description provided for @notificationGroupDeletedMessage.
  ///
  /// In es, this message translates to:
  /// **'El grupo \"{name}\" ha sido disuelto.'**
  String notificationGroupDeletedMessage(String name);

  /// No description provided for @notificationGroupMemberJoinedTitle.
  ///
  /// In es, this message translates to:
  /// **'Nuevo miembro en \"{name}\"'**
  String notificationGroupMemberJoinedTitle(String name);

  /// No description provided for @notificationGroupMemberJoinedMessage.
  ///
  /// In es, this message translates to:
  /// **'{name} se unió al grupo.'**
  String notificationGroupMemberJoinedMessage(String name);

  /// No description provided for @notificationGroupMemberLeftTitle.
  ///
  /// In es, this message translates to:
  /// **'Miembro salió de \"{name}\"'**
  String notificationGroupMemberLeftTitle(String name);

  /// No description provided for @notificationGroupMemberLeftMessage.
  ///
  /// In es, this message translates to:
  /// **'{name} dejó el grupo.'**
  String notificationGroupMemberLeftMessage(String name);

  /// No description provided for @notificationGroupMemberJoinedByCodeMessage.
  ///
  /// In es, this message translates to:
  /// **'{name} se unió por código.'**
  String notificationGroupMemberJoinedByCodeMessage(String name);

  /// No description provided for @userFallback.
  ///
  /// In es, this message translates to:
  /// **'Usuario {id}'**
  String userFallback(int id);

  /// No description provided for @statusRequested.
  ///
  /// In es, this message translates to:
  /// **'Solicitado'**
  String get statusRequested;

  /// No description provided for @statusRequestedCaption.
  ///
  /// In es, this message translates to:
  /// **'Solicitud pendiente de aprobación'**
  String get statusRequestedCaption;

  /// No description provided for @statusOnLoan.
  ///
  /// In es, this message translates to:
  /// **'En préstamo'**
  String get statusOnLoan;

  /// No description provided for @statusOnLoanCaption.
  ///
  /// In es, this message translates to:
  /// **'Préstamo activo'**
  String get statusOnLoanCaption;

  /// No description provided for @statusAvailable.
  ///
  /// In es, this message translates to:
  /// **'Disponible'**
  String get statusAvailable;

  /// No description provided for @statusUnavailable.
  ///
  /// In es, this message translates to:
  /// **'No disponible'**
  String get statusUnavailable;

  /// No description provided for @tooltipViewMembers.
  ///
  /// In es, this message translates to:
  /// **'Ver miembros'**
  String get tooltipViewMembers;

  /// No description provided for @tooltipSortBy.
  ///
  /// In es, this message translates to:
  /// **'Ordenar por'**
  String get tooltipSortBy;

  /// No description provided for @filterHideRead.
  ///
  /// In es, this message translates to:
  /// **'Ocultar leídos'**
  String get filterHideRead;

  /// No description provided for @filterIncludeUnavailable.
  ///
  /// In es, this message translates to:
  /// **'Incluir no disponibles'**
  String get filterIncludeUnavailable;

  /// No description provided for @errorLoadingLibrary.
  ///
  /// In es, this message translates to:
  /// **'No pudimos cargar tu biblioteca.'**
  String get errorLoadingLibrary;

  /// No description provided for @errorLoadingSharedBooksGeneric.
  ///
  /// In es, this message translates to:
  /// **'No pudimos cargar los libros compartidos.'**
  String get errorLoadingSharedBooksGeneric;

  /// No description provided for @emptySearchTitle.
  ///
  /// In es, this message translates to:
  /// **'Sin resultados para tu búsqueda'**
  String get emptySearchTitle;

  /// No description provided for @emptySearchMessage.
  ///
  /// In es, this message translates to:
  /// **'Revisa el término ingresado o restablece los filtros para ver más libros.'**
  String get emptySearchMessage;

  /// No description provided for @actionClearSearch.
  ///
  /// In es, this message translates to:
  /// **'Limpiar búsqueda'**
  String get actionClearSearch;

  /// No description provided for @emptyMemberBooksTitle.
  ///
  /// In es, this message translates to:
  /// **'Sin libros de este miembro'**
  String get emptyMemberBooksTitle;

  /// No description provided for @emptyMemberBooksMessage.
  ///
  /// In es, this message translates to:
  /// **'Prueba con otra persona o vuelve a mostrar todos los libros disponibles.'**
  String get emptyMemberBooksMessage;

  /// No description provided for @actionRemoveFilter.
  ///
  /// In es, this message translates to:
  /// **'Quitar filtro'**
  String get actionRemoveFilter;

  /// No description provided for @emptyDiscoverTitle.
  ///
  /// In es, this message translates to:
  /// **'Todavía no hay libros para descubrir'**
  String get emptyDiscoverTitle;

  /// No description provided for @emptyDiscoverMessage.
  ///
  /// In es, this message translates to:
  /// **'Cuando otros miembros compartan ejemplares compatibles, los verás listados aquí.'**
  String get emptyDiscoverMessage;

  /// No description provided for @actionUpdateList.
  ///
  /// In es, this message translates to:
  /// **'Actualizar lista'**
  String get actionUpdateList;

  /// No description provided for @bookNoTitle.
  ///
  /// In es, this message translates to:
  /// **'Libro sin título'**
  String get bookNoTitle;

  /// No description provided for @bookPages.
  ///
  /// In es, this message translates to:
  /// **'{count} páginas'**
  String bookPages(int count);

  /// No description provided for @noReviewsYet.
  ///
  /// In es, this message translates to:
  /// **'Nadie ha opinado todavía'**
  String get noReviewsYet;

  /// No description provided for @reviewCount.
  ///
  /// In es, this message translates to:
  /// **'{count, plural, =1{1 opinión} other{{count} opiniones}}'**
  String reviewCount(int count);

  /// No description provided for @bookOwner.
  ///
  /// In es, this message translates to:
  /// **'Propietario: {name}'**
  String bookOwner(String name);

  /// No description provided for @bookFormatPhysical.
  ///
  /// In es, this message translates to:
  /// **'Físico'**
  String get bookFormatPhysical;

  /// No description provided for @bookFormatDigital.
  ///
  /// In es, this message translates to:
  /// **'Digital'**
  String get bookFormatDigital;

  /// No description provided for @bookNoDescription.
  ///
  /// In es, this message translates to:
  /// **'Este libro no tiene una descripción añadida.'**
  String get bookNoDescription;

  /// No description provided for @actionsTitle.
  ///
  /// In es, this message translates to:
  /// **'Acciones'**
  String get actionsTitle;

  /// No description provided for @reservedBy.
  ///
  /// In es, this message translates to:
  /// **'Reservado por {name}'**
  String reservedBy(String name);

  /// No description provided for @loanPendingApproval.
  ///
  /// In es, this message translates to:
  /// **'pendiente de aprobación'**
  String get loanPendingApproval;

  /// No description provided for @loanInProgress.
  ///
  /// In es, this message translates to:
  /// **'en curso'**
  String get loanInProgress;

  /// No description provided for @loanStatusMessage.
  ///
  /// In es, this message translates to:
  /// **'El préstamo está {status}. Podrás solicitarlo cuando vuelva a estar disponible.'**
  String loanStatusMessage(String status);

  /// No description provided for @errorLocalSessionRequired.
  ///
  /// In es, this message translates to:
  /// **'Necesitas iniciar sesión local.'**
  String get errorLocalSessionRequired;

  /// No description provided for @errorLocalSessionMessage.
  ///
  /// In es, this message translates to:
  /// **'Solo las personas registradas localmente pueden solicitar préstamos.'**
  String get errorLocalSessionMessage;

  /// No description provided for @pendingRequestTitle.
  ///
  /// In es, this message translates to:
  /// **'Solicitud pendiente'**
  String get pendingRequestTitle;

  /// No description provided for @pendingRequestFrom.
  ///
  /// In es, this message translates to:
  /// **'Tienes una solicitud de {name} para este libro.'**
  String pendingRequestFrom(String name);

  /// No description provided for @actionAcceptRequest.
  ///
  /// In es, this message translates to:
  /// **'Aceptar solicitud'**
  String get actionAcceptRequest;

  /// No description provided for @actionRejectRequest.
  ///
  /// In es, this message translates to:
  /// **'Rechazar'**
  String get actionRejectRequest;

  /// No description provided for @actionBorrow.
  ///
  /// In es, this message translates to:
  /// **'Pedir prestado'**
  String get actionBorrow;

  /// No description provided for @actionAddToLibrary.
  ///
  /// In es, this message translates to:
  /// **'Añadir a mi biblioteca'**
  String get actionAddToLibrary;

  /// No description provided for @actionCancelRequest.
  ///
  /// In es, this message translates to:
  /// **'Cancelar solicitud'**
  String get actionCancelRequest;

  /// No description provided for @alreadyRequestedMessage.
  ///
  /// In es, this message translates to:
  /// **'Ya enviaste una solicitud para este libro y está {status}.'**
  String alreadyRequestedMessage(String status);

  /// No description provided for @bookNotAvailableMessage.
  ///
  /// In es, this message translates to:
  /// **'Este libro no está disponible en este momento.'**
  String get bookNotAvailableMessage;

  /// No description provided for @errorLoadingBook.
  ///
  /// In es, this message translates to:
  /// **'No pudimos cargar este libro.'**
  String get errorLoadingBook;

  /// No description provided for @warningSelectOwner.
  ///
  /// In es, this message translates to:
  /// **'Por favor, selecciona un dueño primero.'**
  String get warningSelectOwner;

  /// No description provided for @ownerSelectorLabel.
  ///
  /// In es, this message translates to:
  /// **'Disponible a través de {count, plural, =1{1 persona} other{{count} personas}}:'**
  String ownerSelectorLabel(int count);

  /// No description provided for @me.
  ///
  /// In es, this message translates to:
  /// **'Mí (propietario)'**
  String get me;

  /// No description provided for @availableNow.
  ///
  /// In es, this message translates to:
  /// **'Disponible ahora'**
  String get availableNow;

  /// No description provided for @notInLibrary.
  ///
  /// In es, this message translates to:
  /// **'No está en tu biblioteca'**
  String get notInLibrary;

  /// No description provided for @opinar.
  ///
  /// In es, this message translates to:
  /// **'Opinar'**
  String get opinar;

  /// No description provided for @edit.
  ///
  /// In es, this message translates to:
  /// **'Editar'**
  String get edit;

  /// No description provided for @dialogCancelRequestTitle.
  ///
  /// In es, this message translates to:
  /// **'¿Cancelar solicitud?'**
  String get dialogCancelRequestTitle;

  /// No description provided for @dialogCancelRequestMessage.
  ///
  /// In es, this message translates to:
  /// **'¿Estás seguro de que quieres cancelar esta solicitud de préstamo?'**
  String get dialogCancelRequestMessage;

  /// No description provided for @dialogRejectRequestTitle.
  ///
  /// In es, this message translates to:
  /// **'¿Rechazar solicitud?'**
  String get dialogRejectRequestTitle;

  /// No description provided for @dialogRejectRequestMessage.
  ///
  /// In es, this message translates to:
  /// **'¿Estás seguro de que quieres rechazar esta solicitud de préstamo?'**
  String get dialogRejectRequestMessage;

  /// No description provided for @dialogAddToLibraryTitle.
  ///
  /// In es, this message translates to:
  /// **'¿Añadir a mi biblioteca?'**
  String get dialogAddToLibraryTitle;

  /// No description provided for @dialogAddToLibraryMessage.
  ///
  /// In es, this message translates to:
  /// **'¿Seguro que quieres pasar este libro a tu biblioteca personal?'**
  String get dialogAddToLibraryMessage;

  /// No description provided for @errorOriginalMetadataNotFound.
  ///
  /// In es, this message translates to:
  /// **'No se encontraron los metadatos del libro original'**
  String get errorOriginalMetadataNotFound;

  /// No description provided for @bookAddedToLibrary.
  ///
  /// In es, this message translates to:
  /// **'\"{title}\" añadido a tu biblioteca'**
  String bookAddedToLibrary(String title);

  /// No description provided for @errorAlreadyInLibrary.
  ///
  /// In es, this message translates to:
  /// **'Ya tienes este libro en tu biblioteca'**
  String get errorAlreadyInLibrary;

  /// No description provided for @errorAddingToLibrary.
  ///
  /// In es, this message translates to:
  /// **'Error al añadir a la biblioteca: {error}'**
  String errorAddingToLibrary(String error);

  /// No description provided for @userUnknown.
  ///
  /// In es, this message translates to:
  /// **'Usuario desconocido'**
  String get userUnknown;

  /// No description provided for @selectOwnerTitle.
  ///
  /// In es, this message translates to:
  /// **'¿A quién quieres pedírselo?'**
  String get selectOwnerTitle;

  /// No description provided for @addedFromGroup.
  ///
  /// In es, this message translates to:
  /// **'Añadido desde un grupo'**
  String get addedFromGroup;

  /// No description provided for @actionRequestLoan.
  ///
  /// In es, this message translates to:
  /// **'Solicitar préstamo'**
  String get actionRequestLoan;

  /// No description provided for @unknown.
  ///
  /// In es, this message translates to:
  /// **'Desconocido'**
  String get unknown;

  /// No description provided for @groupLibrarian.
  ///
  /// In es, this message translates to:
  /// **'Lector@ Maest@: {name} (Dueño)'**
  String groupLibrarian(String name);

  /// No description provided for @lastUpdate.
  ///
  /// In es, this message translates to:
  /// **'Última actualización: {date}'**
  String lastUpdate(String date);

  /// No description provided for @tooltipSyncGroup.
  ///
  /// In es, this message translates to:
  /// **'Sincronizar grupo'**
  String get tooltipSyncGroup;

  /// No description provided for @actionEditGroup.
  ///
  /// In es, this message translates to:
  /// **'Editar grupo'**
  String get actionEditGroup;

  /// No description provided for @actionManageMembers.
  ///
  /// In es, this message translates to:
  /// **'Gestionar miembros'**
  String get actionManageMembers;

  /// No description provided for @actionManageInvitations.
  ///
  /// In es, this message translates to:
  /// **'Gestionar invitaciones'**
  String get actionManageInvitations;

  /// No description provided for @actionViewMembers.
  ///
  /// In es, this message translates to:
  /// **'Ver miembros'**
  String get actionViewMembers;

  /// No description provided for @actionTransferOwnership.
  ///
  /// In es, this message translates to:
  /// **'Transferir propiedad'**
  String get actionTransferOwnership;

  /// No description provided for @actionDeleteGroup.
  ///
  /// In es, this message translates to:
  /// **'Eliminar grupo'**
  String get actionDeleteGroup;

  /// No description provided for @actionLeaveGroup.
  ///
  /// In es, this message translates to:
  /// **'Salir del grupo'**
  String get actionLeaveGroup;

  /// No description provided for @tooltipGroupActions.
  ///
  /// In es, this message translates to:
  /// **'Acciones del grupo'**
  String get tooltipGroupActions;

  /// No description provided for @dialogTransferOwnershipTitle.
  ///
  /// In es, this message translates to:
  /// **'¿Transferir propiedad?'**
  String get dialogTransferOwnershipTitle;

  /// No description provided for @dialogTransferOwnershipMessage.
  ///
  /// In es, this message translates to:
  /// **'¿Estás seguro de que quieres transferir la propiedad del grupo a {name}?'**
  String dialogTransferOwnershipMessage(String name);

  /// No description provided for @dialogDeleteGroupTitle.
  ///
  /// In es, this message translates to:
  /// **'¿Borrar grupo?'**
  String get dialogDeleteGroupTitle;

  /// No description provided for @dialogDeleteGroupMessage.
  ///
  /// In es, this message translates to:
  /// **'¿Estás seguro de que quieres borrar el grupo \"{name}\"? Esta acción no se puede deshacer.'**
  String dialogDeleteGroupMessage(String name);

  /// No description provided for @dialogLeaveGroupTitle.
  ///
  /// In es, this message translates to:
  /// **'¿Salir del grupo?'**
  String get dialogLeaveGroupTitle;

  /// No description provided for @dialogLeaveGroupMessage.
  ///
  /// In es, this message translates to:
  /// **'¿Estás seguro de que quieres salir del grupo \"{name}\"?'**
  String dialogLeaveGroupMessage(String name);

  /// No description provided for @errorUnexpected.
  ///
  /// In es, this message translates to:
  /// **'Ocurrió un error inesperado'**
  String get errorUnexpected;

  /// No description provided for @successGroupDeleted.
  ///
  /// In es, this message translates to:
  /// **'Grupo borrado con éxito'**
  String get successGroupDeleted;

  /// No description provided for @successGroupLeft.
  ///
  /// In es, this message translates to:
  /// **'Has salido del grupo'**
  String get successGroupLeft;

  /// No description provided for @successOwnershipTransferred.
  ///
  /// In es, this message translates to:
  /// **'Propiedad transferida a {name}'**
  String successOwnershipTransferred(String name);

  /// No description provided for @successGroupUpdated.
  ///
  /// In es, this message translates to:
  /// **'Grupo actualizado correctamente'**
  String get successGroupUpdated;

  /// No description provided for @errorUpdatingGroup.
  ///
  /// In es, this message translates to:
  /// **'Error al actualizar grupo: {error}'**
  String errorUpdatingGroup(String error);

  /// No description provided for @errorNoOtherMembers.
  ///
  /// In es, this message translates to:
  /// **'No hay otros miembros a quienes transferir'**
  String get errorNoOtherMembers;

  /// No description provided for @errorTransferringOwnership.
  ///
  /// In es, this message translates to:
  /// **'Error al transferir propiedad: {error}'**
  String errorTransferringOwnership(String error);

  /// No description provided for @errorDeletingGroup.
  ///
  /// In es, this message translates to:
  /// **'Error al eliminar grupo: {error}'**
  String errorDeletingGroup(String error);

  /// No description provided for @errorLeavingGroup.
  ///
  /// In es, this message translates to:
  /// **'Error al salir del grupo: {error}'**
  String errorLeavingGroup(String error);

  /// No description provided for @actionTransfer.
  ///
  /// In es, this message translates to:
  /// **'Transferir'**
  String get actionTransfer;

  /// No description provided for @actionDelete.
  ///
  /// In es, this message translates to:
  /// **'Eliminar'**
  String get actionDelete;

  /// No description provided for @actionLeave.
  ///
  /// In es, this message translates to:
  /// **'Salir'**
  String get actionLeave;

  /// No description provided for @statMembers.
  ///
  /// In es, this message translates to:
  /// **'Miembros'**
  String get statMembers;

  /// No description provided for @statBooks.
  ///
  /// In es, this message translates to:
  /// **'Libros'**
  String get statBooks;

  /// No description provided for @statAvailable.
  ///
  /// In es, this message translates to:
  /// **'Libres'**
  String get statAvailable;

  /// No description provided for @contributionTitle.
  ///
  /// In es, this message translates to:
  /// **'Tu aporte al grupo'**
  String get contributionTitle;

  /// No description provided for @contributionMessage.
  ///
  /// In es, this message translates to:
  /// **'Has compartido {count} libros y hay {activeLoans} en préstamo.'**
  String contributionMessage(int count, int activeLoans);

  /// No description provided for @actionCreateInvitation.
  ///
  /// In es, this message translates to:
  /// **'Crear invitación'**
  String get actionCreateInvitation;

  /// No description provided for @noPendingInvitations.
  ///
  /// In es, this message translates to:
  /// **'No hay invitaciones pendientes'**
  String get noPendingInvitations;

  /// No description provided for @invitationCodeLabel.
  ///
  /// In es, this message translates to:
  /// **'Código: {code}'**
  String invitationCodeLabel(String code);

  /// No description provided for @invitationExpiresLabel.
  ///
  /// In es, this message translates to:
  /// **'Expira: {date}'**
  String invitationExpiresLabel(String date);

  /// No description provided for @successInvitationCreated.
  ///
  /// In es, this message translates to:
  /// **'Invitación creada correctamente'**
  String get successInvitationCreated;

  /// No description provided for @errorCreatingInvitation.
  ///
  /// In es, this message translates to:
  /// **'Error al crear invitación: {error}'**
  String errorCreatingInvitation(String error);

  /// No description provided for @shareInvitationMessage.
  ///
  /// In es, this message translates to:
  /// **'Te envío esta invitación para unirte a mi grupo de lectores: {code}'**
  String shareInvitationMessage(String code);

  /// No description provided for @shareInvitationSubject.
  ///
  /// In es, this message translates to:
  /// **'Invitación a grupo de lectores'**
  String get shareInvitationSubject;

  /// No description provided for @errorSharing.
  ///
  /// In es, this message translates to:
  /// **'Error al compartir: {error}'**
  String errorSharing(String error);

  /// No description provided for @dialogCancelInvitationTitle.
  ///
  /// In es, this message translates to:
  /// **'Cancelar invitación'**
  String get dialogCancelInvitationTitle;

  /// No description provided for @dialogCancelInvitationMessage.
  ///
  /// In es, this message translates to:
  /// **'¿Estás seguro de cancelar esta invitación?'**
  String get dialogCancelInvitationMessage;

  /// No description provided for @actionCancelInvitationConfirm.
  ///
  /// In es, this message translates to:
  /// **'Sí, cancelar'**
  String get actionCancelInvitationConfirm;

  /// No description provided for @successInvitationCancelled.
  ///
  /// In es, this message translates to:
  /// **'Invitación cancelada'**
  String get successInvitationCancelled;

  /// No description provided for @errorCancellingInvitation.
  ///
  /// In es, this message translates to:
  /// **'Error al cancelar invitación: {error}'**
  String errorCancellingInvitation(String error);

  /// No description provided for @noLabel.
  ///
  /// In es, this message translates to:
  /// **'No'**
  String get noLabel;

  /// No description provided for @yesLabel.
  ///
  /// In es, this message translates to:
  /// **'Sí'**
  String get yesLabel;

  /// No description provided for @invitationsHeader.
  ///
  /// In es, this message translates to:
  /// **'Invitaciones'**
  String get invitationsHeader;

  /// No description provided for @starMemberTooltip.
  ///
  /// In es, this message translates to:
  /// **'Miembro Estrella (Máxima actividad)'**
  String get starMemberTooltip;

  /// No description provided for @badgeBibliophile.
  ///
  /// In es, this message translates to:
  /// **'Bibliófilo'**
  String get badgeBibliophile;

  /// No description provided for @badgeCurator.
  ///
  /// In es, this message translates to:
  /// **'Curador'**
  String get badgeCurator;

  /// No description provided for @badgeLibrarian.
  ///
  /// In es, this message translates to:
  /// **'Bibliotecario'**
  String get badgeLibrarian;

  /// No description provided for @badgeActiveReader.
  ///
  /// In es, this message translates to:
  /// **'Lector Activo'**
  String get badgeActiveReader;

  /// No description provided for @badgeGenerous.
  ///
  /// In es, this message translates to:
  /// **'Generoso'**
  String get badgeGenerous;

  /// No description provided for @actionMakeAdmin.
  ///
  /// In es, this message translates to:
  /// **'Hacer admin'**
  String get actionMakeAdmin;

  /// No description provided for @actionMakeMember.
  ///
  /// In es, this message translates to:
  /// **'Hacer miembro'**
  String get actionMakeMember;

  /// No description provided for @roleOwner.
  ///
  /// In es, this message translates to:
  /// **'Propietario'**
  String get roleOwner;

  /// No description provided for @roleAdmin.
  ///
  /// In es, this message translates to:
  /// **'Administrador'**
  String get roleAdmin;

  /// No description provided for @roleMember.
  ///
  /// In es, this message translates to:
  /// **'Miembro'**
  String get roleMember;

  /// No description provided for @successMemberRemoved.
  ///
  /// In es, this message translates to:
  /// **'Miembro eliminado'**
  String get successMemberRemoved;

  /// No description provided for @successRoleUpdated.
  ///
  /// In es, this message translates to:
  /// **'Rol actualizado'**
  String get successRoleUpdated;

  /// No description provided for @selectNewOwnerTitle.
  ///
  /// In es, this message translates to:
  /// **'Seleccionar nuevo propietario'**
  String get selectNewOwnerTitle;

  /// No description provided for @excludedByFilter.
  ///
  /// In es, this message translates to:
  /// **'{count, plural, =1{1 libro excluido} other{{count} libros excluidos}} por el filtro de género · {passing} visibles'**
  String excludedByFilter(int count, int passing);

  /// No description provided for @actionCreateGroup.
  ///
  /// In es, this message translates to:
  /// **'Crear grupo'**
  String get actionCreateGroup;

  /// No description provided for @actionJoinByCode.
  ///
  /// In es, this message translates to:
  /// **'Unirse por código'**
  String get actionJoinByCode;

  /// No description provided for @syncGroupsTitle.
  ///
  /// In es, this message translates to:
  /// **'Sincroniza tus grupos'**
  String get syncGroupsTitle;

  /// No description provided for @syncGroupsMessage.
  ///
  /// In es, this message translates to:
  /// **'Conecta con Supabase para traer tus comunidades, miembros y libros compartidos.'**
  String get syncGroupsMessage;

  /// No description provided for @actionSyncNow.
  ///
  /// In es, this message translates to:
  /// **'Sincronizar ahora'**
  String get actionSyncNow;

  /// No description provided for @errorLoadingGroups.
  ///
  /// In es, this message translates to:
  /// **'No pudimos cargar tus grupos.'**
  String get errorLoadingGroups;

  /// No description provided for @actionRetrySync.
  ///
  /// In es, this message translates to:
  /// **'Reintentar sincronización'**
  String get actionRetrySync;

  /// No description provided for @errorCreatingGroup.
  ///
  /// In es, this message translates to:
  /// **'No se pudo crear el grupo: {error}'**
  String errorCreatingGroup(String error);

  /// No description provided for @thematicGroupTitle.
  ///
  /// In es, this message translates to:
  /// **'Grupo temático'**
  String get thematicGroupTitle;

  /// No description provided for @thematicGroupMessage.
  ///
  /// In es, this message translates to:
  /// **'Este grupo tiene un filtro activo de géneros: {genres}.\n\nSolo los libros físicos de esos géneros serán visibles en este grupo.'**
  String thematicGroupMessage(String genres);

  /// No description provided for @actionGotIt.
  ///
  /// In es, this message translates to:
  /// **'Entendido'**
  String get actionGotIt;

  /// No description provided for @errorSyncing.
  ///
  /// In es, this message translates to:
  /// **'Error de sincronización: {error}'**
  String errorSyncing(String error);

  /// No description provided for @syncCompleted.
  ///
  /// In es, this message translates to:
  /// **'Sincronización completada.'**
  String get syncCompleted;

  /// No description provided for @joinGroupTitle.
  ///
  /// In es, this message translates to:
  /// **'Unirse a grupo'**
  String get joinGroupTitle;

  /// No description provided for @groupCodeLabel.
  ///
  /// In es, this message translates to:
  /// **'Código de grupo'**
  String get groupCodeLabel;

  /// No description provided for @successJoinedGroup.
  ///
  /// In es, this message translates to:
  /// **'¡Te has unido al grupo exitosamente!'**
  String get successJoinedGroup;

  /// No description provided for @pleaseEnterCode.
  ///
  /// In es, this message translates to:
  /// **'Por favor ingresa un código'**
  String get pleaseEnterCode;

  /// No description provided for @actionJoin.
  ///
  /// In es, this message translates to:
  /// **'Unirse'**
  String get actionJoin;

  /// No description provided for @errorInvalidCode.
  ///
  /// In es, this message translates to:
  /// **'El código no es válido o ya expiró. Verifícalo e intenta de nuevo.'**
  String get errorInvalidCode;

  /// No description provided for @coachMarkDiscoverShareTitle.
  ///
  /// In es, this message translates to:
  /// **'Comparte tus libros'**
  String get coachMarkDiscoverShareTitle;

  /// No description provided for @coachMarkDiscoverShareDesc.
  ///
  /// In es, this message translates to:
  /// **'Publica ejemplares para que tu grupo pueda solicitarlos rápidamente.'**
  String get coachMarkDiscoverShareDesc;

  /// No description provided for @coachMarkDiscoverFiltersTitle.
  ///
  /// In es, this message translates to:
  /// **'Filtra resultados'**
  String get coachMarkDiscoverFiltersTitle;

  /// No description provided for @coachMarkDiscoverFiltersDesc.
  ///
  /// In es, this message translates to:
  /// **'Usa estos filtros para ver libros de grupos o propietarios concretos.'**
  String get coachMarkDiscoverFiltersDesc;

  /// No description provided for @coachMarkDetailRequestTitle.
  ///
  /// In es, this message translates to:
  /// **'Solicita un préstamo'**
  String get coachMarkDetailRequestTitle;

  /// No description provided for @coachMarkDetailRequestDesc.
  ///
  /// In es, this message translates to:
  /// **'Desde aquí puedes pedir prestar el libro y coordinar la entrega.'**
  String get coachMarkDetailRequestDesc;

  /// No description provided for @coachMarkGroupInviteTitle.
  ///
  /// In es, this message translates to:
  /// **'Gestiona invitaciones'**
  String get coachMarkGroupInviteTitle;

  /// No description provided for @coachMarkGroupInviteDesc.
  ///
  /// In es, this message translates to:
  /// **'Invita a nuevas personas o revisa solicitudes pendientes de tu grupo.'**
  String get coachMarkGroupInviteDesc;

  /// No description provided for @actionNext.
  ///
  /// In es, this message translates to:
  /// **'Siguiente'**
  String get actionNext;

  /// No description provided for @actionDone.
  ///
  /// In es, this message translates to:
  /// **'Listo'**
  String get actionDone;

  /// No description provided for @actionSkip.
  ///
  /// In es, this message translates to:
  /// **'Saltar'**
  String get actionSkip;

  /// No description provided for @actionCreateGroupDialog.
  ///
  /// In es, this message translates to:
  /// **'Crear grupo'**
  String get actionCreateGroupDialog;

  /// No description provided for @groupNameLabel.
  ///
  /// In es, this message translates to:
  /// **'Nombre del grupo'**
  String get groupNameLabel;

  /// No description provided for @errorInvalidGroupName.
  ///
  /// In es, this message translates to:
  /// **'Introduce un nombre válido.'**
  String get errorInvalidGroupName;

  /// No description provided for @groupDescriptionLabel.
  ///
  /// In es, this message translates to:
  /// **'Descripción (opcional)'**
  String get groupDescriptionLabel;

  /// No description provided for @allowedGenresLabel.
  ///
  /// In es, this message translates to:
  /// **'Géneros permitidos'**
  String get allowedGenresLabel;

  /// No description provided for @optionalLabel.
  ///
  /// In es, this message translates to:
  /// **'(opcional)'**
  String get optionalLabel;

  /// No description provided for @genreFilterExplanation.
  ///
  /// In es, this message translates to:
  /// **'Si eliges géneros, solo los libros de esos géneros serán visibles en este grupo. Sin selección, se muestran todos.'**
  String get genreFilterExplanation;

  /// No description provided for @genreChangeLaterHint.
  ///
  /// In es, this message translates to:
  /// **'Puedes cambiar los géneros más tarde desde el menú del grupo.'**
  String get genreChangeLaterHint;

  /// No description provided for @actionSave.
  ///
  /// In es, this message translates to:
  /// **'Guardar'**
  String get actionSave;

  /// No description provided for @actionCreate.
  ///
  /// In es, this message translates to:
  /// **'Crear'**
  String get actionCreate;

  /// No description provided for @noActiveLoansInGroup.
  ///
  /// In es, this message translates to:
  /// **'No tienes préstamos activos en este grupo.'**
  String get noActiveLoansInGroup;

  /// No description provided for @yourLoansHeader.
  ///
  /// In es, this message translates to:
  /// **'Tus préstamos'**
  String get yourLoansHeader;

  /// No description provided for @errorLoadingLoans.
  ///
  /// In es, this message translates to:
  /// **'Error cargando préstamos: {error}'**
  String errorLoadingLoans(String error);

  /// No description provided for @errorIdentifyingBorrower.
  ///
  /// In es, this message translates to:
  /// **'No pudimos identificar al solicitante.'**
  String get errorIdentifyingBorrower;

  /// No description provided for @successLoanCancelled.
  ///
  /// In es, this message translates to:
  /// **'Solicitud cancelada.'**
  String get successLoanCancelled;

  /// No description provided for @errorCancellingLoan.
  ///
  /// In es, this message translates to:
  /// **'No se pudo cancelar la solicitud: {error}'**
  String errorCancellingLoan(String error);

  /// No description provided for @errorIdentifyingOwner.
  ///
  /// In es, this message translates to:
  /// **'No pudimos identificar al propietario.'**
  String get errorIdentifyingOwner;

  /// No description provided for @successLoanAccepted.
  ///
  /// In es, this message translates to:
  /// **'Préstamo aceptado.'**
  String get successLoanAccepted;

  /// No description provided for @errorAcceptingLoan.
  ///
  /// In es, this message translates to:
  /// **'No se pudo aceptar el préstamo: {error}'**
  String errorAcceptingLoan(String error);

  /// No description provided for @successLoanRejected.
  ///
  /// In es, this message translates to:
  /// **'Solicitud rechazada.'**
  String get successLoanRejected;

  /// No description provided for @errorRejectingLoan.
  ///
  /// In es, this message translates to:
  /// **'No se pudo rechazar la solicitud: {error}'**
  String errorRejectingLoan(String error);

  /// No description provided for @errorIdentifyingActiveUser.
  ///
  /// In es, this message translates to:
  /// **'No pudimos identificar al usuario activo.'**
  String get errorIdentifyingActiveUser;

  /// No description provided for @successLoanReturned.
  ///
  /// In es, this message translates to:
  /// **'Préstamo marcado como devuelto.'**
  String get successLoanReturned;

  /// No description provided for @errorMarkingReturned.
  ///
  /// In es, this message translates to:
  /// **'No se pudo marcar como devuelto: {error}'**
  String errorMarkingReturned(String error);

  /// No description provided for @errorPreparingRequest.
  ///
  /// In es, this message translates to:
  /// **'No pudimos preparar la solicitud para este libro.'**
  String get errorPreparingRequest;

  /// No description provided for @successLoanRequested.
  ///
  /// In es, this message translates to:
  /// **'Solicitud enviada.'**
  String get successLoanRequested;

  /// No description provided for @errorRequestingLoan.
  ///
  /// In es, this message translates to:
  /// **'No se pudo enviar la solicitud: {error}'**
  String errorRequestingLoan(String error);

  /// No description provided for @bookLabel.
  ///
  /// In es, this message translates to:
  /// **'Libro:'**
  String get bookLabel;

  /// No description provided for @noDueDate.
  ///
  /// In es, this message translates to:
  /// **'Sin fecha límite'**
  String get noDueDate;

  /// No description provided for @loanDatesLabel.
  ///
  /// In es, this message translates to:
  /// **'Inicio: {start} · Vence: {due}'**
  String loanDatesLabel(String start, String due);

  /// No description provided for @loanParticipantsLabel.
  ///
  /// In es, this message translates to:
  /// **'Solicitante: {borrower} · Propietario: {owner}'**
  String loanParticipantsLabel(String borrower, String owner);

  /// No description provided for @actionAccept.
  ///
  /// In es, this message translates to:
  /// **'Aceptar'**
  String get actionAccept;

  /// No description provided for @actionReject.
  ///
  /// In es, this message translates to:
  /// **'Rechazar'**
  String get actionReject;

  /// No description provided for @actionMarkReturned.
  ///
  /// In es, this message translates to:
  /// **'Marcar devuelto'**
  String get actionMarkReturned;

  /// No description provided for @bookStatsHeader.
  ///
  /// In es, this message translates to:
  /// **'Estadísticas de libros'**
  String get bookStatsHeader;

  /// No description provided for @totalLabel.
  ///
  /// In es, this message translates to:
  /// **'Total'**
  String get totalLabel;

  /// No description provided for @availableLabel.
  ///
  /// In es, this message translates to:
  /// **'Disponibles'**
  String get availableLabel;

  /// No description provided for @errorLoadingSharedBooks.
  ///
  /// In es, this message translates to:
  /// **'Error cargando libros compartidos: {error}'**
  String errorLoadingSharedBooks(String error);

  /// No description provided for @successSync.
  ///
  /// In es, this message translates to:
  /// **'Sincronización completada'**
  String get successSync;

  /// No description provided for @discoverTabTitle.
  ///
  /// In es, this message translates to:
  /// **'Descubrir'**
  String get discoverTabTitle;

  /// No description provided for @discoverTabDesc.
  ///
  /// In es, this message translates to:
  /// **'Explora los grupos a los que perteneces y descubre libros disponibles para solicitar préstamo.'**
  String get discoverTabDesc;

  /// No description provided for @noGroupsTitle.
  ///
  /// In es, this message translates to:
  /// **'Aún no perteneces a ningún grupo'**
  String get noGroupsTitle;

  /// No description provided for @noGroupsMessage.
  ///
  /// In es, this message translates to:
  /// **'Crea un grupo o únete con un código para empezar a compartir libros y gestionar préstamos.'**
  String get noGroupsMessage;

  /// No description provided for @actionJoinOrSync.
  ///
  /// In es, this message translates to:
  /// **'Unirme o sincronizar'**
  String get actionJoinOrSync;

  /// No description provided for @actionRetry.
  ///
  /// In es, this message translates to:
  /// **'Reintentar'**
  String get actionRetry;

  /// No description provided for @onboardingSlide1Title.
  ///
  /// In es, this message translates to:
  /// **'Tu propia colección'**
  String get onboardingSlide1Title;

  /// No description provided for @onboardingSlide1Message.
  ///
  /// In es, this message translates to:
  /// **'Cada libro cuenta una historia. Preserva las tuyas, añade notas y mantén viva la memoria de tus lecturas.'**
  String get onboardingSlide1Message;

  /// No description provided for @onboardingSlide2Title.
  ///
  /// In es, this message translates to:
  /// **'Círculos de Lectura'**
  String get onboardingSlide2Title;

  /// No description provided for @onboardingSlide2Message.
  ///
  /// In es, this message translates to:
  /// **'Donde las historias se encuentran. Únete a comunidades y descubre bibliotecas compartidas con otros lectores.'**
  String get onboardingSlide2Message;

  /// No description provided for @onboardingSlide3Title.
  ///
  /// In es, this message translates to:
  /// **'El viaje del libro'**
  String get onboardingSlide3Title;

  /// No description provided for @onboardingSlide3Message.
  ///
  /// In es, this message translates to:
  /// **'Sigue el rastro de cada ejemplar prestado. Gestiona devoluciones y comparte el conocimiento con confianza.'**
  String get onboardingSlide3Message;

  /// No description provided for @onboardingSlide4Title.
  ///
  /// In es, this message translates to:
  /// **'Crónica en la nube'**
  String get onboardingSlide4Title;

  /// No description provided for @onboardingSlide4Message.
  ///
  /// In es, this message translates to:
  /// **'Tu catálogo se preserva en Supabase, disponible siempre para continuar la historia desde cualquier lugar.'**
  String get onboardingSlide4Message;

  /// No description provided for @actionStartChronicle.
  ///
  /// In es, this message translates to:
  /// **'Comenzar Crónica'**
  String get actionStartChronicle;

  /// No description provided for @actionNextPage.
  ///
  /// In es, this message translates to:
  /// **'Siguiente Página'**
  String get actionNextPage;

  /// No description provided for @actionSkipPrologue.
  ///
  /// In es, this message translates to:
  /// **'Saltar Prólogo'**
  String get actionSkipPrologue;

  /// No description provided for @welcomeToApp.
  ///
  /// In es, this message translates to:
  /// **'¡Listo! Bienvenido a Book Sharing.'**
  String get welcomeToApp;

  /// No description provided for @stepSkippedHint.
  ///
  /// In es, this message translates to:
  /// **'Paso omitido. Puedes configurarlo más tarde desde la ayuda.'**
  String get stepSkippedHint;

  /// No description provided for @errorSyncingAccount.
  ///
  /// In es, this message translates to:
  /// **'Estamos terminando de sincronizar tu cuenta. Intenta en unos segundos.'**
  String get errorSyncingAccount;

  /// No description provided for @groupAlreadyExists.
  ///
  /// In es, this message translates to:
  /// **'Ya tienes un grupo llamado \"{name}\".'**
  String groupAlreadyExists(String name);

  /// No description provided for @successGroupCreatedWizard.
  ///
  /// In es, this message translates to:
  /// **'Grupo \"{name}\" creado correctamente.'**
  String successGroupCreatedWizard(String name);

  /// No description provided for @errorCreatingGroupWizard.
  ///
  /// In es, this message translates to:
  /// **'No se pudo crear el grupo: {error}'**
  String errorCreatingGroupWizard(String error);

  /// No description provided for @errorJoiningGroupWizard.
  ///
  /// In es, this message translates to:
  /// **'No se pudo unir al grupo: {error}'**
  String errorJoiningGroupWizard(String error);

  /// No description provided for @errorLoadingOnboarding.
  ///
  /// In es, this message translates to:
  /// **'No pudimos cargar el estado del onboarding.'**
  String get errorLoadingOnboarding;

  /// No description provided for @onboardingWizardTitle.
  ///
  /// In es, this message translates to:
  /// **'Comienza tu historia'**
  String get onboardingWizardTitle;

  /// No description provided for @actionSkipIntro.
  ///
  /// In es, this message translates to:
  /// **'Saltar Introducción'**
  String get actionSkipIntro;

  /// No description provided for @actionSealPact.
  ///
  /// In es, this message translates to:
  /// **'Sellar Pacto'**
  String get actionSealPact;

  /// No description provided for @actionContinueWizard.
  ///
  /// In es, this message translates to:
  /// **'Continuar'**
  String get actionContinueWizard;

  /// No description provided for @actionSkipChapter.
  ///
  /// In es, this message translates to:
  /// **'Omitir Capítulo'**
  String get actionSkipChapter;

  /// No description provided for @wizardStep1Title.
  ///
  /// In es, this message translates to:
  /// **'Capítulo 1: La Fundación'**
  String get wizardStep1Title;

  /// No description provided for @wizardStep1Subtitle.
  ///
  /// In es, this message translates to:
  /// **'Crea un círculo para compartir tus volúmenes.'**
  String get wizardStep1Subtitle;

  /// No description provided for @wizardStep1Content.
  ///
  /// In es, this message translates to:
  /// **'Un grupo te permite compartir libros con otros miembros. Puedes crear uno nuevo ahora o hacerlo más tarde.'**
  String get wizardStep1Content;

  /// No description provided for @syncingAccountTitle.
  ///
  /// In es, this message translates to:
  /// **'Sincronizando tu cuenta...'**
  String get syncingAccountTitle;

  /// No description provided for @syncingAccountSubtitle.
  ///
  /// In es, this message translates to:
  /// **'En cuanto terminemos podrás crear grupos.'**
  String get syncingAccountSubtitle;

  /// No description provided for @groupNameHint.
  ///
  /// In es, this message translates to:
  /// **'Ej. Club de lectura Aficionados'**
  String get groupNameHint;

  /// No description provided for @errorGroupNameRequired.
  ///
  /// In es, this message translates to:
  /// **'Introduce un nombre para el grupo.'**
  String get errorGroupNameRequired;

  /// No description provided for @learnAboutGroupsAction.
  ///
  /// In es, this message translates to:
  /// **'Aprender sobre grupos'**
  String get learnAboutGroupsAction;

  /// No description provided for @wizardStep2Title.
  ///
  /// In es, this message translates to:
  /// **'Capítulo 2: La Alianza'**
  String get wizardStep2Title;

  /// No description provided for @wizardStep2Subtitle.
  ///
  /// In es, this message translates to:
  /// **'Únete a un círculo existente mediante código.'**
  String get wizardStep2Subtitle;

  /// No description provided for @wizardStep2Content.
  ///
  /// In es, this message translates to:
  /// **'Si has recibido una invitación, este es el momento de responder al llamado.'**
  String get wizardStep2Content;

  /// No description provided for @syncingAccountSubtitleJoin.
  ///
  /// In es, this message translates to:
  /// **'Necesitamos tu usuario activo para validar el código.'**
  String get syncingAccountSubtitleJoin;

  /// No description provided for @labelInvitationCode.
  ///
  /// In es, this message translates to:
  /// **'Código de invitación'**
  String get labelInvitationCode;

  /// No description provided for @invitationCodeHint.
  ///
  /// In es, this message translates to:
  /// **'Ej. 123e4567-e89b-12d3-a456-426614174000'**
  String get invitationCodeHint;

  /// No description provided for @errorInvalidCodeWizard.
  ///
  /// In es, this message translates to:
  /// **'Introduce un código válido o pulsa \"Omitir paso\".'**
  String get errorInvalidCodeWizard;

  /// No description provided for @errorCodeTooShort.
  ///
  /// In es, this message translates to:
  /// **'El código es demasiado corto.'**
  String get errorCodeTooShort;

  /// No description provided for @wizardStep3Title.
  ///
  /// In es, this message translates to:
  /// **'Epílogo: Confirmaciones'**
  String get wizardStep3Title;

  /// No description provided for @wizardStep3Subtitle.
  ///
  /// In es, this message translates to:
  /// **'Revisa lo escrito antes de cerrar el libro.'**
  String get wizardStep3Subtitle;

  /// No description provided for @whatIsGroupTitle.
  ///
  /// In es, this message translates to:
  /// **'¿Qué es un grupo?'**
  String get whatIsGroupTitle;

  /// No description provided for @whatIsGroupContent.
  ///
  /// In es, this message translates to:
  /// **'Los grupos reúnen a tus amigos o familiares para compartir bibliotecas locales. Desde aquí podrás invitar miembros, gestionar préstamos y llevar un historial conjunto.'**
  String get whatIsGroupContent;

  /// No description provided for @whatIsGroupContent2.
  ///
  /// In es, this message translates to:
  /// **'Puedes crear varios grupos: uno para tu familia, otro para tu club de lectura, etc. Cada grupo tiene sus propias invitaciones y catálogos.'**
  String get whatIsGroupContent2;

  /// No description provided for @statusCompleted.
  ///
  /// In es, this message translates to:
  /// **'Completado'**
  String get statusCompleted;

  /// No description provided for @statusPending.
  ///
  /// In es, this message translates to:
  /// **'Pendiente'**
  String get statusPending;

  /// No description provided for @almostDoneTitle.
  ///
  /// In es, this message translates to:
  /// **'¡Ya casi terminamos!'**
  String get almostDoneTitle;

  /// No description provided for @onboardingSummaryMessage.
  ///
  /// In es, this message translates to:
  /// **'Estos son los pasos que configuraste. Puedes volver atrás si quieres ajustar algo antes de empezar.'**
  String get onboardingSummaryMessage;

  /// No description provided for @profileConfiguredTitle.
  ///
  /// In es, this message translates to:
  /// **'Perfil configurado'**
  String get profileConfiguredTitle;

  /// No description provided for @userLabel.
  ///
  /// In es, this message translates to:
  /// **'Usuario: {name}'**
  String userLabel(String name);

  /// No description provided for @firstGroupTitle.
  ///
  /// In es, this message translates to:
  /// **'Primer grupo'**
  String get firstGroupTitle;

  /// No description provided for @firstGroupSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Creaste tu comunidad principal.'**
  String get firstGroupSubtitle;

  /// No description provided for @joinByCodeTitle.
  ///
  /// In es, this message translates to:
  /// **'Unión por código'**
  String get joinByCodeTitle;

  /// No description provided for @joinByCodeSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Te uniste a un grupo existente.'**
  String get joinByCodeSubtitle;

  /// No description provided for @finishOnboardingMessage.
  ///
  /// In es, this message translates to:
  /// **'Al pulsar “Finalizar” sincronizaremos tu información y te llevaremos a tu biblioteca.'**
  String get finishOnboardingMessage;

  /// No description provided for @notificationLoanApproved.
  ///
  /// In es, this message translates to:
  /// **'Préstamo aceptado'**
  String get notificationLoanApproved;

  /// No description provided for @notificationLoanRejected.
  ///
  /// In es, this message translates to:
  /// **'Solicitud rechazada'**
  String get notificationLoanRejected;

  /// No description provided for @notificationLoanCancelled.
  ///
  /// In es, this message translates to:
  /// **'Solicitud cancelada'**
  String get notificationLoanCancelled;

  /// No description provided for @notificationLoanReturned.
  ///
  /// In es, this message translates to:
  /// **'Préstamo devuelto'**
  String get notificationLoanReturned;

  /// No description provided for @notificationLoanExpired.
  ///
  /// In es, this message translates to:
  /// **'Préstamo vencido'**
  String get notificationLoanExpired;

  /// No description provided for @notificationLoanDueSoon.
  ///
  /// In es, this message translates to:
  /// **'Préstamo por vencer'**
  String get notificationLoanDueSoon;

  /// No description provided for @notificationMemberJoined.
  ///
  /// In es, this message translates to:
  /// **'Nuevo miembro en el grupo'**
  String get notificationMemberJoined;

  /// No description provided for @notificationMemberLeft.
  ///
  /// In es, this message translates to:
  /// **'Miembro dejó el grupo'**
  String get notificationMemberLeft;

  /// No description provided for @notificationGroupUpdated.
  ///
  /// In es, this message translates to:
  /// **'Grupo actualizado'**
  String get notificationGroupUpdated;

  /// No description provided for @notificationGroupDeleted.
  ///
  /// In es, this message translates to:
  /// **'Grupo eliminado'**
  String get notificationGroupDeleted;

  /// No description provided for @notificationLoanRequested.
  ///
  /// In es, this message translates to:
  /// **'Nueva solicitud de préstamo'**
  String get notificationLoanRequested;

  /// No description provided for @actionMarkAsRead.
  ///
  /// In es, this message translates to:
  /// **'Marcar como leído'**
  String get actionMarkAsRead;

  /// No description provided for @actionDismiss.
  ///
  /// In es, this message translates to:
  /// **'Descartar'**
  String get actionDismiss;

  /// No description provided for @noNotificationsToClear.
  ///
  /// In es, this message translates to:
  /// **'No hay notificaciones para limpiar.'**
  String get noNotificationsToClear;

  /// No description provided for @errorNoUserToClearNotifications.
  ///
  /// In es, this message translates to:
  /// **'Configura un usuario activo antes de limpiar.'**
  String get errorNoUserToClearNotifications;

  /// No description provided for @successNotificationsCleared.
  ///
  /// In es, this message translates to:
  /// **'Notificaciones borradas.'**
  String get successNotificationsCleared;

  /// No description provided for @errorClearingNotifications.
  ///
  /// In es, this message translates to:
  /// **'No se pudieron borrar las notificaciones: {error}'**
  String errorClearingNotifications(String error);

  /// No description provided for @notificationsTitle.
  ///
  /// In es, this message translates to:
  /// **'Notificaciones'**
  String get notificationsTitle;

  /// No description provided for @actionClearAll.
  ///
  /// In es, this message translates to:
  /// **'Vaciar'**
  String get actionClearAll;

  /// No description provided for @actionClose.
  ///
  /// In es, this message translates to:
  /// **'Cerrar'**
  String get actionClose;

  /// No description provided for @emptyLoansTitle.
  ///
  /// In es, this message translates to:
  /// **'Sin actividad de préstamos'**
  String get emptyLoansTitle;

  /// No description provided for @emptyLoansMessage.
  ///
  /// In es, this message translates to:
  /// **'Tus solicitudes y libros prestados aparecerán aquí.'**
  String get emptyLoansMessage;

  /// No description provided for @emptyLoansAction.
  ///
  /// In es, this message translates to:
  /// **'Registrar préstamo manual'**
  String get emptyLoansAction;

  /// No description provided for @noNotificationsTitle.
  ///
  /// In es, this message translates to:
  /// **'Sin notificaciones'**
  String get noNotificationsTitle;

  /// No description provided for @noNotificationsMessage.
  ///
  /// In es, this message translates to:
  /// **'Aquí verás las novedades sobre tus préstamos y solicitudes.'**
  String get noNotificationsMessage;

  /// No description provided for @errorLoadingNotifications.
  ///
  /// In es, this message translates to:
  /// **'No se pudieron cargar'**
  String get errorLoadingNotifications;

  /// No description provided for @notificationsTooltip.
  ///
  /// In es, this message translates to:
  /// **'{count, plural, =0{Notificaciones} =1{Tienes 1 notificación} other{Tienes {count} notificaciones}}'**
  String notificationsTooltip(num count);

  /// No description provided for @syncingLabel.
  ///
  /// In es, this message translates to:
  /// **'Sincronizando...'**
  String get syncingLabel;

  /// No description provided for @defaultSyncError.
  ///
  /// In es, this message translates to:
  /// **'Se ha encontrado un error.'**
  String get defaultSyncError;

  /// No description provided for @localChangesReadySync.
  ///
  /// In es, this message translates to:
  /// **'Cambios locales listos para sincronizar.'**
  String get localChangesReadySync;

  /// No description provided for @clubDetailProposals.
  ///
  /// In es, this message translates to:
  /// **'Propuestas'**
  String get clubDetailProposals;

  /// No description provided for @clubDetailMembers.
  ///
  /// In es, this message translates to:
  /// **'Miembros'**
  String get clubDetailMembers;

  /// No description provided for @clubDetailReadingNow.
  ///
  /// In es, this message translates to:
  /// **'LEYENDO AHORA'**
  String get clubDetailReadingNow;

  /// No description provided for @clubDetailNoActiveBook.
  ///
  /// In es, this message translates to:
  /// **'No hay libro activo'**
  String get clubDetailNoActiveBook;

  /// No description provided for @clubDetailAddBook.
  ///
  /// In es, this message translates to:
  /// **'Añadir Libro'**
  String get clubDetailAddBook;

  /// No description provided for @clubDetailDiscussion.
  ///
  /// In es, this message translates to:
  /// **'Discusión'**
  String get clubDetailDiscussion;

  /// No description provided for @clubDetailUpdateProgress.
  ///
  /// In es, this message translates to:
  /// **'Actualizar'**
  String get clubDetailUpdateProgress;

  /// No description provided for @clubDetailNoProposals.
  ///
  /// In es, this message translates to:
  /// **'No hay propuestas activas'**
  String get clubDetailNoProposals;

  /// No description provided for @clubDetailProposalUnavailable.
  ///
  /// In es, this message translates to:
  /// **'Detalles no disponibles para este libro propuesto'**
  String get clubDetailProposalUnavailable;

  /// No description provided for @clubDetailUnknownAuthor.
  ///
  /// In es, this message translates to:
  /// **'Autor desconocido'**
  String get clubDetailUnknownAuthor;

  /// No description provided for @clubDetailSection.
  ///
  /// In es, this message translates to:
  /// **'Sección {current}/{total}'**
  String clubDetailSection(Object current, Object total);

  /// No description provided for @clubMembersTitle.
  ///
  /// In es, this message translates to:
  /// **'Miembros del Club'**
  String get clubMembersTitle;

  /// No description provided for @clubMembersEmpty.
  ///
  /// In es, this message translates to:
  /// **'No hay miembros (esto es raro)'**
  String get clubMembersEmpty;

  /// No description provided for @clubMembersKick.
  ///
  /// In es, this message translates to:
  /// **'Expulsar'**
  String get clubMembersKick;

  /// No description provided for @clubMembersKickConfirmTitle.
  ///
  /// In es, this message translates to:
  /// **'¿Expulsar a {username}?'**
  String clubMembersKickConfirmTitle(String username);

  /// No description provided for @clubMembersKickConfirmMessage.
  ///
  /// In es, this message translates to:
  /// **'Esta acción eliminará al usuario del club. ¿Estás seguro?'**
  String get clubMembersKickConfirmMessage;

  /// No description provided for @clubMembersKickSuccess.
  ///
  /// In es, this message translates to:
  /// **'Usuario expulsado'**
  String get clubMembersKickSuccess;

  /// No description provided for @clubMembersRoleOwner.
  ///
  /// In es, this message translates to:
  /// **'Admin'**
  String get clubMembersRoleOwner;

  /// No description provided for @clubMembersRoleMember.
  ///
  /// In es, this message translates to:
  /// **'Miem.'**
  String get clubMembersRoleMember;

  /// No description provided for @clubProposalsTitle.
  ///
  /// In es, this message translates to:
  /// **'Propuestas de Lectura'**
  String get clubProposalsTitle;

  /// No description provided for @clubProposalsEmpty.
  ///
  /// In es, this message translates to:
  /// **'No hay propuestas activas'**
  String get clubProposalsEmpty;

  /// No description provided for @clubProposalsPropose.
  ///
  /// In es, this message translates to:
  /// **'Proponer'**
  String get clubProposalsPropose;

  /// No description provided for @clubProposalsLoginRequired.
  ///
  /// In es, this message translates to:
  /// **'Debes iniciar sesión para votar'**
  String get clubProposalsLoginRequired;

  /// No description provided for @clubProposalsChapters.
  ///
  /// In es, this message translates to:
  /// **'{count} caps'**
  String clubProposalsChapters(Object count);

  /// No description provided for @clubSettingsTitle.
  ///
  /// In es, this message translates to:
  /// **'Configuración del Club'**
  String get clubSettingsTitle;

  /// No description provided for @clubSettingsSaved.
  ///
  /// In es, this message translates to:
  /// **'Configuración guardada'**
  String get clubSettingsSaved;

  /// No description provided for @clubSettingsName.
  ///
  /// In es, this message translates to:
  /// **'Nombre del Club'**
  String get clubSettingsName;

  /// No description provided for @clubSettingsDescription.
  ///
  /// In es, this message translates to:
  /// **'Descripción'**
  String get clubSettingsDescription;

  /// No description provided for @clubSettingsCity.
  ///
  /// In es, this message translates to:
  /// **'Lugar de reunión'**
  String get clubSettingsCity;

  /// No description provided for @clubSettingsFrequency.
  ///
  /// In es, this message translates to:
  /// **'Frecuencia de lectura'**
  String get clubSettingsFrequency;

  /// No description provided for @clubSettingsCustomFrequency.
  ///
  /// In es, this message translates to:
  /// **'Periodicidad Personalizada'**
  String get clubSettingsCustomFrequency;

  /// No description provided for @clubSettingsCustomFrequencyDays.
  ///
  /// In es, this message translates to:
  /// **'Días asignados para leer cada sección'**
  String get clubSettingsCustomFrequencyDays;

  /// No description provided for @clubSettingsDeleteButton.
  ///
  /// In es, this message translates to:
  /// **'Eliminar Club'**
  String get clubSettingsDeleteButton;

  /// No description provided for @clubSettingsDeleteTitle.
  ///
  /// In es, this message translates to:
  /// **'¿Eliminar Club?'**
  String get clubSettingsDeleteTitle;

  /// No description provided for @clubSettingsDeleteMessage.
  ///
  /// In es, this message translates to:
  /// **'Esta acción no se puede deshacer. Todos los datos del club serán eliminados.'**
  String get clubSettingsDeleteMessage;

  /// No description provided for @clubSettingsDeleteSuccess.
  ///
  /// In es, this message translates to:
  /// **'Club eliminado'**
  String get clubSettingsDeleteSuccess;

  /// No description provided for @clubListCreateGroup.
  ///
  /// In es, this message translates to:
  /// **'Crear Grupo'**
  String get clubListCreateGroup;

  /// No description provided for @clubListJoinByCode.
  ///
  /// In es, this message translates to:
  /// **'Unirse por código'**
  String get clubListJoinByCode;

  /// No description provided for @clubListEmpty.
  ///
  /// In es, this message translates to:
  /// **'Aún no tienes clubes de lectura'**
  String get clubListEmpty;

  /// No description provided for @clubListJoinTitle.
  ///
  /// In es, this message translates to:
  /// **'Unirse a Club'**
  String get clubListJoinTitle;

  /// No description provided for @clubListJoinIdLabel.
  ///
  /// In es, this message translates to:
  /// **'ID del Club'**
  String get clubListJoinIdLabel;

  /// No description provided for @clubListJoinIdHint.
  ///
  /// In es, this message translates to:
  /// **'Ingresa el código UUID del club'**
  String get clubListJoinIdHint;

  /// No description provided for @sectionDiscussionLoginRequired.
  ///
  /// In es, this message translates to:
  /// **'Debes iniciar sesión para comentar'**
  String get sectionDiscussionLoginRequired;

  /// No description provided for @sectionDiscussionTitle.
  ///
  /// In es, this message translates to:
  /// **'Discusión Sección {number}'**
  String sectionDiscussionTitle(Object number);

  /// No description provided for @sectionDiscussionFirstComment.
  ///
  /// In es, this message translates to:
  /// **'Sé el primero en comentar'**
  String get sectionDiscussionFirstComment;

  /// No description provided for @sectionDiscussionHint.
  ///
  /// In es, this message translates to:
  /// **'Escribe un comentario...'**
  String get sectionDiscussionHint;

  /// No description provided for @lockScreenTitle.
  ///
  /// In es, this message translates to:
  /// **'Desbloquea tu biblioteca'**
  String get lockScreenTitle;

  /// No description provided for @lockScreenSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Introduce tu llave para acceder'**
  String get lockScreenSubtitle;

  /// No description provided for @lockScreenBiometric.
  ///
  /// In es, this message translates to:
  /// **'Usar huella'**
  String get lockScreenBiometric;

  /// No description provided for @lockScreenThrottled.
  ///
  /// In es, this message translates to:
  /// **'La cerradura está atascada temporalmente. Espera un momento.'**
  String get lockScreenThrottled;

  /// No description provided for @pinSetupNameLabel.
  ///
  /// In es, this message translates to:
  /// **'Nombre o Alias'**
  String get pinSetupNameLabel;

  /// No description provided for @pinSetupNameHint.
  ///
  /// In es, this message translates to:
  /// **'Ej. El Bibliotecario'**
  String get pinSetupNameHint;

  /// No description provided for @pinSetupPinLabel.
  ///
  /// In es, this message translates to:
  /// **'Forja tu llave maestra (4 dígitos)'**
  String get pinSetupPinLabel;

  /// No description provided for @pinSetupConfirmLabel.
  ///
  /// In es, this message translates to:
  /// **'Confirma la llave'**
  String get pinSetupConfirmLabel;

  /// No description provided for @pinSetupExistingAccount.
  ///
  /// In es, this message translates to:
  /// **'¿Ya tienes una cuenta? Recupérala aquí'**
  String get pinSetupExistingAccount;

  /// No description provided for @loginTitle.
  ///
  /// In es, this message translates to:
  /// **'Inicio con usuario existente'**
  String get loginTitle;

  /// No description provided for @loginUsernameLabel.
  ///
  /// In es, this message translates to:
  /// **'Nombre de usuario'**
  String get loginUsernameLabel;

  /// No description provided for @loginUsernameHint.
  ///
  /// In es, this message translates to:
  /// **'Ej. ana_lectora'**
  String get loginUsernameHint;

  /// No description provided for @loginSubmit.
  ///
  /// In es, this message translates to:
  /// **'Acceder'**
  String get loginSubmit;

  /// No description provided for @loginBack.
  ///
  /// In es, this message translates to:
  /// **'Volver'**
  String get loginBack;

  /// No description provided for @addBookToClubTitle.
  ///
  /// In es, this message translates to:
  /// **'Añadir Libro'**
  String get addBookToClubTitle;

  /// No description provided for @addBookToClubSelectBook.
  ///
  /// In es, this message translates to:
  /// **'Selecciona un libro'**
  String get addBookToClubSelectBook;

  /// No description provided for @addBookToClubInvalidChapters.
  ///
  /// In es, this message translates to:
  /// **'Ingresa un número válido de capítulos'**
  String get addBookToClubInvalidChapters;

  /// No description provided for @addBookToClubAdded.
  ///
  /// In es, this message translates to:
  /// **'Libro añadido al club'**
  String get addBookToClubAdded;

  /// No description provided for @addBookToClubSearchHint.
  ///
  /// In es, this message translates to:
  /// **'Buscar libro (Local o Google Books)'**
  String get addBookToClubSearchHint;

  /// No description provided for @addBookToClubNoResults.
  ///
  /// In es, this message translates to:
  /// **'No se encontraron libros'**
  String get addBookToClubNoResults;

  /// No description provided for @addBookToClubLocalSection.
  ///
  /// In es, this message translates to:
  /// **'En tu biblioteca'**
  String get addBookToClubLocalSection;

  /// No description provided for @addBookToClubGoogleSection.
  ///
  /// In es, this message translates to:
  /// **'En Google Books'**
  String get addBookToClubGoogleSection;

  /// No description provided for @addBookToClubChaptersLabel.
  ///
  /// In es, this message translates to:
  /// **'Número de Capítulos'**
  String get addBookToClubChaptersLabel;

  /// No description provided for @addBookToClubSectionMode.
  ///
  /// In es, this message translates to:
  /// **'Modo de Secciones'**
  String get addBookToClubSectionMode;

  /// No description provided for @addBookToClubStartDate.
  ///
  /// In es, this message translates to:
  /// **'Fecha de Inicio'**
  String get addBookToClubStartDate;

  /// No description provided for @addBookToClubSelectDate.
  ///
  /// In es, this message translates to:
  /// **'Seleccionar'**
  String get addBookToClubSelectDate;

  /// No description provided for @createClubTitle.
  ///
  /// In es, this message translates to:
  /// **'Crear Club de Lectura'**
  String get createClubTitle;

  /// No description provided for @createClubSuccess.
  ///
  /// In es, this message translates to:
  /// **'Club creado exitosamente'**
  String get createClubSuccess;

  /// No description provided for @createClubNameLabel.
  ///
  /// In es, this message translates to:
  /// **'Nombre del Club'**
  String get createClubNameLabel;

  /// No description provided for @createClubDescriptionLabel.
  ///
  /// In es, this message translates to:
  /// **'Descripción'**
  String get createClubDescriptionLabel;

  /// No description provided for @createClubCityLabel.
  ///
  /// In es, this message translates to:
  /// **'Ciudad'**
  String get createClubCityLabel;

  /// No description provided for @createClubFrequencyLabel.
  ///
  /// In es, this message translates to:
  /// **'Frecuencia de Lectura'**
  String get createClubFrequencyLabel;

  /// No description provided for @createClubCustomFrequency.
  ///
  /// In es, this message translates to:
  /// **'Periodicidad Personalizada'**
  String get createClubCustomFrequency;

  /// No description provided for @createClubCustomDays.
  ///
  /// In es, this message translates to:
  /// **'Días asignados para leer cada sección'**
  String get createClubCustomDays;

  /// No description provided for @proposeBookTitle.
  ///
  /// In es, this message translates to:
  /// **'Proponer Libro'**
  String get proposeBookTitle;

  /// No description provided for @proposeBookSuccess.
  ///
  /// In es, this message translates to:
  /// **'Libro propuesto exitosamente'**
  String get proposeBookSuccess;

  /// No description provided for @proposeBookSelectBook.
  ///
  /// In es, this message translates to:
  /// **'Selecciona un libro'**
  String get proposeBookSelectBook;

  /// No description provided for @proposeBookSearchHint.
  ///
  /// In es, this message translates to:
  /// **'Buscar libro (Local o Google Books)'**
  String get proposeBookSearchHint;

  /// No description provided for @proposeBookNoResults.
  ///
  /// In es, this message translates to:
  /// **'No se encontraron libros'**
  String get proposeBookNoResults;

  /// No description provided for @proposeBookLocalSection.
  ///
  /// In es, this message translates to:
  /// **'En tu biblioteca'**
  String get proposeBookLocalSection;

  /// No description provided for @proposeBookGoogleSection.
  ///
  /// In es, this message translates to:
  /// **'En Google Books'**
  String get proposeBookGoogleSection;

  /// No description provided for @proposeBookChaptersLabel.
  ///
  /// In es, this message translates to:
  /// **'Número de Capítulos'**
  String get proposeBookChaptersLabel;

  /// No description provided for @updateProgressTitle.
  ///
  /// In es, this message translates to:
  /// **'Actualizar Progreso'**
  String get updateProgressTitle;

  /// No description provided for @updateProgressSectionLabel.
  ///
  /// In es, this message translates to:
  /// **'¿Por qué sección vas?'**
  String get updateProgressSectionLabel;

  /// No description provided for @updateProgressStatusLabel.
  ///
  /// In es, this message translates to:
  /// **'Estado de lectura'**
  String get updateProgressStatusLabel;

  /// No description provided for @bookFormGenres.
  ///
  /// In es, this message translates to:
  /// **'Géneros'**
  String get bookFormGenres;

  /// No description provided for @bookFormAddGenre.
  ///
  /// In es, this message translates to:
  /// **'Añadir género'**
  String get bookFormAddGenre;

  /// No description provided for @bookFormTitle.
  ///
  /// In es, this message translates to:
  /// **'Título'**
  String get bookFormTitle;

  /// No description provided for @bookFormAuthor.
  ///
  /// In es, this message translates to:
  /// **'Autor'**
  String get bookFormAuthor;

  /// No description provided for @bookFormIsbn.
  ///
  /// In es, this message translates to:
  /// **'ISBN'**
  String get bookFormIsbn;

  /// No description provided for @bookFormIsbnOptional.
  ///
  /// In es, this message translates to:
  /// **'ISBN (opcional)'**
  String get bookFormIsbnOptional;

  /// No description provided for @bookFormAuthorOptional.
  ///
  /// In es, this message translates to:
  /// **'Autor (opcional)'**
  String get bookFormAuthorOptional;

  /// No description provided for @bookFormBarcode.
  ///
  /// In es, this message translates to:
  /// **'Código barras'**
  String get bookFormBarcode;

  /// No description provided for @bookFormScanBarcode.
  ///
  /// In es, this message translates to:
  /// **'Escanear código'**
  String get bookFormScanBarcode;

  /// No description provided for @bookFormPages.
  ///
  /// In es, this message translates to:
  /// **'Páginas'**
  String get bookFormPages;

  /// No description provided for @bookFormPageHint.
  ///
  /// In es, this message translates to:
  /// **'Ej: 350'**
  String get bookFormPageHint;

  /// No description provided for @bookFormYear.
  ///
  /// In es, this message translates to:
  /// **'Año publicación'**
  String get bookFormYear;

  /// No description provided for @bookFormYearHint.
  ///
  /// In es, this message translates to:
  /// **'Ej: 2020'**
  String get bookFormYearHint;

  /// No description provided for @bookFormNotes.
  ///
  /// In es, this message translates to:
  /// **'Notas'**
  String get bookFormNotes;

  /// No description provided for @bookFormShareBook.
  ///
  /// In es, this message translates to:
  /// **'Compartir libro'**
  String get bookFormShareBook;

  /// No description provided for @bookFormAvailable.
  ///
  /// In es, this message translates to:
  /// **'Disponible'**
  String get bookFormAvailable;

  /// No description provided for @bookFormPrivate.
  ///
  /// In es, this message translates to:
  /// **'Privado'**
  String get bookFormPrivate;

  /// No description provided for @bookFormLoaned.
  ///
  /// In es, this message translates to:
  /// **'Prestado'**
  String get bookFormLoaned;

  /// No description provided for @bookFormClearForm.
  ///
  /// In es, this message translates to:
  /// **'Limpiar formulario'**
  String get bookFormClearForm;

  /// No description provided for @bookFormStatus.
  ///
  /// In es, this message translates to:
  /// **'Estado del libro'**
  String get bookFormStatus;

  /// No description provided for @bookFormReadingStatus.
  ///
  /// In es, this message translates to:
  /// **'Estado de lectura'**
  String get bookFormReadingStatus;

  /// No description provided for @bookFormDuplicateTitle.
  ///
  /// In es, this message translates to:
  /// **'Libro duplicado'**
  String get bookFormDuplicateTitle;

  /// No description provided for @bookFormUnderstood.
  ///
  /// In es, this message translates to:
  /// **'Entendido'**
  String get bookFormUnderstood;

  /// No description provided for @bookFormDeleteTitle.
  ///
  /// In es, this message translates to:
  /// **'Eliminar libro'**
  String get bookFormDeleteTitle;

  /// No description provided for @bookFormDeleteMessage.
  ///
  /// In es, this message translates to:
  /// **'¿Seguro que deseas eliminar \"{title}\"?'**
  String bookFormDeleteMessage(String title);

  /// No description provided for @bookFormSelectGenresTitle.
  ///
  /// In es, this message translates to:
  /// **'Seleccionar géneros'**
  String get bookFormSelectGenresTitle;

  /// No description provided for @bookFormSearchGenre.
  ///
  /// In es, this message translates to:
  /// **'Buscar género...'**
  String get bookFormSearchGenre;

  /// No description provided for @bookFormNoActiveUser.
  ///
  /// In es, this message translates to:
  /// **'Necesitas un usuario activo para compartir tus libros.'**
  String get bookFormNoActiveUser;

  /// No description provided for @bookDetails.
  ///
  /// In es, this message translates to:
  /// **'Detalles del libro'**
  String get bookDetails;

  /// No description provided for @bookDetailsSynopsis.
  ///
  /// In es, this message translates to:
  /// **'Sinopsis'**
  String get bookDetailsSynopsis;

  /// No description provided for @bookDetailsWhoRead.
  ///
  /// In es, this message translates to:
  /// **'¿Quién lo ha leído?'**
  String get bookDetailsWhoRead;

  /// No description provided for @bookDetailsOpine.
  ///
  /// In es, this message translates to:
  /// **'Opinar'**
  String get bookDetailsOpine;

  /// No description provided for @bookDetailsNoOpinions.
  ///
  /// In es, this message translates to:
  /// **'Nadie ha opinado todavía'**
  String get bookDetailsNoOpinions;

  /// No description provided for @bookDetailsSeeAllOpinions.
  ///
  /// In es, this message translates to:
  /// **'Ver todas las opiniones'**
  String get bookDetailsSeeAllOpinions;

  /// No description provided for @bookDetailsStarted.
  ///
  /// In es, this message translates to:
  /// **'Empezado'**
  String get bookDetailsStarted;

  /// No description provided for @bookDetailsFinished.
  ///
  /// In es, this message translates to:
  /// **'Terminado'**
  String get bookDetailsFinished;

  /// No description provided for @bookDetailsDuration.
  ///
  /// In es, this message translates to:
  /// **'Duración'**
  String get bookDetailsDuration;

  /// No description provided for @bookDetailsPagesRead.
  ///
  /// In es, this message translates to:
  /// **'Páginas leídas'**
  String get bookDetailsPagesRead;

  /// No description provided for @bookDetailsAvgRhythm.
  ///
  /// In es, this message translates to:
  /// **'Ritmo medio'**
  String get bookDetailsAvgRhythm;

  /// No description provided for @bookDetailsDigital.
  ///
  /// In es, this message translates to:
  /// **'Digital'**
  String get bookDetailsDigital;

  /// No description provided for @bookDetailsPhysical.
  ///
  /// In es, this message translates to:
  /// **'Físico'**
  String get bookDetailsPhysical;

  /// No description provided for @timelineTitle.
  ///
  /// In es, this message translates to:
  /// **'Línea temporal de lectura'**
  String get timelineTitle;

  /// No description provided for @timelineUpdateProgress.
  ///
  /// In es, this message translates to:
  /// **'Actualizar progreso'**
  String get timelineUpdateProgress;

  /// No description provided for @timelineEmpty.
  ///
  /// In es, this message translates to:
  /// **'Aún no has registrado ningún progreso'**
  String get timelineEmpty;

  /// No description provided for @timelineAddFirst.
  ///
  /// In es, this message translates to:
  /// **'Añade tu primer hito de lectura'**
  String get timelineAddFirst;

  /// No description provided for @timelineDeleteTitle.
  ///
  /// In es, this message translates to:
  /// **'Eliminar evento'**
  String get timelineDeleteTitle;

  /// No description provided for @timelineDeleteMessage.
  ///
  /// In es, this message translates to:
  /// **'¿Estás seguro de eliminar este evento de la línea temporal?'**
  String get timelineDeleteMessage;

  /// No description provided for @timelineEntryEdit.
  ///
  /// In es, this message translates to:
  /// **'Editar'**
  String get timelineEntryEdit;

  /// No description provided for @timelineEntryDelete.
  ///
  /// In es, this message translates to:
  /// **'Eliminar'**
  String get timelineEntryDelete;

  /// No description provided for @loanNoActiveLoans.
  ///
  /// In es, this message translates to:
  /// **'No tienes préstamos pendientes o en curso en este momento.'**
  String get loanNoActiveLoans;

  /// No description provided for @loanLenderName.
  ///
  /// In es, this message translates to:
  /// **'Prestamista: {name}'**
  String loanLenderName(String name);

  /// No description provided for @loanBorrowerName.
  ///
  /// In es, this message translates to:
  /// **'Solicitante: {name}'**
  String loanBorrowerName(String name);

  /// No description provided for @loanStatusLabel.
  ///
  /// In es, this message translates to:
  /// **'Estado: {status}'**
  String loanStatusLabel(String status);

  /// No description provided for @loanRequestedDate.
  ///
  /// In es, this message translates to:
  /// **'Solicitado: {date}'**
  String loanRequestedDate(String date);

  /// No description provided for @loanDueDateValue.
  ///
  /// In es, this message translates to:
  /// **'Vence: {date}'**
  String loanDueDateValue(String date);

  /// No description provided for @loanNavigationDetail.
  ///
  /// In es, this message translates to:
  /// **'Navegación a detalle de préstamo'**
  String get loanNavigationDetail;

  /// No description provided for @loanMarkReturned.
  ///
  /// In es, this message translates to:
  /// **'Marcar devuelto'**
  String get loanMarkReturned;

  /// No description provided for @loanMarkReturnedSuccess.
  ///
  /// In es, this message translates to:
  /// **'Préstamo marcado como devuelto'**
  String get loanMarkReturnedSuccess;

  /// No description provided for @loanReturn.
  ///
  /// In es, this message translates to:
  /// **'Devolución'**
  String get loanReturn;

  /// No description provided for @loanReturnDoubleConfirm.
  ///
  /// In es, this message translates to:
  /// **'Cuando se complete la devolución, ambos debéis confirmarlo.'**
  String get loanReturnDoubleConfirm;

  /// No description provided for @loanConfirmReturn.
  ///
  /// In es, this message translates to:
  /// **'Confirmar devolución'**
  String get loanConfirmReturn;

  /// No description provided for @loanWaitingFor.
  ///
  /// In es, this message translates to:
  /// **'Esperando a {name}'**
  String loanWaitingFor(String name);

  /// No description provided for @loanAlreadyConfirmed.
  ///
  /// In es, this message translates to:
  /// **'Ya has confirmado la devolución el {date}.'**
  String loanAlreadyConfirmed(String date);

  /// No description provided for @loanForceFinish.
  ///
  /// In es, this message translates to:
  /// **'Forzar finalización'**
  String get loanForceFinish;

  /// No description provided for @loanSendReminder.
  ///
  /// In es, this message translates to:
  /// **'Enviar recordatorio'**
  String get loanSendReminder;

  /// No description provided for @loanOtherConfirmed.
  ///
  /// In es, this message translates to:
  /// **'¡{name} confirmó!'**
  String loanOtherConfirmed(String name);

  /// No description provided for @loanFinishConfirmation.
  ///
  /// In es, this message translates to:
  /// **'Confirma que has recibido/entregado el libro para finalizar.'**
  String get loanFinishConfirmation;

  /// No description provided for @loanConfirmAndFinish.
  ///
  /// In es, this message translates to:
  /// **'Confirmar y finalizar'**
  String get loanConfirmAndFinish;

  /// No description provided for @loanManualLabel.
  ///
  /// In es, this message translates to:
  /// **'(Préstamo manual)'**
  String get loanManualLabel;

  /// No description provided for @loanInfoReceived.
  ///
  /// In es, this message translates to:
  /// **'Recibido de: {owner}\nVence: {dueDate}'**
  String loanInfoReceived(String owner, String dueDate);

  /// No description provided for @loanInfoSent.
  ///
  /// In es, this message translates to:
  /// **'Prestado a: {borrower}\nPrestado de: {owner}\nVence: {dueDate}'**
  String loanInfoSent(String borrower, String owner, String dueDate);

  /// No description provided for @you.
  ///
  /// In es, this message translates to:
  /// **'Tú'**
  String get you;

  /// No description provided for @borrower.
  ///
  /// In es, this message translates to:
  /// **'Prestatario'**
  String get borrower;

  /// No description provided for @user.
  ///
  /// In es, this message translates to:
  /// **'Usuario'**
  String get user;

  /// No description provided for @someone.
  ///
  /// In es, this message translates to:
  /// **'Alguien'**
  String get someone;

  /// No description provided for @owner.
  ///
  /// In es, this message translates to:
  /// **'Propietario'**
  String get owner;

  /// No description provided for @unknownBook.
  ///
  /// In es, this message translates to:
  /// **'Libro desconocido'**
  String get unknownBook;

  /// No description provided for @statsActivitySummary.
  ///
  /// In es, this message translates to:
  /// **'Resumen de Actividad'**
  String get statsActivitySummary;

  /// No description provided for @statsRealized.
  ///
  /// In es, this message translates to:
  /// **'Realizados'**
  String get statsRealized;

  /// No description provided for @statsAccepted.
  ///
  /// In es, this message translates to:
  /// **'Aceptados'**
  String get statsAccepted;

  /// No description provided for @statsErrorLoadingWithDetail.
  ///
  /// In es, this message translates to:
  /// **'Error al cargar estadísticas: {error}'**
  String statsErrorLoadingWithDetail(String error);

  /// No description provided for @stats30Days.
  ///
  /// In es, this message translates to:
  /// **'30 d'**
  String get stats30Days;

  /// No description provided for @statsTotalYear.
  ///
  /// In es, this message translates to:
  /// **'Total año'**
  String get statsTotalYear;

  /// No description provided for @wishlistTitle.
  ///
  /// In es, this message translates to:
  /// **'Lista de Deseos'**
  String get wishlistTitle;

  /// No description provided for @wishlistEmpty.
  ///
  /// In es, this message translates to:
  /// **'Tu lista de deseos está vacía.'**
  String get wishlistEmpty;

  /// No description provided for @wishlistEmptySub.
  ///
  /// In es, this message translates to:
  /// **'Añade libros que quieras leer o comprar.'**
  String get wishlistEmptySub;

  /// No description provided for @wishlistAddToLibrary.
  ///
  /// In es, this message translates to:
  /// **'Añadir a mi biblioteca'**
  String get wishlistAddToLibrary;

  /// No description provided for @wishlistRemove.
  ///
  /// In es, this message translates to:
  /// **'Eliminar deseo'**
  String get wishlistRemove;

  /// No description provided for @wishlistNew.
  ///
  /// In es, this message translates to:
  /// **'Nuevo deseo'**
  String get wishlistNew;

  /// No description provided for @wishlistDeleteConfirm.
  ///
  /// In es, this message translates to:
  /// **'¿Eliminar deseo?'**
  String get wishlistDeleteConfirm;

  /// No description provided for @wishlistDeleteMessage.
  ///
  /// In es, this message translates to:
  /// **'\"{title}\" se borrará de tu lista.'**
  String wishlistDeleteMessage(String title);

  /// No description provided for @wishlistAlreadyHave.
  ///
  /// In es, this message translates to:
  /// **'¿Ya lo tienes?'**
  String get wishlistAlreadyHave;

  /// No description provided for @wishlistMoveToLibraryConfirm.
  ///
  /// In es, this message translates to:
  /// **'¿Seguro que quieres pasar \"{title}\" a tu biblioteca personal? Se quitará de tu lista de deseos.'**
  String wishlistMoveToLibraryConfirm(String title);

  /// No description provided for @notYet.
  ///
  /// In es, this message translates to:
  /// **'Aún no'**
  String get notYet;

  /// No description provided for @yesItsMine.
  ///
  /// In es, this message translates to:
  /// **'¡Sí, ya es mío!'**
  String get yesItsMine;

  /// No description provided for @wishlistDefaultDescription.
  ///
  /// In es, this message translates to:
  /// **'Añadido desde mi lista de deseos'**
  String get wishlistDefaultDescription;

  /// No description provided for @wishlistAddedToLibrary.
  ///
  /// In es, this message translates to:
  /// **'\"{title}\" añadido a tu biblioteca personal.'**
  String wishlistAddedToLibrary(String title);

  /// No description provided for @wishlistErrorMoving.
  ///
  /// In es, this message translates to:
  /// **'Error al mover a la biblioteca: {error}'**
  String wishlistErrorMoving(String error);

  /// No description provided for @bookFoundTitle.
  ///
  /// In es, this message translates to:
  /// **'📚 Encontrado: {title}'**
  String bookFoundTitle(String title);

  /// No description provided for @bookNotFoundInfo.
  ///
  /// In es, this message translates to:
  /// **'No se encontró información para este código.'**
  String get bookNotFoundInfo;

  /// No description provided for @searchError.
  ///
  /// In es, this message translates to:
  /// **'Error al buscar: {error}'**
  String searchError(String error);

  /// No description provided for @wishlistNewTitle.
  ///
  /// In es, this message translates to:
  /// **'Nuevo Deseo'**
  String get wishlistNewTitle;

  /// No description provided for @bookAuthorOptional.
  ///
  /// In es, this message translates to:
  /// **'Autor (opcional)'**
  String get bookAuthorOptional;

  /// No description provided for @isbnOptional.
  ///
  /// In es, this message translates to:
  /// **'ISBN (opcional)'**
  String get isbnOptional;

  /// No description provided for @wishlistNotesHint.
  ///
  /// In es, this message translates to:
  /// **'Notas / Por qué lo quieres'**
  String get wishlistNotesHint;

  /// No description provided for @wishlistAddAction.
  ///
  /// In es, this message translates to:
  /// **'Añadir a deseos'**
  String get wishlistAddAction;

  /// No description provided for @zenModeNormal.
  ///
  /// In es, this message translates to:
  /// **'Modo Normal'**
  String get zenModeNormal;

  /// No description provided for @zenModeNocturnal.
  ///
  /// In es, this message translates to:
  /// **'Modo Lectura Nocturna'**
  String get zenModeNocturnal;

  /// No description provided for @remaining.
  ///
  /// In es, this message translates to:
  /// **'restante'**
  String get remaining;

  /// No description provided for @endSessionAction.
  ///
  /// In es, this message translates to:
  /// **'TERMINAR SESIÓN'**
  String get endSessionAction;

  /// No description provided for @sessionCompleted.
  ///
  /// In es, this message translates to:
  /// **'Sesión completada'**
  String get sessionCompleted;

  /// No description provided for @sessionDurationSummary.
  ///
  /// In es, this message translates to:
  /// **'{minutes} minutos dedicados a \"{title}\"'**
  String sessionDurationSummary(String minutes, String title);

  /// No description provided for @sessionLastPagePrompt.
  ///
  /// In es, this message translates to:
  /// **'¿En qué página te has quedado?'**
  String get sessionLastPagePrompt;

  /// No description provided for @sessionLastPageHint.
  ///
  /// In es, this message translates to:
  /// **'Ej: 145'**
  String get sessionLastPageHint;

  /// No description provided for @sessionNotesPrompt.
  ///
  /// In es, this message translates to:
  /// **'¿Algo que quieras recordar?'**
  String get sessionNotesPrompt;

  /// No description provided for @sessionNotesHint.
  ///
  /// In es, this message translates to:
  /// **'Ej: \"El capítulo con Maga me hizo llorar. Increíble.\"'**
  String get sessionNotesHint;

  /// No description provided for @sessionMarkFinished.
  ///
  /// In es, this message translates to:
  /// **'Marcar libro como terminado'**
  String get sessionMarkFinished;

  /// No description provided for @sessionSaveOnly.
  ///
  /// In es, this message translates to:
  /// **'SOLO GUARDAR'**
  String get sessionSaveOnly;

  /// No description provided for @sessionSaveAndView.
  ///
  /// In es, this message translates to:
  /// **'GUARDAR Y VER LIBRO'**
  String get sessionSaveAndView;

  /// No description provided for @thisWeek.
  ///
  /// In es, this message translates to:
  /// **'Esta semana'**
  String get thisWeek;

  /// No description provided for @timeLabel.
  ///
  /// In es, this message translates to:
  /// **'Tiempo'**
  String get timeLabel;

  /// No description provided for @pagesLabel.
  ///
  /// In es, this message translates to:
  /// **'Páginas'**
  String get pagesLabel;

  /// No description provided for @pagesPerDayLabel.
  ///
  /// In es, this message translates to:
  /// **'Págs/día'**
  String get pagesPerDayLabel;

  /// No description provided for @thisMonth.
  ///
  /// In es, this message translates to:
  /// **'Este mes'**
  String get thisMonth;

  /// No description provided for @finishedLabel.
  ///
  /// In es, this message translates to:
  /// **'Terminados'**
  String get finishedLabel;

  /// No description provided for @rhythmJourneyTitle.
  ///
  /// In es, this message translates to:
  /// **'Tu viaje lector'**
  String get rhythmJourneyTitle;

  /// No description provided for @rhythmEmptyState.
  ///
  /// In es, this message translates to:
  /// **'El silencio antes de la historia...'**
  String get rhythmEmptyState;

  /// No description provided for @securityResetConfirmTitle.
  ///
  /// In es, this message translates to:
  /// **'¿Eliminar PIN y salir de la cuenta?'**
  String get securityResetConfirmTitle;

  /// No description provided for @securityResetConfirmMessage.
  ///
  /// In es, this message translates to:
  /// **'Se eliminarán TODOS los datos locales (libros, grupos, préstamos) y tendrás que iniciar sesión o configurar un nuevo usuario.'**
  String get securityResetConfirmMessage;

  /// No description provided for @securityResetConfirmTip.
  ///
  /// In es, this message translates to:
  /// **'💡 Tip: Exporta tu biblioteca antes de continuar. Si tienes backups automáticos, búscalos en Descargas/BookSharing/backups.'**
  String get securityResetConfirmTip;

  /// No description provided for @securityResetAction.
  ///
  /// In es, this message translates to:
  /// **'Eliminar todo'**
  String get securityResetAction;

  /// No description provided for @securityResetSuccess.
  ///
  /// In es, this message translates to:
  /// **'Datos eliminados. Reinicia la app para configurar un nuevo usuario.'**
  String get securityResetSuccess;

  /// No description provided for @errorActiveSessionRequired.
  ///
  /// In es, this message translates to:
  /// **'Debes tener una sesión activa.'**
  String get errorActiveSessionRequired;

  /// No description provided for @errorExportingLoans.
  ///
  /// In es, this message translates to:
  /// **'Error al exportar préstamos: {error}'**
  String errorExportingLoans(String error);

  /// No description provided for @errorLoadingTheme.
  ///
  /// In es, this message translates to:
  /// **'No pudimos cargar la preferencia de tema.'**
  String get errorLoadingTheme;

  /// No description provided for @googleBooksKeyConfigured.
  ///
  /// In es, this message translates to:
  /// **'API key configurada. Puedes buscar libros en Google Books.'**
  String get googleBooksKeyConfigured;

  /// No description provided for @googleBooksKeyNotConfigured.
  ///
  /// In es, this message translates to:
  /// **'Configura una API key para buscar libros en Google Books.'**
  String get googleBooksKeyNotConfigured;

  /// No description provided for @configApiKey.
  ///
  /// In es, this message translates to:
  /// **'Configurar API key'**
  String get configApiKey;

  /// No description provided for @googleBooksKeyHelpTitle.
  ///
  /// In es, this message translates to:
  /// **'¿Cómo obtener una API key?'**
  String get googleBooksKeyHelpTitle;

  /// No description provided for @googleBooksKeyHelpSteps.
  ///
  /// In es, this message translates to:
  /// **'1. Ve a Google Cloud Console\\n2. Crea un nuevo proyecto o selecciona uno existente\\n3. Habilita la \"Books API\"\\n4. Crea credenciales tipo \"API key\"\\n5. Copia la clave y pégala aquí'**
  String get googleBooksKeyHelpSteps;

  /// No description provided for @googleBooksKeyDialogTitle.
  ///
  /// In es, this message translates to:
  /// **'Configurar API key de Google Books'**
  String get googleBooksKeyDialogTitle;

  /// No description provided for @googleBooksKeyDialogDesc.
  ///
  /// In es, this message translates to:
  /// **'Introduce tu API key de Google Books para poder buscar libros.'**
  String get googleBooksKeyDialogDesc;

  /// No description provided for @googleBooksKeyHint.
  ///
  /// In es, this message translates to:
  /// **'Pega tu API key aquí'**
  String get googleBooksKeyHint;

  /// No description provided for @googleBooksKeyValidationTip.
  ///
  /// In es, this message translates to:
  /// **'Puedes validar la API key antes de guardarla.'**
  String get googleBooksKeyValidationTip;

  /// No description provided for @validateAndSave.
  ///
  /// In es, this message translates to:
  /// **'Validar y guardar'**
  String get validateAndSave;

  /// No description provided for @errorValidatingApiKey.
  ///
  /// In es, this message translates to:
  /// **'Error al validar API key: {error}'**
  String errorValidatingApiKey(String error);

  /// No description provided for @apiKeySavedSuccess.
  ///
  /// In es, this message translates to:
  /// **'API key guardada correctamente.'**
  String get apiKeySavedSuccess;

  /// No description provided for @errorSavingApiKey.
  ///
  /// In es, this message translates to:
  /// **'Error al guardar API key: {error}'**
  String errorSavingApiKey(String error);

  /// No description provided for @googleBooksKeyDeleteTitle.
  ///
  /// In es, this message translates to:
  /// **'¿Eliminar API key de Google Books?'**
  String get googleBooksKeyDeleteTitle;

  /// No description provided for @googleBooksKeyDeleteDesc.
  ///
  /// In es, this message translates to:
  /// **'Se eliminará la API key guardada. La búsqueda de libros en Google Books dejará de funcionar hasta que configures una nueva key.'**
  String get googleBooksKeyDeleteDesc;

  /// No description provided for @apiKeyDeletedSuccess.
  ///
  /// In es, this message translates to:
  /// **'API key eliminada.'**
  String get apiKeyDeletedSuccess;

  /// No description provided for @errorDeletingApiKey.
  ///
  /// In es, this message translates to:
  /// **'Error al eliminar API key: {error}'**
  String errorDeletingApiKey(String error);

  /// No description provided for @backupPermissionDesc.
  ///
  /// In es, this message translates to:
  /// **'Para guardar y restaurar backups en la carpeta de Descargas, necesitamos acceso a todos los archivos.\\n\\nPor favor, concede el permiso en la siguiente pantalla.'**
  String get backupPermissionDesc;

  /// No description provided for @errorStoragePermissionRequired.
  ///
  /// In es, this message translates to:
  /// **'Se requiere permiso de almacenamiento para guardar el backup.'**
  String get errorStoragePermissionRequired;

  /// No description provided for @autoBackupEnabled.
  ///
  /// In es, this message translates to:
  /// **'Backup automático semanal activado'**
  String get autoBackupEnabled;

  /// No description provided for @autoBackupDisabled.
  ///
  /// In es, this message translates to:
  /// **'Backup automático desactivado'**
  String get autoBackupDisabled;

  /// No description provided for @errorChangingBackupConfig.
  ///
  /// In es, this message translates to:
  /// **'Error al cambiar configuración: {error}'**
  String errorChangingBackupConfig(String error);

  /// No description provided for @creatingBackup.
  ///
  /// In es, this message translates to:
  /// **'Creando copia de seguridad...'**
  String get creatingBackup;

  /// No description provided for @backupSavedAt.
  ///
  /// In es, this message translates to:
  /// **'Backup guardado en: {path}'**
  String backupSavedAt(String path);

  /// No description provided for @errorCreatingBackup.
  ///
  /// In es, this message translates to:
  /// **'No se pudo crear el backup. Intenta de nuevo.'**
  String get errorCreatingBackup;

  /// No description provided for @errorCreatingBackupDetail.
  ///
  /// In es, this message translates to:
  /// **'Error al crear backup: {error}'**
  String errorCreatingBackupDetail(String error);

  /// No description provided for @restoreLatestBackupTitle.
  ///
  /// In es, this message translates to:
  /// **'¿Restaurar último backup automático?'**
  String get restoreLatestBackupTitle;

  /// No description provided for @restoreBackupWarning.
  ///
  /// In es, this message translates to:
  /// **'Esta acción reemplazará TODOS tus datos actuales con la copia de seguridad más reciente.'**
  String get restoreBackupWarning;

  /// No description provided for @searchingBackups.
  ///
  /// In es, this message translates to:
  /// **'Buscando backups...'**
  String get searchingBackups;

  /// No description provided for @noBackupsFound.
  ///
  /// In es, this message translates to:
  /// **'No se encontraron backups automáticos.'**
  String get noBackupsFound;

  /// No description provided for @restoringBackup.
  ///
  /// In es, this message translates to:
  /// **'Restaurando {filename}...'**
  String restoringBackup(String filename);

  /// No description provided for @restoreComplete.
  ///
  /// In es, this message translates to:
  /// **'Restauración completada. Reiniciando...'**
  String get restoreComplete;

  /// No description provided for @errorRestoringBackup.
  ///
  /// In es, this message translates to:
  /// **'Error al restaurar: {error}'**
  String errorRestoringBackup(String error);

  /// No description provided for @restoreSpecificBackupTitle.
  ///
  /// In es, this message translates to:
  /// **'¿Restaurar este backup?'**
  String get restoreSpecificBackupTitle;

  /// No description provided for @restore.
  ///
  /// In es, this message translates to:
  /// **'Restaurar'**
  String get restore;

  /// No description provided for @appRestartNote.
  ///
  /// In es, this message translates to:
  /// **'La aplicación se reiniciará automáticamente tras la restauración.'**
  String get appRestartNote;

  /// No description provided for @deleteAction.
  ///
  /// In es, this message translates to:
  /// **'Eliminar'**
  String get deleteAction;

  /// No description provided for @permissionRequired.
  ///
  /// In es, this message translates to:
  /// **'Permiso requerido'**
  String get permissionRequired;

  /// No description provided for @continueLabel.
  ///
  /// In es, this message translates to:
  /// **'Continuar'**
  String get continueLabel;

  /// No description provided for @warningLabel.
  ///
  /// In es, this message translates to:
  /// **'Advertencia'**
  String get warningLabel;

  /// No description provided for @backupFileLabel.
  ///
  /// In es, this message translates to:
  /// **'Archivo: {filename}'**
  String backupFileLabel(String filename);

  /// No description provided for @errorResettingDatabase.
  ///
  /// In es, this message translates to:
  /// **'Error al resetear la base de datos: {error}'**
  String errorResettingDatabase(String error);

  /// No description provided for @deleteCoversTitle.
  ///
  /// In es, this message translates to:
  /// **'¿Borrar todas las portadas?'**
  String get deleteCoversTitle;

  /// No description provided for @deleteCoversDesc.
  ///
  /// In es, this message translates to:
  /// **'Se eliminarán todas las imágenes de portada descargadas. Podrás volver a descargarlas manualmente desde la biblioteca.'**
  String get deleteCoversDesc;

  /// No description provided for @coversDeletedCount.
  ///
  /// In es, this message translates to:
  /// **'Se eliminaron {count} portadas.'**
  String coversDeletedCount(String count);

  /// No description provided for @errorDeletingCovers.
  ///
  /// In es, this message translates to:
  /// **'Error al borrar portadas: {error}'**
  String errorDeletingCovers(String error);

  /// No description provided for @importBooksDialogTitle.
  ///
  /// In es, this message translates to:
  /// **'Importar libros'**
  String get importBooksDialogTitle;

  /// No description provided for @importBooksDialogDesc.
  ///
  /// In es, this message translates to:
  /// **'Selecciona un archivo CSV o JSON para importar tus libros.'**
  String get importBooksDialogDesc;

  /// No description provided for @selectFile.
  ///
  /// In es, this message translates to:
  /// **'Seleccionar archivo'**
  String get selectFile;

  /// No description provided for @importSuccessCount.
  ///
  /// In es, this message translates to:
  /// **'Se importaron {count} libros correctamente'**
  String importSuccessCount(String count);

  /// No description provided for @importFailureCount.
  ///
  /// In es, this message translates to:
  /// **' ({count} fallidos)'**
  String importFailureCount(String count);

  /// No description provided for @importMoreErrors.
  ///
  /// In es, this message translates to:
  /// **' (y {count} más...)'**
  String importMoreErrors(String count);

  /// No description provided for @errorNoBooksImported.
  ///
  /// In es, this message translates to:
  /// **'No se pudo importar ningún libro'**
  String get errorNoBooksImported;

  /// No description provided for @errorNoActiveUserImport.
  ///
  /// In es, this message translates to:
  /// **'No hay usuario activo para importar los libros.'**
  String get errorNoActiveUserImport;

  /// No description provided for @errorUnsupportedFileFormat.
  ///
  /// In es, this message translates to:
  /// **'Formato de archivo no soportado'**
  String get errorUnsupportedFileFormat;

  /// No description provided for @releaseNotesTitle.
  ///
  /// In es, this message translates to:
  /// **'¡Nuevos Capítulos!'**
  String get releaseNotesTitle;

  /// No description provided for @versionLabel.
  ///
  /// In es, this message translates to:
  /// **'Versión {version}'**
  String versionLabel(String version);

  /// No description provided for @releaseNotesAction.
  ///
  /// In es, this message translates to:
  /// **'¡A seguir leyendo!'**
  String get releaseNotesAction;

  /// No description provided for @bookshelfSearchTooltip.
  ///
  /// In es, this message translates to:
  /// **'Buscar en mis lecturas'**
  String get bookshelfSearchTooltip;

  /// No description provided for @bookshelfThemeTooltip.
  ///
  /// In es, this message translates to:
  /// **'Personalizar estantería'**
  String get bookshelfThemeTooltip;

  /// No description provided for @bookshelfManageTooltip.
  ///
  /// In es, this message translates to:
  /// **'Gestionar títulos'**
  String get bookshelfManageTooltip;

  /// No description provided for @bookshelfSearchHint.
  ///
  /// In es, this message translates to:
  /// **'Buscar por título o autor...'**
  String get bookshelfSearchHint;

  /// No description provided for @bookshelfCustomTitle.
  ///
  /// In es, this message translates to:
  /// **'Personalizar Estantería'**
  String get bookshelfCustomTitle;

  /// No description provided for @bookshelfTabShelves.
  ///
  /// In es, this message translates to:
  /// **'Baldas'**
  String get bookshelfTabShelves;

  /// No description provided for @bookshelfTabWall.
  ///
  /// In es, this message translates to:
  /// **'Fondo'**
  String get bookshelfTabWall;

  /// No description provided for @sortRecent.
  ///
  /// In es, this message translates to:
  /// **'Recientes'**
  String get sortRecent;

  /// No description provided for @sortAlpha.
  ///
  /// In es, this message translates to:
  /// **'A → Z'**
  String get sortAlpha;

  /// No description provided for @sortAuthor.
  ///
  /// In es, this message translates to:
  /// **'Autor'**
  String get sortAuthor;

  /// No description provided for @sortPages.
  ///
  /// In es, this message translates to:
  /// **'Páginas'**
  String get sortPages;

  /// No description provided for @sortRating.
  ///
  /// In es, this message translates to:
  /// **'Valoración'**
  String get sortRating;

  /// No description provided for @shelfThemeClassic.
  ///
  /// In es, this message translates to:
  /// **'Clásica'**
  String get shelfThemeClassic;

  /// No description provided for @shelfThemeModern.
  ///
  /// In es, this message translates to:
  /// **'Moderna'**
  String get shelfThemeModern;

  /// No description provided for @shelfThemeVintage.
  ///
  /// In es, this message translates to:
  /// **'Vintage'**
  String get shelfThemeVintage;

  /// No description provided for @shelfThemeIndustrial.
  ///
  /// In es, this message translates to:
  /// **'Industrial'**
  String get shelfThemeIndustrial;

  /// No description provided for @shelfThemePastel.
  ///
  /// In es, this message translates to:
  /// **'Pastel'**
  String get shelfThemePastel;

  /// No description provided for @wallThemePlaster.
  ///
  /// In es, this message translates to:
  /// **'Yeso'**
  String get wallThemePlaster;

  /// No description provided for @wallThemeBrick.
  ///
  /// In es, this message translates to:
  /// **'Ladrillo'**
  String get wallThemeBrick;

  /// No description provided for @wallThemePaper.
  ///
  /// In es, this message translates to:
  /// **'Papel'**
  String get wallThemePaper;

  /// No description provided for @wallThemeWood.
  ///
  /// In es, this message translates to:
  /// **'Madera'**
  String get wallThemeWood;

  /// No description provided for @wallThemeDark.
  ///
  /// In es, this message translates to:
  /// **'Oscuro'**
  String get wallThemeDark;

  /// No description provided for @statsGeneralTitle.
  ///
  /// In es, this message translates to:
  /// **'Estadísticas generales'**
  String get statsGeneralTitle;

  /// No description provided for @statsTotalBooks.
  ///
  /// In es, this message translates to:
  /// **'Libros totales'**
  String get statsTotalBooks;

  /// No description provided for @statsReadBooks.
  ///
  /// In es, this message translates to:
  /// **'Libros leídos'**
  String get statsReadBooks;

  /// No description provided for @statsAvailable.
  ///
  /// In es, this message translates to:
  /// **'Disponibles'**
  String get statsAvailable;

  /// No description provided for @statsTotalLoans.
  ///
  /// In es, this message translates to:
  /// **'Préstamos totales'**
  String get statsTotalLoans;

  /// No description provided for @statsActiveLoans.
  ///
  /// In es, this message translates to:
  /// **'Préstamos activos'**
  String get statsActiveLoans;

  /// No description provided for @statsReturned.
  ///
  /// In es, this message translates to:
  /// **'Devueltos'**
  String get statsReturned;

  /// No description provided for @statsExpired.
  ///
  /// In es, this message translates to:
  /// **'Expirados'**
  String get statsExpired;

  /// No description provided for @statsViewReadingHistory.
  ///
  /// In es, this message translates to:
  /// **'Ver historial de lecturas'**
  String get statsViewReadingHistory;

  /// No description provided for @statsActiveLoansHeader.
  ///
  /// In es, this message translates to:
  /// **'Préstamos activos'**
  String get statsActiveLoansHeader;

  /// No description provided for @statsTopBooksHeader.
  ///
  /// In es, this message translates to:
  /// **'Libros más prestados'**
  String get statsTopBooksHeader;

  /// No description provided for @statsNoTopBooksMessage.
  ///
  /// In es, this message translates to:
  /// **'Cuando registres préstamos aparecerán aquí tus libros más populares.'**
  String get statsNoTopBooksMessage;

  /// No description provided for @statsLoanCount.
  ///
  /// In es, this message translates to:
  /// **'Préstamos registrados: {count}'**
  String statsLoanCount(String count);

  /// No description provided for @statsErrorLoading.
  ///
  /// In es, this message translates to:
  /// **'No pudimos cargar las estadísticas.'**
  String get statsErrorLoading;

  /// No description provided for @statsRecommendationsTitle.
  ///
  /// In es, this message translates to:
  /// **'Recomendaciones para ti'**
  String get statsRecommendationsTitle;

  /// No description provided for @statsUnknownAuthor.
  ///
  /// In es, this message translates to:
  /// **'Autor desconocido'**
  String get statsUnknownAuthor;

  /// No description provided for @loanManualTitle.
  ///
  /// In es, this message translates to:
  /// **'Nuevo Préstamo Manual'**
  String get loanManualTitle;

  /// No description provided for @loanReceiveTitle.
  ///
  /// In es, this message translates to:
  /// **'Registrar libro prestado'**
  String get loanReceiveTitle;

  /// No description provided for @loanReceiveDescription.
  ///
  /// In es, this message translates to:
  /// **'Registra un libro que alguien (fuera de la app) te ha prestado.'**
  String get loanReceiveDescription;

  /// No description provided for @loanWhoLentIt.
  ///
  /// In es, this message translates to:
  /// **'¿Quién te lo prestó?'**
  String get loanWhoLentIt;

  /// No description provided for @loanLenderNameRequired.
  ///
  /// In es, this message translates to:
  /// **'Nombre del propietario *'**
  String get loanLenderNameRequired;

  /// No description provided for @loanLenderNameRequiredError.
  ///
  /// In es, this message translates to:
  /// **'¿Quién es el guardián de este libro?'**
  String get loanLenderNameRequiredError;

  /// No description provided for @lenderLabel.
  ///
  /// In es, this message translates to:
  /// **'Propietario:'**
  String get lenderLabel;

  /// No description provided for @loanErrorRegister.
  ///
  /// In es, this message translates to:
  /// **'Error al registrar: {error}'**
  String loanErrorRegister(String error);

  /// No description provided for @isbnInvalid.
  ///
  /// In es, this message translates to:
  /// **'ISBN no válido'**
  String get isbnInvalid;

  /// No description provided for @bookNotFound.
  ///
  /// In es, this message translates to:
  /// **'No se encontró el libro'**
  String get bookNotFound;

  /// No description provided for @searchPromptTitleOrIsbn.
  ///
  /// In es, this message translates to:
  /// **'Introduce título o ISBN'**
  String get searchPromptTitleOrIsbn;

  /// No description provided for @searchNoResults.
  ///
  /// In es, this message translates to:
  /// **'Sin resultados'**
  String get searchNoResults;

  /// No description provided for @searchSelectResult.
  ///
  /// In es, this message translates to:
  /// **'Selecciona un resultado'**
  String get searchSelectResult;

  /// No description provided for @unknownAuthor.
  ///
  /// In es, this message translates to:
  /// **'Autor desconocido'**
  String get unknownAuthor;

  /// No description provided for @permissionCameraDenied.
  ///
  /// In es, this message translates to:
  /// **'Permiso de cámara denegado'**
  String get permissionCameraDenied;

  /// No description provided for @scanBarcode.
  ///
  /// In es, this message translates to:
  /// **'Escanear código'**
  String get scanBarcode;

  /// No description provided for @searching.
  ///
  /// In es, this message translates to:
  /// **'Buscando...'**
  String get searching;

  /// No description provided for @searchData.
  ///
  /// In es, this message translates to:
  /// **'Buscar datos'**
  String get searchData;

  /// No description provided for @bookTitleRequired.
  ///
  /// In es, this message translates to:
  /// **'Título del libro *'**
  String get bookTitleRequired;

  /// No description provided for @bookTitleRequiredError.
  ///
  /// In es, this message translates to:
  /// **'¿Cómo se llama la historia?'**
  String get bookTitleRequiredError;

  /// No description provided for @loanBookToLend.
  ///
  /// In es, this message translates to:
  /// **'Libro a prestar'**
  String get loanBookToLend;

  /// No description provided for @loanNoAvailableBooks.
  ///
  /// In es, this message translates to:
  /// **'No tienes libros disponibles para prestar.'**
  String get loanNoAvailableBooks;

  /// No description provided for @loanSelectBook.
  ///
  /// In es, this message translates to:
  /// **'Selecciona un libro'**
  String get loanSelectBook;

  /// No description provided for @loanErrorLoadingBooks.
  ///
  /// In es, this message translates to:
  /// **'Error cargando libros: {error}'**
  String loanErrorLoadingBooks(String error);

  /// No description provided for @loanBorrowerData.
  ///
  /// In es, this message translates to:
  /// **'Datos del prestatario'**
  String get loanBorrowerData;

  /// No description provided for @loanFullName.
  ///
  /// In es, this message translates to:
  /// **'Nombre Completo'**
  String get loanFullName;

  /// No description provided for @loanFullNameHint.
  ///
  /// In es, this message translates to:
  /// **'Ej. Juan Pérez'**
  String get loanFullNameHint;

  /// No description provided for @loanNameRequired.
  ///
  /// In es, this message translates to:
  /// **'El nombre es requerido'**
  String get loanNameRequired;

  /// No description provided for @loanContactOptional.
  ///
  /// In es, this message translates to:
  /// **'Contacto (Opcional)'**
  String get loanContactOptional;

  /// No description provided for @loanContactHint.
  ///
  /// In es, this message translates to:
  /// **'Teléfono, email o nota'**
  String get loanContactHint;

  /// No description provided for @loanDueDate.
  ///
  /// In es, this message translates to:
  /// **'Fecha de devolución'**
  String get loanDueDate;

  /// No description provided for @loanIndefinite.
  ///
  /// In es, this message translates to:
  /// **'Indefinido'**
  String get loanIndefinite;

  /// No description provided for @loanNoDueDate.
  ///
  /// In es, this message translates to:
  /// **'Sin fecha límite'**
  String get loanNoDueDate;

  /// No description provided for @loanRegister.
  ///
  /// In es, this message translates to:
  /// **'Registrar Préstamo'**
  String get loanRegister;

  /// No description provided for @loanRegisteredSuccess.
  ///
  /// In es, this message translates to:
  /// **'Préstamo registrado'**
  String get loanRegisteredSuccess;

  /// No description provided for @borrowerLabel.
  ///
  /// In es, this message translates to:
  /// **'Prestatario:'**
  String get borrowerLabel;

  /// No description provided for @dueLabel.
  ///
  /// In es, this message translates to:
  /// **'Vence:'**
  String get dueLabel;

  /// No description provided for @understood.
  ///
  /// In es, this message translates to:
  /// **'Entendido'**
  String get understood;

  /// No description provided for @saving.
  ///
  /// In es, this message translates to:
  /// **'Guardando...'**
  String get saving;

  /// No description provided for @timelineStart.
  ///
  /// In es, this message translates to:
  /// **'Inicio'**
  String get timelineStart;

  /// No description provided for @timelineProgress.
  ///
  /// In es, this message translates to:
  /// **'Progreso'**
  String get timelineProgress;

  /// No description provided for @timelinePause.
  ///
  /// In es, this message translates to:
  /// **'Pausa'**
  String get timelinePause;

  /// No description provided for @timelineResume.
  ///
  /// In es, this message translates to:
  /// **'Reanudación'**
  String get timelineResume;

  /// No description provided for @timelineFinish.
  ///
  /// In es, this message translates to:
  /// **'Finalizado'**
  String get timelineFinish;

  /// No description provided for @timelinePage.
  ///
  /// In es, this message translates to:
  /// **'Página {number}'**
  String timelinePage(int number);

  /// No description provided for @addTimelineDate.
  ///
  /// In es, this message translates to:
  /// **'Fecha'**
  String get addTimelineDate;

  /// No description provided for @addTimelineCurrentPage.
  ///
  /// In es, this message translates to:
  /// **'Página actual (opcional)'**
  String get addTimelineCurrentPage;

  /// No description provided for @addTimelineNote.
  ///
  /// In es, this message translates to:
  /// **'Nota personal (opcional)'**
  String get addTimelineNote;

  /// No description provided for @addTimelineNoteHint.
  ///
  /// In es, this message translates to:
  /// **'Tus impresiones, pensamientos...'**
  String get addTimelineNoteHint;

  /// No description provided for @addTimelineInvalidPage.
  ///
  /// In es, this message translates to:
  /// **'Por favor, introduce un número de página válido'**
  String get addTimelineInvalidPage;

  /// No description provided for @addTimelineEditTitle.
  ///
  /// In es, this message translates to:
  /// **'Editar progreso'**
  String get addTimelineEditTitle;

  /// No description provided for @addTimelineAddTitle.
  ///
  /// In es, this message translates to:
  /// **'Añadir progreso'**
  String get addTimelineAddTitle;

  /// No description provided for @addTimelineToday.
  ///
  /// In es, this message translates to:
  /// **'Hoy, {time}'**
  String addTimelineToday(String time);

  /// No description provided for @addTimelineYesterday.
  ///
  /// In es, this message translates to:
  /// **'Ayer, {time}'**
  String addTimelineYesterday(String time);

  /// No description provided for @addTimelineTotalPagesHint.
  ///
  /// In es, this message translates to:
  /// **'De {count} páginas'**
  String addTimelineTotalPagesHint(int count);

  /// No description provided for @addTimelinePageNumberHint.
  ///
  /// In es, this message translates to:
  /// **'Número de página'**
  String get addTimelinePageNumberHint;

  /// No description provided for @addTimelineUpdateSuccess.
  ///
  /// In es, this message translates to:
  /// **'Progreso actualizado'**
  String get addTimelineUpdateSuccess;

  /// No description provided for @addTimelineAddSuccess.
  ///
  /// In es, this message translates to:
  /// **'Progreso añadido'**
  String get addTimelineAddSuccess;

  /// No description provided for @reviewDialogTitle.
  ///
  /// In es, this message translates to:
  /// **'¿Cómo recomendarías \"{title}\"?'**
  String reviewDialogTitle(String title);

  /// No description provided for @reviewDialogOptionalComment.
  ///
  /// In es, this message translates to:
  /// **'Escribe una reseña (opcional)'**
  String get reviewDialogOptionalComment;

  /// No description provided for @reviewDialogCommentHint.
  ///
  /// In es, this message translates to:
  /// **'Comparte tu opinión sobre este libro...'**
  String get reviewDialogCommentHint;

  /// No description provided for @reviewDialogAdded.
  ///
  /// In es, this message translates to:
  /// **'Reseña añadida.'**
  String get reviewDialogAdded;

  /// No description provided for @reviewDialogRecommendTitle.
  ///
  /// In es, this message translates to:
  /// **'¿A quién se lo recomiendas?'**
  String get reviewDialogRecommendTitle;

  /// No description provided for @reviewDialogRecommendMessage.
  ///
  /// In es, this message translates to:
  /// **'Has dado una valoración positiva. ¿Quieres enviarle un mensaje a alguien para recomendárselo?'**
  String get reviewDialogRecommendMessage;

  /// No description provided for @reviewDialogNotNow.
  ///
  /// In es, this message translates to:
  /// **'Ahora no'**
  String get reviewDialogNotNow;

  /// No description provided for @reviewDialogRecommend.
  ///
  /// In es, this message translates to:
  /// **'Recomendar'**
  String get reviewDialogRecommend;

  /// No description provided for @reviewDialogWriteTitle.
  ///
  /// In es, this message translates to:
  /// **'Escribe una reseña'**
  String get reviewDialogWriteTitle;

  /// No description provided for @reviewDialogByAuthor.
  ///
  /// In es, this message translates to:
  /// **'por {author}'**
  String reviewDialogByAuthor(String author);

  /// No description provided for @reviewListEdit.
  ///
  /// In es, this message translates to:
  /// **'Editar reseña'**
  String get reviewListEdit;

  /// No description provided for @readStatusFilterAll.
  ///
  /// In es, this message translates to:
  /// **'Todos los libros'**
  String get readStatusFilterAll;

  /// No description provided for @readStatusFilterRead.
  ///
  /// In es, this message translates to:
  /// **'Leídos'**
  String get readStatusFilterRead;

  /// No description provided for @readStatusFilterUnread.
  ///
  /// In es, this message translates to:
  /// **'No leídos'**
  String get readStatusFilterUnread;

  /// No description provided for @libraryEmpty.
  ///
  /// In es, this message translates to:
  /// **'Tu biblioteca está vacía'**
  String get libraryEmpty;

  /// No description provided for @libraryEmptyMessage.
  ///
  /// In es, this message translates to:
  /// **'Registra tu primer libro para organizar préstamos y compartir lecturas con tu grupo.'**
  String get libraryEmptyMessage;

  /// No description provided for @libraryRegister.
  ///
  /// In es, this message translates to:
  /// **'Registrar libro'**
  String get libraryRegister;

  /// No description provided for @searchBarHint.
  ///
  /// In es, this message translates to:
  /// **'Buscar por título o autor...'**
  String get searchBarHint;

  /// No description provided for @exportCSV.
  ///
  /// In es, this message translates to:
  /// **'Exportar como CSV'**
  String get exportCSV;

  /// No description provided for @exportJSON.
  ///
  /// In es, this message translates to:
  /// **'Exportar como JSON'**
  String get exportJSON;

  /// No description provided for @exportPDF.
  ///
  /// In es, this message translates to:
  /// **'Exportar como PDF'**
  String get exportPDF;

  /// No description provided for @export.
  ///
  /// In es, this message translates to:
  /// **'Exportar'**
  String get export;

  /// No description provided for @exportNoBooks.
  ///
  /// In es, this message translates to:
  /// **'No hay libros para exportar.'**
  String get exportNoBooks;

  /// No description provided for @exportError.
  ///
  /// In es, this message translates to:
  /// **'No se pudo exportar: {error}'**
  String exportError(String error);

  /// No description provided for @refreshMetadata.
  ///
  /// In es, this message translates to:
  /// **'Actualizar metadatos'**
  String get refreshMetadata;

  /// No description provided for @refreshMetadataMessage.
  ///
  /// In es, this message translates to:
  /// **'Se buscarán portadas y datos faltantes (páginas, año, género) para tus libros.'**
  String get refreshMetadataMessage;

  /// No description provided for @refreshMetadataWaitMessage.
  ///
  /// In es, this message translates to:
  /// **'Se buscarán portadas y datos faltantes (páginas, año, género) para tus libros. Esto puede tardar varios minutos dependiendo de cuántos libros tengas.'**
  String get refreshMetadataWaitMessage;

  /// No description provided for @refreshOnlyMissing.
  ///
  /// In es, this message translates to:
  /// **'Solo faltantes'**
  String get refreshOnlyMissing;

  /// No description provided for @refreshForceAll.
  ///
  /// In es, this message translates to:
  /// **'Forzar todo'**
  String get refreshForceAll;

  /// No description provided for @refreshingMetadata.
  ///
  /// In es, this message translates to:
  /// **'Actualizando metadatos...'**
  String get refreshingMetadata;

  /// No description provided for @refreshMetadataNone.
  ///
  /// In es, this message translates to:
  /// **'Todos los libros ya tienen metadatos completos.'**
  String get refreshMetadataNone;

  /// No description provided for @refreshMetadataSuccess.
  ///
  /// In es, this message translates to:
  /// **'Metadatos actualizados: {success} de {total}.'**
  String refreshMetadataSuccess(int success, int total);

  /// No description provided for @refreshMetadataError.
  ///
  /// In es, this message translates to:
  /// **'Error al actualizar metadatos: {error}'**
  String refreshMetadataError(String error);

  /// No description provided for @coverGallery.
  ///
  /// In es, this message translates to:
  /// **'Galería'**
  String get coverGallery;

  /// No description provided for @coverCamera.
  ///
  /// In es, this message translates to:
  /// **'Cámara'**
  String get coverCamera;

  /// No description provided for @coverDelete.
  ///
  /// In es, this message translates to:
  /// **'Eliminar'**
  String get coverDelete;

  /// No description provided for @readingStatusTitle.
  ///
  /// In es, this message translates to:
  /// **'Estado de lectura'**
  String get readingStatusTitle;

  /// No description provided for @readingStatusChanged.
  ///
  /// In es, this message translates to:
  /// **'Estado cambiado a: {status}'**
  String readingStatusChanged(String status);

  /// No description provided for @readingStatusError.
  ///
  /// In es, this message translates to:
  /// **'Error al cambiar estado: {error}'**
  String readingStatusError(String error);

  /// No description provided for @insightJustStarted.
  ///
  /// In es, this message translates to:
  /// **'Acabas de empezar este libro'**
  String get insightJustStarted;

  /// No description provided for @insightNearlyFinished.
  ///
  /// In es, this message translates to:
  /// **'Estás a punto de terminar este libro'**
  String get insightNearlyFinished;

  /// No description provided for @insightReflective.
  ///
  /// In es, this message translates to:
  /// **'Este libro parece invitar a pausas y reflexión'**
  String get insightReflective;

  /// No description provided for @insightDevoured.
  ///
  /// In es, this message translates to:
  /// **'Has devorado este libro con entusiasmo'**
  String get insightDevoured;

  /// No description provided for @insightFastPace.
  ///
  /// In es, this message translates to:
  /// **'Una lectura vertiginosa, difícil de soltar'**
  String get insightFastPace;

  /// No description provided for @insightSlowPace.
  ///
  /// In es, this message translates to:
  /// **'Estás saboreando este libro con calma, sin prisas'**
  String get insightSlowPace;

  /// No description provided for @insightSteadyPace.
  ///
  /// In es, this message translates to:
  /// **'Llevas un ritmo constante con este libro'**
  String get insightSteadyPace;

  /// No description provided for @insightFinishedFast.
  ///
  /// In es, this message translates to:
  /// **'¡Lo leíste de un tirón! Otra aventura vivida.'**
  String get insightFinishedFast;

  /// No description provided for @insightFinishedNormal.
  ///
  /// In es, this message translates to:
  /// **'Un viaje completado. Cada página, un paso más.'**
  String get insightFinishedNormal;

  /// No description provided for @insightFinishedSlow.
  ///
  /// In es, this message translates to:
  /// **'Terminado. Las historias que duran también dejan huella.'**
  String get insightFinishedSlow;

  /// No description provided for @recommendLevel1.
  ///
  /// In es, this message translates to:
  /// **'No lo recomendaría'**
  String get recommendLevel1;

  /// No description provided for @recommendLevel2.
  ///
  /// In es, this message translates to:
  /// **'Está bien, pero no es para mí'**
  String get recommendLevel2;

  /// No description provided for @recommendLevel3.
  ///
  /// In es, this message translates to:
  /// **'Lo recomiendo a gente como yo'**
  String get recommendLevel3;

  /// No description provided for @recommendLevel4.
  ///
  /// In es, this message translates to:
  /// **'Todo el mundo debería leerlo'**
  String get recommendLevel4;

  /// No description provided for @recommendLevel5.
  ///
  /// In es, this message translates to:
  /// **'Lo terminé, pero me costó'**
  String get recommendLevel5;

  /// No description provided for @recommendLevel1Short.
  ///
  /// In es, this message translates to:
  /// **'No recomendado'**
  String get recommendLevel1Short;

  /// No description provided for @recommendLevel2Short.
  ///
  /// In es, this message translates to:
  /// **'Ni fu ni fa'**
  String get recommendLevel2Short;

  /// No description provided for @recommendLevel3Short.
  ///
  /// In es, this message translates to:
  /// **'Recomendado'**
  String get recommendLevel3Short;

  /// No description provided for @recommendLevel4Short.
  ///
  /// In es, this message translates to:
  /// **'Imprescindible'**
  String get recommendLevel4Short;

  /// No description provided for @recommendLevel5Short.
  ///
  /// In es, this message translates to:
  /// **'Terminado con esfuerzo'**
  String get recommendLevel5Short;

  /// No description provided for @bookDetailsIsbn.
  ///
  /// In es, this message translates to:
  /// **'ISBN: {isbn}'**
  String bookDetailsIsbn(String isbn);

  /// No description provided for @coverNoCover.
  ///
  /// In es, this message translates to:
  /// **'Sin portada'**
  String get coverNoCover;

  /// No description provided for @coverSelected.
  ///
  /// In es, this message translates to:
  /// **'Portada seleccionada'**
  String get coverSelected;

  /// No description provided for @coverHelp.
  ///
  /// In es, this message translates to:
  /// **'Añade una imagen para identificar mejor tus libros.'**
  String get coverHelp;

  /// No description provided for @coverNotAvailable.
  ///
  /// In es, this message translates to:
  /// **'Portadas no disponibles en esta plataforma'**
  String get coverNotAvailable;

  /// No description provided for @selectGenresTitle.
  ///
  /// In es, this message translates to:
  /// **'Seleccionar géneros'**
  String get selectGenresTitle;

  /// No description provided for @searchGenreHint.
  ///
  /// In es, this message translates to:
  /// **'Buscar género...'**
  String get searchGenreHint;

  /// No description provided for @bookSourceFound.
  ///
  /// In es, this message translates to:
  /// **'Fuente: {source}'**
  String bookSourceFound(String source);

  /// No description provided for @manualLoanTitle.
  ///
  /// In es, this message translates to:
  /// **'Nuevo Préstamo Manual'**
  String get manualLoanTitle;

  /// No description provided for @manualLoanBookSection.
  ///
  /// In es, this message translates to:
  /// **'Libro a prestar'**
  String get manualLoanBookSection;

  /// No description provided for @manualLoanNoBooksAvailable.
  ///
  /// In es, this message translates to:
  /// **'No tienes libros disponibles para prestar.'**
  String get manualLoanNoBooksAvailable;

  /// No description provided for @manualLoanSelectBook.
  ///
  /// In es, this message translates to:
  /// **'Selecciona un libro'**
  String get manualLoanSelectBook;

  /// No description provided for @manualLoanBorrowerSection.
  ///
  /// In es, this message translates to:
  /// **'Datos del prestatario'**
  String get manualLoanBorrowerSection;

  /// No description provided for @manualLoanFullName.
  ///
  /// In es, this message translates to:
  /// **'Nombre Completo'**
  String get manualLoanFullName;

  /// No description provided for @manualLoanFullNameHint.
  ///
  /// In es, this message translates to:
  /// **'Ej. Juan Pérez'**
  String get manualLoanFullNameHint;

  /// No description provided for @manualLoanContact.
  ///
  /// In es, this message translates to:
  /// **'Contacto (Opcional)'**
  String get manualLoanContact;

  /// No description provided for @manualLoanContactHint.
  ///
  /// In es, this message translates to:
  /// **'Teléfono, email o nota'**
  String get manualLoanContactHint;

  /// No description provided for @manualLoanDueDate.
  ///
  /// In es, this message translates to:
  /// **'Fecha de devolución'**
  String get manualLoanDueDate;

  /// No description provided for @manualLoanIndefinite.
  ///
  /// In es, this message translates to:
  /// **'Indefinido'**
  String get manualLoanIndefinite;

  /// No description provided for @manualLoanRegistered.
  ///
  /// In es, this message translates to:
  /// **'Préstamo registrado'**
  String get manualLoanRegistered;

  /// No description provided for @receiveExternalTitle.
  ///
  /// In es, this message translates to:
  /// **'Registrar libro prestado'**
  String get receiveExternalTitle;

  /// No description provided for @receiveExternalSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Registra un libro que alguien (fuera de la app) te ha prestado.'**
  String get receiveExternalSubtitle;

  /// No description provided for @receiveExternalBookSection.
  ///
  /// In es, this message translates to:
  /// **'Detalles del libro'**
  String get receiveExternalBookSection;

  /// No description provided for @receiveExternalTitleLabel.
  ///
  /// In es, this message translates to:
  /// **'Título del libro *'**
  String get receiveExternalTitleLabel;

  /// No description provided for @receiveExternalAuthor.
  ///
  /// In es, this message translates to:
  /// **'Autor'**
  String get receiveExternalAuthor;

  /// No description provided for @receiveExternalOwnerSection.
  ///
  /// In es, this message translates to:
  /// **'¿Quién te lo prestó?'**
  String get receiveExternalOwnerSection;

  /// No description provided for @receiveExternalOwnerLabel.
  ///
  /// In es, this message translates to:
  /// **'Nombre del propietario *'**
  String get receiveExternalOwnerLabel;

  /// No description provided for @receiveExternalContact.
  ///
  /// In es, this message translates to:
  /// **'Contacto (Opcional)'**
  String get receiveExternalContact;

  /// No description provided for @receiveExternalContactHint.
  ///
  /// In es, this message translates to:
  /// **'Teléfono, email, etc.'**
  String get receiveExternalContactHint;

  /// No description provided for @receiveExternalDueDate.
  ///
  /// In es, this message translates to:
  /// **'Fecha de devolución'**
  String get receiveExternalDueDate;

  /// No description provided for @receiveExternalIndefinite.
  ///
  /// In es, this message translates to:
  /// **'Indefinido'**
  String get receiveExternalIndefinite;

  /// No description provided for @receiveExternalRegister.
  ///
  /// In es, this message translates to:
  /// **'Registrar préstamo'**
  String get receiveExternalRegister;

  /// No description provided for @loanConfirmMarkReturned.
  ///
  /// In es, this message translates to:
  /// **'Marcar Devuelto'**
  String get loanConfirmMarkReturned;

  /// No description provided for @loanConfirmConfirmReturn.
  ///
  /// In es, this message translates to:
  /// **'Confirmar devolución'**
  String get loanConfirmConfirmReturn;

  /// No description provided for @loanConfirmSendReminder.
  ///
  /// In es, this message translates to:
  /// **'Enviar recordatorio'**
  String get loanConfirmSendReminder;

  /// No description provided for @loanConfirmForceFinish.
  ///
  /// In es, this message translates to:
  /// **'Forzar finalización'**
  String get loanConfirmForceFinish;

  /// No description provided for @loanConfirmFinish.
  ///
  /// In es, this message translates to:
  /// **'Confirmar y finalizar'**
  String get loanConfirmFinish;

  /// No description provided for @activeLoansEmpty.
  ///
  /// In es, this message translates to:
  /// **'No tienes préstamos pendientes o en curso en este momento.'**
  String get activeLoansEmpty;

  /// No description provided for @loanStatsTitle.
  ///
  /// In es, this message translates to:
  /// **'Resumen de Actividad'**
  String get loanStatsTitle;

  /// No description provided for @loanStatsMade.
  ///
  /// In es, this message translates to:
  /// **'Realizados'**
  String get loanStatsMade;

  /// No description provided for @loanStatsRequests.
  ///
  /// In es, this message translates to:
  /// **'Solicitudes'**
  String get loanStatsRequests;

  /// No description provided for @loanStatsAccepted.
  ///
  /// In es, this message translates to:
  /// **'Aceptados'**
  String get loanStatsAccepted;

  /// No description provided for @wishlistAddTitle.
  ///
  /// In es, this message translates to:
  /// **'Nuevo Deseo'**
  String get wishlistAddTitle;

  /// No description provided for @wishlistTitleLabel.
  ///
  /// In es, this message translates to:
  /// **'Título del libro'**
  String get wishlistTitleLabel;

  /// No description provided for @wishlistScanBarcode.
  ///
  /// In es, this message translates to:
  /// **'Escanear código de barras'**
  String get wishlistScanBarcode;

  /// No description provided for @wishlistAuthorOptional.
  ///
  /// In es, this message translates to:
  /// **'Autor (opcional)'**
  String get wishlistAuthorOptional;

  /// No description provided for @wishlistAddButton.
  ///
  /// In es, this message translates to:
  /// **'Añadir a deseos'**
  String get wishlistAddButton;

  /// No description provided for @readingStatsThisWeek.
  ///
  /// In es, this message translates to:
  /// **'Esta semana'**
  String get readingStatsThisWeek;

  /// No description provided for @readingStatsThisMonth.
  ///
  /// In es, this message translates to:
  /// **'Este mes'**
  String get readingStatsThisMonth;

  /// No description provided for @readingStatsTime.
  ///
  /// In es, this message translates to:
  /// **'Tiempo'**
  String get readingStatsTime;

  /// No description provided for @readingStatsPages.
  ///
  /// In es, this message translates to:
  /// **'Páginas'**
  String get readingStatsPages;

  /// No description provided for @readingStatsFinished.
  ///
  /// In es, this message translates to:
  /// **'Terminados'**
  String get readingStatsFinished;

  /// No description provided for @readingRhythmEmpty.
  ///
  /// In es, this message translates to:
  /// **'El silencio antes de la historia...'**
  String get readingRhythmEmpty;

  /// No description provided for @importBooksTitle.
  ///
  /// In es, this message translates to:
  /// **'Importar libros'**
  String get importBooksTitle;

  /// No description provided for @importBooksMessage.
  ///
  /// In es, this message translates to:
  /// **'Selecciona un archivo CSV o JSON para importar tus libros.'**
  String get importBooksMessage;

  /// No description provided for @importSelectFile.
  ///
  /// In es, this message translates to:
  /// **'Seleccionar archivo'**
  String get importSelectFile;

  /// No description provided for @releaseNotesClose.
  ///
  /// In es, this message translates to:
  /// **'¡A seguir leyendo!'**
  String get releaseNotesClose;

  /// No description provided for @reviewWidgetActiveUser.
  ///
  /// In es, this message translates to:
  /// **'Necesitas un usuario activo'**
  String get reviewWidgetActiveUser;

  /// No description provided for @reviewDialogListTitle.
  ///
  /// In es, this message translates to:
  /// **'Opiniones de \"{title}\"'**
  String reviewDialogListTitle(String title);

  /// No description provided for @reviewWidgetError.
  ///
  /// In es, this message translates to:
  /// **'Error al guardar reseña: {error}'**
  String reviewWidgetError(String error);

  /// No description provided for @reviewWidgetErrorLoad.
  ///
  /// In es, this message translates to:
  /// **'Error al cargar opiniones: {error}'**
  String reviewWidgetErrorLoad(String error);

  /// No description provided for @reviewWidgetRating.
  ///
  /// In es, this message translates to:
  /// **'Valoración'**
  String get reviewWidgetRating;

  /// No description provided for @reviewWidgetComment.
  ///
  /// In es, this message translates to:
  /// **'Comentario (opcional)'**
  String get reviewWidgetComment;

  /// No description provided for @reviewWidgetCommentHint.
  ///
  /// In es, this message translates to:
  /// **'Comparte tu opinión sobre este libro...'**
  String get reviewWidgetCommentHint;

  /// No description provided for @actionSeeAll.
  ///
  /// In es, this message translates to:
  /// **'Ver todas'**
  String get actionSeeAll;

  /// No description provided for @actionManage.
  ///
  /// In es, this message translates to:
  /// **'Gestionar'**
  String get actionManage;

  /// No description provided for @clubRoleOwner.
  ///
  /// In es, this message translates to:
  /// **'Dueño'**
  String get clubRoleOwner;

  /// No description provided for @clubRoleAdmin.
  ///
  /// In es, this message translates to:
  /// **'Admin'**
  String get clubRoleAdmin;

  /// No description provided for @clubStatusActive.
  ///
  /// In es, this message translates to:
  /// **'Activo'**
  String get clubStatusActive;

  /// No description provided for @clubStatusInactive.
  ///
  /// In es, this message translates to:
  /// **'Inactivo'**
  String get clubStatusInactive;
}

class _SDelegate extends LocalizationsDelegate<S> {
  const _SDelegate();

  @override
  Future<S> load(Locale locale) {
    return SynchronousFuture<S>(lookupS(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_SDelegate old) => false;
}

S lookupS(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return SEn();
    case 'es':
      return SEs();
  }

  throw FlutterError(
      'S.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
