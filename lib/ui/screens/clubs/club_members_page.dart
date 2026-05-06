import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/local/database.dart';
import '../../../data/local/club_dao.dart';
import '../../../providers/book_providers.dart';
import '../../../providers/clubs_provider.dart';
import '../../../l10n/generated/app_localizations.dart';

class ClubMembersPage extends ConsumerWidget {
  const ClubMembersPage({super.key, required this.club});

  final ReadingClub club;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = S.of(context);
    final membersAsync = ref.watch(clubMembersProvider(club.uuid));
    final activeUser = ref.watch(activeUserProvider).value;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.clubMembersTitle),
      ),
      body: membersAsync.when(
        data: (members) {
          if (members.isEmpty) {
            return Center(child: Text(l10n.clubMembersEmpty));
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
                  '${_getRoleLabel(item.member.role, l10n)} • ${_getStatusLabel(item.member.status, l10n)}',
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
                            _confirmKick(context, ref, item, l10n);
                          }
                        },
                        itemBuilder: (context) => [
                          PopupMenuItem(
                            value: 'kick',
                            child: Row(
                              children: [
                                const Icon(Icons.remove_circle_outline,
                                    color: Colors.red),
                                const SizedBox(width: 8),
                                Text(l10n.clubMembersKick,
                                    style: const TextStyle(color: Colors.red)),
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

  String _getRoleLabel(String role, S l10n) {
    switch (role) {
      case 'dueño':
        return l10n.clubRoleOwner;
      case 'admin':
        return l10n.clubRoleAdmin;
      default:
        return l10n.roleMember;
    }
  }

  String _getStatusLabel(String status, S l10n) {
    switch (status) {
      case 'activo':
        return l10n.clubStatusActive;
      case 'inactivo':
        return l10n.clubStatusInactive;
      default:
        return status;
    }
  }

  void _confirmKick(
      BuildContext context, WidgetRef ref, ClubMemberWithUser target, S l10n) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.clubMembersKickConfirmTitle(target.user.username)),
        content: Text(l10n.clubMembersKickConfirmMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
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
                    SnackBar(content: Text(l10n.clubMembersKickSuccess)),
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
            child: Text(l10n.clubMembersKick),
          ),
        ],
      ),
    );
  }
}
