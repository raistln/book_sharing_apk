import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/global_sync_state.dart';
import '../services/unified_sync_coordinator.dart';
import 'auth_providers.dart';
import 'book_providers.dart';

/// Provider del coordinador unificado de sincronización.
final unifiedSyncCoordinatorProvider = Provider<UnifiedSyncCoordinator>((ref) {
  final userSync = ref.watch(userSyncControllerProvider.notifier);
  final bookSync = ref.watch(bookSyncControllerProvider.notifier);
  final groupSync = ref.watch(groupSyncControllerProvider.notifier);
  final notificationSync = ref.watch(notificationSyncControllerProvider.notifier);

  // Callback para notificar actividad de usuario
  final inactivityManager = ref.watch(inactivityManagerProvider);

  final coordinator = UnifiedSyncCoordinator(
    userSyncController: userSync,
    bookSyncController: bookSync,
    groupSyncController: groupSync,
    notificationSyncController: notificationSync,
    onUserActivity: () {
      // Registrar actividad en el InactivityManager
      inactivityManager.registerActivity();
    },
  );

  ref.onDispose(() {
    coordinator.dispose();
  });

  return coordinator;
});

/// Provider del estado global de sincronización.
final globalSyncStateProvider = StreamProvider<GlobalSyncState>((ref) {
  final coordinator = ref.watch(unifiedSyncCoordinatorProvider);
  return coordinator.syncStateStream;
});

/// Provider para verificar si la app está completamente sincronizada.
final isFullySyncedProvider = Provider<bool>((ref) {
  final asyncState = ref.watch(globalSyncStateProvider);
  return asyncState.maybeWhen(
    data: (state) => state.isFullySynced,
    orElse: () => false,
  );
});

/// Provider para verificar si hay errores de sincronización.
final hasSyncErrorsProvider = Provider<bool>((ref) {
  final asyncState = ref.watch(globalSyncStateProvider);
  return asyncState.maybeWhen(
    data: (state) => state.hasErrors,
    orElse: () => false,
  );
});

/// Provider para contar cambios pendientes.
final pendingChangesCountProvider = Provider<int>((ref) {
  final asyncState = ref.watch(globalSyncStateProvider);
  return asyncState.maybeWhen(
    data: (state) => state.pendingChangesCount,
    orElse: () => 0,
  );
});
