import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../data/local/database.dart';
import '../../../../data/local/group_dao.dart';
import '../../../../providers/book_providers.dart';
import '../../../../services/coach_marks/coach_mark_controller.dart';
import '../../../../services/coach_marks/coach_mark_models.dart';
import '../../../../ui/widgets/coach_mark_target.dart';
import '../../../../utils/group_utils.dart';
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

    // Ocultar menú para el grupo de préstamos personales
    final isPersonalGroup = isPersonalLoansGroup(group.name);

    Widget? menuButton;
    if (activeUser != null && (isOwner || isAdmin || currentMembership != null) && !isPersonalGroup) {
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
                      // Mostrar propietario para todos excepto Préstamos Personales
                      if (!isPersonalGroup && members.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        // Buscar el propietario en los miembros
                        Builder(
                          builder: (context) {
                            final ownerMember = members.cast<GroupMemberDetail?>().firstWhere(
                              (m) => m?.membership.memberUserId == group.ownerUserId,
                              orElse: () => null,
                            );
                            final ownerName = ownerMember?.user?.username ?? 'Desconocido';
                            return Text(
                              'Lector@ Maest@: $ownerName (Dueño)',
                              style: theme.textTheme.bodySmall,
                            );
                          },
                        ),
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
            // Hide stats and shared books for personal loans group
            if (!isPersonalGroup) ...[
              GroupStatsChips(
                groupId: group.id,
                membersAsync: membersAsync,
                sharedBooksAsync: sharedBooksAsync,
                loansAsync: loansAsync,
                invitationsAsync: invitationsAsync,
              ),
              const SizedBox(height: 16),
              SharedBooksSection(sharedBooksAsync: sharedBooksAsync),
              const SizedBox(height: 12),
            ],
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

// Group action implementations
Future<void> _handleEditGroup(
  BuildContext context,
  WidgetRef ref,
  Group group,
) async {
  final result = await showDialog<({String name, String? description})>(
    context: context,
    builder: (context) => _GroupFormDialog(
      initialName: group.name,
      initialDescription: group.description,
    ),
  );

  if (result == null || !context.mounted) return;

  final controller = ref.read(groupPushControllerProvider.notifier);
  try {
    await controller.updateGroup(
      group: group,
      name: result.name,
      description: result.description,
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

Future<void> _handleLeaveGroup(BuildContext context, WidgetRef ref, Group group) async {
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
  final membership = await groupDao.findMember(groupId: group.id, userId: activeUser.id);
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
    builder: (context) => _ManageMembersSheet(group: group),
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

// Dialogs and Sheets
class _GroupFormDialog extends StatefulWidget {
  const _GroupFormDialog({
    this.initialName,
    this.initialDescription,
  });

  final String? initialName;
  final String? initialDescription;

  @override
  State<_GroupFormDialog> createState() => _GroupFormDialogState();
}

class _GroupFormDialogState extends State<_GroupFormDialog> {
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName);
    _descriptionController = TextEditingController(text: widget.initialDescription);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Editar grupo'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Nombre del grupo'),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'El nombre es obligatorio';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Descripción (opcional)'),
              maxLines: 3,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              Navigator.of(context).pop((
                name: _nameController.text.trim(),
                description: _descriptionController.text.trim().isEmpty
                    ? null
                    : _descriptionController.text.trim(),
              ));
            }
          },
          child: const Text('Guardar'),
        ),
      ],
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

class _ManageMembersSheet extends ConsumerWidget {
  const _ManageMembersSheet({required this.group});

  final Group group;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final membersAsync = ref.watch(groupMemberDetailsProvider(group.id));
    final activeUser = ref.watch(activeUserProvider).value;
    final isOwner = activeUser != null && group.ownerUserId == activeUser.id;

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
                  Text('Gestionar miembros', style: theme.textTheme.titleLarge),
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
                  return ListView.builder(
                    controller: scrollController,
                    itemCount: members.length,
                    itemBuilder: (context, index) {
                      final member = members[index];
                      final user = member.user;
                      final isCurrentOwner = group.ownerUserId == member.membership.memberUserId;
                      
                      return ListTile(
                        leading: CircleAvatar(
                          child: Text((user?.username ?? '?')[0].toUpperCase()),
                        ),
                        title: Text(user?.username ?? 'Usuario desconocido'),
                        subtitle: Text(_getRoleLabel(member.membership.role, isCurrentOwner)),
                        trailing: isOwner && !isCurrentOwner
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
  ConsumerState<_ManageInvitationsSheet> createState() => _ManageInvitationsSheetState();
}

class _ManageInvitationsSheetState extends ConsumerState<_ManageInvitationsSheet> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final invitationsAsync = ref.watch(groupInvitationDetailsProvider(widget.group.id));
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
                  Text('Gestionar invitaciones', style: theme.textTheme.titleLarge),
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
                onPressed: activeUser != null ? () => _createInvitation(activeUser) : null,
                icon: const Icon(Icons.add),
                label: const Text('Crear invitación'),
              ),
            ),
            Expanded(
              child: invitationsAsync.when(
                data: (invitations) {
                  if (invitations.isEmpty) {
                    return const Center(child: Text('No hay invitaciones pendientes'));
                  }
                  return ListView.builder(
                    controller: scrollController,
                    itemCount: invitations.length,
                    itemBuilder: (context, index) {
                      final invitation = invitations[index].invitation;
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                                    onPressed: () => _shareInvitation(invitation.code),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete),
                                    onPressed: () => _cancelInvitation(invitation.id),
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
    final message = 'Te envío esta invitación para unirte a mi grupo de lectores: $code';
    
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
