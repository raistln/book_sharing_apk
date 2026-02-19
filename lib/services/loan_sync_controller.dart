import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/book_providers.dart'; // activeUserProvider is here
import '../../providers/sync_providers.dart';
import '../../services/sync_service.dart';
import 'supabase_config_service.dart';
// import '../../providers/app_providers.dart';

class LoanSyncController extends SyncController {
  final Ref _ref;

  LoanSyncController(this._ref)
      : super(
          getActiveUser: () async => _ref.read(activeUserProvider).value,
          loadConfig: () => const SupabaseConfigService().loadConfig(),
          // We combine push and pull into the sync operations delegated below
          // or we can map them specifically if SyncController calls them individually.
          // Since SyncController calls pushLocalChanges and fetchRemoteChanges separately:
          pushLocalChanges: () async {
            final user = _ref.read(activeUserProvider).value;
            final repository = _ref.read(supabaseLoanSyncRepositoryProvider);
            if (user != null) {
              await repository.syncLoans(user.id
                  .toString()); // This actually does both in current repo implementation, but that's fine.
            }
          },
          fetchRemoteChanges: () async {
            // Handled by syncLoans above, but provided to satisfy interface if needed
            // or we're overriding sync() anyway so these might be unused if we override.
            // BUT, if we override sync(), we don't need to pass meaningful callbacks if we don't call super.sync()
            // However, SyncController constructor REQUIRES them.
          },
        );

  @override
  Future<void> sync() async {
    final user = _ref.read(activeUserProvider).value;
    if (user == null) {
      return;
    }

    // Reuse base class state management by calling super methods if possible,
    // OR just use our repository directly while updating state.
    // The base SyncController.sync() does a lot of good state management (isSyncing, error handling).
    // Let's try to use it.

    // We can just call super.sync() and let it call our callbacks.
    // BUT our repository.syncLoans() does BOTH push and pull.
    // So let's override sync to call repository directly but use super's state logic if we can access it,
    // OR just duplicate the state logic (safest given the single-method repo).
    // The base class methods _updateStateSafely are private.
    // Actually, looking at the code, we can just pass the same repo method to pushLocalChanges
    // and empty to fetchRemoteChanges (or vice versa) since syncLoans does both.

    await super.sync();
  }
}
