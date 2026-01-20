import 'package:flutter/material.dart';

import '../../../../data/local/database.dart';

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
          const PopupMenuItem<GroupMenuAction>(
            value: GroupMenuAction.edit,
            child: Text('Editar grupo'),
          ),
        )
        ..add(
          const PopupMenuItem<GroupMenuAction>(
            value: GroupMenuAction.manageMembers,
            child: Text('Gestionar miembros'),
          ),
        )
        ..add(
          const PopupMenuItem<GroupMenuAction>(
            value: GroupMenuAction.manageInvitations,
            child: Text('Gestionar invitaciones'),
          ),
        );
    } else {
      // For non-admins, show View Members
      menuEntries.add(
        const PopupMenuItem<GroupMenuAction>(
          value: GroupMenuAction.viewMembers,
          child: Text('Ver miembros'),
        ),
      );
    }

    if (isOwner) {
      if (menuEntries.isNotEmpty) {
        menuEntries.add(const PopupMenuDivider());
      }
      menuEntries
        ..add(
          const PopupMenuItem<GroupMenuAction>(
            value: GroupMenuAction.transferOwnership,
            child: Text('Transferir propiedad'),
          ),
        )
        ..add(
          const PopupMenuItem<GroupMenuAction>(
            value: GroupMenuAction.delete,
            child: Text('Eliminar grupo'),
          ),
        );
    }

    if (!isOwner) {
      if (menuEntries.isNotEmpty) {
        menuEntries.add(const PopupMenuDivider());
      }
      menuEntries.add(
        const PopupMenuItem<GroupMenuAction>(
          value: GroupMenuAction.leaveGroup,
          child: Text('Salir del grupo'),
        ),
      );
    }

    if (menuEntries.isEmpty) {
      return const SizedBox.shrink();
    }

    return PopupMenuButton<GroupMenuAction>(
      icon: const Icon(Icons.more_vert),
      tooltip: 'Acciones del grupo',
      enabled: !isGroupBusy,
      itemBuilder: (context) => menuEntries,
      onSelected: onAction,
    );
  }
}
