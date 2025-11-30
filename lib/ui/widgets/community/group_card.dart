import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../data/local/database.dart';
import '../../../../data/local/group_dao.dart';
import '../../../../providers/book_providers.dart';
import '../../../../services/coach_marks/coach_mark_controller.dart';
import '../../../../services/coach_marks/coach_mark_models.dart';
import '../../../../ui/widgets/coach_mark_target.dart';
import 'group_stats_chips.dart';
import 'shared_books_section.dart';
import 'loans_section.dart';
import 'group_menu.dart';

class GroupCard extends ConsumerStatefulWidget {
  const GroupCard({
    super.key,
    required this.group,
    required this.onSync,
  });

  final Group group;
  final Future<void> Function() onSync;

  @override
  ConsumerState<GroupCard> createState() => _GroupCardState();
}

class _GroupCardState extends ConsumerState<GroupCard> {
  bool _waitingDetailCompletion = false;
  late ProviderSubscription<CoachMarkState> _groupCardCoachSub;

  @override
  void initState() {
    super.initState();

    final initialState = ref.read(coachMarkControllerProvider);
    if (initialState.sequence == CoachMarkSequence.detail) {
      _waitingDetailCompletion = true;
    }

    _groupCardCoachSub = ref.listenManual<CoachMarkState>(
      coachMarkControllerProvider,
      (previous, next) {
        if (next.sequence == CoachMarkSequence.detail) {
          _waitingDetailCompletion = true;
        }

        if (_waitingDetailCompletion &&
            previous?.sequence == CoachMarkSequence.detail &&
            next.sequence != CoachMarkSequence.detail &&
            !next.isVisible &&
            next.queue.isEmpty) {
          _waitingDetailCompletion = false;
          unawaited(() async {
            final onboarding = ref.read(onboardingServiceProvider);
            await onboarding.markDetailCoachSeen();
            ref.invalidate(onboardingProgressProvider);
          }());
        }
      },
    );
  }

  @override
  void dispose() {
    _groupCardCoachSub.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final group = widget.group;
    final membersAsync = ref.watch(groupMemberDetailsProvider(group.id));
    final sharedBooksAsync = ref.watch(sharedBookDetailsProvider(group.id));
    final loansAsync = ref.watch(userRelevantLoansProvider(group.id));
    final invitationsAsync = ref.watch(groupInvitationDetailsProvider(group.id));
    final activeUserAsync = ref.watch(activeUserProvider);
    final activeUser = activeUserAsync.value;
    final groupActionState = ref.watch(groupPushControllerProvider);
    final isGroupBusy = groupActionState.isLoading;
    final loanController = ref.watch(loanControllerProvider.notifier);
    final loanState = ref.watch(loanControllerProvider);

    final members = membersAsync.asData?.value ?? const <GroupMemberDetail>[];
    final isOwner = activeUser != null && group.ownerUserId != null && group.ownerUserId == activeUser.id;
    final currentMembership = activeUser != null
        ? _findMemberDetail(members, activeUser.id)
        : null;
    final isAdmin = isOwner || currentMembership?.membership.role == _kRoleAdmin;

    final bool highlightManageInvitations = activeUser != null && isAdmin;

    Widget? menuButton;
    if (activeUser != null && (isOwner || isAdmin || currentMembership != null)) {
      final popup = GroupMenu(
        group: group,
        activeUser: activeUser,
        isOwner: isOwner,
        isAdmin: isAdmin,
        isGroupBusy: isGroupBusy,
        onAction: (action) {
          unawaited(
            _onGroupMenuAction(
              context: context,
              ref: ref,
              action: action,
              group: group,
            ),
          );
        },
      );

      menuButton = highlightManageInvitations
          ? CoachMarkTarget(
              id: CoachMarkId.groupManageInvitations,
              child: popup,
            )
          : popup;
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(group.name, style: theme.textTheme.titleMedium),
                      if (group.ownerRemoteId != null) ...[
                        const SizedBox(height: 4),
                        Text('Propietario remoto: ${group.ownerRemoteId}',
                            style: theme.textTheme.bodySmall),
                      ],
                      const SizedBox(height: 4),
                      Text('Última actualización: ${DateFormat.yMd().add_Hm().format(group.updatedAt)}',
                          style: theme.textTheme.bodySmall),
                    ],
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      onPressed: isGroupBusy ? null : () => widget.onSync(),
                      icon: const Icon(Icons.sync_outlined),
                      tooltip: 'Sincronizar grupo',
                    ),
                    if (menuButton != null) menuButton,
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            GroupStatsChips(
              membersAsync: membersAsync,
              sharedBooksAsync: sharedBooksAsync,
              loansAsync: loansAsync,
              invitationsAsync: invitationsAsync,
            ),
            const SizedBox(height: 16),
            SharedBooksSection(sharedBooksAsync: sharedBooksAsync),
            const SizedBox(height: 12),
            LoansSection(
              loansAsync: loansAsync,
              activeUser: activeUser,
              loanController: loanController,
              loanState: loanState,
              onFeedback: (message, isError) {
                _showFeedbackSnackBar(
                  context: context,
                  message: message,
                  isError: isError,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

const _kRoleAdmin = 'admin';

GroupMemberDetail? _findMemberDetail(List<GroupMemberDetail> members, int userId) {
  for (final detail in members) {
    final user = detail.user;
    if (user != null && user.id == userId) {
      return detail;
    }
  }
  return null;
}

Future<void> _onGroupMenuAction({
  required BuildContext context,
  required WidgetRef ref,
  required GroupMenuAction action,
  required Group group,
}) async {
  switch (action) {
    case GroupMenuAction.edit:
      await _handleEditGroup(context, ref, group);
      break;
    case GroupMenuAction.transferOwnership:
      await _handleTransferOwnership(context, ref, group);
      break;
    case GroupMenuAction.manageMembers:
      await _showManageMembersSheet(context, ref, group: group);
      break;
    case GroupMenuAction.manageInvitations:
      await _showInvitationsSheet(context, ref, group: group);
      break;
    case GroupMenuAction.delete:
      await _handleDeleteGroup(context, ref, group);
      break;
    case GroupMenuAction.leaveGroup:
      await _handleLeaveGroup(context, ref, group);
      break;
  }
}

void _showFeedbackSnackBar({
  required BuildContext context,
  required String message,
  required bool isError,
}) {
  final theme = Theme.of(context);
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: isError ? theme.colorScheme.error : theme.colorScheme.primary,
    ),
  );
}

// Placeholder implementations - these will be moved to separate files
Future<void> _handleEditGroup(
  BuildContext context,
  WidgetRef ref,
  Group group,
) async {
  // Implementation will be moved from CommunityTab
}

Future<void> _handleTransferOwnership(
  BuildContext context,
  WidgetRef ref,
  Group group,
) async {
  // Implementation will be moved from CommunityTab
}

Future<void> _handleDeleteGroup(
  BuildContext context,
  WidgetRef ref,
  Group group,
) async {
  // Implementation will be moved from CommunityTab
}

Future<void> _handleLeaveGroup(BuildContext context, WidgetRef ref, Group group) async {
  // Implementation will be moved from CommunityTab
}

Future<void> _showManageMembersSheet(
  BuildContext context,
  WidgetRef ref, {
  required Group group,
}) async {
  // Implementation will be moved from CommunityTab
}

Future<void> _showInvitationsSheet(
  BuildContext context,
  WidgetRef ref, {
  required Group group,
}) async {
  // Implementation will be moved from CommunityTab
}
