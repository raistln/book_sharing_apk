// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class SEs extends S {
  SEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'PassTheBook';

  @override
  String get tabReading => 'Leyendo';

  @override
  String get tabLibrary => 'Biblioteca';

  @override
  String get tabLoans => 'Préstamos';

  @override
  String get tabGroups => 'Grupos';

  @override
  String get tooltipBulletin => 'Boletín Literario';

  @override
  String get tooltipBookshelf => 'Estantería Virtual';

  @override
  String get tooltipNotifications => 'Notificaciones';

  @override
  String get tooltipProfile => 'Perfil';

  @override
  String get tooltipSettings => 'Ajustes';

  @override
  String get tooltipEdit => 'Editar';

  @override
  String get tooltipSave => 'Guardar';

  @override
  String get tooltipLoanHistory => 'Historial de préstamos';

  @override
  String get tooltipSortBooks => 'Ordenar libros';

  @override
  String get tooltipViewList => 'Ver lista';

  @override
  String get tooltipViewGrid => 'Ver cuadrícula';

  @override
  String get tooltipRefreshCovers => 'Actualizar portadas';

  @override
  String get tooltipExportLibrary => 'Exportar biblioteca';

  @override
  String get tooltipRead => 'Leído';

  @override
  String get addBook => 'Añadir libro';

  @override
  String get debugResetPin => 'Debug: reset PIN';

  @override
  String get snackBookAdded => 'Libro añadido a tu biblioteca.';

  @override
  String get snackBookUpdated => 'Libro actualizado correctamente.';

  @override
  String get snackBookDeleted => 'Libro eliminado.';

  @override
  String get snackPinCleared => 'PIN borrado (solo debug).';

  @override
  String get residenceRequired => 'Lugar de residencia necesario';

  @override
  String get residenceRequiredMessage =>
      'Para recibir boletines literarios de tu zona, por favor rellena tu lugar de residencia en tu perfil.';

  @override
  String get notNow => 'Ahora no';

  @override
  String get goToProfile => 'Ir al Perfil';

  @override
  String noBulletinPlaceholder(String province) {
    return 'No se han registrado eventos literarios destacados en la provincia de $province para este mes. ¡Suscríbete a nuestras notificaciones para enterarte de las novedades!';
  }

  @override
  String errorLoadingBulletin(String error) {
    return 'Error al cargar el boletín: $error';
  }

  @override
  String get readingHeader => 'Leyendo';

  @override
  String get activityHeader => 'Actividad';

  @override
  String get chartRhythm => 'Ritmo';

  @override
  String get chartCalendar => 'Calendario';

  @override
  String get noActiveReading => 'Sin lecturas activas';

  @override
  String get goToLibrary => 'Ve a tu biblioteca para empezar';

  @override
  String get statusPaused => 'Pausado';

  @override
  String get readingNow => 'Leyendo ahora';

  @override
  String get libraryHeader => 'Biblioteca';

  @override
  String get tabMyBooks => 'Mis libros';

  @override
  String get tabBorrowedBooks => 'Me prestaron';

  @override
  String get emptyMyBooksMessage => 'Añade tus libros para gestionarlos aquí.';

  @override
  String get emptyBorrowedBooksMessage =>
      'Aquí aparecerán los libros que te presten amigos, ya sea por la app o fuera de ella.';

  @override
  String get noFilterResults => 'No hay coincidencias con los filtros.';

  @override
  String get sortTitleAZ => 'Título (A-Z)';

  @override
  String get sortTitleZA => 'Título (Z-A)';

  @override
  String get sortAuthorAZ => 'Autor (A-Z)';

  @override
  String get sortAuthorZA => 'Autor (Z-A)';

  @override
  String get sortNewest => 'Más recientes';

  @override
  String get sortOldest => 'Más antiguos';

  @override
  String get genreFilter => 'Género';

  @override
  String get allGenres => 'Todos los géneros';

  @override
  String get loansHeader => 'Préstamos';

  @override
  String get loan => 'préstamo';

  @override
  String get loans => 'préstamos';

  @override
  String get requests => 'solicitudes';

  @override
  String incomingRequests(int count) {
    return 'Solicitudes Recibidas ($count)';
  }

  @override
  String outgoingRequests(int count) {
    return 'Solicitudes Enviadas ($count)';
  }

  @override
  String get lentByYou => 'Prestados por ti';

  @override
  String get borrowedFromOthers => 'Te prestaron';

  @override
  String get recentLoans => 'Recientes';

  @override
  String get manualLoan => 'Préstamo Manual';

  @override
  String loanRequestedBy(String name) {
    return 'Solicitado por $name';
  }

  @override
  String lentByWithName(String name) {
    return 'De $name';
  }

  @override
  String loanRequestedTo(String name) {
    return 'Solicitado a $name';
  }

  @override
  String get reject => 'Rechazar';

  @override
  String get accept => 'Aceptar';

  @override
  String get cancelRequest => 'Cancelar solicitud';

  @override
  String get acceptLoanTitle => 'Aceptar Préstamo';

  @override
  String get selectDueDate => 'Selecciona una fecha de vencimiento:';

  @override
  String get indefinite => 'Indefinido';

  @override
  String get cancel => 'Cancelar';

  @override
  String get confirm => 'Confirmar';

  @override
  String get youLent => 'Prestaste';

  @override
  String get theyLentYou => 'Te prestaron';

  @override
  String get bookFallback => 'Libro';

  @override
  String get someoneFallback => 'Alguien';

  @override
  String get ownerFallback => 'Propietario';

  @override
  String get book => 'libro';

  @override
  String booksCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count libros',
      one: '1 libro',
    );
    return '$_temp0';
  }

  @override
  String get fromLabel => 'De:';

  @override
  String get toLabel => 'A:';

  @override
  String get lendBookManually => 'Prestar libro manualmente';

  @override
  String get lendBookManuallyDesc =>
      'Registra un préstamo de tu biblioteca a alguien sin la app';

  @override
  String get registerReceivedBook => 'Registrar libro recibido';

  @override
  String get registerReceivedBookDesc =>
      'Registra un libro que alguien te prestó';

  @override
  String get loanStatusRequested => 'Solicitado';

  @override
  String get loanStatusActive => 'En curso';

  @override
  String get loanStatusReturned => 'Devuelto';

  @override
  String get loanStatusCancelled => 'Cancelado';

  @override
  String get loanStatusRejected => 'Rechazado';

  @override
  String get loanStatusCompleted => 'Completado';

  @override
  String get loanStatusExpired => 'Expirado';

  @override
  String get profileTitle => 'Perfil';

  @override
  String get profileEditTitle => 'Editar Perfil';

  @override
  String get statsBooks => 'Libros';

  @override
  String get statsRead => 'Leídos';

  @override
  String get statsReading => 'Leyendo';

  @override
  String get aboutMe => 'Sobre mí';

  @override
  String get favoriteBook => 'Libro favorito';

  @override
  String get favoriteGenre => 'Género favorito';

  @override
  String get locationLabel => 'Ubicación';

  @override
  String get contactLabel => 'Contacto';

  @override
  String get biographyHeader => 'Biografía';

  @override
  String get quickAccess => 'Accesos rápidos';

  @override
  String get myReadBooks => 'Mis libros leídos';

  @override
  String get wishlist => 'Lista de deseos';

  @override
  String get notSpecified => 'No especificado';

  @override
  String get nameFromRegistration => 'Nombre (desde registro)';

  @override
  String get emailLabel => 'Correo';

  @override
  String get residenceLabel => 'Lugar de residencia (Provincia)';

  @override
  String get favoriteBookLabel => 'Libro favorito';

  @override
  String get favoriteGenreLabel => 'Género favorito';

  @override
  String get biographyNotesLabel => 'Biografía / Notas';

  @override
  String get selectValidProvince =>
      'Seleccione una provincia válida de la lista';

  @override
  String get settingsLibrary => 'Biblioteca';

  @override
  String get settingsLibraryDesc =>
      'Importa o exporta tu biblioteca de libros.';

  @override
  String get exportLibrary => 'Exportar biblioteca';

  @override
  String get exportLibraryDesc =>
      'Guarda tu lista de libros en CSV, JSON o PDF';

  @override
  String get exportLoanHistory => 'Exportar historial de préstamos';

  @override
  String get exportLoanHistoryDesc =>
      'Genera un informe de tus préstamos (CSV)';

  @override
  String get importBooks => 'Importar libros';

  @override
  String get importBooksDesc => 'Importa libros desde un archivo CSV o JSON';

  @override
  String get settingsStorage => 'Almacenamiento';

  @override
  String get deleteAllCovers => 'Borrar todas las portadas';

  @override
  String get deleteAllCoversDesc =>
      'Libera espacio eliminando las imágenes descargadas.';

  @override
  String get resetLocalDatabase => 'Resetear base de datos local';

  @override
  String get resetLocalDatabaseDesc =>
      'Elimina todos los datos locales y comienza desde cero.';

  @override
  String get settingsBackup => 'Copias de seguridad';

  @override
  String get settingsSecurity => 'Ajustes de seguridad';

  @override
  String get settingsSecurityDesc =>
      'Gestiona tu PIN y controla el bloqueo automático por inactividad.';

  @override
  String get changePin => 'Cambiar PIN';

  @override
  String get changePinDesc => 'Vuelve a definir el código de acceso.';

  @override
  String get deletePinAndSwitchUser => 'Eliminar PIN y cambiar de usuario';

  @override
  String get deletePinAndSwitchUserDesc =>
      'Vuelve al inicio para configurar otra cuenta.';

  @override
  String get deletePinConfirmTitle => '¿Eliminar PIN y salir de la cuenta?';

  @override
  String get deletePinConfirmMessage =>
      'Se eliminarán TODOS los datos locales (libros, grupos, préstamos) y tendrás que iniciar sesión o configurar un nuevo usuario.';

  @override
  String get deletePinTip =>
      '💡 Tip: Exporta tu biblioteca antes de continuar. Si tienes backups automáticos, búscalos en Descargas/BookSharing/backups.';

  @override
  String get deleteAll => 'Eliminar todo';

  @override
  String get dataDeleted =>
      'Datos eliminados. Reinicia la app para configurar un nuevo usuario.';

  @override
  String get settingsAppearance => 'Apariencia';

  @override
  String get settingsLanguage => 'Idioma';

  @override
  String get settingsLanguageDesc =>
      'Selecciona en qué idioma se muestra la app.';

  @override
  String get languageSystem => 'Sistema';

  @override
  String get languageSpanish => 'Español';

  @override
  String get languageEnglish => 'English';

  @override
  String get settingsExternalIntegrations => 'Integraciones externas';

  @override
  String get settingsMoreComingSoon => 'Más configuraciones próximamente';

  @override
  String get settingsMoreComingSoonDesc =>
      'Pronto podrás gestionar copias de seguridad, sincronización y preferencias.';

  @override
  String get settingsOpenLibraryCredit =>
      'Datos bibliográficos proporcionados por Open Library (Internet Archive). Contenido bajo licencia ODC-By.';

  @override
  String get donationTitle => 'Invítame a un café';

  @override
  String get donationMessage =>
      'Si esta app te resulta útil, puedes apoyar su desarrollo con una donación.';

  @override
  String get donationButton => 'Invítame a un café';

  @override
  String get donationLinkInvalid => 'El enlace de donación no es válido.';

  @override
  String get donationLinkError => 'No se pudo abrir el enlace de donación.';

  @override
  String donationLinkOpenError(String error) {
    return 'Error al abrir el enlace: $error';
  }

  @override
  String get syncStatus => 'Estado de sincronización';

  @override
  String get syncingWithSupabase => 'Sincronizando con Supabase...';

  @override
  String lastSync(String date) {
    return 'Última sincronización: $date';
  }

  @override
  String get notSyncedYet => 'Aún no se ha sincronizado con Supabase.';

  @override
  String get syncErrorRecent => 'Se encontraron errores recientemente';

  @override
  String get syncLastError => 'Último error de sincronización';

  @override
  String get pendingChanges => 'Hay cambios pendientes por sincronizar.';

  @override
  String get manualSync => 'Sincronización manual';

  @override
  String get manualSyncDesc =>
      'Fuerza la subida y bajada de libros, préstamos y clubes con Supabase. Normalmente esto ocurre de forma automática en segundo plano.';

  @override
  String get syncing => 'Sincronizando...';

  @override
  String get syncNow => 'Sincronizar ahora';

  @override
  String get syncComplete => 'Sincronización completada.';

  @override
  String syncError(String error) {
    return 'Error de sincronización: $error';
  }

  @override
  String get resetDatabaseTitle => '⚠️ Resetear base de datos local';

  @override
  String get resetDatabaseWarning => 'Esto eliminará TODOS los datos locales:';

  @override
  String get resetDatabaseItem1 => '• Libros registrados';

  @override
  String get resetDatabaseItem2 => '• Grupos y membresías';

  @override
  String get resetDatabaseItem3 => '• Préstamos y notificaciones';

  @override
  String get resetDatabaseItem4 => '• Configuración local';

  @override
  String get resetDatabaseCloudNote =>
      'Los datos en la nube (Supabase) NO se eliminarán.';

  @override
  String get resetDatabaseRestartNote =>
      'Después de resetear, la app se reiniciará automáticamente.';

  @override
  String get resetAll => 'Resetear todo';

  @override
  String get resettingDatabase => 'Reseteando base de datos...';

  @override
  String get databaseResetSuccess =>
      'Base de datos reseteada. Reiniciando app...';

  @override
  String databaseResetError(String error) {
    return 'Error al resetear la base de datos: $error';
  }

  @override
  String get deleteCoversConfirmTitle => '¿Borrar todas las portadas?';

  @override
  String get deleteCoversConfirmMessage =>
      'Se eliminarán todas las imágenes de portada descargadas. Podrás volver a descargarlas manualmente desde la biblioteca.';

  @override
  String get delete => 'Eliminar';

  @override
  String coversDeleted(int count) {
    return 'Se eliminaron $count portadas.';
  }

  @override
  String coversDeleteError(String error) {
    return 'Error al borrar portadas: $error';
  }

  @override
  String get googleBooksApi => 'Google Books API';

  @override
  String get googleBooksApiConfigured =>
      'API key configurada. Puedes buscar libros en Google Books.';

  @override
  String get googleBooksApiNotConfigured =>
      'Configura una API key para buscar libros en Google Books.';

  @override
  String get changeApiKey => 'Cambiar API key';

  @override
  String get configureApiKey => 'Configurar API key';

  @override
  String get removeLabel => 'Eliminar';

  @override
  String get howToGetApiKey => '¿Cómo obtener una API key?';

  @override
  String get apiKeyInstructions =>
      '1. Ve a Google Cloud Console\n2. Crea un nuevo proyecto o selecciona uno existente\n3. Habilita la \"Books API\"\n4. Crea credenciales tipo \"API key\"\n5. Copia la clave y pégala aquí';

  @override
  String get configureGoogleBooksApiKey => 'Configurar API key de Google Books';

  @override
  String get apiKeyInputHint =>
      'Introduce tu API key de Google Books para poder buscar libros.';

  @override
  String get apiKeySaved => 'API key guardada correctamente.';

  @override
  String apiKeySaveError(String error) {
    return 'Error al guardar API key: $error';
  }

  @override
  String get deleteApiKeyConfirmTitle => '¿Eliminar API key de Google Books?';

  @override
  String get deleteApiKeyConfirmMessage =>
      'Se eliminará la API key guardada. La búsqueda de libros en Google Books dejará de funcionar hasta que configures una nueva key.';

  @override
  String get apiKeyDeleted => 'API key eliminada.';

  @override
  String apiKeyDeleteError(String error) {
    return 'Error al eliminar API key: $error';
  }

  @override
  String exportLoansError(String error) {
    return 'Error al exportar préstamos: $error';
  }

  @override
  String get activeSessionRequired => 'Debes tener una sesión activa.';

  @override
  String get themeSystem => 'Usar tema del sistema';

  @override
  String get themeLight => 'Modo claro';

  @override
  String get themeDark => 'Modo oscuro';

  @override
  String get themeLoadError => 'No pudimos cargar la preferencia de tema.';

  @override
  String get retry => 'Reintentar';

  @override
  String get genreFantasy => 'Fantasía';

  @override
  String get genreScienceFiction => 'Ciencia Ficción';

  @override
  String get genreHorror => 'Terror';

  @override
  String get genreThrillerSuspense => 'Thriller / Suspense';

  @override
  String get genreCrimeMystery => 'Crimen / Misterio';

  @override
  String get genreRomance => 'Romance';

  @override
  String get genreHistorical => 'Histórica';

  @override
  String get genreLiteraryFiction => 'Ficción Literaria';

  @override
  String get genreNonFiction => 'No Ficción';

  @override
  String get genreBiographyMemoir => 'Biografía / Memorias';

  @override
  String get genreEssay => 'Ensayo';

  @override
  String get genrePhilosophy => 'Filosofía';

  @override
  String get genrePoetry => 'Poesía';

  @override
  String get genreComicsGraphicNovel => 'Cómic / Novela Gráfica';

  @override
  String get genreYoungAdult => 'Juvenil (YA)';

  @override
  String get genreChildren => 'Infantil';

  @override
  String get genreTechnicalEducational => 'Técnico / Educativo';

  @override
  String get genreSelfHelp => 'Autoayuda';

  @override
  String get genrePoliticsSociety => 'Política / Sociedad';

  @override
  String get genreReligionSpirituality => 'Religión / Espiritualidad';

  @override
  String get genreHumor => 'Humor';

  @override
  String get genreAdventure => 'Aventura';

  @override
  String get genreDystopian => 'Distopía';

  @override
  String get genreClassic => 'Clásico';

  @override
  String get evocEmptyLibraryTitle => 'Tu biblioteca aguarda en silencio';

  @override
  String get evocEmptyLibraryMessage =>
      'Las estanterías esperan sus primeros habitantes. Cada gran colección comienza con un solo libro.';

  @override
  String get evocEmptyLibraryAction => 'Añadir primer libro';

  @override
  String get evocEmptySharedLibraryTitle => 'El archivo colectivo está vacío';

  @override
  String get evocEmptySharedLibraryMessage =>
      'Aún no hay libros compartidos en este círculo de lectores. Sé el primero en contribuir al conocimiento común.';

  @override
  String get evocEmptyLoansTitle => 'Sin historias en tránsito';

  @override
  String get evocEmptyLoansMessage =>
      'Los libros descansan en sus estantes. Inicia un nuevo viaje compartiendo una lectura.';

  @override
  String get evocEmptyLoansAction => 'Registrar préstamo';

  @override
  String get evocEmptyPendingLoansTitle => 'No hay solicitudes pendientes';

  @override
  String get evocEmptyPendingLoansMessage =>
      'El buzón de peticiones está vacío. Ningún lector aguarda por el momento.';

  @override
  String get evocEmptyGroupsTitle => 'Aún no formas parte de ningún círculo';

  @override
  String get evocEmptyGroupsMessage =>
      'Los círculos de lectura son comunidades donde las historias fluyen. Únete a uno o crea el tuyo propio.';

  @override
  String get evocEmptyGroupsAction => 'Crear círculo';

  @override
  String get evocEmptyReviewsTitle => 'Sin reseñas todavía';

  @override
  String get evocEmptyReviewsMessage =>
      'Este libro aguarda su primera impresión. ¿Qué te pareció su historia?';

  @override
  String get evocEmptyReviewsAction => 'Escribir primera reseña';

  @override
  String get evocWelcomeTitle => 'Bienvenido a tu biblioteca personal';

  @override
  String get evocWelcomeMessage =>
      'Un lugar donde las historias encuentran hogar y viajan entre lectores.';

  @override
  String get evocEnteringArchive => 'Entrando al archivo...';

  @override
  String get evocLoadingBooks => 'Reuniendo los volúmenes...';

  @override
  String get evocSyncingLibrary => 'Sincronizando el catálogo...';

  @override
  String evocArchiveButton(String groupName) {
    return 'El Gran Archivo de $groupName';
  }

  @override
  String get evocArchiveButtonShort => 'El Gran Archivo';

  @override
  String get evocLoanConfirmed => 'El libro ha iniciado su viaje';

  @override
  String get evocLoanReturned => 'El libro ha regresado a casa';

  @override
  String get evocBookAdded => 'Un nuevo volumen se une a tu colección';

  @override
  String get evocBookRemoved => 'El libro ha sido retirado del catálogo';

  @override
  String get evocBookNotFound => 'Este volumen parece haberse extraviado';

  @override
  String get evocConnectionError =>
      'No se puede alcanzar el archivo remoto en este momento';

  @override
  String get evocSyncError => 'Hubo un problema al sincronizar el catálogo';

  @override
  String get evocReadStatus => 'Leído';

  @override
  String get evocUnreadStatus => 'Por leer';

  @override
  String get evocReadingStatus => 'Leyendo';

  @override
  String evocLoanRequest(String requester, String bookTitle) {
    return '$requester solicita \"$bookTitle\" de tu biblioteca';
  }

  @override
  String evocLoanAccepted(String bookTitle) {
    return 'Tu solicitud de \"$bookTitle\" ha sido aceptada';
  }

  @override
  String evocLoanReturnReminder(String bookTitle, int daysLeft) {
    String _temp0 = intl.Intl.pluralLogic(
      daysLeft,
      locale: localeName,
      other: 'días',
      one: 'día',
    );
    return '\"$bookTitle\" debe regresar en $daysLeft $_temp0';
  }

  @override
  String evocLoanOverdue(String bookTitle) {
    return '\"$bookTitle\" ha excedido su tiempo de préstamo';
  }

  @override
  String get readingStatusPending => 'Pendiente';

  @override
  String get readingStatusReading => 'Leyendo';

  @override
  String get readingStatusPaused => 'Pausado';

  @override
  String get readingStatusFinished => 'Terminado';

  @override
  String get readingStatusAbandoned => 'Abandonado';

  @override
  String get readingStatusRereading => 'Releyendo';

  @override
  String get bookStatusAvailable => 'Disponible';

  @override
  String get bookStatusLoaned => 'Prestado';

  @override
  String get bookStatusPrivate => 'Privado';

  @override
  String get bookStatusArchived => 'Archivado';

  @override
  String get searchBooks => 'Buscar libros...';

  @override
  String get readFilter => 'Leídos';

  @override
  String get unreadFilter => 'No leídos';

  @override
  String get allFilter => 'Todos';

  @override
  String get save => 'Guardar';

  @override
  String get close => 'Cerrar';

  @override
  String get ok => 'Aceptar';

  @override
  String get yes => 'Sí';

  @override
  String get no => 'No';

  @override
  String get error => 'Error';

  @override
  String get errorStateLabel => 'Error';

  @override
  String get loading => 'Cargando...';

  @override
  String errorGeneric(String error) {
    return 'Error: $error';
  }

  @override
  String errorImporting(Object error) {
    return 'Error al importar: $error';
  }

  @override
  String get notificationLoanDueSoonTitle => 'Préstamo por vencer';

  @override
  String get notificationLoanDueSoonBody =>
      'Tu préstamo vence en menos de una semana.';

  @override
  String notificationLoanDueSoonBodyWithTitle(String title) {
    return 'El préstamo de \"$title\" vence pronto.';
  }

  @override
  String get notificationLoanExpiredTitle => 'Préstamo vencido';

  @override
  String get notificationLoanExpiredBody =>
      'Tu préstamo ha llegado a su fecha límite.';

  @override
  String notificationLoanExpiredBodyWithTitle(String title) {
    return 'El préstamo de \"$title\" ha expirado.';
  }

  @override
  String get notificationLoanRequestTitle => 'Nueva solicitud de préstamo';

  @override
  String notificationLoanRequestFallback(String name) {
    return '$name solicitó un préstamo.';
  }

  @override
  String notificationLoanRequestWithTitle(String name, String title) {
    return '$name quiere pedir prestado \"$title\".';
  }

  @override
  String get notificationLoanCancelledTitle =>
      'Solicitud de préstamo cancelada';

  @override
  String notificationLoanCancelledFallback(String name) {
    return '$name canceló la solicitud de préstamo.';
  }

  @override
  String notificationLoanCancelledWithTitle(String name, String title) {
    return '$name canceló la solicitud para \"$title\".';
  }

  @override
  String get notificationLoanRejectedTitle => 'Solicitud de préstamo rechazada';

  @override
  String notificationLoanRejectedFallback(String name) {
    return '$name rechazó tu solicitud de préstamo.';
  }

  @override
  String notificationLoanRejectedWithTitle(String name, String title) {
    return '$name rechazó tu solicitud para \"$title\".';
  }

  @override
  String get notificationLoanAcceptedTitle => 'Préstamo aceptado';

  @override
  String notificationLoanAcceptedFallback(String name) {
    return '$name aceptó tu solicitud de préstamo.';
  }

  @override
  String notificationLoanAcceptedWithTitle(String name, String title) {
    return '$name aceptó tu solicitud para \"$title\".';
  }

  @override
  String get notificationLoanReturnedTitle => 'Préstamo marcado como devuelto';

  @override
  String notificationLoanReturnedFallback(String name) {
    return '$name marcó el préstamo como devuelto.';
  }

  @override
  String notificationLoanReturnedWithTitle(String name, String title) {
    return '$name marcó como devuelto \"$title\".';
  }

  @override
  String get notificationReturnReminderTitle => 'Confirmación pendiente';

  @override
  String get notificationReturnReminderFallback =>
      'Recordatorio para confirmar devolución.';

  @override
  String notificationReturnReminderWithTitle(String title) {
    return 'Recordatorio: Por favor confirma la devolución de \"$title\".';
  }

  @override
  String get loanManualRegistered => 'Préstamo manual registrado.';

  @override
  String get loanExternalRegistered => 'Préstamo externo registrado.';

  @override
  String get loanRequestSent => 'Solicitud enviada.';

  @override
  String get loanRequestCancelled => 'Solicitud cancelada.';

  @override
  String get loanRequestRejected => 'Solicitud rechazada.';

  @override
  String get loanRequestAccepted => 'Préstamo aceptado.';

  @override
  String get loanMarkedReturned => 'Préstamo marcado como devuelto.';

  @override
  String get loanMarkedExpired => 'Préstamo marcado como expirado.';

  @override
  String get loanReturnConfirmed => 'Devolución confirmada.';

  @override
  String get loanReminderSent => 'Recordatorio enviado.';

  @override
  String get errorLoanDueDatePast =>
      'La fecha de devolución no puede ser anterior a hoy.';

  @override
  String get errorLoanCancelledByOther =>
      'El usuario canceló la solicitud antes de que pudieras aceptarla.';

  @override
  String get errorLoanAlreadyActive =>
      'Este libro ya ha sido prestado a otra persona.';

  @override
  String get errorLoanInvalidState =>
      'La solicitud ya no es válida (quizás ya fue aceptada o rechazada).';

  @override
  String get groupCreated => 'Grupo creado.';

  @override
  String get groupUpdated => 'Grupo actualizado.';

  @override
  String get groupDeleted => 'Grupo eliminado.';

  @override
  String get ownershipTransferred => 'Propiedad transferida.';

  @override
  String get memberAdded => 'Miembro añadido.';

  @override
  String get roleUpdated => 'Rol actualizado.';

  @override
  String get memberRemoved => 'Miembro eliminado.';

  @override
  String get invitationCreated => 'Invitación creada.';

  @override
  String get invitationCancelled => 'Invitación cancelada.';

  @override
  String get invitationAccepted => 'Invitación aceptada.';

  @override
  String get invitationUpdated => 'Invitación actualizada.';

  @override
  String get joinedGroup => 'Te uniste al grupo.';

  @override
  String notificationGroupUpdatedTitle(String name) {
    return 'Grupo \"$name\" actualizado';
  }

  @override
  String get notificationGroupUpdatedMessage =>
      'Se han realizado cambios en los detalles del grupo.';

  @override
  String get notificationGroupDeletedTitle => 'Grupo eliminado';

  @override
  String notificationGroupDeletedMessage(String name) {
    return 'El grupo \"$name\" ha sido disuelto.';
  }

  @override
  String notificationGroupMemberJoinedTitle(String name) {
    return 'Nuevo miembro en \"$name\"';
  }

  @override
  String notificationGroupMemberJoinedMessage(String name) {
    return '$name se unió al grupo.';
  }

  @override
  String notificationGroupMemberLeftTitle(String name) {
    return 'Miembro salió de \"$name\"';
  }

  @override
  String notificationGroupMemberLeftMessage(String name) {
    return '$name dejó el grupo.';
  }

  @override
  String notificationGroupMemberJoinedByCodeMessage(String name) {
    return '$name se unió por código.';
  }

  @override
  String userFallback(int id) {
    return 'Usuario $id';
  }

  @override
  String get statusRequested => 'Solicitado';

  @override
  String get statusRequestedCaption => 'Solicitud pendiente de aprobación';

  @override
  String get statusOnLoan => 'En préstamo';

  @override
  String get statusOnLoanCaption => 'Préstamo activo';

  @override
  String get statusAvailable => 'Disponible';

  @override
  String get statusUnavailable => 'No disponible';

  @override
  String get tooltipViewMembers => 'Ver miembros';

  @override
  String get tooltipSortBy => 'Ordenar por';

  @override
  String get filterHideRead => 'Ocultar leídos';

  @override
  String get filterIncludeUnavailable => 'Incluir no disponibles';

  @override
  String get errorLoadingLibrary => 'No pudimos cargar tu biblioteca.';

  @override
  String get errorLoadingSharedBooksGeneric =>
      'No pudimos cargar los libros compartidos.';

  @override
  String get emptySearchTitle => 'Sin resultados para tu búsqueda';

  @override
  String get emptySearchMessage =>
      'Revisa el término ingresado o restablece los filtros para ver más libros.';

  @override
  String get actionClearSearch => 'Limpiar búsqueda';

  @override
  String get emptyMemberBooksTitle => 'Sin libros de este miembro';

  @override
  String get emptyMemberBooksMessage =>
      'Prueba con otra persona o vuelve a mostrar todos los libros disponibles.';

  @override
  String get actionRemoveFilter => 'Quitar filtro';

  @override
  String get emptyDiscoverTitle => 'Todavía no hay libros para descubrir';

  @override
  String get emptyDiscoverMessage =>
      'Cuando otros miembros compartan ejemplares compatibles, los verás listados aquí.';

  @override
  String get actionUpdateList => 'Actualizar lista';

  @override
  String get bookNoTitle => 'Libro sin título';

  @override
  String bookPages(int count) {
    return '$count páginas';
  }

  @override
  String get noReviewsYet => 'Nadie ha opinado todavía';

  @override
  String reviewCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count opiniones',
      one: '1 opinión',
    );
    return '$_temp0';
  }

  @override
  String bookOwner(String name) {
    return 'Propietario: $name';
  }

  @override
  String get bookFormatPhysical => 'Físico';

  @override
  String get bookFormatDigital => 'Digital';

  @override
  String get bookNoDescription =>
      'Este libro no tiene una descripción añadida.';

  @override
  String get actionsTitle => 'Acciones';

  @override
  String reservedBy(String name) {
    return 'Reservado por $name';
  }

  @override
  String get loanPendingApproval => 'pendiente de aprobación';

  @override
  String get loanInProgress => 'en curso';

  @override
  String loanStatusMessage(String status) {
    return 'El préstamo está $status. Podrás solicitarlo cuando vuelva a estar disponible.';
  }

  @override
  String get errorLocalSessionRequired => 'Necesitas iniciar sesión local.';

  @override
  String get errorLocalSessionMessage =>
      'Solo las personas registradas localmente pueden solicitar préstamos.';

  @override
  String get pendingRequestTitle => 'Solicitud pendiente';

  @override
  String pendingRequestFrom(String name) {
    return 'Tienes una solicitud de $name para este libro.';
  }

  @override
  String get actionAcceptRequest => 'Aceptar solicitud';

  @override
  String get actionRejectRequest => 'Rechazar';

  @override
  String get actionBorrow => 'Pedir prestado';

  @override
  String get actionAddToLibrary => 'Añadir a mi biblioteca';

  @override
  String get actionCancelRequest => 'Cancelar solicitud';

  @override
  String alreadyRequestedMessage(String status) {
    return 'Ya enviaste una solicitud para este libro y está $status.';
  }

  @override
  String get bookNotAvailableMessage =>
      'Este libro no está disponible en este momento.';

  @override
  String get errorLoadingBook => 'No pudimos cargar este libro.';

  @override
  String get warningSelectOwner => 'Por favor, selecciona un dueño primero.';

  @override
  String ownerSelectorLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count personas',
      one: '1 persona',
    );
    return 'Disponible a través de $_temp0:';
  }

  @override
  String get me => 'Mí (propietario)';

  @override
  String get availableNow => 'Disponible ahora';

  @override
  String get notInLibrary => 'No está en tu biblioteca';

  @override
  String get opinar => 'Opinar';

  @override
  String get edit => 'Editar';

  @override
  String get dialogCancelRequestTitle => '¿Cancelar solicitud?';

  @override
  String get dialogCancelRequestMessage =>
      '¿Estás seguro de que quieres cancelar esta solicitud de préstamo?';

  @override
  String get dialogRejectRequestTitle => '¿Rechazar solicitud?';

  @override
  String get dialogRejectRequestMessage =>
      '¿Estás seguro de que quieres rechazar esta solicitud de préstamo?';

  @override
  String get dialogAddToLibraryTitle => '¿Añadir a mi biblioteca?';

  @override
  String get dialogAddToLibraryMessage =>
      '¿Seguro que quieres pasar este libro a tu biblioteca personal?';

  @override
  String get errorOriginalMetadataNotFound =>
      'No se encontraron los metadatos del libro original';

  @override
  String bookAddedToLibrary(String title) {
    return '\"$title\" añadido a tu biblioteca';
  }

  @override
  String get errorAlreadyInLibrary => 'Ya tienes este libro en tu biblioteca';

  @override
  String errorAddingToLibrary(String error) {
    return 'Error al añadir a la biblioteca: $error';
  }

  @override
  String get userUnknown => 'Usuario desconocido';

  @override
  String get selectOwnerTitle => '¿A quién quieres pedírselo?';

  @override
  String get addedFromGroup => 'Añadido desde un grupo';

  @override
  String get actionRequestLoan => 'Solicitar préstamo';

  @override
  String get unknown => 'Desconocido';

  @override
  String groupLibrarian(String name) {
    return 'Lector@ Maest@: $name (Dueño)';
  }

  @override
  String lastUpdate(String date) {
    return 'Última actualización: $date';
  }

  @override
  String get tooltipSyncGroup => 'Sincronizar grupo';

  @override
  String get actionEditGroup => 'Editar grupo';

  @override
  String get actionManageMembers => 'Gestionar miembros';

  @override
  String get actionManageInvitations => 'Gestionar invitaciones';

  @override
  String get actionViewMembers => 'Ver miembros';

  @override
  String get actionTransferOwnership => 'Transferir propiedad';

  @override
  String get actionDeleteGroup => 'Eliminar grupo';

  @override
  String get actionLeaveGroup => 'Salir del grupo';

  @override
  String get tooltipGroupActions => 'Acciones del grupo';

  @override
  String get dialogTransferOwnershipTitle => '¿Transferir propiedad?';

  @override
  String dialogTransferOwnershipMessage(String name) {
    return '¿Estás seguro de que quieres transferir la propiedad del grupo a $name?';
  }

  @override
  String get dialogDeleteGroupTitle => '¿Borrar grupo?';

  @override
  String dialogDeleteGroupMessage(String name) {
    return '¿Estás seguro de que quieres borrar el grupo \"$name\"? Esta acción no se puede deshacer.';
  }

  @override
  String get dialogLeaveGroupTitle => '¿Salir del grupo?';

  @override
  String dialogLeaveGroupMessage(String name) {
    return '¿Estás seguro de que quieres salir del grupo \"$name\"?';
  }

  @override
  String get errorUnexpected => 'Ocurrió un error inesperado';

  @override
  String get successGroupDeleted => 'Grupo borrado con éxito';

  @override
  String get successGroupLeft => 'Has salido del grupo';

  @override
  String successOwnershipTransferred(String name) {
    return 'Propiedad transferida a $name';
  }

  @override
  String get successGroupUpdated => 'Grupo actualizado correctamente';

  @override
  String errorUpdatingGroup(String error) {
    return 'Error al actualizar grupo: $error';
  }

  @override
  String get errorNoOtherMembers =>
      'No hay otros miembros a quienes transferir';

  @override
  String errorTransferringOwnership(String error) {
    return 'Error al transferir propiedad: $error';
  }

  @override
  String errorDeletingGroup(String error) {
    return 'Error al eliminar grupo: $error';
  }

  @override
  String errorLeavingGroup(String error) {
    return 'Error al salir del grupo: $error';
  }

  @override
  String get actionTransfer => 'Transferir';

  @override
  String get actionDelete => 'Eliminar';

  @override
  String get actionLeave => 'Salir';

  @override
  String get statMembers => 'Miembros';

  @override
  String get statBooks => 'Libros';

  @override
  String get statAvailable => 'Libres';

  @override
  String get contributionTitle => 'Tu aporte al grupo';

  @override
  String contributionMessage(int count, int activeLoans) {
    return 'Has compartido $count libros y hay $activeLoans en préstamo.';
  }

  @override
  String get actionCreateInvitation => 'Crear invitación';

  @override
  String get noPendingInvitations => 'No hay invitaciones pendientes';

  @override
  String invitationCodeLabel(String code) {
    return 'Código: $code';
  }

  @override
  String invitationExpiresLabel(String date) {
    return 'Expira: $date';
  }

  @override
  String get successInvitationCreated => 'Invitación creada correctamente';

  @override
  String errorCreatingInvitation(String error) {
    return 'Error al crear invitación: $error';
  }

  @override
  String shareInvitationMessage(String code) {
    return 'Te envío esta invitación para unirte a mi grupo de lectores: $code';
  }

  @override
  String get shareInvitationSubject => 'Invitación a grupo de lectores';

  @override
  String errorSharing(String error) {
    return 'Error al compartir: $error';
  }

  @override
  String get dialogCancelInvitationTitle => 'Cancelar invitación';

  @override
  String get dialogCancelInvitationMessage =>
      '¿Estás seguro de cancelar esta invitación?';

  @override
  String get actionCancelInvitationConfirm => 'Sí, cancelar';

  @override
  String get successInvitationCancelled => 'Invitación cancelada';

  @override
  String errorCancellingInvitation(String error) {
    return 'Error al cancelar invitación: $error';
  }

  @override
  String get noLabel => 'No';

  @override
  String get yesLabel => 'Sí';

  @override
  String get invitationsHeader => 'Invitaciones';

  @override
  String get starMemberTooltip => 'Miembro Estrella (Máxima actividad)';

  @override
  String get badgeBibliophile => 'Bibliófilo';

  @override
  String get badgeCurator => 'Curador';

  @override
  String get badgeLibrarian => 'Bibliotecario';

  @override
  String get badgeActiveReader => 'Lector Activo';

  @override
  String get badgeGenerous => 'Generoso';

  @override
  String get actionMakeAdmin => 'Hacer admin';

  @override
  String get actionMakeMember => 'Hacer miembro';

  @override
  String get roleOwner => 'Propietario';

  @override
  String get roleAdmin => 'Administrador';

  @override
  String get roleMember => 'Miembro';

  @override
  String get successMemberRemoved => 'Miembro eliminado';

  @override
  String get successRoleUpdated => 'Rol actualizado';

  @override
  String get selectNewOwnerTitle => 'Seleccionar nuevo propietario';

  @override
  String excludedByFilter(int count, int passing) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count libros excluidos',
      one: '1 libro excluido',
    );
    return '$_temp0 por el filtro de género · $passing visibles';
  }

  @override
  String get actionCreateGroup => 'Crear grupo';

  @override
  String get actionJoinByCode => 'Unirse por código';

  @override
  String get syncGroupsTitle => 'Sincroniza tus grupos';

  @override
  String get syncGroupsMessage =>
      'Conecta con Supabase para traer tus comunidades, miembros y libros compartidos.';

  @override
  String get actionSyncNow => 'Sincronizar ahora';

  @override
  String get errorLoadingGroups => 'No pudimos cargar tus grupos.';

  @override
  String get actionRetrySync => 'Reintentar sincronización';

  @override
  String errorCreatingGroup(String error) {
    return 'No se pudo crear el grupo: $error';
  }

  @override
  String get thematicGroupTitle => 'Grupo temático';

  @override
  String thematicGroupMessage(String genres) {
    return 'Este grupo tiene un filtro activo de géneros: $genres.\n\nSolo los libros físicos de esos géneros serán visibles en este grupo.';
  }

  @override
  String get actionGotIt => 'Entendido';

  @override
  String errorSyncing(String error) {
    return 'Error de sincronización: $error';
  }

  @override
  String get syncCompleted => 'Sincronización completada.';

  @override
  String get joinGroupTitle => 'Unirse a grupo';

  @override
  String get groupCodeLabel => 'Código de grupo';

  @override
  String get successJoinedGroup => '¡Te has unido al grupo exitosamente!';

  @override
  String get pleaseEnterCode => 'Por favor ingresa un código';

  @override
  String get actionJoin => 'Unirse';

  @override
  String get errorInvalidCode =>
      'El código no es válido o ya expiró. Verifícalo e intenta de nuevo.';

  @override
  String get coachMarkDiscoverShareTitle => 'Comparte tus libros';

  @override
  String get coachMarkDiscoverShareDesc =>
      'Publica ejemplares para que tu grupo pueda solicitarlos rápidamente.';

  @override
  String get coachMarkDiscoverFiltersTitle => 'Filtra resultados';

  @override
  String get coachMarkDiscoverFiltersDesc =>
      'Usa estos filtros para ver libros de grupos o propietarios concretos.';

  @override
  String get coachMarkDetailRequestTitle => 'Solicita un préstamo';

  @override
  String get coachMarkDetailRequestDesc =>
      'Desde aquí puedes pedir prestar el libro y coordinar la entrega.';

  @override
  String get coachMarkGroupInviteTitle => 'Gestiona invitaciones';

  @override
  String get coachMarkGroupInviteDesc =>
      'Invita a nuevas personas o revisa solicitudes pendientes de tu grupo.';

  @override
  String get actionNext => 'Siguiente';

  @override
  String get actionDone => 'Listo';

  @override
  String get actionSkip => 'Saltar';

  @override
  String get actionCreateGroupDialog => 'Crear grupo';

  @override
  String get groupNameLabel => 'Nombre del grupo';

  @override
  String get errorInvalidGroupName => 'Introduce un nombre válido.';

  @override
  String get groupDescriptionLabel => 'Descripción (opcional)';

  @override
  String get allowedGenresLabel => 'Géneros permitidos';

  @override
  String get optionalLabel => '(opcional)';

  @override
  String get genreFilterExplanation =>
      'Si eliges géneros, solo los libros de esos géneros serán visibles en este grupo. Sin selección, se muestran todos.';

  @override
  String get genreChangeLaterHint =>
      'Puedes cambiar los géneros más tarde desde el menú del grupo.';

  @override
  String get actionSave => 'Guardar';

  @override
  String get actionCreate => 'Crear';

  @override
  String get noActiveLoansInGroup =>
      'No tienes préstamos activos en este grupo.';

  @override
  String get yourLoansHeader => 'Tus préstamos';

  @override
  String errorLoadingLoans(String error) {
    return 'Error cargando préstamos: $error';
  }

  @override
  String get errorIdentifyingBorrower =>
      'No pudimos identificar al solicitante.';

  @override
  String get successLoanCancelled => 'Solicitud cancelada.';

  @override
  String errorCancellingLoan(String error) {
    return 'No se pudo cancelar la solicitud: $error';
  }

  @override
  String get errorIdentifyingOwner => 'No pudimos identificar al propietario.';

  @override
  String get successLoanAccepted => 'Préstamo aceptado.';

  @override
  String errorAcceptingLoan(String error) {
    return 'No se pudo aceptar el préstamo: $error';
  }

  @override
  String get successLoanRejected => 'Solicitud rechazada.';

  @override
  String errorRejectingLoan(String error) {
    return 'No se pudo rechazar la solicitud: $error';
  }

  @override
  String get errorIdentifyingActiveUser =>
      'No pudimos identificar al usuario activo.';

  @override
  String get successLoanReturned => 'Préstamo marcado como devuelto.';

  @override
  String errorMarkingReturned(String error) {
    return 'No se pudo marcar como devuelto: $error';
  }

  @override
  String get errorPreparingRequest =>
      'No pudimos preparar la solicitud para este libro.';

  @override
  String get successLoanRequested => 'Solicitud enviada.';

  @override
  String errorRequestingLoan(String error) {
    return 'No se pudo enviar la solicitud: $error';
  }

  @override
  String get bookLabel => 'Libro:';

  @override
  String get noDueDate => 'Sin fecha límite';

  @override
  String loanDatesLabel(String start, String due) {
    return 'Inicio: $start · Vence: $due';
  }

  @override
  String loanParticipantsLabel(String borrower, String owner) {
    return 'Solicitante: $borrower · Propietario: $owner';
  }

  @override
  String get actionAccept => 'Aceptar';

  @override
  String get actionReject => 'Rechazar';

  @override
  String get actionMarkReturned => 'Marcar devuelto';

  @override
  String get bookStatsHeader => 'Estadísticas de libros';

  @override
  String get totalLabel => 'Total';

  @override
  String get availableLabel => 'Disponibles';

  @override
  String errorLoadingSharedBooks(String error) {
    return 'Error cargando libros compartidos: $error';
  }

  @override
  String get successSync => 'Sincronización completada';

  @override
  String get discoverTabTitle => 'Descubrir';

  @override
  String get discoverTabDesc =>
      'Explora los grupos a los que perteneces y descubre libros disponibles para solicitar préstamo.';

  @override
  String get noGroupsTitle => 'Aún no perteneces a ningún grupo';

  @override
  String get noGroupsMessage =>
      'Crea un grupo o únete con un código para empezar a compartir libros y gestionar préstamos.';

  @override
  String get actionJoinOrSync => 'Unirme o sincronizar';

  @override
  String get actionRetry => 'Reintentar';

  @override
  String get onboardingSlide1Title => 'Tu propia colección';

  @override
  String get onboardingSlide1Message =>
      'Cada libro cuenta una historia. Preserva las tuyas, añade notas y mantén viva la memoria de tus lecturas.';

  @override
  String get onboardingSlide2Title => 'Círculos de Lectura';

  @override
  String get onboardingSlide2Message =>
      'Donde las historias se encuentran. Únete a comunidades y descubre bibliotecas compartidas con otros lectores.';

  @override
  String get onboardingSlide3Title => 'El viaje del libro';

  @override
  String get onboardingSlide3Message =>
      'Sigue el rastro de cada ejemplar prestado. Gestiona devoluciones y comparte el conocimiento con confianza.';

  @override
  String get onboardingSlide4Title => 'Crónica en la nube';

  @override
  String get onboardingSlide4Message =>
      'Tu catálogo se preserva en Supabase, disponible siempre para continuar la historia desde cualquier lugar.';

  @override
  String get actionStartChronicle => 'Comenzar Crónica';

  @override
  String get actionNextPage => 'Siguiente Página';

  @override
  String get actionSkipPrologue => 'Saltar Prólogo';

  @override
  String get welcomeToApp => '¡Listo! Bienvenido a Book Sharing.';

  @override
  String get stepSkippedHint =>
      'Paso omitido. Puedes configurarlo más tarde desde la ayuda.';

  @override
  String get errorSyncingAccount =>
      'Estamos terminando de sincronizar tu cuenta. Intenta en unos segundos.';

  @override
  String groupAlreadyExists(String name) {
    return 'Ya tienes un grupo llamado \"$name\".';
  }

  @override
  String successGroupCreatedWizard(String name) {
    return 'Grupo \"$name\" creado correctamente.';
  }

  @override
  String errorCreatingGroupWizard(String error) {
    return 'No se pudo crear el grupo: $error';
  }

  @override
  String errorJoiningGroupWizard(String error) {
    return 'No se pudo unir al grupo: $error';
  }

  @override
  String get errorLoadingOnboarding =>
      'No pudimos cargar el estado del onboarding.';

  @override
  String get onboardingWizardTitle => 'Comienza tu historia';

  @override
  String get actionSkipIntro => 'Saltar Introducción';

  @override
  String get actionSealPact => 'Sellar Pacto';

  @override
  String get actionContinueWizard => 'Continuar';

  @override
  String get actionSkipChapter => 'Omitir Capítulo';

  @override
  String get wizardStep1Title => 'Capítulo 1: La Fundación';

  @override
  String get wizardStep1Subtitle =>
      'Crea un círculo para compartir tus volúmenes.';

  @override
  String get wizardStep1Content =>
      'Un grupo te permite compartir libros con otros miembros. Puedes crear uno nuevo ahora o hacerlo más tarde.';

  @override
  String get syncingAccountTitle => 'Sincronizando tu cuenta...';

  @override
  String get syncingAccountSubtitle =>
      'En cuanto terminemos podrás crear grupos.';

  @override
  String get groupNameHint => 'Ej. Club de lectura Aficionados';

  @override
  String get errorGroupNameRequired => 'Introduce un nombre para el grupo.';

  @override
  String get learnAboutGroupsAction => 'Aprender sobre grupos';

  @override
  String get wizardStep2Title => 'Capítulo 2: La Alianza';

  @override
  String get wizardStep2Subtitle =>
      'Únete a un círculo existente mediante código.';

  @override
  String get wizardStep2Content =>
      'Si has recibido una invitación, este es el momento de responder al llamado.';

  @override
  String get syncingAccountSubtitleJoin =>
      'Necesitamos tu usuario activo para validar el código.';

  @override
  String get labelInvitationCode => 'Código de invitación';

  @override
  String get invitationCodeHint => 'Ej. 123e4567-e89b-12d3-a456-426614174000';

  @override
  String get errorInvalidCodeWizard =>
      'Introduce un código válido o pulsa \"Omitir paso\".';

  @override
  String get errorCodeTooShort => 'El código es demasiado corto.';

  @override
  String get wizardStep3Title => 'Epílogo: Confirmaciones';

  @override
  String get wizardStep3Subtitle =>
      'Revisa lo escrito antes de cerrar el libro.';

  @override
  String get whatIsGroupTitle => '¿Qué es un grupo?';

  @override
  String get whatIsGroupContent =>
      'Los grupos reúnen a tus amigos o familiares para compartir bibliotecas locales. Desde aquí podrás invitar miembros, gestionar préstamos y llevar un historial conjunto.';

  @override
  String get whatIsGroupContent2 =>
      'Puedes crear varios grupos: uno para tu familia, otro para tu club de lectura, etc. Cada grupo tiene sus propias invitaciones y catálogos.';

  @override
  String get statusCompleted => 'Completado';

  @override
  String get statusPending => 'Pendiente';

  @override
  String get almostDoneTitle => '¡Ya casi terminamos!';

  @override
  String get onboardingSummaryMessage =>
      'Estos son los pasos que configuraste. Puedes volver atrás si quieres ajustar algo antes de empezar.';

  @override
  String get profileConfiguredTitle => 'Perfil configurado';

  @override
  String userLabel(String name) {
    return 'Usuario: $name';
  }

  @override
  String get firstGroupTitle => 'Primer grupo';

  @override
  String get firstGroupSubtitle => 'Creaste tu comunidad principal.';

  @override
  String get joinByCodeTitle => 'Unión por código';

  @override
  String get joinByCodeSubtitle => 'Te uniste a un grupo existente.';

  @override
  String get finishOnboardingMessage =>
      'Al pulsar “Finalizar” sincronizaremos tu información y te llevaremos a tu biblioteca.';

  @override
  String get notificationLoanApproved => 'Préstamo aceptado';

  @override
  String get notificationLoanRejected => 'Solicitud rechazada';

  @override
  String get notificationLoanCancelled => 'Solicitud cancelada';

  @override
  String get notificationLoanReturned => 'Préstamo devuelto';

  @override
  String get notificationLoanExpired => 'Préstamo vencido';

  @override
  String get notificationLoanDueSoon => 'Préstamo por vencer';

  @override
  String get notificationMemberJoined => 'Nuevo miembro en el grupo';

  @override
  String get notificationMemberLeft => 'Miembro dejó el grupo';

  @override
  String get notificationGroupUpdated => 'Grupo actualizado';

  @override
  String get notificationGroupDeleted => 'Grupo eliminado';

  @override
  String get notificationLoanRequested => 'Nueva solicitud de préstamo';

  @override
  String get actionMarkAsRead => 'Marcar como leído';

  @override
  String get actionDismiss => 'Descartar';

  @override
  String get noNotificationsToClear => 'No hay notificaciones para limpiar.';

  @override
  String get errorNoUserToClearNotifications =>
      'Configura un usuario activo antes de limpiar.';

  @override
  String get successNotificationsCleared => 'Notificaciones borradas.';

  @override
  String errorClearingNotifications(String error) {
    return 'No se pudieron borrar las notificaciones: $error';
  }

  @override
  String get notificationsTitle => 'Notificaciones';

  @override
  String get actionClearAll => 'Vaciar';

  @override
  String get actionClose => 'Cerrar';

  @override
  String get emptyLoansTitle => 'Sin actividad de préstamos';

  @override
  String get emptyLoansMessage =>
      'Tus solicitudes y libros prestados aparecerán aquí.';

  @override
  String get emptyLoansAction => 'Registrar préstamo manual';

  @override
  String get noNotificationsTitle => 'Sin notificaciones';

  @override
  String get noNotificationsMessage =>
      'Aquí verás las novedades sobre tus préstamos y solicitudes.';

  @override
  String get errorLoadingNotifications => 'No se pudieron cargar';

  @override
  String notificationsTooltip(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Tienes $count notificaciones',
      one: 'Tienes 1 notificación',
      zero: 'Notificaciones',
    );
    return '$_temp0';
  }

  @override
  String get syncingLabel => 'Sincronizando...';

  @override
  String get defaultSyncError => 'Se ha encontrado un error.';

  @override
  String get localChangesReadySync =>
      'Cambios locales listos para sincronizar.';

  @override
  String get clubDetailProposals => 'Propuestas';

  @override
  String get clubDetailMembers => 'Miembros';

  @override
  String get clubDetailReadingNow => 'LEYENDO AHORA';

  @override
  String get clubDetailNoActiveBook => 'No hay libro activo';

  @override
  String get clubDetailAddBook => 'Añadir Libro';

  @override
  String get clubDetailDiscussion => 'Discusión';

  @override
  String get clubDetailUpdateProgress => 'Actualizar';

  @override
  String get clubDetailNoProposals => 'No hay propuestas activas';

  @override
  String get clubDetailProposalUnavailable =>
      'Detalles no disponibles para este libro propuesto';

  @override
  String get clubDetailUnknownAuthor => 'Autor desconocido';

  @override
  String clubDetailSection(Object current, Object total) {
    return 'Sección $current/$total';
  }

  @override
  String get clubMembersTitle => 'Miembros del Club';

  @override
  String get clubMembersEmpty => 'No hay miembros (esto es raro)';

  @override
  String get clubMembersKick => 'Expulsar';

  @override
  String clubMembersKickConfirmTitle(String username) {
    return '¿Expulsar a $username?';
  }

  @override
  String get clubMembersKickConfirmMessage =>
      'Esta acción eliminará al usuario del club. ¿Estás seguro?';

  @override
  String get clubMembersKickSuccess => 'Usuario expulsado';

  @override
  String get clubMembersRoleOwner => 'Admin';

  @override
  String get clubMembersRoleMember => 'Miem.';

  @override
  String get clubProposalsTitle => 'Propuestas de Lectura';

  @override
  String get clubProposalsEmpty => 'No hay propuestas activas';

  @override
  String get clubProposalsPropose => 'Proponer';

  @override
  String get clubProposalsLoginRequired => 'Debes iniciar sesión para votar';

  @override
  String clubProposalsChapters(Object count) {
    return '$count caps';
  }

  @override
  String get clubSettingsTitle => 'Configuración del Club';

  @override
  String get clubSettingsSaved => 'Configuración guardada';

  @override
  String get clubSettingsName => 'Nombre del Club';

  @override
  String get clubSettingsDescription => 'Descripción';

  @override
  String get clubSettingsCity => 'Lugar de reunión';

  @override
  String get clubSettingsFrequency => 'Frecuencia de lectura';

  @override
  String get clubSettingsCustomFrequency => 'Periodicidad Personalizada';

  @override
  String get clubSettingsCustomFrequencyDays =>
      'Días asignados para leer cada sección';

  @override
  String get clubSettingsDeleteButton => 'Eliminar Club';

  @override
  String get clubSettingsDeleteTitle => '¿Eliminar Club?';

  @override
  String get clubSettingsDeleteMessage =>
      'Esta acción no se puede deshacer. Todos los datos del club serán eliminados.';

  @override
  String get clubSettingsDeleteSuccess => 'Club eliminado';

  @override
  String get clubListCreateGroup => 'Crear Grupo';

  @override
  String get clubListJoinByCode => 'Unirse por código';

  @override
  String get clubListEmpty => 'Aún no tienes clubes de lectura';

  @override
  String get clubListJoinTitle => 'Unirse a Club';

  @override
  String get clubListJoinIdLabel => 'ID del Club';

  @override
  String get clubListJoinIdHint => 'Ingresa el código UUID del club';

  @override
  String get sectionDiscussionLoginRequired =>
      'Debes iniciar sesión para comentar';

  @override
  String sectionDiscussionTitle(Object number) {
    return 'Discusión Sección $number';
  }

  @override
  String get sectionDiscussionFirstComment => 'Sé el primero en comentar';

  @override
  String get sectionDiscussionHint => 'Escribe un comentario...';

  @override
  String get lockScreenTitle => 'Desbloquea tu biblioteca';

  @override
  String get lockScreenSubtitle => 'Introduce tu llave para acceder';

  @override
  String get lockScreenBiometric => 'Usar huella';

  @override
  String get lockScreenThrottled =>
      'La cerradura está atascada temporalmente. Espera un momento.';

  @override
  String get pinSetupNameLabel => 'Nombre o Alias';

  @override
  String get pinSetupNameHint => 'Ej. El Bibliotecario';

  @override
  String get pinSetupPinLabel => 'Forja tu llave maestra (4 dígitos)';

  @override
  String get pinSetupConfirmLabel => 'Confirma la llave';

  @override
  String get pinSetupExistingAccount =>
      '¿Ya tienes una cuenta? Recupérala aquí';

  @override
  String get loginTitle => 'Inicio con usuario existente';

  @override
  String get loginUsernameLabel => 'Nombre de usuario';

  @override
  String get loginUsernameHint => 'Ej. ana_lectora';

  @override
  String get loginSubmit => 'Acceder';

  @override
  String get loginBack => 'Volver';

  @override
  String get addBookToClubTitle => 'Añadir Libro';

  @override
  String get addBookToClubSelectBook => 'Selecciona un libro';

  @override
  String get addBookToClubInvalidChapters =>
      'Ingresa un número válido de capítulos';

  @override
  String get addBookToClubAdded => 'Libro añadido al club';

  @override
  String get addBookToClubSearchHint => 'Buscar libro (Local o Google Books)';

  @override
  String get addBookToClubNoResults => 'No se encontraron libros';

  @override
  String get addBookToClubLocalSection => 'En tu biblioteca';

  @override
  String get addBookToClubGoogleSection => 'En Google Books';

  @override
  String get addBookToClubChaptersLabel => 'Número de Capítulos';

  @override
  String get addBookToClubSectionMode => 'Modo de Secciones';

  @override
  String get addBookToClubStartDate => 'Fecha de Inicio';

  @override
  String get addBookToClubSelectDate => 'Seleccionar';

  @override
  String get createClubTitle => 'Crear Club de Lectura';

  @override
  String get createClubSuccess => 'Club creado exitosamente';

  @override
  String get createClubNameLabel => 'Nombre del Club';

  @override
  String get createClubDescriptionLabel => 'Descripción';

  @override
  String get createClubCityLabel => 'Ciudad';

  @override
  String get createClubFrequencyLabel => 'Frecuencia de Lectura';

  @override
  String get createClubCustomFrequency => 'Periodicidad Personalizada';

  @override
  String get createClubCustomDays => 'Días asignados para leer cada sección';

  @override
  String get proposeBookTitle => 'Proponer Libro';

  @override
  String get proposeBookSuccess => 'Libro propuesto exitosamente';

  @override
  String get proposeBookSelectBook => 'Selecciona un libro';

  @override
  String get proposeBookSearchHint => 'Buscar libro (Local o Google Books)';

  @override
  String get proposeBookNoResults => 'No se encontraron libros';

  @override
  String get proposeBookLocalSection => 'En tu biblioteca';

  @override
  String get proposeBookGoogleSection => 'En Google Books';

  @override
  String get proposeBookChaptersLabel => 'Número de Capítulos';

  @override
  String get updateProgressTitle => 'Actualizar Progreso';

  @override
  String get updateProgressSectionLabel => '¿Por qué sección vas?';

  @override
  String get updateProgressStatusLabel => 'Estado de lectura';

  @override
  String get bookFormGenres => 'Géneros';

  @override
  String get bookFormAddGenre => 'Añadir género';

  @override
  String get bookFormTitle => 'Título';

  @override
  String get bookFormAuthor => 'Autor';

  @override
  String get bookFormIsbn => 'ISBN';

  @override
  String get bookFormIsbnOptional => 'ISBN (opcional)';

  @override
  String get bookFormAuthorOptional => 'Autor (opcional)';

  @override
  String get bookFormBarcode => 'Código barras';

  @override
  String get bookFormScanBarcode => 'Escanear código';

  @override
  String get bookFormPages => 'Páginas';

  @override
  String get bookFormPageHint => 'Ej: 350';

  @override
  String get bookFormYear => 'Año publicación';

  @override
  String get bookFormYearHint => 'Ej: 2020';

  @override
  String get bookFormNotes => 'Notas';

  @override
  String get bookFormShareBook => 'Compartir libro';

  @override
  String get bookFormAvailable => 'Disponible';

  @override
  String get bookFormPrivate => 'Privado';

  @override
  String get bookFormLoaned => 'Prestado';

  @override
  String get bookFormClearForm => 'Limpiar formulario';

  @override
  String get bookFormStatus => 'Estado del libro';

  @override
  String get bookFormReadingStatus => 'Estado de lectura';

  @override
  String get bookFormDuplicateTitle => 'Libro duplicado';

  @override
  String get bookFormUnderstood => 'Entendido';

  @override
  String get bookFormDeleteTitle => 'Eliminar libro';

  @override
  String bookFormDeleteMessage(String title) {
    return '¿Seguro que deseas eliminar \"$title\"?';
  }

  @override
  String get bookFormSelectGenresTitle => 'Seleccionar géneros';

  @override
  String get bookFormSearchGenre => 'Buscar género...';

  @override
  String get bookFormNoActiveUser =>
      'Necesitas un usuario activo para compartir tus libros.';

  @override
  String get bookDetails => 'Detalles del libro';

  @override
  String get bookDetailsSynopsis => 'Sinopsis';

  @override
  String get bookDetailsWhoRead => '¿Quién lo ha leído?';

  @override
  String get bookDetailsOpine => 'Opinar';

  @override
  String get bookDetailsNoOpinions => 'Nadie ha opinado todavía';

  @override
  String get bookDetailsSeeAllOpinions => 'Ver todas las opiniones';

  @override
  String get bookDetailsStarted => 'Empezado';

  @override
  String get bookDetailsFinished => 'Terminado';

  @override
  String get bookDetailsDuration => 'Duración';

  @override
  String get bookDetailsPagesRead => 'Páginas leídas';

  @override
  String get bookDetailsAvgRhythm => 'Ritmo medio';

  @override
  String get bookDetailsDigital => 'Digital';

  @override
  String get bookDetailsPhysical => 'Físico';

  @override
  String get timelineTitle => 'Línea temporal de lectura';

  @override
  String get timelineUpdateProgress => 'Actualizar progreso';

  @override
  String get timelineEmpty => 'Aún no has registrado ningún progreso';

  @override
  String get timelineAddFirst => 'Añade tu primer hito de lectura';

  @override
  String get timelineDeleteTitle => 'Eliminar evento';

  @override
  String get timelineDeleteMessage =>
      '¿Estás seguro de eliminar este evento de la línea temporal?';

  @override
  String get timelineEntryEdit => 'Editar';

  @override
  String get timelineEntryDelete => 'Eliminar';

  @override
  String get loanNoActiveLoans =>
      'No tienes préstamos pendientes o en curso en este momento.';

  @override
  String loanLenderName(String name) {
    return 'Prestamista: $name';
  }

  @override
  String loanBorrowerName(String name) {
    return 'Solicitante: $name';
  }

  @override
  String loanStatusLabel(String status) {
    return 'Estado: $status';
  }

  @override
  String loanRequestedDate(String date) {
    return 'Solicitado: $date';
  }

  @override
  String loanDueDateValue(String date) {
    return 'Vence: $date';
  }

  @override
  String get loanNavigationDetail => 'Navegación a detalle de préstamo';

  @override
  String get loanMarkReturned => 'Marcar devuelto';

  @override
  String get loanMarkReturnedSuccess => 'Préstamo marcado como devuelto';

  @override
  String get loanReturn => 'Devolución';

  @override
  String get loanReturnDoubleConfirm =>
      'Cuando se complete la devolución, ambos debéis confirmarlo.';

  @override
  String get loanConfirmReturn => 'Confirmar devolución';

  @override
  String loanWaitingFor(String name) {
    return 'Esperando a $name';
  }

  @override
  String loanAlreadyConfirmed(String date) {
    return 'Ya has confirmado la devolución el $date.';
  }

  @override
  String get loanForceFinish => 'Forzar finalización';

  @override
  String get loanSendReminder => 'Enviar recordatorio';

  @override
  String loanOtherConfirmed(String name) {
    return '¡$name confirmó!';
  }

  @override
  String get loanFinishConfirmation =>
      'Confirma que has recibido/entregado el libro para finalizar.';

  @override
  String get loanConfirmAndFinish => 'Confirmar y finalizar';

  @override
  String get loanManualLabel => '(Préstamo manual)';

  @override
  String loanInfoReceived(String owner, String dueDate) {
    return 'Recibido de: $owner\nVence: $dueDate';
  }

  @override
  String loanInfoSent(String borrower, String owner, String dueDate) {
    return 'Prestado a: $borrower\nPrestado de: $owner\nVence: $dueDate';
  }

  @override
  String get you => 'Tú';

  @override
  String get borrower => 'Prestatario';

  @override
  String get user => 'Usuario';

  @override
  String get someone => 'Alguien';

  @override
  String get owner => 'Propietario';

  @override
  String get unknownBook => 'Libro desconocido';

  @override
  String get statsActivitySummary => 'Resumen de Actividad';

  @override
  String get statsRealized => 'Realizados';

  @override
  String get statsAccepted => 'Aceptados';

  @override
  String statsErrorLoadingWithDetail(String error) {
    return 'Error al cargar estadísticas: $error';
  }

  @override
  String get stats30Days => '30 d';

  @override
  String get statsTotalYear => 'Total año';

  @override
  String get wishlistTitle => 'Lista de Deseos';

  @override
  String get wishlistEmpty => 'Tu lista de deseos está vacía.';

  @override
  String get wishlistEmptySub => 'Añade libros que quieras leer o comprar.';

  @override
  String get wishlistAddToLibrary => 'Añadir a mi biblioteca';

  @override
  String get wishlistRemove => 'Eliminar deseo';

  @override
  String get wishlistNew => 'Nuevo deseo';

  @override
  String get wishlistDeleteConfirm => '¿Eliminar deseo?';

  @override
  String wishlistDeleteMessage(String title) {
    return '\"$title\" se borrará de tu lista.';
  }

  @override
  String get wishlistAlreadyHave => '¿Ya lo tienes?';

  @override
  String wishlistMoveToLibraryConfirm(String title) {
    return '¿Seguro que quieres pasar \"$title\" a tu biblioteca personal? Se quitará de tu lista de deseos.';
  }

  @override
  String get notYet => 'Aún no';

  @override
  String get yesItsMine => '¡Sí, ya es mío!';

  @override
  String get wishlistDefaultDescription => 'Añadido desde mi lista de deseos';

  @override
  String wishlistAddedToLibrary(String title) {
    return '\"$title\" añadido a tu biblioteca personal.';
  }

  @override
  String wishlistErrorMoving(String error) {
    return 'Error al mover a la biblioteca: $error';
  }

  @override
  String bookFoundTitle(String title) {
    return '📚 Encontrado: $title';
  }

  @override
  String get bookNotFoundInfo => 'No se encontró información para este código.';

  @override
  String searchError(String error) {
    return 'Error al buscar: $error';
  }

  @override
  String get wishlistNewTitle => 'Nuevo Deseo';

  @override
  String get bookAuthorOptional => 'Autor (opcional)';

  @override
  String get isbnOptional => 'ISBN (opcional)';

  @override
  String get wishlistNotesHint => 'Notas / Por qué lo quieres';

  @override
  String get wishlistAddAction => 'Añadir a deseos';

  @override
  String get zenModeNormal => 'Modo Normal';

  @override
  String get zenModeNocturnal => 'Modo Lectura Nocturna';

  @override
  String get remaining => 'restante';

  @override
  String get endSessionAction => 'TERMINAR SESIÓN';

  @override
  String get sessionCompleted => 'Sesión completada';

  @override
  String sessionDurationSummary(String minutes, String title) {
    return '$minutes minutos dedicados a \"$title\"';
  }

  @override
  String get sessionLastPagePrompt => '¿En qué página te has quedado?';

  @override
  String get sessionLastPageHint => 'Ej: 145';

  @override
  String get sessionNotesPrompt => '¿Algo que quieras recordar?';

  @override
  String get sessionNotesHint =>
      'Ej: \"El capítulo con Maga me hizo llorar. Increíble.\"';

  @override
  String get sessionMarkFinished => 'Marcar libro como terminado';

  @override
  String get sessionSaveOnly => 'SOLO GUARDAR';

  @override
  String get sessionSaveAndView => 'GUARDAR Y VER LIBRO';

  @override
  String get thisWeek => 'Esta semana';

  @override
  String get timeLabel => 'Tiempo';

  @override
  String get pagesLabel => 'Páginas';

  @override
  String get pagesPerDayLabel => 'Págs/día';

  @override
  String get thisMonth => 'Este mes';

  @override
  String get finishedLabel => 'Terminados';

  @override
  String get rhythmJourneyTitle => 'Tu viaje lector';

  @override
  String get rhythmEmptyState => 'El silencio antes de la historia...';

  @override
  String get securityResetConfirmTitle => '¿Eliminar PIN y salir de la cuenta?';

  @override
  String get securityResetConfirmMessage =>
      'Se eliminarán TODOS los datos locales (libros, grupos, préstamos) y tendrás que iniciar sesión o configurar un nuevo usuario.';

  @override
  String get securityResetConfirmTip =>
      '💡 Tip: Exporta tu biblioteca antes de continuar. Si tienes backups automáticos, búscalos en Descargas/BookSharing/backups.';

  @override
  String get securityResetAction => 'Eliminar todo';

  @override
  String get securityResetSuccess =>
      'Datos eliminados. Reinicia la app para configurar un nuevo usuario.';

  @override
  String get errorActiveSessionRequired => 'Debes tener una sesión activa.';

  @override
  String errorExportingLoans(String error) {
    return 'Error al exportar préstamos: $error';
  }

  @override
  String get errorLoadingTheme => 'No pudimos cargar la preferencia de tema.';

  @override
  String get googleBooksKeyConfigured =>
      'API key configurada. Puedes buscar libros en Google Books.';

  @override
  String get googleBooksKeyNotConfigured =>
      'Configura una API key para buscar libros en Google Books.';

  @override
  String get configApiKey => 'Configurar API key';

  @override
  String get googleBooksKeyHelpTitle => '¿Cómo obtener una API key?';

  @override
  String get googleBooksKeyHelpSteps =>
      '1. Ve a Google Cloud Console\\n2. Crea un nuevo proyecto o selecciona uno existente\\n3. Habilita la \"Books API\"\\n4. Crea credenciales tipo \"API key\"\\n5. Copia la clave y pégala aquí';

  @override
  String get googleBooksKeyDialogTitle => 'Configurar API key de Google Books';

  @override
  String get googleBooksKeyDialogDesc =>
      'Introduce tu API key de Google Books para poder buscar libros.';

  @override
  String get googleBooksKeyHint => 'Pega tu API key aquí';

  @override
  String get googleBooksKeyValidationTip =>
      'Puedes validar la API key antes de guardarla.';

  @override
  String get validateAndSave => 'Validar y guardar';

  @override
  String errorValidatingApiKey(String error) {
    return 'Error al validar API key: $error';
  }

  @override
  String get apiKeySavedSuccess => 'API key guardada correctamente.';

  @override
  String errorSavingApiKey(String error) {
    return 'Error al guardar API key: $error';
  }

  @override
  String get googleBooksKeyDeleteTitle => '¿Eliminar API key de Google Books?';

  @override
  String get googleBooksKeyDeleteDesc =>
      'Se eliminará la API key guardada. La búsqueda de libros en Google Books dejará de funcionar hasta que configures una nueva key.';

  @override
  String get apiKeyDeletedSuccess => 'API key eliminada.';

  @override
  String errorDeletingApiKey(String error) {
    return 'Error al eliminar API key: $error';
  }

  @override
  String get backupPermissionDesc =>
      'Para guardar y restaurar backups en la carpeta de Descargas, necesitamos acceso a todos los archivos.\\n\\nPor favor, concede el permiso en la siguiente pantalla.';

  @override
  String get errorStoragePermissionRequired =>
      'Se requiere permiso de almacenamiento para guardar el backup.';

  @override
  String get autoBackupEnabled => 'Backup automático semanal activado';

  @override
  String get autoBackupDisabled => 'Backup automático desactivado';

  @override
  String errorChangingBackupConfig(String error) {
    return 'Error al cambiar configuración: $error';
  }

  @override
  String get creatingBackup => 'Creando copia de seguridad...';

  @override
  String backupSavedAt(String path) {
    return 'Backup guardado en: $path';
  }

  @override
  String get errorCreatingBackup =>
      'No se pudo crear el backup. Intenta de nuevo.';

  @override
  String errorCreatingBackupDetail(String error) {
    return 'Error al crear backup: $error';
  }

  @override
  String get restoreLatestBackupTitle => '¿Restaurar último backup automático?';

  @override
  String get restoreBackupWarning =>
      'Esta acción reemplazará TODOS tus datos actuales con la copia de seguridad más reciente.';

  @override
  String get searchingBackups => 'Buscando backups...';

  @override
  String get noBackupsFound => 'No se encontraron backups automáticos.';

  @override
  String restoringBackup(String filename) {
    return 'Restaurando $filename...';
  }

  @override
  String get restoreComplete => 'Restauración completada. Reiniciando...';

  @override
  String errorRestoringBackup(String error) {
    return 'Error al restaurar: $error';
  }

  @override
  String get restoreSpecificBackupTitle => '¿Restaurar este backup?';

  @override
  String get restore => 'Restaurar';

  @override
  String get appRestartNote =>
      'La aplicación se reiniciará automáticamente tras la restauración.';

  @override
  String get deleteAction => 'Eliminar';

  @override
  String get permissionRequired => 'Permiso requerido';

  @override
  String get continueLabel => 'Continuar';

  @override
  String get warningLabel => 'Advertencia';

  @override
  String backupFileLabel(String filename) {
    return 'Archivo: $filename';
  }

  @override
  String errorResettingDatabase(String error) {
    return 'Error al resetear la base de datos: $error';
  }

  @override
  String get deleteCoversTitle => '¿Borrar todas las portadas?';

  @override
  String get deleteCoversDesc =>
      'Se eliminarán todas las imágenes de portada descargadas. Podrás volver a descargarlas manualmente desde la biblioteca.';

  @override
  String coversDeletedCount(String count) {
    return 'Se eliminaron $count portadas.';
  }

  @override
  String errorDeletingCovers(String error) {
    return 'Error al borrar portadas: $error';
  }

  @override
  String get importBooksDialogTitle => 'Importar libros';

  @override
  String get importBooksDialogDesc =>
      'Selecciona un archivo CSV o JSON para importar tus libros.';

  @override
  String get selectFile => 'Seleccionar archivo';

  @override
  String importSuccessCount(String count) {
    return 'Se importaron $count libros correctamente';
  }

  @override
  String importFailureCount(String count) {
    return ' ($count fallidos)';
  }

  @override
  String importMoreErrors(String count) {
    return ' (y $count más...)';
  }

  @override
  String get errorNoBooksImported => 'No se pudo importar ningún libro';

  @override
  String get errorNoActiveUserImport =>
      'No hay usuario activo para importar los libros.';

  @override
  String get errorUnsupportedFileFormat => 'Formato de archivo no soportado';

  @override
  String get releaseNotesTitle => '¡Nuevos Capítulos!';

  @override
  String versionLabel(String version) {
    return 'Versión $version';
  }

  @override
  String get releaseNotesAction => '¡A seguir leyendo!';

  @override
  String get bookshelfSearchTooltip => 'Buscar en mis lecturas';

  @override
  String get bookshelfThemeTooltip => 'Personalizar estantería';

  @override
  String get bookshelfManageTooltip => 'Gestionar títulos';

  @override
  String get bookshelfSearchHint => 'Buscar por título o autor...';

  @override
  String get bookshelfCustomTitle => 'Personalizar Estantería';

  @override
  String get bookshelfTabShelves => 'Baldas';

  @override
  String get bookshelfTabWall => 'Fondo';

  @override
  String get sortRecent => 'Recientes';

  @override
  String get sortAlpha => 'A → Z';

  @override
  String get sortAuthor => 'Autor';

  @override
  String get sortPages => 'Páginas';

  @override
  String get sortRating => 'Valoración';

  @override
  String get shelfThemeClassic => 'Clásica';

  @override
  String get shelfThemeModern => 'Moderna';

  @override
  String get shelfThemeVintage => 'Vintage';

  @override
  String get shelfThemeIndustrial => 'Industrial';

  @override
  String get shelfThemePastel => 'Pastel';

  @override
  String get wallThemePlaster => 'Yeso';

  @override
  String get wallThemeBrick => 'Ladrillo';

  @override
  String get wallThemePaper => 'Papel';

  @override
  String get wallThemeWood => 'Madera';

  @override
  String get wallThemeDark => 'Oscuro';

  @override
  String get statsGeneralTitle => 'Estadísticas generales';

  @override
  String get statsTotalBooks => 'Libros totales';

  @override
  String get statsReadBooks => 'Libros leídos';

  @override
  String get statsAvailable => 'Disponibles';

  @override
  String get statsTotalLoans => 'Préstamos totales';

  @override
  String get statsActiveLoans => 'Préstamos activos';

  @override
  String get statsReturned => 'Devueltos';

  @override
  String get statsExpired => 'Expirados';

  @override
  String get statsViewReadingHistory => 'Ver historial de lecturas';

  @override
  String get statsActiveLoansHeader => 'Préstamos activos';

  @override
  String get statsTopBooksHeader => 'Libros más prestados';

  @override
  String get statsNoTopBooksMessage =>
      'Cuando registres préstamos aparecerán aquí tus libros más populares.';

  @override
  String statsLoanCount(String count) {
    return 'Préstamos registrados: $count';
  }

  @override
  String get statsErrorLoading => 'No pudimos cargar las estadísticas.';

  @override
  String get statsRecommendationsTitle => 'Recomendaciones para ti';

  @override
  String get statsUnknownAuthor => 'Autor desconocido';

  @override
  String get loanManualTitle => 'Nuevo Préstamo Manual';

  @override
  String get loanReceiveTitle => 'Registrar libro prestado';

  @override
  String get loanReceiveDescription =>
      'Registra un libro que alguien (fuera de la app) te ha prestado.';

  @override
  String get loanWhoLentIt => '¿Quién te lo prestó?';

  @override
  String get loanLenderNameRequired => 'Nombre del propietario *';

  @override
  String get loanLenderNameRequiredError =>
      '¿Quién es el guardián de este libro?';

  @override
  String get lenderLabel => 'Propietario:';

  @override
  String loanErrorRegister(String error) {
    return 'Error al registrar: $error';
  }

  @override
  String get isbnInvalid => 'ISBN no válido';

  @override
  String get bookNotFound => 'No se encontró el libro';

  @override
  String get searchPromptTitleOrIsbn => 'Introduce título o ISBN';

  @override
  String get searchNoResults => 'Sin resultados';

  @override
  String get searchSelectResult => 'Selecciona un resultado';

  @override
  String get unknownAuthor => 'Autor desconocido';

  @override
  String get permissionCameraDenied => 'Permiso de cámara denegado';

  @override
  String get scanBarcode => 'Escanear código';

  @override
  String get searching => 'Buscando...';

  @override
  String get searchData => 'Buscar datos';

  @override
  String get bookTitleRequired => 'Título del libro *';

  @override
  String get bookTitleRequiredError => '¿Cómo se llama la historia?';

  @override
  String get loanBookToLend => 'Libro a prestar';

  @override
  String get loanNoAvailableBooks =>
      'No tienes libros disponibles para prestar.';

  @override
  String get loanSelectBook => 'Selecciona un libro';

  @override
  String loanErrorLoadingBooks(String error) {
    return 'Error cargando libros: $error';
  }

  @override
  String get loanBorrowerData => 'Datos del prestatario';

  @override
  String get loanFullName => 'Nombre Completo';

  @override
  String get loanFullNameHint => 'Ej. Juan Pérez';

  @override
  String get loanNameRequired => 'El nombre es requerido';

  @override
  String get loanContactOptional => 'Contacto (Opcional)';

  @override
  String get loanContactHint => 'Teléfono, email o nota';

  @override
  String get loanDueDate => 'Fecha de devolución';

  @override
  String get loanIndefinite => 'Indefinido';

  @override
  String get loanNoDueDate => 'Sin fecha límite';

  @override
  String get loanRegister => 'Registrar Préstamo';

  @override
  String get loanRegisteredSuccess => 'Préstamo registrado';

  @override
  String get borrowerLabel => 'Prestatario:';

  @override
  String get dueLabel => 'Vence:';

  @override
  String get understood => 'Entendido';

  @override
  String get saving => 'Guardando...';

  @override
  String get timelineStart => 'Inicio';

  @override
  String get timelineProgress => 'Progreso';

  @override
  String get timelinePause => 'Pausa';

  @override
  String get timelineResume => 'Reanudación';

  @override
  String get timelineFinish => 'Finalizado';

  @override
  String timelinePage(int number) {
    return 'Página $number';
  }

  @override
  String get addTimelineDate => 'Fecha';

  @override
  String get addTimelineCurrentPage => 'Página actual (opcional)';

  @override
  String get addTimelineNote => 'Nota personal (opcional)';

  @override
  String get addTimelineNoteHint => 'Tus impresiones, pensamientos...';

  @override
  String get addTimelineInvalidPage =>
      'Por favor, introduce un número de página válido';

  @override
  String get addTimelineEditTitle => 'Editar progreso';

  @override
  String get addTimelineAddTitle => 'Añadir progreso';

  @override
  String addTimelineToday(String time) {
    return 'Hoy, $time';
  }

  @override
  String addTimelineYesterday(String time) {
    return 'Ayer, $time';
  }

  @override
  String addTimelineTotalPagesHint(int count) {
    return 'De $count páginas';
  }

  @override
  String get addTimelinePageNumberHint => 'Número de página';

  @override
  String get addTimelineUpdateSuccess => 'Progreso actualizado';

  @override
  String get addTimelineAddSuccess => 'Progreso añadido';

  @override
  String reviewDialogTitle(String title) {
    return '¿Cómo recomendarías \"$title\"?';
  }

  @override
  String get reviewDialogOptionalComment => 'Escribe una reseña (opcional)';

  @override
  String get reviewDialogCommentHint =>
      'Comparte tu opinión sobre este libro...';

  @override
  String get reviewDialogAdded => 'Reseña añadida.';

  @override
  String get reviewDialogRecommendTitle => '¿A quién se lo recomiendas?';

  @override
  String get reviewDialogRecommendMessage =>
      'Has dado una valoración positiva. ¿Quieres enviarle un mensaje a alguien para recomendárselo?';

  @override
  String get reviewDialogNotNow => 'Ahora no';

  @override
  String get reviewDialogRecommend => 'Recomendar';

  @override
  String get reviewDialogWriteTitle => 'Escribe una reseña';

  @override
  String reviewDialogByAuthor(String author) {
    return 'por $author';
  }

  @override
  String get reviewListEdit => 'Editar reseña';

  @override
  String get readStatusFilterAll => 'Todos los libros';

  @override
  String get readStatusFilterRead => 'Leídos';

  @override
  String get readStatusFilterUnread => 'No leídos';

  @override
  String get libraryEmpty => 'Tu biblioteca está vacía';

  @override
  String get libraryEmptyMessage =>
      'Registra tu primer libro para organizar préstamos y compartir lecturas con tu grupo.';

  @override
  String get libraryRegister => 'Registrar libro';

  @override
  String get searchBarHint => 'Buscar por título o autor...';

  @override
  String get exportCSV => 'Exportar como CSV';

  @override
  String get exportJSON => 'Exportar como JSON';

  @override
  String get exportPDF => 'Exportar como PDF';

  @override
  String get export => 'Exportar';

  @override
  String get exportNoBooks => 'No hay libros para exportar.';

  @override
  String exportError(String error) {
    return 'No se pudo exportar: $error';
  }

  @override
  String get refreshMetadata => 'Actualizar metadatos';

  @override
  String get refreshMetadataMessage =>
      'Se buscarán portadas y datos faltantes (páginas, año, género) para tus libros.';

  @override
  String get refreshMetadataWaitMessage =>
      'Se buscarán portadas y datos faltantes (páginas, año, género) para tus libros. Esto puede tardar varios minutos dependiendo de cuántos libros tengas.';

  @override
  String get refreshOnlyMissing => 'Solo faltantes';

  @override
  String get refreshForceAll => 'Forzar todo';

  @override
  String get refreshingMetadata => 'Actualizando metadatos...';

  @override
  String get refreshMetadataNone =>
      'Todos los libros ya tienen metadatos completos.';

  @override
  String refreshMetadataSuccess(int success, int total) {
    return 'Metadatos actualizados: $success de $total.';
  }

  @override
  String refreshMetadataError(String error) {
    return 'Error al actualizar metadatos: $error';
  }

  @override
  String get coverGallery => 'Galería';

  @override
  String get coverCamera => 'Cámara';

  @override
  String get coverDelete => 'Eliminar';

  @override
  String get readingStatusTitle => 'Estado de lectura';

  @override
  String readingStatusChanged(String status) {
    return 'Estado cambiado a: $status';
  }

  @override
  String readingStatusError(String error) {
    return 'Error al cambiar estado: $error';
  }

  @override
  String get insightJustStarted => 'Acabas de empezar este libro';

  @override
  String get insightNearlyFinished => 'Estás a punto de terminar este libro';

  @override
  String get insightReflective =>
      'Este libro parece invitar a pausas y reflexión';

  @override
  String get insightDevoured => 'Has devorado este libro con entusiasmo';

  @override
  String get insightFastPace => 'Una lectura vertiginosa, difícil de soltar';

  @override
  String get insightSlowPace =>
      'Estás saboreando este libro con calma, sin prisas';

  @override
  String get insightSteadyPace => 'Llevas un ritmo constante con este libro';

  @override
  String get insightFinishedFast =>
      '¡Lo leíste de un tirón! Otra aventura vivida.';

  @override
  String get insightFinishedNormal =>
      'Un viaje completado. Cada página, un paso más.';

  @override
  String get insightFinishedSlow =>
      'Terminado. Las historias que duran también dejan huella.';

  @override
  String get recommendLevel1 => 'No lo recomendaría';

  @override
  String get recommendLevel2 => 'Está bien, pero no es para mí';

  @override
  String get recommendLevel3 => 'Lo recomiendo a gente como yo';

  @override
  String get recommendLevel4 => 'Todo el mundo debería leerlo';

  @override
  String get recommendLevel5 => 'Lo terminé, pero me costó';

  @override
  String get recommendLevel1Short => 'No recomendado';

  @override
  String get recommendLevel2Short => 'Ni fu ni fa';

  @override
  String get recommendLevel3Short => 'Recomendado';

  @override
  String get recommendLevel4Short => 'Imprescindible';

  @override
  String get recommendLevel5Short => 'Terminado con esfuerzo';

  @override
  String bookDetailsIsbn(String isbn) {
    return 'ISBN: $isbn';
  }

  @override
  String get coverNoCover => 'Sin portada';

  @override
  String get coverSelected => 'Portada seleccionada';

  @override
  String get coverHelp => 'Añade una imagen para identificar mejor tus libros.';

  @override
  String get coverNotAvailable => 'Portadas no disponibles en esta plataforma';

  @override
  String get selectGenresTitle => 'Seleccionar géneros';

  @override
  String get searchGenreHint => 'Buscar género...';

  @override
  String bookSourceFound(String source) {
    return 'Fuente: $source';
  }

  @override
  String get manualLoanTitle => 'Nuevo Préstamo Manual';

  @override
  String get manualLoanBookSection => 'Libro a prestar';

  @override
  String get manualLoanNoBooksAvailable =>
      'No tienes libros disponibles para prestar.';

  @override
  String get manualLoanSelectBook => 'Selecciona un libro';

  @override
  String get manualLoanBorrowerSection => 'Datos del prestatario';

  @override
  String get manualLoanFullName => 'Nombre Completo';

  @override
  String get manualLoanFullNameHint => 'Ej. Juan Pérez';

  @override
  String get manualLoanContact => 'Contacto (Opcional)';

  @override
  String get manualLoanContactHint => 'Teléfono, email o nota';

  @override
  String get manualLoanDueDate => 'Fecha de devolución';

  @override
  String get manualLoanIndefinite => 'Indefinido';

  @override
  String get manualLoanRegistered => 'Préstamo registrado';

  @override
  String get receiveExternalTitle => 'Registrar libro prestado';

  @override
  String get receiveExternalSubtitle =>
      'Registra un libro que alguien (fuera de la app) te ha prestado.';

  @override
  String get receiveExternalBookSection => 'Detalles del libro';

  @override
  String get receiveExternalTitleLabel => 'Título del libro *';

  @override
  String get receiveExternalAuthor => 'Autor';

  @override
  String get receiveExternalOwnerSection => '¿Quién te lo prestó?';

  @override
  String get receiveExternalOwnerLabel => 'Nombre del propietario *';

  @override
  String get receiveExternalContact => 'Contacto (Opcional)';

  @override
  String get receiveExternalContactHint => 'Teléfono, email, etc.';

  @override
  String get receiveExternalDueDate => 'Fecha de devolución';

  @override
  String get receiveExternalIndefinite => 'Indefinido';

  @override
  String get receiveExternalRegister => 'Registrar préstamo';

  @override
  String get loanConfirmMarkReturned => 'Marcar Devuelto';

  @override
  String get loanConfirmConfirmReturn => 'Confirmar devolución';

  @override
  String get loanConfirmSendReminder => 'Enviar recordatorio';

  @override
  String get loanConfirmForceFinish => 'Forzar finalización';

  @override
  String get loanConfirmFinish => 'Confirmar y finalizar';

  @override
  String get activeLoansEmpty =>
      'No tienes préstamos pendientes o en curso en este momento.';

  @override
  String get loanStatsTitle => 'Resumen de Actividad';

  @override
  String get loanStatsMade => 'Realizados';

  @override
  String get loanStatsRequests => 'Solicitudes';

  @override
  String get loanStatsAccepted => 'Aceptados';

  @override
  String get wishlistAddTitle => 'Nuevo Deseo';

  @override
  String get wishlistTitleLabel => 'Título del libro';

  @override
  String get wishlistScanBarcode => 'Escanear código de barras';

  @override
  String get wishlistAuthorOptional => 'Autor (opcional)';

  @override
  String get wishlistAddButton => 'Añadir a deseos';

  @override
  String get readingStatsThisWeek => 'Esta semana';

  @override
  String get readingStatsThisMonth => 'Este mes';

  @override
  String get readingStatsTime => 'Tiempo';

  @override
  String get readingStatsPages => 'Páginas';

  @override
  String get readingStatsFinished => 'Terminados';

  @override
  String get readingRhythmEmpty => 'El silencio antes de la historia...';

  @override
  String get importBooksTitle => 'Importar libros';

  @override
  String get importBooksMessage =>
      'Selecciona un archivo CSV o JSON para importar tus libros.';

  @override
  String get importSelectFile => 'Seleccionar archivo';

  @override
  String get releaseNotesClose => '¡A seguir leyendo!';

  @override
  String get reviewWidgetActiveUser => 'Necesitas un usuario activo';

  @override
  String reviewDialogListTitle(String title) {
    return 'Opiniones de \"$title\"';
  }

  @override
  String reviewWidgetError(String error) {
    return 'Error al guardar reseña: $error';
  }

  @override
  String reviewWidgetErrorLoad(String error) {
    return 'Error al cargar opiniones: $error';
  }

  @override
  String get reviewWidgetRating => 'Valoración';

  @override
  String get reviewWidgetComment => 'Comentario (opcional)';

  @override
  String get reviewWidgetCommentHint =>
      'Comparte tu opinión sobre este libro...';

  @override
  String get actionSeeAll => 'Ver todas';

  @override
  String get actionManage => 'Gestionar';

  @override
  String get clubRoleOwner => 'Dueño';

  @override
  String get clubRoleAdmin => 'Admin';

  @override
  String get clubStatusActive => 'Activo';

  @override
  String get clubStatusInactive => 'Inactivo';
}
