import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/book_providers.dart'; // activeUserProvider is here
import '../../providers/sync_providers.dart';
import '../../services/sync_service.dart';
import 'supabase_config_service.dart';
// import '../../providers/app_providers.dart';

class LoanSyncController extends SyncController {
  LoanSyncController(Ref ref)
      : super(
          getActiveUser: () async => ref.read(activeUserProvider).value,
          loadConfig: () => const SupabaseConfigService().loadConfig(),
          fetchRemoteChanges: () async {
            final user = ref.read(activeUserProvider).value;
            final repository = ref.read(supabaseLoanSyncRepositoryProvider);
            if (user != null) {
              await repository.syncLoans(user.remoteId ?? user.uuid);
            }
          },
          pushLocalChanges: () async {},
        );
}
