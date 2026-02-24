import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/global_sync_state.dart';
import '../services/loan_sync_controller.dart';
import '../services/supabase_loan_service.dart';
import '../data/repositories/supabase_loan_sync_repository.dart';
import '../data/local/club_dao.dart';
import '../data/repositories/supabase_club_book_sync_repository.dart';
import '../data/repositories/supabase_club_sync_repository.dart';
import '../services/sync_service.dart';
import '../services/supabase_config_service.dart';
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
  final syncCursorDao = ref.watch(syncCursorDaoProvider);
  return SupabaseLoanSyncRepository(db, api, syncCursorDao);
});

final loanSyncControllerProvider =
    StateNotifierProvider<LoanSyncController, void>((ref) {
  return LoanSyncController(ref);
});

final clubDaoForSyncProvider = Provider<ClubDao>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return ClubDao(db);
});

final supabaseClubSyncRepositoryProvider =
    Provider<SupabaseClubSyncRepository>((ref) {
  final clubDao = ref.watch(clubDaoForSyncProvider);
  final userDao = ref.watch(userDaoProvider);
  return SupabaseClubSyncRepository(
    clubDao: clubDao,
    userDao: userDao,
  );
});

final supabaseClubBookSyncRepositoryProvider =
    Provider<SupabaseClubBookSyncRepository>((ref) {
  final clubDao = ref.watch(clubDaoForSyncProvider);
  return SupabaseClubBookSyncRepository(
    clubDao: clubDao,
  );
});

final clubSyncControllerProvider =
    StateNotifierProvider<SyncController, SyncState>((ref) {
  final userRepository = ref.watch(userRepositoryProvider);
  final clubSyncRepository = ref.watch(supabaseClubSyncRepositoryProvider);
  final clubBookSyncRepository =
      ref.watch(supabaseClubBookSyncRepositoryProvider);

  return SyncController(
    getActiveUser: () async => userRepository.getActiveUser(),
    fetchRemoteChanges: () async {
      final user = await userRepository.getActiveUser();
      if (user == null) {
        throw const SyncException('No active user for club sync');
      }
      await clubSyncRepository.syncFromRemote();
    },
    pushLocalChanges: () async {
      final user = await userRepository.getActiveUser();
      if (user == null) {
        throw const SyncException('No active user for club sync');
      }
      await clubSyncRepository.pushLocalChanges();
      await clubBookSyncRepository.pushLocalChanges();
    },
    loadConfig: () async {
      return const SupabaseConfigService().loadConfig();
    },
  );
});

/// Provider del coordinador unificado de sincronización.
final unifiedSyncCoordinatorProvider = Provider<UnifiedSyncCoordinator>((ref) {
  final userSync = ref.watch(userSyncControllerProvider.notifier);
  final bookSync = ref.watch(bookSyncControllerProvider.notifier);
  final groupSync = ref.watch(groupSyncControllerProvider.notifier);
  final notificationSync =
      ref.watch(notificationSyncControllerProvider.notifier);
  final loanSync = ref.watch(loanSyncControllerProvider.notifier); // NEW
  final clubSync = ref.watch(clubSyncControllerProvider.notifier);

  // Callback para notificar actividad de usuario
  // final inactivityManager = ref.watch(inactivityManagerProvider); // Removed this line

  final coordinator = UnifiedSyncCoordinator(
    userSyncController: userSync,
    bookSyncController: bookSync,
    groupSyncController: groupSync,
    notificationSyncController: notificationSync,
    loanSyncController: loanSync, // NEW
    clubSyncController: clubSync,
    onUserActivity: () {
      // Registrar actividad en el InactivityManager
      // Usamos ref.read para evitar ciclos de dependencia en la inicialización
      ref.read(inactivityManagerProvider).registerActivity();
    },
  );

  coordinator.startAutoSync();

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

/// Provider para verificar si hay una sincronización en curso.
final isSyncingProvider = Provider<bool>((ref) {
  final asyncState = ref.watch(globalSyncStateProvider);
  return asyncState.maybeWhen(
    data: (state) => state.isSyncing,
    loading: () => true,
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
