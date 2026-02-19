import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/global_sync_state.dart';
import '../services/loan_sync_controller.dart';
import '../services/supabase_loan_service.dart';
import '../data/repositories/supabase_loan_sync_repository.dart';
import '../services/unified_sync_coordinator.dart';
import 'auth_providers.dart';
import 'book_providers.dart';
import 'api_providers.dart';
// import 'app_providers.dart';

// --- New Loan Sync Providers ---

final supabaseLoanServiceProvider = Provider<SupabaseLoanService>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return SupabaseLoanService(client);
});

final supabaseLoanSyncRepositoryProvider =
    Provider<SupabaseLoanSyncRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  final api = ref.watch(supabaseLoanServiceProvider);
  return SupabaseLoanSyncRepository(db, api);
});

final loanSyncControllerProvider =
    StateNotifierProvider<LoanSyncController, void>((ref) {
  return LoanSyncController(ref);
});

/// Provider del coordinador unificado de sincronización.
final unifiedSyncCoordinatorProvider = Provider<UnifiedSyncCoordinator>((ref) {
  final userSync = ref.watch(userSyncControllerProvider.notifier);
  final bookSync = ref.watch(bookSyncControllerProvider.notifier);
  final groupSync = ref.watch(groupSyncControllerProvider.notifier);
  final notificationSync =
      ref.watch(notificationSyncControllerProvider.notifier);
  final loanSync = ref.watch(loanSyncControllerProvider.notifier); // NEW

  // Callback para notificar actividad de usuario
  final inactivityManager = ref.watch(inactivityManagerProvider);

  final coordinator = UnifiedSyncCoordinator(
    userSyncController: userSync,
    bookSyncController: bookSync,
    groupSyncController: groupSync,
    notificationSyncController: notificationSync,
    loanSyncController: loanSync, // NEW
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
