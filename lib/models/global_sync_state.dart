/// Entidades que pueden ser sincronizadas.
enum SyncEntity {
  users,
  books,
  groups,
  loans,
  notifications,
  clubs;

  @override
  String toString() => name;
}

/// Prioridad de sincronización para una entidad.
enum SyncPriority {
  high, // Inmediato
  medium, // Debounced 2s
  low; // Debounced 5s

  @override
  String toString() => name;
}

/// Eventos críticos que disparan sincronización inmediata.
enum SyncEvent {
  groupInvitationAccepted,
  groupInvitationRejected,
  loanCreated,
  loanReturned,
  loanCancelled,
  userJoinedGroup,
  userLeftGroup,
  criticalNotification;

  @override
  String toString() => name;
}

/// Estado de sincronización de una entidad individual.
class EntitySyncState {
  const EntitySyncState({
    this.isSyncing = false,
    this.hasPendingChanges = false,
    this.lastSyncedAt,
    this.error,
  });

  final bool isSyncing;
  final bool hasPendingChanges;
  final DateTime? lastSyncedAt;
  final String? error;

  EntitySyncState copyWith({
    bool? isSyncing,
    bool? hasPendingChanges,
    DateTime? lastSyncedAt,
    String? Function()? error,
  }) {
    return EntitySyncState(
      isSyncing: isSyncing ?? this.isSyncing,
      hasPendingChanges: hasPendingChanges ?? this.hasPendingChanges,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      error: error != null ? error() : this.error,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is EntitySyncState &&
        other.isSyncing == isSyncing &&
        other.hasPendingChanges == hasPendingChanges &&
        other.lastSyncedAt == lastSyncedAt &&
        other.error == error;
  }

  @override
  int get hashCode => Object.hash(
        isSyncing,
        hasPendingChanges,
        lastSyncedAt,
        error,
      );
}

/// Estado global de sincronización de toda la aplicación.
class GlobalSyncState {
  const GlobalSyncState({
    this.isSyncing = false,
    this.entityStates = const {},
    this.lastFullSync,
    this.lastError,
    this.isTimerSuspended = false,
    this.isConnected = true,
    this.isBatterySaverMode = false,
  });

  final bool isSyncing;
  final Map<SyncEntity, EntitySyncState> entityStates;
  final DateTime? lastFullSync;
  final String? lastError;
  final bool isTimerSuspended;
  final bool isConnected;
  final bool isBatterySaverMode;

  /// Retorna true si todas las entidades están sincronizadas.
  bool get isFullySynced =>
      !isSyncing && pendingChangesCount == 0 && lastError == null;

  /// Retorna true si hay errores de sincronización.
  bool get hasErrors =>
      lastError != null || entityStates.values.any((e) => e.error != null);

  /// Cuenta total de cambios pendientes en todas las entidades.
  int get pendingChangesCount =>
      entityStates.values.where((e) => e.hasPendingChanges).length;

  GlobalSyncState copyWith({
    bool? isSyncing,
    Map<SyncEntity, EntitySyncState>? entityStates,
    DateTime? lastFullSync,
    String? Function()? lastError,
    bool? isTimerSuspended,
    bool? isConnected,
    bool? isBatterySaverMode,
  }) {
    return GlobalSyncState(
      isSyncing: isSyncing ?? this.isSyncing,
      entityStates: entityStates ?? this.entityStates,
      lastFullSync: lastFullSync ?? this.lastFullSync,
      lastError: lastError != null ? lastError() : this.lastError,
      isTimerSuspended: isTimerSuspended ?? this.isTimerSuspended,
      isConnected: isConnected ?? this.isConnected,
      isBatterySaverMode: isBatterySaverMode ?? this.isBatterySaverMode,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is GlobalSyncState &&
        other.isSyncing == isSyncing &&
        other.lastFullSync == lastFullSync &&
        other.lastError == lastError &&
        other.isTimerSuspended == isTimerSuspended &&
        other.isConnected == isConnected &&
        other.isBatterySaverMode == isBatterySaverMode;
  }

  @override
  int get hashCode => Object.hash(
        isSyncing,
        lastFullSync,
        lastError,
        isTimerSuspended,
        isConnected,
        isBatterySaverMode,
      );
}
