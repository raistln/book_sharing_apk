import 'package:book_sharing_app/data/local/database.dart';
import 'package:book_sharing_app/services/supabase_config_service.dart';
import 'package:book_sharing_app/services/sync_service.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeUser extends LocalUser {
  _FakeUser({required super.id, required super.uuid, required super.username})
      : super(
          remoteId: null,
          isDirty: false,
          isDeleted: false,
          syncedAt: null,
          createdAt: DateTime(2023, 1, 1),
          updatedAt: DateTime(2023, 1, 1),
        );
}

void main() {
  const config = SupabaseConfig(url: 'https://example.supabase.co', anonKey: 'key');

  group('SyncController', () {
    test('marks pending changes', () {
      final controller = SyncController(
        getActiveUser: () async => null,
        pushLocalChanges: () async {},
        loadConfig: () async => config,
      );

      expect(controller.state.hasPendingChanges, isFalse);
      controller.markPendingChanges();
      expect(controller.state.hasPendingChanges, isTrue);
    });

    test('clears error', () {
      final controller = SyncController(
        getActiveUser: () async => null,
        pushLocalChanges: () async {},
        loadConfig: () async => config,
      );

      controller.state = controller.state.copyWith(lastError: () => 'error');
      controller.clearError();
      expect(controller.state.lastError, isNull);
    });

    test('throws when user is missing', () async {
      var pushCalled = false;
      final controller = SyncController(
        getActiveUser: () async => null,
        pushLocalChanges: () async {
          pushCalled = true;
        },
        loadConfig: () async => config,
      );

      await controller.sync();

      expect(controller.state.isSyncing, isFalse);
      expect(controller.state.lastError, isNotNull);
      expect(pushCalled, isFalse);
    });

    test('throws when config is missing', () async {
      final controller = SyncController(
        getActiveUser: () async => _FakeUser(
          id: 1,
          uuid: 'uuid',
          username: 'user',
        ),
        pushLocalChanges: () async {},
        loadConfig: () async => const SupabaseConfig(url: '', anonKey: ''),
      );

      await controller.sync();

      expect(controller.state.isSyncing, isFalse);
      expect(controller.state.lastError, isNotNull);
    });

    test('pushes changes when pending', () async {
      var pushCount = 0;
      final controller = SyncController(
        getActiveUser: () async => _FakeUser(
          id: 1,
          uuid: 'uuid',
          username: 'user',
        ),
        pushLocalChanges: () async {
          pushCount++;
        },
        loadConfig: () async => config,
      );

      controller.markPendingChanges();
      await controller.sync();

      expect(pushCount, 1);
      expect(controller.state.hasPendingChanges, isFalse);
      expect(controller.state.lastError, isNull);
      expect(controller.state.lastSyncedAt, isNotNull);
    });

    test('does not push when already syncing', () async {
      var pushCount = 0;
      final controller = SyncController(
        getActiveUser: () async => _FakeUser(
          id: 1,
          uuid: 'uuid',
          username: 'user',
        ),
        pushLocalChanges: () async {
          pushCount++;
        },
        loadConfig: () async => config,
      );

      controller.state = controller.state.copyWith(isSyncing: true);
      await controller.sync();

      expect(pushCount, 0);
    });
  });
}
