/// Configuración centralizada de parámetros de sincronización.
class SyncConfig {
  const SyncConfig._();

  // Intervalos base
  static const Duration baseInterval = Duration(minutes: 2);
  static const Duration maxInterval = Duration(minutes: 5);
  static const Duration minInterval = Duration(seconds: 30);

  // Intervalos en modo ahorro de batería
  static const Duration batterySaverBaseInterval = Duration(minutes: 4);
  static const Duration batterySaverMaxInterval = Duration(minutes: 10);

  // Debounce por prioridad
  static const Duration highPriorityDebounce = Duration.zero; // Inmediato
  static const Duration mediumPriorityDebounce = Duration(seconds: 2);
  static const Duration lowPriorityDebounce = Duration(seconds: 5);

  // Reintentos
  static const int maxRetries = 5;
  static const Duration initialRetryDelay = Duration(seconds: 1);
  static const Duration maxRetryDelay = Duration(seconds: 30);

  // Suspensión automática
  static const Duration inactivityThreshold = Duration(minutes: 5);
  static const bool autoSuspendOnInactivity = true;

  // Conectividad
  static const bool syncOnlyOnWifi = false; // Configurable por usuario
  static const bool pauseOnNoConnection = true;
}
