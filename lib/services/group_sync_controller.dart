import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/repositories/supabase_group_repository.dart';
import '../data/repositories/user_repository.dart';
import 'supabase_config_service.dart';
import 'sync_service.dart';

class GroupSyncController extends StateNotifier<SyncState> {
  GroupSyncController({
    required SupabaseGroupSyncRepository groupRepository,
    required UserRepository userRepository,
    required SupabaseConfigService configService,
  })  : _groupRepository = groupRepository,
        _userRepository = userRepository,
        _configService = configService,
        super(const SyncState());

  final SupabaseGroupSyncRepository _groupRepository;
  final UserRepository _userRepository;
  final SupabaseConfigService _configService;

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

  Future<void> syncGroups({String? accessToken}) async {
    if (state.isSyncing) {
      if (kDebugMode) {
        debugPrint('[GroupSync] Sync already in progress, skipping');
      }
      return;
    }

    if (kDebugMode) {
      debugPrint('[GroupSync] Starting sync...');
    }

    state = state.copyWith(isSyncing: true, lastError: () => null);

    try {
      final user = await _userRepository.getActiveUser();
      if (user == null || user.isDeleted) {
        throw const SyncException(
            'Crea o selecciona un usuario antes de sincronizar.');
      }

      final config = await _configService.loadConfig();
      if (config.url.isEmpty || config.anonKey.isEmpty) {
        throw const SyncException('Configura Supabase antes de sincronizar.');
      }

      // Always push local changes - the method internally checks for dirty records
      if (kDebugMode) {
        debugPrint('[GroupSync] Pushing local changes to Supabase...');
      }
      await _groupRepository.pushLocalChanges(accessToken: accessToken);

      if (kDebugMode) {
        debugPrint('[GroupSync] Pulling remote changes from Supabase...');
      }
      await _groupRepository.syncFromRemote(accessToken: accessToken);

      state = state.copyWith(
        isSyncing: false,
        hasPendingChanges: false,
        lastSyncedAt: DateTime.now(),
      );

      if (kDebugMode) {
        debugPrint('[GroupSync] ✓ Sync completed successfully');
      }
    } catch (error) {
      final message = error is SyncException ? error.message : error.toString();
      state = state.copyWith(
        isSyncing: false,
        lastError: () => message,
      );

      if (kDebugMode) {
        debugPrint('[GroupSync] ✗ Sync failed: $message');
      }

      rethrow; // Re-throw para que el coordinador maneje los reintentos
    }
  }
}
