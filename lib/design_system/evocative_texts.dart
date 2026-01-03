/// Textos evocadores para la aplicación
/// Inspirados en la literatura y el mundo de los libros
class EvocativeTexts {
  EvocativeTexts._();

  // Estados vacíos - Biblioteca Personal
  static const String emptyLibraryTitle = 'Tu biblioteca aguarda en silencio';
  static const String emptyLibraryMessage =
      'Las estanterías esperan sus primeros habitantes. Cada gran colección comienza con un solo libro.';
  static const String emptyLibraryAction = 'Añadir primer libro';

  // Estados vacíos - Biblioteca Compartida
  static const String emptySharedLibraryTitle =
      'El archivo colectivo está vacío';
  static const String emptySharedLibraryMessage =
      'Aún no hay libros compartidos en este círculo de lectores. Sé el primero en contribuir al conocimiento común.';

  // Estados vacíos - Préstamos
  static const String emptyLoansTitle = 'Sin historias en tránsito';
  static const String emptyLoansMessage =
      'Los libros descansan en sus estantes. Inicia un nuevo viaje compartiendo una lectura.';
  static const String emptyLoansAction = 'Registrar préstamo';

  // Estados vacíos - Préstamos pendientes
  static const String emptyPendingLoansTitle = 'No hay solicitudes pendientes';
  static const String emptyPendingLoansMessage =
      'El buzón de peticiones está vacío. Ningún lector aguarda por el momento.';

  // Estados vacíos - Grupos
  static const String emptyGroupsTitle =
      'Aún no formas parte de ningún círculo';
  static const String emptyGroupsMessage =
      'Los círculos de lectura son comunidades donde las historias fluyen. Únete a uno o crea el tuyo propio.';
  static const String emptyGroupsAction = 'Crear círculo';

  // Estados vacíos - Reseñas
  static const String emptyReviewsTitle = 'Sin reseñas todavía';
  static const String emptyReviewsMessage =
      'Este libro aguarda su primera impresión. ¿Qué te pareció su historia?';
  static const String emptyReviewsAction = 'Escribir primera reseña';

  // Mensajes de bienvenida
  static const String welcomeTitle = 'Bienvenido a tu biblioteca personal';
  static const String welcomeMessage =
      'Un lugar donde las historias encuentran hogar y viajan entre lectores.';

  // Transiciones
  static const String enteringArchive = 'Entrando al archivo...';
  static const String loadingBooks = 'Reuniendo los volúmenes...';
  static const String syncingLibrary = 'Sincronizando el catálogo...';

  // Botones y acciones
  static String archiveButtonText(String groupName) =>
      'El Gran Archivo de $groupName';
  static const String archiveButtonTextShort = 'El Gran Archivo';

  // Confirmaciones
  static const String loanConfirmed = 'El libro ha iniciado su viaje';
  static const String loanReturned = 'El libro ha regresado a casa';
  static const String bookAdded = 'Un nuevo volumen se une a tu colección';
  static const String bookRemoved = 'El libro ha sido retirado del catálogo';

  // Errores (evocadores pero claros)
  static const String bookNotFound = 'Este volumen parece haberse extraviado';
  static const String connectionError =
      'No se puede alcanzar el archivo remoto en este momento';
  static const String syncError = 'Hubo un problema al sincronizar el catálogo';

  // Estados de lectura
  static const String readStatus = 'Leído';
  static const String unreadStatus = 'Por leer';
  static const String readingStatus = 'Leyendo';

  // Notificaciones
  static String loanRequestNotification(String bookTitle, String requester) =>
      '$requester solicita "$bookTitle" de tu biblioteca';
  static String loanAcceptedNotification(String bookTitle) =>
      'Tu solicitud de "$bookTitle" ha sido aceptada';
  static String loanReturnReminderNotification(
          String bookTitle, int daysLeft) =>
      '"$bookTitle" debe regresar en $daysLeft ${daysLeft == 1 ? 'día' : 'días'}';
  static String loanOverdueNotification(String bookTitle) =>
      '"$bookTitle" ha excedido su tiempo de préstamo';
}
