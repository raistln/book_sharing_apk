import 'package:flutter/material.dart';

import '../../../../data/local/database.dart';
import '../../../../l10n/generated/app_localizations.dart';

enum GroupMenuAction {
  edit,
  transferOwnership,
  manageMembers,
  manageInvitations,
  viewMembers,
  delete,
  leaveGroup,
}

class GroupMenu extends StatelessWidget {
  const GroupMenu({
    super.key,
    required this.group,
    required this.activeUser,
    required this.isOwner,
    required this.isAdmin,
    required this.isGroupBusy,
    required this.onAction,
  });

  final Group group;
  final LocalUser activeUser;
  final bool isOwner;
  final bool isAdmin;
  final bool isGroupBusy;
  final void Function(GroupMenuAction action) onAction;

  @override
  Widget build(BuildContext context) {
    final menuEntries = <PopupMenuEntry<GroupMenuAction>>[];

    if (isOwner || isAdmin) {
      menuEntries
        ..add(
          PopupMenuItem<GroupMenuAction>(
            value: GroupMenuAction.edit,
            child: Text(S.of(context).actionEditGroup),
          ),
        )
        ..add(
          PopupMenuItem<GroupMenuAction>(
            value: GroupMenuAction.manageMembers,
            child: Text(S.of(context).actionManageMembers),
          ),
        )
        ..add(
          PopupMenuItem<GroupMenuAction>(
            value: GroupMenuAction.manageInvitations,
            child: Text(S.of(context).actionManageInvitations),
          ),
        );
    } else {
      // For non-admins, show View Members
      menuEntries.add(
        PopupMenuItem<GroupMenuAction>(
          value: GroupMenuAction.viewMembers,
          child: Text(S.of(context).actionViewMembers),
        ),
      );
    }

    if (isOwner) {
      if (menuEntries.isNotEmpty) {
        menuEntries.add(const PopupMenuDivider());
      }
      menuEntries
        ..add(
          PopupMenuItem<GroupMenuAction>(
            value: GroupMenuAction.transferOwnership,
            child: Text(S.of(context).actionTransferOwnership),
          ),
        )
        ..add(
          PopupMenuItem<GroupMenuAction>(
            value: GroupMenuAction.delete,
            child: Text(S.of(context).actionDeleteGroup),
          ),
        );
    }

    if (!isOwner) {
      if (menuEntries.isNotEmpty) {
        menuEntries.add(const PopupMenuDivider());
      }
      menuEntries.add(
        PopupMenuItem<GroupMenuAction>(
          value: GroupMenuAction.leaveGroup,
          child: Text(S.of(context).actionLeaveGroup),
        ),
      );
    }

    if (menuEntries.isEmpty) {
      return const SizedBox.shrink();
    }

    return PopupMenuButton<GroupMenuAction>(
      icon: const Icon(Icons.more_vert),
      tooltip: S.of(context).tooltipGroupActions,
      enabled: !isGroupBusy,
      itemBuilder: (context) => menuEntries,
      onSelected: onAction,
    );
  }
}
