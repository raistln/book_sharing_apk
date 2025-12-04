import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/local/database.dart';
import '../data/local/group_dao.dart';
import '../data/repositories/book_repository.dart';
import '../data/repositories/group_push_repository.dart';
import '../models/global_sync_state.dart';
import 'group_sync_controller.dart';
import 'notification_service.dart';
import 'unified_sync_coordinator.dart';

class GroupActionState {
  const GroupActionState({
    this.isLoading = false,
    this.lastError,
    this.lastSuccess,
  });

  final bool isLoading;
  final String? lastError;
  final String? lastSuccess;

  GroupActionState copyWith({
    bool? isLoading,
    ValueGetter<String?>? lastError,
    ValueGetter<String?>? lastSuccess,
  }) {
    return GroupActionState(
      isLoading: isLoading ?? this.isLoading,
      lastError: lastError != null ? lastError() : this.lastError,
      lastSuccess: lastSuccess != null ? lastSuccess() : this.lastSuccess,
    );
  }
}

class GroupPushController extends StateNotifier<GroupActionState> {
  GroupPushController({
    required GroupPushRepository groupPushRepository,
    required GroupSyncController groupSyncController,
    required NotificationClient notificationClient,
    required BookRepository bookRepository,
    required GroupDao groupDao,
    required UnifiedSyncCoordinator syncCoordinator,
  })  : _groupPushRepository = groupPushRepository,
        _groupSyncController = groupSyncController,
        _notificationClient = notificationClient,
        _bookRepository = bookRepository,
        _groupDao = groupDao,
        _syncCoordinator = syncCoordinator,
        super(const GroupActionState());

  final GroupPushRepository _groupPushRepository;
  final GroupSyncController _groupSyncController;
  final NotificationClient _notificationClient;
  final BookRepository _bookRepository;
  final GroupDao _groupDao;
  final UnifiedSyncCoordinator _syncCoordinator;

  void dismissError() {
    state = state.copyWith(lastError: () => null);
  }

  void dismissSuccess() {
    state = state.copyWith(lastSuccess: () => null);
  }

  Future<Group> createGroup({
    required String name,
    String? description,
    required LocalUser owner,
    String? accessToken,
  }) async {
    state = state.copyWith(isLoading: true, lastError: () => null, lastSuccess: () => null);
    try {
      final group = await _groupPushRepository.createGroup(
        name: name,
        description: description,
        owner: owner,
        accessToken: accessToken,
      );
      
      // Automatically share existing books with the new group
      await _bookRepository.shareExistingBooksWithGroup(
        group: group,
        owner: owner,
      );

      // Trigger critical sync event for group creation
      await _syncCoordinator.syncOnCriticalEvent(SyncEvent.userJoinedGroup);
      
      state = state.copyWith(
        isLoading: false,
        lastSuccess: () => 'Grupo creado.',
      );
      return group;
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        lastError: () => error.toString(),
      );
      rethrow;
    }
  }

  Future<void> updateGroup({
    required Group group,
    required String name,
    String? description,
    String? accessToken,
  }) async {
    state = state.copyWith(isLoading: true, lastError: () => null, lastSuccess: () => null);
    try {
      await _groupPushRepository.updateGroup(
        group: group,
        name: name,
        description: description,
        accessToken: accessToken,
      );
      _groupSyncController.markPendingChanges();
      state = state.copyWith(
        isLoading: false,
        lastSuccess: () => 'Grupo actualizado.',
      );
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        lastError: () => error.toString(),
      );
      rethrow;
    }
  }

  Future<void> deleteGroup({
    required Group group,
    String? accessToken,
  }) async {
    state = state.copyWith(isLoading: true, lastError: () => null, lastSuccess: () => null);
    try {
      await _groupPushRepository.deleteGroup(
        group: group,
        accessToken: accessToken,
      );
      
      // Trigger critical sync event for group deletion
      await _syncCoordinator.syncOnCriticalEvent(SyncEvent.userLeftGroup);
      
      state = state.copyWith(
        isLoading: false,
        lastSuccess: () => 'Grupo eliminado.',
      );
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        lastError: () => error.toString(),
      );
      rethrow;
    }
  }

  Future<void> transferOwnership({
    required Group group,
    required LocalUser newOwner,
    String? accessToken,
  }) async {
    state = state.copyWith(isLoading: true, lastError: () => null, lastSuccess: () => null);
    try {
      await _groupPushRepository.transferOwnership(
        group: group,
        newOwner: newOwner,
        accessToken: accessToken,
      );
      _groupSyncController.markPendingChanges();
      state = state.copyWith(
        isLoading: false,
        lastSuccess: () => 'Propiedad transferida.',
      );
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        lastError: () => error.toString(),
      );
      rethrow;
    }
  }

  Future<GroupMember> addMember({
    required Group group,
    required LocalUser user,
    required String role,
    String? accessToken,
  }) async {
    state = state.copyWith(isLoading: true, lastError: () => null, lastSuccess: () => null);
    try {
      final member = await _groupPushRepository.addMember(
        group: group,
        user: user,
        role: role,
        accessToken: accessToken,
      );
      _groupSyncController.markPendingChanges();
      state = state.copyWith(
        isLoading: false,
        lastSuccess: () => 'Miembro añadido.',
      );
      return member;
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        lastError: () => error.toString(),
      );
      rethrow;
    }
  }

  Future<void> updateMemberRole({
    required GroupMember member,
    required String role,
    String? accessToken,
  }) async {
    state = state.copyWith(isLoading: true, lastError: () => null, lastSuccess: () => null);
    try {
      await _groupPushRepository.updateMemberRole(
        member: member,
        role: role,
        accessToken: accessToken,
      );
      _groupSyncController.markPendingChanges();
      state = state.copyWith(
        isLoading: false,
        lastSuccess: () => 'Rol actualizado.',
      );
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        lastError: () => error.toString(),
      );
      rethrow;
    }
  }

  Future<void> removeMember({
    required GroupMember member,
    String? accessToken,
  }) async {
    state = state.copyWith(isLoading: true, lastError: () => null, lastSuccess: () => null);
    try {
      await _groupPushRepository.removeMember(
        member: member,
        accessToken: accessToken,
      );
      // Evento crítico: usuario salió del grupo → sync inmediata
      await _syncCoordinator.syncOnCriticalEvent(SyncEvent.userLeftGroup);
      state = state.copyWith(
        isLoading: false,
        lastSuccess: () => 'Miembro eliminado.',
      );
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        lastError: () => error.toString(),
      );
      rethrow;
    }
  }

  Future<GroupInvitation> createInvitation({
    required Group group,
    required LocalUser inviter,
    String role = 'member',
    DateTime? expiresAt,
    String? accessToken,
  }) async {
    state = state.copyWith(isLoading: true, lastError: () => null, lastSuccess: () => null);
    try {
      final invitation = await _groupPushRepository.createInvitation(
        group: group,
        inviter: inviter,
        role: role,
        expiresAt: expiresAt,
        accessToken: accessToken,
      );
      
      // Trigger critical sync event for invitation creation
      await _syncCoordinator.syncOnCriticalEvent(SyncEvent.groupInvitationAccepted);
      
      state = state.copyWith(
        isLoading: false,
        lastSuccess: () => 'Invitación creada.',
      );
      
      // Removed self-notification - user will share via share button
      return invitation;
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        lastError: () => error.toString(),
      );
      rethrow;
    }
  }

  Future<void> cancelInvitation({
    required GroupInvitation invitation,
    String? accessToken,
  }) async {
    state = state.copyWith(isLoading: true, lastError: () => null, lastSuccess: () => null);
    try {
      await _groupPushRepository.cancelInvitation(
        invitation: invitation,
        accessToken: accessToken,
      );
      _groupSyncController.markPendingChanges();
      state = state.copyWith(
        isLoading: false,
        lastSuccess: () => 'Invitación cancelada.',
      );
      await _cancelGroupInvitationNotification(invitation);
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        lastError: () => error.toString(),
      );
      rethrow;
    }
  }

  Future<GroupInvitation> respondInvitation({
    required GroupInvitation invitation,
    required Group group,
    required LocalUser user,
    required String newStatus,
    String? accessToken,
  }) async {
    state = state.copyWith(isLoading: true, lastError: () => null, lastSuccess: () => null);
    try {
      final updated = await _groupPushRepository.respondInvitation(
        invitation: invitation,
        group: group,
        user: user,
        newStatus: newStatus,
        accessToken: accessToken,
      );
      
      // If invitation was accepted, share existing books with the group
      if (newStatus == 'accepted') {
        await _bookRepository.shareExistingBooksWithGroup(
          group: group,
          owner: user,
        );
        // Evento crítico: invitación aceptada → sync inmediata
        await _syncCoordinator.syncOnCriticalEvent(SyncEvent.groupInvitationAccepted);
      } else if (newStatus == 'rejected') {
        // Evento crítico: invitación rechazada → sync inmediata
        await _syncCoordinator.syncOnCriticalEvent(SyncEvent.groupInvitationRejected);
      } else {
        // Otros estados usan debouncing normal
        _syncCoordinator.markPendingChanges(SyncEntity.groups, priority: SyncPriority.medium);
      }
      
      state = state.copyWith(
        isLoading: false,
        lastSuccess: () =>
            newStatus == 'accepted' ? 'Invitación aceptada.' : 'Invitación actualizada.',
      );
      await _cancelGroupInvitationNotification(updated);
      return updated;
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        lastError: () => error.toString(),
      );
      rethrow;
    }
  }

  Future<GroupInvitation> acceptInvitationByCode({
    required String code,
    required LocalUser user,
    String? accessToken,
  }) async {
    state = state.copyWith(isLoading: true, lastError: () => null, lastSuccess: () => null);
    try {
      final invitation = await _groupPushRepository.acceptInvitationByCode(
        code: code,
        user: user,
        accessToken: accessToken,
      );
      
      // Share existing books with the newly joined group
      final group = await _groupDao.findGroupById(invitation.groupId);
      if (group != null) {
        await _bookRepository.shareExistingBooksWithGroup(
          group: group,
          owner: user,
        );
      }
      
      // Evento crítico: usuario se unió al grupo → sync inmediata
      await _syncCoordinator.syncOnCriticalEvent(SyncEvent.userJoinedGroup);
      
      state = state.copyWith(
        isLoading: false,
        lastSuccess: () => 'Te uniste al grupo.',
      );
      await _cancelGroupInvitationNotification(invitation);
      return invitation;
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        lastError: () => error.toString(),
      );
      rethrow;
    }
  }

  Future<void> _cancelGroupInvitationNotification(GroupInvitation invitation) async {
    final invitationUuid = invitation.uuid;
    if (invitationUuid.isEmpty) {
      return;
    }

    try {
      await _notificationClient.cancel(NotificationIds.groupInvitation(invitationUuid));
    } catch (error, stackTrace) {
      debugPrint('Error cancelling group invitation notification: $error');
      debugPrintStack(stackTrace: stackTrace);
    }
  }
}
