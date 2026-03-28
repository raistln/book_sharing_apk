import 'package:book_sharing_app/models/global_sync_state.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SyncEntity', () {
    test('toString returns the name', () {
      expect(SyncEntity.users.toString(), 'users');
      expect(SyncEntity.books.toString(), 'books');
      expect(SyncEntity.groups.toString(), 'groups');
      expect(SyncEntity.loans.toString(), 'loans');
      expect(SyncEntity.notifications.toString(), 'notifications');
      expect(SyncEntity.clubs.toString(), 'clubs');
      expect(SyncEntity.sessions.toString(), 'sessions');
      expect(SyncEntity.timeline.toString(), 'timeline');
    });
  });

  group('SyncPriority', () {
    test('toString returns the name', () {
      expect(SyncPriority.high.toString(), 'high');
      expect(SyncPriority.medium.toString(), 'medium');
      expect(SyncPriority.low.toString(), 'low');
    });
  });

  group('SyncEvent', () {
    test('toString returns the name', () {
      expect(SyncEvent.groupInvitationAccepted.toString(), 'groupInvitationAccepted');
      expect(SyncEvent.groupInvitationRejected.toString(), 'groupInvitationRejected');
      expect(SyncEvent.loanCreated.toString(), 'loanCreated');
      expect(SyncEvent.loanReturned.toString(), 'loanReturned');
      expect(SyncEvent.loanCancelled.toString(), 'loanCancelled');
      expect(SyncEvent.userJoinedGroup.toString(), 'userJoinedGroup');
      expect(SyncEvent.userLeftGroup.toString(), 'userLeftGroup');
      expect(SyncEvent.criticalNotification.toString(), 'criticalNotification');
    });
  });

  group('EntitySyncState', () {
    test('constructor sets default values', () {
      const state = EntitySyncState();
      expect(state.isSyncing, false);
      expect(state.hasPendingChanges, false);
      expect(state.lastSyncedAt, null);
      expect(state.error, null);
    });

    test('constructor sets provided values', () {
      const state = EntitySyncState(
        isSyncing: true,
        hasPendingChanges: true,
        lastSyncedAt: null,
        error: 'error',
      );
      expect(state.isSyncing, true);
      expect(state.hasPendingChanges, true);
      expect(state.lastSyncedAt, null);
      expect(state.error, 'error');
    });
  });
}
