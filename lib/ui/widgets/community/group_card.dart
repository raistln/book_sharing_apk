import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../data/local/database.dart';
import '../../../../data/local/group_dao.dart';
import '../../../../models/book_genre.dart';
import '../../../../providers/book_providers.dart';
import '../../../../services/coach_marks/coach_mark_controller.dart';
import '../../../../services/coach_marks/coach_mark_models.dart';
import '../../../../ui/dialogs/group_form_dialog.dart';
import '../../../../ui/widgets/coach_mark_target.dart';
import '../../../../utils/group_utils.dart';
import '../../../../design_system/literary_shadows.dart';
import '../../../../design_system/evocative_texts.dart';
import '../../../../ui/utils/library_transition.dart';
import 'group_stats_table.dart';
import 'group_menu.dart';
import '../../screens/home/tabs/discover_group_page.dart';

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
    final activeUserAsync = ref.watch(activeUserProvider);
    final activeUser = activeUserAsync.value;
    final groupActionState = ref.watch(groupPushControllerProvider);
    final isGroupBusy = groupActionState.isLoading;

    final members = membersAsync.asData?.value ?? const <GroupMemberDetail>[];
    final isOwner = activeUser != null &&
        group.ownerUserId != null &&
        group.ownerUserId == activeUser.id;
    final currentMembership =
        activeUser != null ? _findMemberDetail(members, activeUser.id) : null;
    final isAdmin =
        isOwner || currentMembership?.membership.role == _kRoleAdmin;

    final bool highlightManageInvitations = activeUser != null && isAdmin;

    // Ocultar menú para el grupo de préstamos personales
    final isPersonalGroup = isPersonalLoansGroup(group.name);

    Widget? menuButton;
    if (activeUser != null &&
        (isOwner || isAdmin || currentMembership != null) &&
        !isPersonalGroup) {
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

    // ---- Thematic group color tint -----------------------------------
    Color? tintColor;
    if (group.primaryColor != null) {
      final hex = group.primaryColor!.replaceFirst('#', '');
      try {
        tintColor = Color(int.parse('FF$hex', radix: 16));
      } catch (_) {}
    }

    // ---- Allowed genres list (for subtitle) -------------------------
    final allowedGenres = BookGenre.allowedFromJson(group.allowedGenres);
    final genreSubtitle = allowedGenres.isNotEmpty
        ? allowedGenres.map((g) => g.label).join(' · ')
        : null;

    // ---- Owner excluded-books count ---------------------------------
    // Only show for the owner when genre filter is active
    Map<String, int>? excludedInfo;
    if (isOwner && allowedGenres.isNotEmpty) {
      final myBooksAsync = ref.watch(bookListProvider);
      final myBooks = myBooksAsync.asData?.value ?? [];
      int passing = 0;
      int excluded = 0;
      for (final book in myBooks) {
        if (!book.isPhysical || book.isDeleted) continue;
        final genre = BookGenre.fromString(book.genre);
        if (genre != null && allowedGenres.contains(genre)) {
          passing++;
        } else {
          excluded++;
        }
      }
      excludedInfo = {'passing': passing, 'excluded': excluded};
    }
    // -----------------------------------------------------------------

    return Card(
      elevation: 0,
      shadowColor: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: theme.cardTheme.color ?? theme.colorScheme.surface,
          boxShadow: LiteraryShadows.groupCardShadow(context),
          // Thematic tint: soft 15% opacity overlay
          gradient: tintColor != null
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    tintColor.withValues(alpha: 0.12),
                    tintColor.withValues(alpha: 0.04),
                  ],
                )
              : null,
        ),
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
                        // Mostrar propietario para todos excepto Préstamos Personales
                        if (!isPersonalGroup && members.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          // Buscar el propietario en los miembros
                          Builder(
                            builder: (context) {
                              final ownerMember =
                                  members.cast<GroupMemberDetail?>().firstWhere(
                                        (m) =>
                                            m?.membership.memberUserId ==
                                            group.ownerUserId,
                                        orElse: () => null,
                                      );
                              final ownerName =
                                  ownerMember?.user?.username ?? 'Desconocido';
                              return Text(
                                'Lector@ Maest@: $ownerName (Dueño)',
                                style: theme.textTheme.bodySmall,
                              );
                            },
                          ),
                        ],
                        // Genre subtitle — visible to all members
                        if (genreSubtitle != null) ...[
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                Icons.local_library_outlined,
                                size: 12,
                                color: tintColor ??
                                    theme.colorScheme.onSurfaceVariant,
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  genreSubtitle,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: tintColor?.withValues(alpha: 0.85) ??
                                        theme.colorScheme.onSurfaceVariant,
                                    fontStyle: FontStyle.italic,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                        const SizedBox(height: 4),
                        Text(
                            'Última actualización: ${DateFormat.yMd().add_Hm().format(group.updatedAt)}',
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
              // Owner excluded-books info block
              if (excludedInfo != null && excludedInfo['excluded']! > 0) ...[
                const SizedBox(height: 8),
                _ExcludedBooksRow(
                  passing: excludedInfo['passing']!,
                  excluded: excludedInfo['excluded']!,
                ),
              ],
              const SizedBox(height: 12),
              // Hide stats and shared books for personal loans group
              if (!isPersonalGroup) ...[
                GroupStatsTable(
                  members: members,
                  sharedBooks: sharedBooksAsync.asData?.value ?? [],
                  loansAsync: loansAsync,
                  currentUserId: activeUser?.id,
                ),
                const SizedBox(height: 16),
                // Prominent Discovery Button
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.tonalIcon(
                    onPressed: () {
                      Navigator.of(context).push(
                        LibraryPageRoute(
                          page: DiscoverGroupPage(group: group),
                        ),
                      );
                    },
                    icon: const Icon(Icons.auto_stories), // Library icon
                    label: Text(EvocativeTexts.archiveButtonText(group.name)),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

const _kRoleAdmin = 'admin';

GroupMemberDetail? _findMemberDetail(
    List<GroupMemberDetail> members, int userId) {
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
    case GroupMenuAction.viewMembers:
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
      backgroundColor:
          isError ? theme.colorScheme.error : theme.colorScheme.primary,
    ),
  );
}

// Group action implementations
Future<void> _handleEditGroup(
  BuildContext context,
  WidgetRef ref,
  Group group,
) async {
  // Decode current genres so the dialog can pre-populate them
  final currentGenres = BookGenre.allowedFromJson(group.allowedGenres).toList();

  final result = await showDialog<GroupFormResult>(
    context: context,
    builder: (context) => GroupFormDialog(
      initialName: group.name,
      initialDescription: group.description,
      initialGenres: currentGenres,
    ),
  );

  if (result == null || !context.mounted) return;

  // Decode genre list from JSON for the controller
  List<String>? allowedGenres;
  if (result.allowedGenres != null) {
    try {
      final j = result.allowedGenres!.trim();
      if (j.startsWith('[')) {
        final inner = j.substring(1, j.length - 1);
        allowedGenres = inner.isEmpty
            ? []
            : inner
                .split(',')
                .map((s) => s.trim().replaceAll('"', '').replaceAll("'", ''))
                .where((s) => s.isNotEmpty)
                .toList();
      }
    } catch (_) {}
  }

  final controller = ref.read(groupPushControllerProvider.notifier);
  try {
    await controller.updateGroup(
      group: group,
      name: result.name,
      description: result.description,
      allowedGenres: allowedGenres,
      primaryColor: result.primaryColor,
    );
    if (!context.mounted) return;
    _showFeedbackSnackBar(
      context: context,
      message: 'Grupo actualizado correctamente',
      isError: false,
    );
  } catch (error) {
    if (!context.mounted) return;
    _showFeedbackSnackBar(
      context: context,
      message: 'Error al actualizar grupo: $error',
      isError: true,
    );
  }
}

Future<void> _handleTransferOwnership(
  BuildContext context,
  WidgetRef ref,
  Group group,
) async {
  final membersAsync = ref.read(groupMemberDetailsProvider(group.id));
  final allMembers = membersAsync.asData?.value ?? [];

  // Filter out the current owner from the list
  final members = allMembers
      .where((m) => m.membership.memberUserId != group.ownerUserId)
      .toList();

  if (members.isEmpty) {
    _showFeedbackSnackBar(
      context: context,
      message: 'No hay otros miembros a quienes transferir',
      isError: true,
    );
    return;
  }

  final selectedMember = await showDialog<GroupMemberDetail>(
    context: context,
    builder: (context) => _SelectMemberDialog(members: members),
  );

  if (selectedMember == null || !context.mounted) return;

  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Transferir propiedad'),
      content: Text(
        '¿Estás seguro de transferir la propiedad del grupo a ${selectedMember.user?.username ?? "este usuario"}? Esta acción no se puede deshacer.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text('Transferir'),
        ),
      ],
    ),
  );

  if (confirmed != true || !context.mounted) return;

  final controller = ref.read(groupPushControllerProvider.notifier);
  final newOwner = selectedMember.user;
  if (newOwner == null) return;

  try {
    await controller.transferOwnership(
      group: group,
      newOwner: newOwner,
    );
    if (!context.mounted) return;
    _showFeedbackSnackBar(
      context: context,
      message: 'Propiedad transferida correctamente',
      isError: false,
    );
  } catch (error) {
    if (!context.mounted) return;
    _showFeedbackSnackBar(
      context: context,
      message: 'Error al transferir propiedad: $error',
      isError: true,
    );
  }
}

Future<void> _handleDeleteGroup(
  BuildContext context,
  WidgetRef ref,
  Group group,
) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Eliminar grupo'),
      content: Text(
        '¿Estás seguro de eliminar el grupo "${group.name}"? Esta acción no se puede deshacer y se eliminarán todos los libros compartidos y préstamos asociados.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(true),
          style: FilledButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
          child: const Text('Eliminar'),
        ),
      ],
    ),
  );

  if (confirmed != true || !context.mounted) return;

  final controller = ref.read(groupPushControllerProvider.notifier);
  try {
    await controller.deleteGroup(group: group);
    if (!context.mounted) return;
    _showFeedbackSnackBar(
      context: context,
      message: 'Grupo eliminado correctamente',
      isError: false,
    );
  } catch (error) {
    if (!context.mounted) return;
    _showFeedbackSnackBar(
      context: context,
      message: 'Error al eliminar grupo: $error',
      isError: true,
    );
  }
}

Future<void> _handleLeaveGroup(
    BuildContext context, WidgetRef ref, Group group) async {
  final activeUser = ref.read(activeUserProvider).value;
  if (activeUser == null) return;

  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Salir del grupo'),
      content: Text(
        '¿Estás seguro de salir del grupo "${group.name}"? Perderás acceso a los libros compartidos.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text('Salir'),
        ),
      ],
    ),
  );

  if (confirmed != true || !context.mounted) return;

  final controller = ref.read(groupPushControllerProvider.notifier);
  final groupDao = ref.read(groupDaoProvider);
  final membership =
      await groupDao.findMember(groupId: group.id, userId: activeUser.id);
  if (membership == null) return;

  try {
    await controller.removeMember(
      member: membership,
    );
    if (!context.mounted) return;
    _showFeedbackSnackBar(
      context: context,
      message: 'Has salido del grupo correctamente',
      isError: false,
    );
  } catch (error) {
    if (!context.mounted) return;
    _showFeedbackSnackBar(
      context: context,
      message: 'Error al salir del grupo: $error',
      isError: true,
    );
  }
}

Future<void> _showManageMembersSheet(
  BuildContext context,
  WidgetRef ref, {
  required Group group,
}) async {
  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (context) => GroupMembersSheet(group: group),
  );
}

Future<void> _showInvitationsSheet(
  BuildContext context,
  WidgetRef ref, {
  required Group group,
}) async {
  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (context) => _ManageInvitationsSheet(group: group),
  );
}

/// Shows the owner how many of their books pass vs. are excluded by the group
/// genre filter. Provides a nudge to fix excluded books.
class _ExcludedBooksRow extends StatelessWidget {
  const _ExcludedBooksRow({required this.passing, required this.excluded});

  final int passing;
  final int excluded;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: colorScheme.errorContainer.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: colorScheme.error.withValues(alpha: 0.25),
          width: 0.8,
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.filter_list_outlined,
              size: 16, color: colorScheme.error.withValues(alpha: 0.8)),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              '$excluded ${excluded == 1 ? 'libro excluido' : 'libros excluidos'} por el filtro de género · $passing visibles',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onErrorContainer,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SelectMemberDialog extends StatelessWidget {
  const _SelectMemberDialog({required this.members});

  final List<GroupMemberDetail> members;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Seleccionar nuevo propietario'),
      content: SizedBox(
        width: double.maxFinite,
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: members.length,
          itemBuilder: (context, index) {
            final member = members[index];
            final user = member.user;
            return ListTile(
              title: Text(user?.username ?? 'Usuario desconocido'),
              subtitle: Text('Rol: ${member.membership.role}'),
              onTap: () => Navigator.of(context).pop(member),
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
      ],
    );
  }
}

class GroupMembersSheet extends ConsumerWidget {
  const GroupMembersSheet({super.key, required this.group});

  final Group group;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final membersAsync = ref.watch(groupMemberDetailsProvider(group.id));
    final activeUser = ref.watch(activeUserProvider).value;
    final isOwner = activeUser != null && group.ownerUserId == activeUser.id;

    // Check if current user is admin
    final members = membersAsync.asData?.value ?? [];
    final currentUserMembership = activeUser != null
        ? members.cast<GroupMemberDetail?>().firstWhere(
            (m) => m?.membership.memberUserId == activeUser.id,
            orElse: () => null)
        : null;
    final isAdmin =
        isOwner || currentUserMembership?.membership.role == 'admin';

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Text(isAdmin ? 'Gestionar miembros' : 'Miembros del grupo',
                      style: theme.textTheme.titleLarge),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: membersAsync.when(
                data: (members) {
                  if (members.isEmpty) {
                    return const Center(child: Text('No hay miembros'));
                  }
                  final memberActivity =
                      ref.watch(groupMemberActivityProvider(group.id));

                  return ListView.builder(
                    controller: scrollController,
                    itemCount: members.length,
                    itemBuilder: (context, index) {
                      final member = members[index];
                      final user = member.user;
                      final isCurrentOwner =
                          group.ownerUserId == member.membership.memberUserId;
                      final activity =
                          memberActivity[member.membership.memberUserId];

                      // Determine star member (top score)
                      final isStarMember = activity != null &&
                          activity.score > 0 &&
                          !memberActivity.values.any(
                              (a) => a != activity && a.score > activity.score);

                      return ListTile(
                        leading: CircleAvatar(
                          child: Text((user?.username ?? '?')[0].toUpperCase()),
                        ),
                        title: Row(
                          children: [
                            Expanded(
                              child: Text(
                                user?.username ?? 'Usuario desconocido',
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (isStarMember)
                              const Tooltip(
                                message: 'Miembro Estrella (Máxima actividad)',
                                child: Text(' ⭐'),
                              ),
                          ],
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(_getRoleLabel(
                                member.membership.role, isCurrentOwner)),
                            if (activity != null && activity.score > 0)
                              Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Wrap(
                                  spacing: 4,
                                  runSpacing: 4,
                                  children: [
                                    if (activity.sharedCount >= 5)
                                      const _ActivityBadge(
                                        label: 'Bibliófilo',
                                        icon: Icons.auto_stories,
                                        color: Colors.blue,
                                      ),
                                    if (activity.sharedCount >= 20)
                                      const _ActivityBadge(
                                        label: 'Curador',
                                        icon:
                                            Icons.collections_bookmark_outlined,
                                        color: Colors.amber,
                                      ),
                                    if (activity.sharedCount >= 10)
                                      const _ActivityBadge(
                                        label: 'Bibliotecario',
                                        icon: Icons.account_balance,
                                        color: Colors.purple,
                                      ),
                                    if (activity.lendingCount >= 3)
                                      const _ActivityBadge(
                                        label: 'Lector Activo',
                                        icon: Icons.handshake_outlined,
                                        color: Colors.green,
                                      ),
                                    if (activity.lendingCount >= 8)
                                      const _ActivityBadge(
                                        label: 'Generoso',
                                        icon: Icons.volunteer_activism_outlined,
                                        color: Colors.orange,
                                      ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                        trailing: isAdmin && !isCurrentOwner
                            ? PopupMenuButton<String>(
                                itemBuilder: (context) => [
                                  const PopupMenuItem(
                                    value: 'admin',
                                    child: Text('Hacer admin'),
                                  ),
                                  const PopupMenuItem(
                                    value: 'member',
                                    child: Text('Hacer miembro'),
                                  ),
                                  const PopupMenuDivider(),
                                  const PopupMenuItem(
                                    value: 'remove',
                                    child: Text('Eliminar'),
                                  ),
                                ],
                                onSelected: (value) => _handleMemberAction(
                                  context,
                                  ref,
                                  member,
                                  value,
                                ),
                              )
                            : null,
                      );
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, _) => Center(child: Text('Error: $error')),
              ),
            ),
          ],
        );
      },
    );
  }

  String _getRoleLabel(String role, bool isOwner) {
    if (isOwner) return 'Propietario';
    switch (role) {
      case 'admin':
        return 'Administrador';
      case 'member':
        return 'Miembro';
      default:
        return role;
    }
  }

  Future<void> _handleMemberAction(
    BuildContext context,
    WidgetRef ref,
    GroupMemberDetail member,
    String action,
  ) async {
    final controller = ref.read(groupPushControllerProvider.notifier);

    try {
      if (action == 'remove') {
        await controller.removeMember(
          member: member.membership,
        );
        if (!context.mounted) return;
        _showFeedbackSnackBar(
          context: context,
          message: 'Miembro eliminado',
          isError: false,
        );
      } else {
        await controller.updateMemberRole(
          member: member.membership,
          role: action,
        );
        if (!context.mounted) return;
        _showFeedbackSnackBar(
          context: context,
          message: 'Rol actualizado',
          isError: false,
        );
      }
    } catch (error) {
      if (!context.mounted) return;
      _showFeedbackSnackBar(
        context: context,
        message: 'Error: $error',
        isError: true,
      );
    }
  }
}

class _ManageInvitationsSheet extends ConsumerStatefulWidget {
  const _ManageInvitationsSheet({required this.group});

  final Group group;

  @override
  ConsumerState<_ManageInvitationsSheet> createState() =>
      _ManageInvitationsSheetState();
}

class _ManageInvitationsSheetState
    extends ConsumerState<_ManageInvitationsSheet> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final invitationsAsync =
        ref.watch(groupInvitationDetailsProvider(widget.group.id));
    final activeUser = ref.watch(activeUserProvider).value;

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Text('Gestionar invitaciones',
                      style: theme.textTheme.titleLarge),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(16),
              child: FilledButton.icon(
                onPressed: activeUser != null
                    ? () => _createInvitation(activeUser)
                    : null,
                icon: const Icon(Icons.add),
                label: const Text('Crear invitación'),
              ),
            ),
            Expanded(
              child: invitationsAsync.when(
                data: (invitations) {
                  if (invitations.isEmpty) {
                    return const Center(
                        child: Text('No hay invitaciones pendientes'));
                  }
                  return ListView.builder(
                    controller: scrollController,
                    itemCount: invitations.length,
                    itemBuilder: (context, index) {
                      final invitation = invitations[index].invitation;
                      return Card(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      'Código: ${invitation.code}',
                                      style: theme.textTheme.titleSmall,
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.share),
                                    onPressed: () =>
                                        _shareInvitation(invitation.code),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete),
                                    onPressed: () =>
                                        _cancelInvitation(invitation.id),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Expira: ${DateFormat.yMd().add_Hm().format(invitation.expiresAt)}',
                                style: theme.textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, _) => Center(child: Text('Error: $error')),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _createInvitation(LocalUser inviter) async {
    final controller = ref.read(groupPushControllerProvider.notifier);
    try {
      await controller.createInvitation(
        group: widget.group,
        inviter: inviter,
      );
      if (!mounted) return;
      _showFeedbackSnackBar(
        context: context,
        message: 'Invitación creada correctamente',
        isError: false,
      );
      // No auto-share - user will click share button manually
    } catch (error) {
      if (!mounted) return;
      _showFeedbackSnackBar(
        context: context,
        message: 'Error al crear invitación: $error',
        isError: true,
      );
    }
  }

  Future<void> _shareInvitation(String code) async {
    final message =
        'Te envío esta invitación para unirte a mi grupo de lectores: $code';

    try {
      await Share.share(
        message,
        subject: 'Invitación a grupo de lectores',
      );
    } catch (error) {
      if (!mounted) return;
      _showFeedbackSnackBar(
        context: context,
        message: 'Error al compartir: $error',
        isError: true,
      );
    }
  }

  Future<void> _cancelInvitation(int invitationId) async {
    // Add confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancelar invitación'),
        content: const Text('¿Estás seguro de cancelar esta invitación?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('No'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Sí, cancelar'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    final controller = ref.read(groupPushControllerProvider.notifier);
    final groupDao = ref.read(groupDaoProvider);
    final invitation = await groupDao.findInvitationById(invitationId);
    if (invitation == null) return;

    try {
      await controller.cancelInvitation(invitation: invitation);
      if (!mounted) return;
      _showFeedbackSnackBar(
        context: context,
        message: 'Invitación cancelada',
        isError: false,
      );
    } catch (error) {
      if (!mounted) return;
      _showFeedbackSnackBar(
        context: context,
        message: 'Error al cancelar invitación: $error',
        isError: true,
      );
    }
  }
}

class _ActivityBadge extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;

  const _ActivityBadge({
    required this.label,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Tooltip(
      message: label,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 12, color: color),
            const SizedBox(width: 4),
            Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(
                color: color,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
