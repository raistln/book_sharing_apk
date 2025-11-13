import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/local/database.dart';
import 'supabase_config_service.dart';

class SyncState {
  const SyncState({
    this.isSyncing = false,
    this.hasPendingChanges = false,
    this.lastSyncedAt,
    this.lastError,
  });

  final bool isSyncing;
  final bool hasPendingChanges;
  final DateTime? lastSyncedAt;
  final String? lastError;

  SyncState copyWith({
    bool? isSyncing,
    bool? hasPendingChanges,
    DateTime? lastSyncedAt,
    ValueGetter<String?>? lastError,
  }) {
    return SyncState(
      isSyncing: isSyncing ?? this.isSyncing,
      hasPendingChanges: hasPendingChanges ?? this.hasPendingChanges,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      lastError: lastError != null ? lastError() : this.lastError,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SyncState &&
        other.isSyncing == isSyncing &&
        other.hasPendingChanges == hasPendingChanges &&
        other.lastError == lastError &&
        other.lastSyncedAt == lastSyncedAt;
  }

  @override
  int get hashCode => Object.hash(isSyncing, hasPendingChanges, lastSyncedAt, lastError);
}

class SyncException implements Exception {
  const SyncException(this.message);

  final String message;

  @override
  String toString() => 'SyncException: $message';
}

typedef GetActiveUser = Future<LocalUser?> Function();
typedef FetchRemoteChanges = Future<void> Function();
typedef PushLocalChanges = Future<void> Function();
typedef LoadConfig = Future<SupabaseConfig> Function();

class SyncController extends StateNotifier<SyncState> {
  SyncController({
    required GetActiveUser getActiveUser,
    required PushLocalChanges pushLocalChanges,
    required LoadConfig loadConfig,
    FetchRemoteChanges? fetchRemoteChanges,
  })  : _getActiveUser = getActiveUser,
        _pushLocalChanges = pushLocalChanges,
        _loadConfig = loadConfig,
        _fetchRemoteChanges = fetchRemoteChanges,
        super(const SyncState());

  final GetActiveUser _getActiveUser;
  final PushLocalChanges _pushLocalChanges;
  final LoadConfig _loadConfig;
  final FetchRemoteChanges? _fetchRemoteChanges;

  void markPendingChanges() {
    if (!state.hasPendingChanges) {
      state = state.copyWith(hasPendingChanges: true);
    }
  }

  void clearError() {
    if (state.lastError != null) {
      state = state.copyWith(lastError: () => null);
    }
  }

  Future<void> sync() async {
    if (state.isSyncing) {
      return;
    }

    state = state.copyWith(isSyncing: true, lastError: () => null);

    try {
      final user = await _getActiveUser();
      if (user == null || user.isDeleted) {
        throw const SyncException('No hay usuario local configurado.');
      }

      final config = await _loadConfig();
      if (config.url.isEmpty || config.anonKey.isEmpty) {
        throw const SyncException('Configura Supabase antes de sincronizar.');
      }

      if (_fetchRemoteChanges != null) {
        await _fetchRemoteChanges();
      }

      if (state.hasPendingChanges) {
        await _pushLocalChanges();
      }

      state = state.copyWith(
        isSyncing: false,
        hasPendingChanges: false,
        lastSyncedAt: DateTime.now(),
      );
    } catch (error) {
      final message = error is SyncException ? error.message : error.toString();
      state = state.copyWith(
        isSyncing: false,
        lastError: () => message,
      );
    }
  }
}
