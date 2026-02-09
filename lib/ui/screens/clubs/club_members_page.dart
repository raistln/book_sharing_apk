import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/local/database.dart';
import '../../../data/local/club_dao.dart';
import '../../../providers/book_providers.dart';
import '../../../providers/clubs_provider.dart';

class ClubMembersPage extends ConsumerWidget {
  const ClubMembersPage({super.key, required this.club});

  final ReadingClub club;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final membersAsync = ref.watch(clubMembersProvider(club.uuid));
    final activeUser = ref.watch(activeUserProvider).value;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Miembros del Club'),
      ),
      body: membersAsync.when(
        data: (members) {
          if (members.isEmpty) {
            return const Center(child: Text('No hay miembros (esto es raro)'));
          }

          // Determine current user's role
          final currentUserMember = members
              .where((m) => m.user.remoteId == activeUser?.remoteId)
              .firstOrNull;

          final isCurrentUserAdmin = currentUserMember != null &&
              (currentUserMember.member.role == 'dueño' ||
                  currentUserMember.member.role == 'admin');

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: members.length,
            separatorBuilder: (context, index) => const Divider(),
            itemBuilder: (context, index) {
              final item = members[index];
              final isMe = item.user.remoteId == activeUser?.remoteId;
              final isTargetOwner = item.member.role == 'dueño';

              return ListTile(
                leading: CircleAvatar(
                  // Placeholder for avatar since we don't have it in LocalUser yet
                  child: Text(item.user.username.substring(0, 1).toUpperCase()),
                ),
                title: Text(item.user.username),
                subtitle: Text(
                  '${_getRoleLabel(item.member.role)} • ${_getStatusLabel(item.member.status)}',
                  style: TextStyle(
                    color: item.member.status == 'activo'
                        ? Colors.green
                        : Colors.grey,
                  ),
                ),
                trailing: (isCurrentUserAdmin && !isMe && !isTargetOwner)
                    ? PopupMenuButton<String>(
                        onSelected: (value) {
                          if (value == 'kick') {
                            _confirmKick(context, ref, item);
                          }
                        },
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: 'kick',
                            child: Row(
                              children: [
                                Icon(Icons.remove_circle_outline,
                                    color: Colors.red),
                                SizedBox(width: 8),
                                Text('Expulsar',
                                    style: TextStyle(color: Colors.red)),
                              ],
                            ),
                          ),
                        ],
                      )
                    : null,
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text('Error: $e')),
      ),
    );
  }

  String _getRoleLabel(String role) {
    switch (role) {
      case 'dueño':
        return 'Dueño';
      case 'admin':
        return 'Admin';
      default:
        return 'Miembro';
    }
  }

  String _getStatusLabel(String status) {
    switch (status) {
      case 'activo':
        return 'Activo';
      case 'inactivo':
        return 'Inactivo';
      default:
        return status;
    }
  }

  void _confirmKick(
      BuildContext context, WidgetRef ref, ClubMemberWithUser target) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Expulsar a ${target.user.username}?'),
        content: const Text(
            'Esta acción eliminará al usuario del club. ¿Estás seguro?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              if (target.member.memberRemoteId == null) return;

              final activeUser = ref.read(activeUserProvider).value;
              if (activeUser?.remoteId == null) return;

              try {
                await ref.read(clubServiceProvider).kickMember(
                      clubUuid: club.uuid,
                      targetUserUuid: target.member.memberRemoteId!,
                      performedByUuid: activeUser!.remoteId!,
                    );
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Usuario expulsado')),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $e')),
                  );
                }
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Expulsar'),
          ),
        ],
      ),
    );
  }
}
