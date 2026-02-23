import 'dart:async';
import 'dart:developer' as developer;

import 'package:battery_plus/battery_plus.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

import '../models/global_sync_state.dart';
import '../models/sync_config.dart';
import 'group_sync_controller.dart';
import 'sync_service.dart';

/// Coordinador unificado que gestiona todas las sincronizaciones de manera inteligente.
class UnifiedSyncCoordinator {
  UnifiedSyncCoordinator({
    required SyncController userSyncController,
    required SyncController bookSyncController,
    required GroupSyncController groupSyncController,
    required SyncController notificationSyncController,
    required SyncController loanSyncController,
    required SyncController clubSyncController,
    VoidCallback? onUserActivity,
    bool enableConnectivityMonitoring = true,
    bool enableBatteryMonitoring = true,
  })  : _userSyncController = userSyncController,
        _bookSyncController = bookSyncController,
        _groupSyncController = groupSyncController,
        _notificationSyncController = notificationSyncController,
        _loanSyncController = loanSyncController,
        _clubSyncController = clubSyncController,
        _onUserActivity = onUserActivity,
        _enableConnectivityMonitoring = enableConnectivityMonitoring,
        _enableBatteryMonitoring = enableBatteryMonitoring {
    _initialize();
  }

  final SyncController _userSyncController;
  final SyncController _bookSyncController;
  final GroupSyncController _groupSyncController;
  final SyncController _notificationSyncController;
  final SyncController _loanSyncController;
  final SyncController _clubSyncController;
  final VoidCallback? _onUserActivity;
  final bool _enableConnectivityMonitoring;
  final bool _enableBatteryMonitoring;

  final _stateController = StreamController<GlobalSyncState>.broadcast();
  GlobalSyncState _state = const GlobalSyncState();

  // Timers
  Timer? _periodicSyncTimer;
  final Map<SyncEntity, Timer?> _debounceTimers = {};

  // Conectividad y batería
  Connectivity? _connectivity;
  Battery? _battery;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  StreamSubscription<BatteryState>? _batterySubscription;

  // Control de actividad
  DateTime _lastActivityTime = DateTime.now();

  // Retry tracking
  final Map<SyncEntity, int> _retryCount = {};
  final Map<SyncEntity, Timer?> _retryTimers = {};

  Stream<GlobalSyncState> get syncStateStream => _stateController.stream;
  GlobalSyncState get currentState => _state;
  bool get isTimerSuspended => _state.isTimerSuspended;

  void _initialize() {
    _log('Inicializando UnifiedSyncCoordinator...');

    if (_enableConnectivityMonitoring) {
      _connectivity = Connectivity();
      _setupConnectivityListener();
      _checkInitialConnectivity();
    }

    if (_enableBatteryMonitoring) {
      _battery = Battery();
      _setupBatteryListener();
    }
  }

  void _setupConnectivityListener() {
    if (_connectivity == null) return;

    _connectivitySubscription = _connectivity!.onConnectivityChanged.listen(
      (List<ConnectivityResult> results) {
        final isConnected = results.isNotEmpty &&
            results.any((result) => result != ConnectivityResult.none);

        _log('Conectividad cambió: $results (conectado: $isConnected)');

        if (isConnected != _state.isConnected) {
          _updateState(_state.copyWith(isConnected: isConnected));

          if (isConnected) {
            _log('Conexión restaurada, sincronizando inmediatamente...');
            syncNow();
          } else if (SyncConfig.pauseOnNoConnection) {
            _log('Sin conexión, pausando sincronización automática.');
            _suspendPeriodicSync();
          }
        }
      },
      onError: (error) {
        _log('Error en listener de conectividad: $error', error: error);
      },
    );
  }

  void _setupBatteryListener() {
    if (_battery == null) return;

    _batterySubscription = _battery!.onBatteryStateChanged.listen(
      (BatteryState state) {
        final isBatterySaver = state == BatteryState.charging ? false : true;
        // Nota: battery_plus no proporciona directamente el modo de ahorro de batería
        // Aquí asumimos que si está descargando, podríamos estar en modo ahorro
        // En producción, podrías usar platform channels para detectar esto mejor

        if (isBatterySaver != _state.isBatterySaverMode) {
          _log('Modo batería cambió: $state (ahorro: $isBatterySaver)');
          _updateState(_state.copyWith(isBatterySaverMode: isBatterySaver));
          _adjustPeriodicSyncInterval();
        }
      },
      onError: (error) {
        _log('Error en listener de batería: $error', error: error);
      },
    );
  }

  Future<void> _checkInitialConnectivity() async {
    if (_connectivity == null) return;

    try {
      final results = await _connectivity!.checkConnectivity();
      final isConnected = results.isNotEmpty &&
          results.any((result) => result != ConnectivityResult.none);
      _updateState(_state.copyWith(isConnected: isConnected));
      _log('Conectividad inicial: $results (conectado: $isConnected)');
    } catch (error) {
      _log('Error verificando conectividad inicial: $error', error: error);
    }
  }

  /// Marca cambios pendientes para una entidad con prioridad específica.
  void markPendingChanges(
    SyncEntity entity, {
    SyncPriority priority = SyncPriority.medium,
  }) {
    _log('Cambios pendientes marcados: $entity (prioridad: $priority)');

    // 1. Marcar estado interno del coordinador
    final entityState = _getEntityState(entity);
    _updateEntityState(
      entity,
      entityState.copyWith(hasPendingChanges: true),
    );

    // 2. Propagar estado al controlador respectivo
    _markControllerAsDirty(entity);

    _registerActivity();
    _scheduleDebouncedSync(entity, priority);
  }

  void _markControllerAsDirty(SyncEntity entity) {
    switch (entity) {
      case SyncEntity.users:
        _userSyncController.markPendingChanges();
        break;
      case SyncEntity.books:
        _bookSyncController.markPendingChanges();
        break;
      case SyncEntity.groups:
        _groupSyncController.markPendingChanges();
        break;
      case SyncEntity.loans:
        _loanSyncController.markPendingChanges();
        break;
      case SyncEntity.notifications:
        _notificationSyncController.markPendingChanges();
        break;
      case SyncEntity.clubs:
        _clubSyncController.markPendingChanges();
        break;
    }
  }

  /// Sincronización manual forzada de entidades específicas o todas.
  Future<void> syncNow({List<SyncEntity>? entities}) async {
    if (!_state.isConnected && SyncConfig.pauseOnNoConnection) {
      _log('Sincronización omitida: sin conexión.');
      return;
    }

    final entitiesToSync = entities ?? SyncEntity.values;
    _log('Sincronización manual iniciada para: $entitiesToSync');

    _updateState(_state.copyWith(isSyncing: true));

    try {
      // Sincronizar en orden de prioridad estricto para manejar dependencias
      // 1. Usuarios (Base para todo)
      await _syncEntity(SyncEntity.users);

      // 2. Grupos (Aporta libros compartidos que la línea de tiempo/sesiones pueden necesitar)
      if (entitiesToSync.contains(SyncEntity.groups)) {
        await _syncEntity(SyncEntity.groups);
      }

      // 3. Libros (Incluye línea de tiempo, sesiones, reseñas y wishlist de libros personales y de grupo)
      // SYNC BOOKS BEFORE LOANS so loans can find local book IDs
      if (entitiesToSync.contains(SyncEntity.books)) {
        await _syncEntity(SyncEntity.books);
      }

      // 4. Préstamos (Relaciona libros y usuarios)
      if (entitiesToSync.contains(SyncEntity.loans)) {
        await _syncEntity(SyncEntity.loans);
      }

      // 5. Notificaciones y Clubes (Opcionales/Independientes)
      if (entitiesToSync.contains(SyncEntity.notifications)) {
        await _syncEntity(SyncEntity.notifications);
      }

      if (entitiesToSync.contains(SyncEntity.clubs)) {
        await _syncEntity(SyncEntity.clubs);
      }

      _updateState(_state.copyWith(
        isSyncing: false,
        lastFullSync: DateTime.now(),
        lastError: () => null,
      ));

      _log('🏁 FULL SYNC COMPLETED SUCCESSFULLY');
    } catch (e, st) {
      _log('❌ Error during sync', error: e, stackTrace: st);
      _updateState(_state.copyWith(isSyncing: false));
      rethrow;
    } finally {
      _updateState(_state.copyWith(isSyncing: false));
    }
  }

  /// Sincronización por evento crítico (bypass debounce).
  Future<void> syncOnCriticalEvent(SyncEvent event) async {
    _log('Evento crítico recibido: $event, sincronizando inmediatamente...');

    // Mapear evento a entidades relevantes
    final entities = _getEntitiesForEvent(event);

    // 1. Marcar todas las entidades como pendientes Y dirty en sus controladores
    // Lo hacemos manualmente para no disparar el debounce timer antes de syncNow
    for (final entity in entities) {
      final entityState = _getEntityState(entity);
      _updateEntityState(
        entity,
        entityState.copyWith(hasPendingChanges: true),
      );
      _markControllerAsDirty(entity);

      // Cancelar cualquier debounce timer pendiente
      _debounceTimers[entity]?.cancel();
      _debounceTimers[entity] = null;
    }

    _registerActivity();

    // 2. Sincronizar inmediatamente y AWAIT para asegurar que la operación remota termine
    await syncNow(entities: entities);
  }

  List<SyncEntity> _getEntitiesForEvent(SyncEvent event) {
    switch (event) {
      case SyncEvent.groupInvitationAccepted:
      case SyncEvent.groupInvitationRejected:
      case SyncEvent.userJoinedGroup:
      case SyncEvent.userLeftGroup:
        return [SyncEntity.groups, SyncEntity.users];
      case SyncEvent.loanCreated:
      case SyncEvent.loanReturned:
      case SyncEvent.loanCancelled:
        return [SyncEntity.loans, SyncEntity.groups, SyncEntity.books];
      case SyncEvent.criticalNotification:
        return [SyncEntity.notifications];
    }
  }

  Future<void> _syncEntity(SyncEntity entity) async {
    final entityState = _getEntityState(entity);

    if (!entityState.hasPendingChanges && entityState.lastSyncedAt != null) {
      final timeSinceLastSync =
          DateTime.now().difference(entityState.lastSyncedAt!);
      if (timeSinceLastSync < SyncConfig.minInterval) {
        _log('Omitiendo $entity: sincronizado recientemente.');
        return;
      }
    }

    _updateEntityState(entity, entityState.copyWith(isSyncing: true));

    try {
      switch (entity) {
        case SyncEntity.users:
          await _userSyncController.sync();
          break;
        case SyncEntity.books:
          await _bookSyncController.sync();
          break;
        case SyncEntity.groups:
          await _groupSyncController.syncGroups();
          break;
        case SyncEntity.loans:
          await _loanSyncController.sync(); // Now uses dedicated controller
          break;
        case SyncEntity.notifications:
          await _notificationSyncController.sync();
          break;
        case SyncEntity.clubs:
          await _clubSyncController.sync();
          break;
      }

      _updateEntityState(
        entity,
        entityState.copyWith(
          isSyncing: false,
          hasPendingChanges: false,
          lastSyncedAt: DateTime.now(),
          error: () => null,
        ),
      );

      _retryCount[entity] = 0;
      _retryTimers[entity]?.cancel();
      _retryTimers[entity] = null;

      _log('Sincronización de $entity completada.');
    } catch (error, stackTrace) {
      _log('Error sincronizando $entity: $error',
          error: error, stackTrace: stackTrace);

      _updateEntityState(
        entity,
        entityState.copyWith(
          isSyncing: false,
          error: () => error.toString(),
        ),
      );

      _scheduleRetry(entity);
    }
  }

  void _scheduleRetry(SyncEntity entity) {
    final retries = _retryCount[entity] ?? 0;

    _retryCount[entity] = retries + 1;

    final delay = _calculateRetryDelay(retries);
    _log(
        'Programando reintento ${retries + 1}/${SyncConfig.maxRetries} para $entity en ${delay.inSeconds}s');

    _retryTimers[entity]?.cancel();
    _retryTimers[entity] = Timer(delay, () {
      _log('Ejecutando reintento ${retries + 1} para $entity');
      _syncEntity(entity);
    });
  }

  Duration _calculateRetryDelay(int retryCount) {
    // Exponencial: 1s, 2s, 4s, 8s, 16s, max 30s
    final delay = SyncConfig.initialRetryDelay * (1 << retryCount);
    return delay > SyncConfig.maxRetryDelay ? SyncConfig.maxRetryDelay : delay;
  }

  void _scheduleDebouncedSync(SyncEntity entity, SyncPriority priority) {
    _debounceTimers[entity]?.cancel();

    final delay = _getDebounceDelay(priority);

    if (delay == Duration.zero) {
      // Alta prioridad: sincronizar inmediatamente
      _syncEntity(entity);
      return;
    }

    _debounceTimers[entity] = Timer(delay, () {
      _syncEntity(entity);
    });
  }

  Duration _getDebounceDelay(SyncPriority priority) {
    switch (priority) {
      case SyncPriority.high:
        return SyncConfig.highPriorityDebounce;
      case SyncPriority.medium:
        return SyncConfig.mediumPriorityDebounce;
      case SyncPriority.low:
        return SyncConfig.lowPriorityDebounce;
    }
  }

  /// Inicia la sincronización periódica automática.
  void startAutoSync() {
    if (_periodicSyncTimer != null) {
      _log('Auto-sync ya está activo.');
      return;
    }

    _log('Iniciando auto-sync periódico...');
    _scheduleNextPeriodicSync();
  }

  /// Detiene la sincronización periódica automática.
  void stopAutoSync() {
    _log('Deteniendo auto-sync periódico...');
    _periodicSyncTimer?.cancel();
    _periodicSyncTimer = null;
    _updateState(_state.copyWith(isTimerSuspended: false));
  }

  /// Suspende temporalmente la sincronización automática.
  void suspendAutoSync() {
    if (_state.isTimerSuspended) return;

    _log('Suspendiendo auto-sync temporalmente...');
    _periodicSyncTimer?.cancel();
    _periodicSyncTimer = null;
    _updateState(_state.copyWith(isTimerSuspended: true));
  }

  /// Reanuda la sincronización automática desde suspensión.
  void resumeAutoSync() {
    if (!_state.isTimerSuspended) return;

    _log('Reanudando auto-sync...');
    _updateState(_state.copyWith(isTimerSuspended: false));
    _scheduleNextPeriodicSync();
  }

  void _scheduleNextPeriodicSync() {
    _periodicSyncTimer?.cancel();

    final interval = _calculateNextSyncInterval();
    _log('Próxima sincronización periódica en ${interval.inSeconds}s');

    _periodicSyncTimer = Timer(interval, () {
      _onPeriodicSyncTrigger();
    });
  }

  Future<void> _onPeriodicSyncTrigger() async {
    _log('Timer periódico disparado.');

    // Verificar si debemos suspender
    if (_shouldSuspendSync()) {
      _log('Suspendiendo sync: sin cambios pendientes ni actividad reciente.');
      suspendAutoSync();
      return;
    }

    // Verificar conectividad
    if (!_state.isConnected && SyncConfig.pauseOnNoConnection) {
      _log('Omitiendo sync periódico: sin conexión.');
      _scheduleNextPeriodicSync();
      return;
    }

    // Ejecutar sincronización
    await syncNow();

    // Programar siguiente
    if (!_state.isTimerSuspended) {
      _scheduleNextPeriodicSync();
    }
  }

  bool _shouldSuspendSync() {
    if (!SyncConfig.autoSuspendOnInactivity) return false;

    // No suspender si hay cambios pendientes
    if (_state.pendingChangesCount > 0) return false;

    // Suspender si no hay actividad reciente
    final timeSinceActivity = DateTime.now().difference(_lastActivityTime);
    return timeSinceActivity > SyncConfig.inactivityThreshold;
  }

  Duration _calculateNextSyncInterval() {
    final baseInterval = _state.isBatterySaverMode
        ? SyncConfig.batterySaverBaseInterval
        : SyncConfig.baseInterval;

    final maxInterval = _state.isBatterySaverMode
        ? SyncConfig.batterySaverMaxInterval
        : SyncConfig.maxInterval;

    // Adaptativo basado en actividad
    final timeSinceActivity = DateTime.now().difference(_lastActivityTime);

    if (timeSinceActivity < const Duration(minutes: 2)) {
      return baseInterval;
    } else if (timeSinceActivity < const Duration(minutes: 5)) {
      return baseInterval + (maxInterval - baseInterval) ~/ 2;
    } else {
      return maxInterval;
    }
  }

  void _adjustPeriodicSyncInterval() {
    if (_periodicSyncTimer != null && !_state.isTimerSuspended) {
      _log('Ajustando intervalo de sincronización periódica...');
      _scheduleNextPeriodicSync();
    }
  }

  void _suspendPeriodicSync() {
    if (_periodicSyncTimer != null) {
      suspendAutoSync();
    }
  }

  void _registerActivity() {
    final wasInactive = DateTime.now().difference(_lastActivityTime) >
        const Duration(minutes: 1);

    _lastActivityTime = DateTime.now();

    if (wasInactive && _state.isTimerSuspended) {
      _log('Actividad detectada, reanudando auto-sync.');
      resumeAutoSync();
    }

    _onUserActivity?.call();
  }

  EntitySyncState _getEntityState(SyncEntity entity) {
    return _state.entityStates[entity] ?? const EntitySyncState();
  }

  void _updateEntityState(SyncEntity entity, EntitySyncState newState) {
    final updatedStates =
        Map<SyncEntity, EntitySyncState>.from(_state.entityStates);
    updatedStates[entity] = newState;
    _updateState(_state.copyWith(entityStates: updatedStates));
  }

  void _updateState(GlobalSyncState newState) {
    _state = newState;
    _stateController.add(_state);
  }

  void _log(
    String message, {
    Object? error,
    StackTrace? stackTrace,
  }) {
    developer.log(
      message,
      name: 'UnifiedSyncCoordinator',
      error: error,
      stackTrace: stackTrace,
    );

    if (kDebugMode) {
      debugPrint('[UnifiedSyncCoordinator] $message');
      if (error != null) {
        debugPrint('[UnifiedSyncCoordinator] Error: $error');
      }
    }
  }

  /// Registra actividad del usuario para reiniciar el temporizador de inactividad
  void recordUserActivity() {
    _onUserActivity?.call();
  }

  void dispose() {
    _log('Disposing UnifiedSyncCoordinator...');
    stopAutoSync();

    for (final timer in _debounceTimers.values) {
      timer?.cancel();
    }
    _debounceTimers.clear();

    for (final timer in _retryTimers.values) {
      timer?.cancel();
    }
    _retryTimers.clear();

    _connectivitySubscription?.cancel();
    _batterySubscription?.cancel();
    _stateController.close();
  }
}
