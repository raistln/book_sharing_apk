import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../data/local/database.dart';
import '../../../../data/local/group_dao.dart';
import '../../../../providers/book_providers.dart';
import '../../../../services/coach_marks/coach_mark_controller.dart';
import '../../../../services/coach_marks/coach_mark_models.dart';
import '../../../../services/loan_controller.dart';
import '../../../widgets/coach_mark_target.dart';
import '../../../widgets/empty_state.dart';
import '../../../widgets/loan_feedback_banner.dart';
import '../../../dialogs/group_form_dialog.dart';

class CommunityTab extends ConsumerWidget {
  const CommunityTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groupsAsync = ref.watch(groupListProvider);
    final loanActionState = ref.watch(loanControllerProvider);
    final groupActionState = ref.watch(groupPushControllerProvider);
    final activeUser = ref.watch(activeUserProvider).value;
    final isGroupBusy = groupActionState.isLoading;

    return SafeArea(
      child: Column(
        children: [
          if (groupActionState.lastError != null)
            LoanFeedbackBanner(
              message: groupActionState.lastError!,
              isError: true,
              onDismiss: () => ref.read(groupPushControllerProvider.notifier).dismissError(),
            )
          else if (groupActionState.lastSuccess != null)
            LoanFeedbackBanner(
              message: groupActionState.lastSuccess!,
              isError: false,
              onDismiss: () => ref.read(groupPushControllerProvider.notifier).dismissSuccess(),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 8),
            child: Wrap(
              spacing: 12,
              runSpacing: 12,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                FilledButton.icon(
                  onPressed: activeUser == null || isGroupBusy
                      ? null
                      : () => _handleCreateGroup(context, ref, activeUser),
                  icon: const Icon(Icons.group_add_outlined),
                  label: const Text('Crear grupo'),
                ),
                OutlinedButton.icon(
                  onPressed: activeUser == null || isGroupBusy
                      ? null
                      : () => _handleJoinGroupByCode(context, ref, activeUser),
                  icon: const Icon(Icons.qr_code_2_outlined),
                  label: const Text('Unirse por código'),
                ),
                if (isGroupBusy)
                  const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2.5),
                  ),
              ],
            ),
          ),
          if (loanActionState.lastError != null)
            LoanFeedbackBanner(
              message: loanActionState.lastError!,
              isError: true,
              onDismiss: () => ref.read(loanControllerProvider.notifier).dismissError(),
            )
          else if (loanActionState.lastSuccess != null)
            LoanFeedbackBanner(
              message: loanActionState.lastSuccess!,
              isError: false,
              onDismiss: () =>
                  ref.read(loanControllerProvider.notifier).dismissSuccess(),
            ),
          Expanded(
            child: groupsAsync.when(
              data: (groups) {
                if (groups.isEmpty) {
                  return _EmptyCommunityState(onSync: () => _syncNow(context, ref));
                }

                return RefreshIndicator(
                  onRefresh: () async => _syncNow(context, ref),
                  child: ListView.separated(
                    padding: const EdgeInsets.all(24),
                    itemCount: groups.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      final group = groups[index];
                      return _GroupCard(
                        group: group,
                        onSync: () => _syncNow(context, ref),
                      );
                    },
                  ),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => _ErrorCommunityState(
                message: '$error',
                onRetry: () => _syncNow(context, ref),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _syncNow(BuildContext context, WidgetRef ref) async {
    await _performSync(context, ref);
  }
}

class _EmptyCommunityState extends StatelessWidget {
  const _EmptyCommunityState({required this.onSync});

  final Future<void> Function() onSync;

  @override
  Widget build(BuildContext context) {
    return EmptyState(
      icon: Icons.groups_outlined,
      title: 'Sincroniza tus grupos',
      message:
          'Conecta con Supabase para traer tus comunidades, miembros y libros compartidos.',
      action: EmptyStateAction(
        label: 'Sincronizar ahora',
        icon: Icons.sync_outlined,
        onPressed: () => unawaited(onSync()),
      ),
    );
  }
}

class _ErrorCommunityState extends StatelessWidget {
  const _ErrorCommunityState({required this.message, required this.onRetry});

  final String message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 64, color: theme.colorScheme.error),
            const SizedBox(height: 12),
            Text(
              'No pudimos cargar tus grupos.',
              style: theme.textTheme.titleLarge?.copyWith(color: theme.colorScheme.error),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar sincronización'),
            ),
          ],
        ),
      ),
    );
  }
}

class _GroupCard extends ConsumerStatefulWidget {
  const _GroupCard({required this.group, required this.onSync});

  final Group group;
  final Future<void> Function() onSync;

  @override
  ConsumerState<_GroupCard> createState() => _GroupCardState();
}

class _GroupCardState extends ConsumerState<_GroupCard> {
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

    final menuEntries = <PopupMenuEntry<_GroupMenuAction>>[];
    if (activeUser != null && isAdmin) {
      menuEntries
        ..add(
          const PopupMenuItem<_GroupMenuAction>(
            value: _GroupMenuAction.edit,
            child: Text('Editar grupo'),
          ),
        )
        ..add(
          const PopupMenuItem<_GroupMenuAction>(
            value: _GroupMenuAction.manageMembers,
            child: Text('Gestionar miembros'),
          ),
        )
        ..add(
          const PopupMenuItem<_GroupMenuAction>(
            value: _GroupMenuAction.manageInvitations,
            child: Text('Gestionar invitaciones'),
          ),
        );
    }
    if (activeUser != null && isOwner) {
      if (menuEntries.isNotEmpty) {
        menuEntries.add(const PopupMenuDivider());
      }
      menuEntries
        ..add(
          const PopupMenuItem<_GroupMenuAction>(
            value: _GroupMenuAction.transferOwnership,
            child: Text('Transferir propiedad'),
          ),
        )
        ..add(
          const PopupMenuItem<_GroupMenuAction>(
            value: _GroupMenuAction.delete,
            child: Text('Eliminar grupo'),
          ),
        );
    }

    if (activeUser != null && !isOwner) {
      if (menuEntries.isNotEmpty) {
        menuEntries.add(const PopupMenuDivider());
      }
      menuEntries.add(
        const PopupMenuItem<_GroupMenuAction>(
          value: _GroupMenuAction.leaveGroup,
          child: Text('Salir del grupo'),
        ),
      );
    }

    final bool highlightManageInvitations = activeUser != null && isAdmin;

    Widget? menuButton;
    if (menuEntries.isNotEmpty) {
      final popup = PopupMenuButton<_GroupMenuAction>(
        icon: const Icon(Icons.more_vert),
        tooltip: 'Acciones del grupo',
        enabled: !isGroupBusy,
        itemBuilder: (context) => menuEntries,
        onSelected: (action) {
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
            Wrap(
              spacing: 16,
              runSpacing: 8,
              children: [
                _AsyncCountChip(
                  icon: Icons.people_outline,
                  label: 'Miembros',
                  value: membersAsync,
                ),
                _AsyncCountChip(
                  icon: Icons.menu_book_outlined,
                  label: 'Libros compartidos',
                  value: sharedBooksAsync,
                ),
                _AsyncCountChip(
                  icon: Icons.swap_horiz_outlined,
                  label: 'Préstamos',
                  value: loansAsync,
                ),
                _AsyncCountChip(
                  icon: Icons.qr_code_2_outlined,
                  label: 'Invitaciones',
                  value: invitationsAsync,
                ),
              ],
            ),
            const SizedBox(height: 16),
            _SharedBooksSection(sharedBooksAsync: sharedBooksAsync),
            const SizedBox(height: 12),
            _LoansSection(
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

class _AsyncCountChip<T> extends StatelessWidget {
  const _AsyncCountChip({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final AsyncValue<List<T>> value;

  @override
  Widget build(BuildContext context) {
    return value.when(
      data: (items) => Chip(
        avatar: Icon(icon, size: 18),
        label: Text('$label: ${items.length}'),
      ),
      loading: () => const Chip(
        avatar: SizedBox(
          width: 16,
          height: 16,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
        label: Text('Cargando...'),
      ),
      error: (error, _) => Chip(
        avatar: const Icon(Icons.error_outline, size: 18),
        label: Text('Error $label'),
      ),
    );
  }
}

class _SharedBooksSection extends StatelessWidget {
  const _SharedBooksSection({required this.sharedBooksAsync});

  final AsyncValue<List<SharedBookDetail>> sharedBooksAsync;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return sharedBooksAsync.when(
      data: (books) {
        if (books.isEmpty) {
          return Text('No hay libros compartidos todavía.',
              style: theme.textTheme.bodyMedium);
        }
        
        final totalBooks = books.length;
        final availableBooks = books.where((b) => b.sharedBook.isAvailable).length;
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Estadísticas de libros', style: theme.textTheme.titleSmall),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    icon: Icons.menu_book_outlined,
                    label: 'Total',
                    value: '$totalBooks',
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    icon: Icons.check_circle_outline,
                    label: 'Disponibles',
                    value: '$availableBooks',
                    color: Colors.green,
                  ),
                ),
              ],
            ),
          ],
        );
      },
      loading: () => const Padding(
        padding: EdgeInsets.symmetric(vertical: 8),
        child: LinearProgressIndicator(),
      ),
      error: (error, _) => Text('Error cargando libros compartidos: $error',
          style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.error)),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _LoansSection extends StatelessWidget {
  const _LoansSection({
    required this.loansAsync,
    required this.activeUser,
    required this.loanController,
    required this.loanState,
    required this.onFeedback,
  });

  final AsyncValue<List<LoanDetail>> loansAsync;
  final LocalUser? activeUser;
  final LoanController loanController;
  final LoanActionState loanState;
  final void Function(String message, bool isError) onFeedback;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
return loansAsync.when(
      data: (loans) {
        // Filter to show only loans where user is involved
        final userLoans = loans.where((detail) {
          final loan = detail.loan;
          return loan.borrowerUserId == activeUser?.id || 
                 loan.lenderUserId == activeUser?.id;
        }).toList();
        
        if (userLoans.isEmpty) {
          return Text('No tienes préstamos activos en este grupo.',
              style: theme.textTheme.bodyMedium);
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Tus préstamos', style: theme.textTheme.titleSmall),
            const SizedBox(height: 8),
            ...userLoans.map((detail) {
              final loan = detail.loan;
              final bookTitle = detail.book?.title ?? 'Libro';
              final status = loan.status;
              final start = DateFormat.yMd().format(loan.requestedAt);
              final due = loan.dueDate != null
                  ? DateFormat.yMd().format(loan.dueDate!)
                  : 'Sin fecha límite';
              final isBorrower = activeUser != null && loan.borrowerUserId == activeUser!.id;
              final isOwner = activeUser != null && loan.lenderUserId == activeUser!.id;
              final isManualLoan = loan.externalBorrowerName != null;

              return Card(
                margin: EdgeInsets.zero,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.swap_horiz_outlined),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              '$bookTitle · ${status.toUpperCase()}',
                              style: theme.textTheme.titleSmall,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text('Inicio: $start · Vence: $due',
                          style: theme.textTheme.bodySmall),
                      if (detail.borrower != null || detail.owner != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          'Solicitante: ${loan.externalBorrowerName ?? _resolveUserName(detail.borrower)} · '
                          'Propietario: ${_resolveUserName(detail.owner)}',
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          if (isBorrower && loan.status == 'pending')
                            OutlinedButton.icon(
                              onPressed: loanState.isLoading
                                  ? null
                                  : () => _cancelLoan(context, detail),
                              icon: const Icon(Icons.cancel_outlined),
                              label: const Text('Cancelar solicitud'),
                            ),
                          if (isOwner && loan.status == 'pending') ...[
                            FilledButton.icon(
                              onPressed: loanState.isLoading
                                  ? null
                                  : () => _acceptLoan(context, detail),
                              icon: const Icon(Icons.check_circle_outlined),
                              label: const Text('Aceptar'),
                            ),
                            OutlinedButton.icon(
                              onPressed: loanState.isLoading
                                  ? null
                                  : () => _rejectLoan(context, detail),
                              icon: const Icon(Icons.cancel_schedule_send_outlined),
                              label: const Text('Rechazar'),
                            ),
                          ],
                          if (((isOwner || isBorrower) && !isManualLoan || (isOwner && isManualLoan)) && loan.status == 'active') ...[
                            FilledButton.icon(
                              onPressed: loanState.isLoading
                                  ? null
                                  : () => _markReturned(context, detail),
                              icon: const Icon(Icons.assignment_turned_in_outlined),
                              label: const Text('Marcar devuelto'),
                            ),
                          ],
                          if (detail.sharedBook != null &&
                              detail.sharedBook!.ownerUserId != activeUser?.id &&
                              detail.sharedBook!.isAvailable &&
                              loan.status == 'pending')
                            FilledButton.icon(
                              onPressed: loanState.isLoading
                                  ? null
                                  : () => _requestLoan(context, detail),
                              icon: const Icon(Icons.handshake_outlined),
                              label: const Text('Solicitar préstamo'),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }),
          ],
        );
      },
      loading: () => const Padding(
        padding: EdgeInsets.symmetric(vertical: 8),
        child: LinearProgressIndicator(),
      ),
      error: (error, _) => Text('Error cargando préstamos: $error',
          style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.error)),
    );
  }

  Future<void> _cancelLoan(BuildContext context, LoanDetail detail) async {
    final borrower = detail.borrower;
    if (borrower == null) {
      onFeedback('No pudimos identificar al solicitante.', true);
      return;
    }

    try {
      await loanController.cancelLoan(loan: detail.loan, borrower: borrower);
      if (!context.mounted) return;
      onFeedback('Solicitud cancelada.', false);
    } catch (error) {
      if (!context.mounted) return;
      onFeedback('No se pudo cancelar la solicitud: $error', true);
    }
  }

  Future<void> _acceptLoan(BuildContext context, LoanDetail detail) async {
    final owner = detail.owner;
    if (owner == null) {
      onFeedback('No pudimos identificar al propietario.', true);
      return;
    }

    try {
      await loanController.acceptLoan(loan: detail.loan, owner: owner);
      if (!context.mounted) return;
      onFeedback('Préstamo aceptado.', false);
    } catch (error) {
      if (!context.mounted) return;
      onFeedback('No se pudo aceptar el préstamo: $error', true);
    }
  }

  Future<void> _rejectLoan(BuildContext context, LoanDetail detail) async {
    final owner = detail.owner;
    if (owner == null) {
      onFeedback('No pudimos identificar al propietario.', true);
      return;
    }

    try {
      await loanController.rejectLoan(loan: detail.loan, owner: owner);
      if (!context.mounted) return;
      onFeedback('Solicitud rechazada.', false);
    } catch (error) {
      if (!context.mounted) return;
      onFeedback('No se pudo rechazar la solicitud: $error', true);
    }
  }

  Future<void> _markReturned(BuildContext context, LoanDetail detail) async {
    final actor = activeUser;
    if (actor == null) {
      onFeedback('No pudimos identificar al usuario activo.', true);
      return;
    }

    try {
      await loanController.markReturned(loan: detail.loan, actor: actor);
      if (!context.mounted) return;
      onFeedback('Préstamo marcado como devuelto.', false);
    } catch (error) {
      if (!context.mounted) return;
      onFeedback('No se pudo marcar como devuelto: $error', true);
    }
  }

  Future<void> _requestLoan(BuildContext context, LoanDetail detail) async {
    final sharedBook = detail.sharedBook;
    final borrower = activeUser;
    if (sharedBook == null || borrower == null) {
      onFeedback('No pudimos preparar la solicitud para este libro.', true);
      return;
    }

    try {
      await loanController.requestLoan(sharedBook: sharedBook, borrower: borrower);
      if (!context.mounted) return;
      onFeedback('Solicitud enviada.', false);
    } catch (error) {
      if (!context.mounted) return;
      onFeedback('No se pudo enviar la solicitud: $error', true);
    }
  }
}

enum _GroupMenuAction {
  edit,
  transferOwnership,
  manageMembers,
  manageInvitations,
  delete,
  leaveGroup,
}

enum _MemberAction {
  promoteToAdmin,
  demoteToMember,
  remove,
}

const _kRoleAdmin = 'admin';
const _kRoleMember = 'member';
const _kInvitationStatusPending = 'pending';

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
  required _GroupMenuAction action,
  required Group group,
}) async {
  switch (action) {
    case _GroupMenuAction.edit:
      await _handleEditGroup(context, ref, group);
      break;
    case _GroupMenuAction.transferOwnership:
      await _handleTransferOwnership(context, ref, group);
      break;
    case _GroupMenuAction.manageMembers:
      await _showManageMembersSheet(context, ref, group: group);
      break;
    case _GroupMenuAction.manageInvitations:
      await _showInvitationsSheet(context, ref, group: group);
      break;
    case _GroupMenuAction.delete:
      await _handleDeleteGroup(context, ref, group);
      break;
    case _GroupMenuAction.leaveGroup:
      await _handleLeaveGroup(context, ref, group);
      break;
  }
}

Future<void> _handleCreateGroup(
  BuildContext context,
  WidgetRef ref,
  LocalUser owner,
) async {
  final result = await _showGroupFormDialog(context);
  if (result == null) {
    return;
  }

  final controller = ref.read(groupPushControllerProvider.notifier);
  try {
    await controller.createGroup(
      name: result.name,
      description: result.description,
      owner: owner,
    );
  } catch (error) {
    if (!context.mounted) {
      return;
    }
    _showFeedbackSnackBar(
      context: context,
      message: 'No se pudo crear el grupo: $error',
      isError: true,
    );
  }
}

Future<void> _handleJoinGroupByCode(
  BuildContext context,
  WidgetRef ref,
  LocalUser user,
) async {
  final code = await _showJoinGroupByCodeDialog(context);
  if (code == null) {
    return;
  }

  final controller = ref.read(groupPushControllerProvider.notifier);
  try {
    await controller.acceptInvitationByCode(
      code: code,
      user: user,
    );
  } catch (error) {
    if (!context.mounted) {
      return;
    }
    _showFeedbackSnackBar(
      context: context,
      message: error.toString(),
      isError: true,
    );
  }
}

String _resolveUserName(LocalUser? user) {
  if (user == null) {
    return 'Usuario desconocido';
  }
  final username = user.username.trim();
  return username.isEmpty ? 'Usuario desconocido' : username;
}

Future<void> _performSync(BuildContext context, WidgetRef ref) async {
  final controller = ref.read(groupSyncControllerProvider.notifier);
  await controller.syncGroups();
  if (!context.mounted) return;

  final state = ref.read(groupSyncControllerProvider);
  if (state.lastError != null) {
    _showFeedbackSnackBar(
      context: context,
      message: 'Error de sincronización: ${state.lastError}',
      isError: true,
    );
    return;
  }

  _showFeedbackSnackBar(
    context: context,
    message: 'Sincronización completada.',
    isError: false,
  );
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

Future<void> _handleEditGroup(
  BuildContext context,
  WidgetRef ref,
  Group group,
) async {
  final result = await _showGroupFormDialog(context);

  if (result == null) {
    return;
  }

  final controller = ref.read(groupPushControllerProvider.notifier);
  try {
    await controller.updateGroup(
      group: group,
      name: result.name,
      description: result.description,
    );
  } catch (error) {
    if (!context.mounted) return;
    _showFeedbackSnackBar(
      context: context,
      message: error.toString(),
      isError: true,
    );
  }
}

Future<void> _handleTransferOwnership(
  BuildContext context,
  WidgetRef ref,
  Group group,
) async {
  final members = await ref.read(groupMemberDetailsProvider(group.id).future);
  if (!context.mounted) {
    return;
  }
  final candidates = members
      .where((detail) => detail.user != null && detail.user!.id != group.ownerUserId)
      .toList();

  if (candidates.isEmpty) {
    if (!context.mounted) return;
    _showFeedbackSnackBar(
      context: context,
      message: 'No hay otros miembros disponibles para transferir la propiedad.',
      isError: true,
    );
    return;
  }

  final selected = await showDialog<GroupMemberDetail>(
    context: context,
    builder: (dialogContext) {
      return SimpleDialog(
        title: const Text('Transferir propiedad'),
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 4),
            child: Text('Selecciona a la persona que será la nueva propietaria.'),
          ),
          for (final detail in candidates)
            SimpleDialogOption(
              onPressed: () => Navigator.of(dialogContext).pop(detail),
              child: Text(detail.user?.username ?? 'Miembro'),
            ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancelar'),
          ),
        ],
      );
    },
  );

  if (!context.mounted) {
    return;
  }

  if (selected == null) {
    return;
  }

  final newOwner = selected.user;
  if (newOwner == null) {
    return;
  }

  final controller = ref.read(groupPushControllerProvider.notifier);
  try {
    await controller.transferOwnership(group: group, newOwner: newOwner);
  } catch (error) {
    if (!context.mounted) return;
    _showFeedbackSnackBar(
      context: context,
      message: error.toString(),
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
    builder: (dialogContext) {
      return AlertDialog(
        title: const Text('Eliminar grupo'),
        content: Text(
          '¿Seguro que deseas eliminar "${group.name}"? Esta acción solo afecta a la copia local y marcará el grupo para eliminación remota.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(dialogContext).colorScheme.error,
            ),
            child: const Text('Eliminar'),
          ),
        ],
      );
    },
  );

  if (confirmed != true) {
    return;
  }

  final controller = ref.read(groupPushControllerProvider.notifier);
  try {
    await controller.deleteGroup(group: group);
  } catch (error) {
    if (!context.mounted) return;
    _showFeedbackSnackBar(
      context: context,
      message: error.toString(),
      isError: true,
    );
  }
}

Future<void> _handleLeaveGroup(BuildContext context, WidgetRef ref, Group group) async {
  final confirm = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: const Text('Salir del grupo'),
      content: const Text('¿Estás seguro de que quieres salir de este grupo?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(false),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(dialogContext).pop(true),
          child: const Text('Salir'),
        ),
      ],
    ),
  );

  if (confirm != true) return;

  final controller = ref.read(groupPushControllerProvider.notifier);
  final activeUser = ref.read(activeUserProvider).value;
  if (activeUser == null) return;

  final members = await ref.read(groupMemberDetailsProvider(group.id).future);
  final memberDetail = _findMemberDetail(members, activeUser.id);

  if (memberDetail == null) {
    if (!context.mounted) return;
    _showFeedbackSnackBar(
      context: context,
      message: 'No eres miembro de este grupo',
      isError: true,
    );
    return;
  }

  try {
    await controller.removeMember(member: memberDetail.membership);
    if (!context.mounted) return;
    _showFeedbackSnackBar(
      context: context,
      message: 'Has salido del grupo',
      isError: false,
    );
  } catch (error) {
    if (!context.mounted) return;
    _showFeedbackSnackBar(
      context: context,
      message: error.toString(),
      isError: true,
    );
  }
}

Future<void> _showManageMembersSheet(
  BuildContext context,
  WidgetRef ref, {
  required Group group,
}) async {
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (sheetContext) {
      final bottomInset = MediaQuery.of(sheetContext).viewInsets.bottom;
      return Padding(
        padding: EdgeInsets.only(bottom: bottomInset),
        child: Consumer(
          builder: (context, sheetRef, _) {
            final membersAsync = sheetRef.watch(groupMemberDetailsProvider(group.id));
            final actionState = sheetRef.watch(groupPushControllerProvider);
            final activeUser = sheetRef.watch(activeUserProvider).value;
            final isBusy = actionState.isLoading;

            return SafeArea(
              child: FractionallySizedBox(
                heightFactor: 0.85,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
                      child: Row(
                        children: [
                          const Expanded(
                            child: Text(
                              'Gestionar miembros',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                            ),
                          ),
                          IconButton(
                            onPressed: () => Navigator.of(sheetContext).pop(),
                            icon: const Icon(Icons.close),
                            tooltip: 'Cerrar',
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Text(
                        'Promueve, degrada o elimina miembros del grupo. Añade nuevos miembros sincronizados localmente.',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Row(
                        children: [
                          FilledButton.icon(
                            onPressed: isBusy
                                ? null
                                : () => _handleAddMember(sheetContext, sheetRef, group),
                            icon: const Icon(Icons.person_add_alt_1_outlined),
                            label: const Text('Añadir miembro'),
                          ),
                          const SizedBox(width: 12),
                          if (isBusy)
                            const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: membersAsync.when(
                        data: (members) {
                          if (members.isEmpty) {
                            return const Center(
                              child: Text('No hay miembros registrados.'),
                            );
                          }

                          return ListView.separated(
                            padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                            itemCount: members.length,
                            separatorBuilder: (_, __) => const Divider(),
                            itemBuilder: (context, index) {
                              final detail = members[index];
                              final user = detail.user;
                              final membership = detail.membership;
                              final isOwner = group.ownerUserId != null &&
                                  membership.memberUserId == group.ownerUserId;
                              final isAdmin = membership.role == _kRoleAdmin;
                              final displayName = user?.username ?? 'Usuario';
                              final roleLabel = isOwner
                                  ? 'Propietario'
                                  : isAdmin
                                      ? 'Admin'
                                      : 'Miembro';
                              final canEdit = !isOwner && activeUser != null;

                              return ListTile(
                                leading: CircleAvatar(
                                  child: Text(displayName.characters.first.toUpperCase()),
                                ),
                                title: Text(displayName),
                                subtitle: Text('Rol: $roleLabel'),
                                trailing: canEdit
                                    ? PopupMenuButton<_MemberAction>(
                                        onSelected: (action) => unawaited(
                                          _handleMemberAction(
                                            context: sheetContext,
                                            ref: sheetRef,
                                            detail: detail,
                                            action: action,
                                          ),
                                        ),
                                        enabled: !isBusy,
                                        itemBuilder: (context) {
                                          final entries = <PopupMenuEntry<_MemberAction>>[];
                                          if (!isAdmin) {
                                            entries.add(
                                              const PopupMenuItem<_MemberAction>(
                                                value: _MemberAction.promoteToAdmin,
                                                child: Text('Promover a admin'),
                                              ),
                                            );
                                          } else {
                                            entries.add(
                                              const PopupMenuItem<_MemberAction>(
                                                value: _MemberAction.demoteToMember,
                                                child: Text('Degradar a miembro'),
                                              ),
                                            );
                                          }
                                          entries.add(
                                            const PopupMenuItem<_MemberAction>(
                                              value: _MemberAction.remove,
                                              child: Text('Eliminar del grupo'),
                                            ),
                                          );
                                          return entries;
                                        },
                                        icon: const Icon(Icons.more_vert),
                                      )
                                    : null,
                              );
                            },
                          );
                        },
                        loading: () => const Center(child: CircularProgressIndicator()),
                        error: (error, _) => Center(
                          child: Text('Error al cargar miembros: $error'),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      );
    },
  );
}

Future<void> _handleAddMember(BuildContext context, WidgetRef ref, Group group) async {
  final members = await ref.read(groupMemberDetailsProvider(group.id).future);
  if (!context.mounted) {
    return;
  }
  final existingIds = members
      .map((detail) => detail.user?.id)
      .whereType<int>()
      .toSet();

  final users = await ref.read(userRepositoryProvider).getActiveUsers();
  if (!context.mounted) {
    return;
  }
  final candidates = users.where((user) => !existingIds.contains(user.id)).toList();

  if (candidates.isEmpty) {
    if (!context.mounted) return;
    _showFeedbackSnackBar(
      context: context,
      message: 'No hay usuarios locales disponibles para añadir.',
      isError: true,
    );
    return;
  }

  final result = await _showAddMemberDialog(context, candidates);
  if (!context.mounted) {
    return;
  }
  if (result == null) {
    return;
  }

  final controller = ref.read(groupPushControllerProvider.notifier);
  try {
    await controller.addMember(
      group: group,
      user: result.user,
      role: result.role,
    );
  } catch (error) {
    if (!context.mounted) return;
    _showFeedbackSnackBar(
      context: context,
      message: error.toString(),
      isError: true,
    );
  }
}

Future<_AddMemberResult?> _showAddMemberDialog(
  BuildContext context,
  List<LocalUser> candidates,
) async {
  final formKey = GlobalKey<FormState>();
  LocalUser? selectedUser = candidates.isNotEmpty ? candidates.first : null;
  String selectedRole = _kRoleMember;

  return showDialog<_AddMemberResult>(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) {
      return AlertDialog(
        title: const Text('Añadir miembro'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DropdownButtonFormField<LocalUser>(
                initialValue: selectedUser,
                items: candidates
                    .map(
                      (user) => DropdownMenuItem<LocalUser>(
                        value: user,
                        child: Text(user.username),
                      ),
                    )
                    .toList(),
                onChanged: (value) => selectedUser = value,
                decoration: const InputDecoration(
                  labelText: 'Usuario',
                ),
                validator: (value) => value == null ? 'Selecciona un usuario.' : null,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: selectedRole,
                items: const [
                  DropdownMenuItem(
                    value: _kRoleMember,
                    child: Text('Miembro'),
                  ),
                  DropdownMenuItem(
                    value: _kRoleAdmin,
                    child: Text('Admin'),
                  ),
                ],
                onChanged: (value) {
                  if (value != null) {
                    selectedRole = value;
                  }
                },
                decoration: const InputDecoration(labelText: 'Rol'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              if (!(formKey.currentState?.validate() ?? false)) {
                return;
              }
              Navigator.of(dialogContext).pop(
                _AddMemberResult(user: selectedUser!, role: selectedRole),
              );
            },
            child: const Text('Añadir'),
          ),
        ],
      );
    },
  );
}

Future<void> _handleMemberAction({
  required BuildContext context,
  required WidgetRef ref,
  required GroupMemberDetail detail,
  required _MemberAction action,
}) async {
  final controller = ref.read(groupPushControllerProvider.notifier);

  try {
    switch (action) {
      case _MemberAction.promoteToAdmin:
        await controller.updateMemberRole(
          member: detail.membership,
          role: _kRoleAdmin,
        );
        break;
      case _MemberAction.demoteToMember:
        await controller.updateMemberRole(
          member: detail.membership,
          role: _kRoleMember,
        );
        break;
      case _MemberAction.remove:
        await controller.removeMember(member: detail.membership);
        break;
    }
  } catch (error) {
    if (!context.mounted) return;
    _showFeedbackSnackBar(
      context: context,
      message: error.toString(),
      isError: true,
    );
  }
}

Future<void> _showInvitationsSheet(
  BuildContext context,
  WidgetRef ref, {
  required Group group,
}) async {
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (sheetContext) {
      final mediaQuery = MediaQuery.of(sheetContext);
      final bottomInset = mediaQuery.viewInsets.bottom;
      return Padding(
        padding: EdgeInsets.only(bottom: bottomInset),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isCompactWidth = constraints.maxWidth < 420;
            final heightFactor = constraints.maxHeight < 560 ? 0.95 : 0.85;
            final horizontalPadding = constraints.maxWidth >= 720
                ? 32.0
                : constraints.maxWidth >= 480
                    ? 24.0
                    : 16.0;

            return Consumer(
              builder: (context, sheetRef, _) {
                final invitationsAsync = sheetRef.watch(groupInvitationDetailsProvider(group.id));
                final activeUser = sheetRef.watch(activeUserProvider).value;
                final actionState = sheetRef.watch(groupPushControllerProvider);
                final isBusy = actionState.isLoading;

                return SafeArea(
                  child: FractionallySizedBox(
                    heightFactor: heightFactor,
                    widthFactor: 1,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Padding(
                          padding: EdgeInsets.fromLTRB(horizontalPadding, 16, horizontalPadding, 8),
                          child: Row(
                            children: [
                              const Expanded(
                                child: Text(
                                  'Invitaciones del grupo',
                                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                                ),
                              ),
                              IconButton(
                                onPressed: () => Navigator.of(sheetContext).pop(),
                                icon: const Icon(Icons.close),
                                tooltip: 'Cerrar',
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                          child: Wrap(
                            spacing: 12,
                            runSpacing: 12,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              FilledButton.icon(
                                onPressed: isBusy || activeUser == null
                                    ? null
                                    : () => _handleCreateInvitation(
                                          sheetContext,
                                          sheetRef,
                                          group: group,
                                          inviter: activeUser,
                                        ),
                                icon: const Icon(Icons.qr_code_2_outlined),
                                label: const Text('Nueva invitación'),
                              ),
                              if (isBusy)
                                const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        Expanded(
                          child: invitationsAsync.when(
                            data: (invitations) {
                              if (invitations.isEmpty) {
                                return const Center(
                                  child: Text('Aún no se han generado invitaciones.'),
                                );
                              }

                              return ListView.separated(
                                padding: EdgeInsets.fromLTRB(
                                  horizontalPadding,
                                  0,
                                  horizontalPadding,
                                  24 + mediaQuery.padding.bottom,
                                ),
                                itemCount: invitations.length,
                                separatorBuilder: (_, __) => const Divider(),
                                itemBuilder: (context, index) {
                                  final detail = invitations[index];
                                  final invitation = detail.invitation;
                                  final status = invitation.status;
                                  final expiresAt =
                                      DateFormat.yMd().add_Hm().format(invitation.expiresAt);
                                  final code = invitation.code;
                                  final canCancel = status == _kInvitationStatusPending && !isBusy;

                                  final actionButtons = <Widget>[
                                    IconButton(
                                      tooltip: 'Copiar código',
                                      onPressed: () => _copyToClipboard(sheetContext, code),
                                      icon: const Icon(Icons.copy_outlined),
                                      visualDensity: VisualDensity.compact,
                                    ),
                                    IconButton(
                                      tooltip: 'Mostrar QR',
                                      onPressed: () => _showInvitationQrDialog(sheetContext, code),
                                      icon: const Icon(Icons.fullscreen),
                                      visualDensity: VisualDensity.compact,
                                    ),
                                    IconButton(
                                      tooltip: 'Compartir código',
                                      onPressed: () => _shareInvitationCode(
                                        context: sheetContext,
                                        group: group,
                                        invitation: invitation,
                                      ),
                                      icon: const Icon(Icons.share_outlined),
                                      visualDensity: VisualDensity.compact,
                                    ),
                                  ];

                                  if (canCancel) {
                                    actionButtons.add(
                                      TextButton.icon(
                                        onPressed: () => _handleCancelInvitation(
                                          sheetContext,
                                          sheetRef,
                                          invitation: invitation,
                                        ),
                                        icon: const Icon(Icons.cancel_outlined, size: 20),
                                        label: const Text('Cancelar'),
                                        style: TextButton.styleFrom(
                                          visualDensity: VisualDensity.compact,
                                          padding: const EdgeInsets.symmetric(horizontal: 12),
                                        ),
                                      ),
                                    );
                                  }

                                  final maxActionsWidth = isCompactWidth
                                      ? constraints.maxWidth * 0.55
                                      : 200.0;

                                  return ListTile(
                                    leading: const Icon(Icons.qr_code_2_outlined),
                                    title: Text('Código: $code'),
                                    subtitle: Text(
                                      'Rol: ${invitation.role} · Estado: $status · Expira: $expiresAt',
                                    ),
                                    contentPadding: EdgeInsets.zero,
                                    isThreeLine: true,
                                    trailing: ConstrainedBox(
                                      constraints: BoxConstraints(maxWidth: maxActionsWidth),
                                      child: Align(
                                        alignment: Alignment.centerRight,
                                        child: Wrap(
                                          alignment: WrapAlignment.end,
                                          spacing: 4,
                                          runSpacing: 4,
                                          children: actionButtons,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                            loading: () => const Center(child: CircularProgressIndicator()),
                            error: (error, _) => Center(
                              child: Text('Error al cargar invitaciones: $error'),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      );
    },
  );
}

Future<void> _handleCreateInvitation(
  BuildContext context,
  WidgetRef ref, {
  required Group group,
  required LocalUser inviter,
}) async {
  final result = await _showInvitationFormDialog(context);
  if (result == null) {
    return;
  }

  final controller = ref.read(groupPushControllerProvider.notifier);
  try {
    await controller.createInvitation(
      group: group,
      inviter: inviter,
      role: result.role,
      expiresAt: result.expiresAt,
    );
  } catch (error) {
    if (!context.mounted) return;
    _showFeedbackSnackBar(
      context: context,
      message: error.toString(),
      isError: true,
    );
  }
}

Future<_InvitationFormResult?> _showInvitationFormDialog(BuildContext context) async {
  final formKey = GlobalKey<FormState>();
  String role = _kRoleMember;
  final durationOptions = <Duration, String>{
    const Duration(days: 1): '1 día',
    const Duration(days: 7): '7 días',
    const Duration(days: 30): '30 días',
  };
  Duration selectedDuration = const Duration(days: 7);

  return showDialog<_InvitationFormResult>(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) {
      return AlertDialog(
        title: const Text('Crear invitación'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                initialValue: role,
                items: const [
                  DropdownMenuItem(
                    value: _kRoleMember,
                    child: Text('Miembro'),
                  ),
                  DropdownMenuItem(
                    value: _kRoleAdmin,
                    child: Text('Admin'),
                  ),
                ],
                onChanged: (value) {
                  if (value != null) {
                    role = value;
                  }
                },
                decoration: const InputDecoration(labelText: 'Rol asignado'),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<Duration>(
                initialValue: selectedDuration,
                items: durationOptions.entries
                    .map(
                      (entry) => DropdownMenuItem<Duration>(
                        value: entry.key,
                        child: Text('Expira en ${entry.value}'),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    selectedDuration = value;
                  }
                },
                decoration: const InputDecoration(labelText: 'Duración'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              if (!(formKey.currentState?.validate() ?? false)) {
                return;
              }
              Navigator.of(dialogContext).pop(
                _InvitationFormResult(
                  role: role,
                  expiresAt: DateTime.now().add(selectedDuration),
                ),
              );
            },
            child: const Text('Crear'),
          ),
        ],
      );
    },
  );
}

Future<void> _handleCancelInvitation(
  BuildContext context,
  WidgetRef ref, {
  required GroupInvitation invitation,
}) async {
  final controller = ref.read(groupPushControllerProvider.notifier);
  try {
    await controller.cancelInvitation(invitation: invitation);
  } catch (error) {
    if (!context.mounted) return;
    _showFeedbackSnackBar(
      context: context,
      message: error.toString(),
      isError: true,
    );
  }
}

Future<void> _showInvitationQrDialog(BuildContext context, String code) {
  final data = 'group-invite://$code';
  return showDialog<void>(
    context: context,
    useRootNavigator: true,
    builder: (dialogContext) {
      return AlertDialog(
        title: const Text('Código QR de invitación'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            QrImageView(
              data: data,
              size: 220,
              backgroundColor: Colors.white,
            ),
            const SizedBox(height: 12),
            Text(
              code,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'Escanea este código o comparte el código alfanumérico para unirse al grupo.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => _copyToClipboard(dialogContext, code),
            child: const Text('Copiar código'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cerrar'),
          ),
        ],
      );
    },
  );
}

void _copyToClipboard(BuildContext context, String value) {
  Clipboard.setData(ClipboardData(text: value));
  _showFeedbackSnackBar(
    context: context,
    message: 'Código copiado al portapapeles.',
    isError: false,
  );
}

Future<void> _shareInvitationCode({
  required BuildContext context,
  required Group group,
  required GroupInvitation invitation,
}) async {
  final subject = 'Únete al grupo "${group.name}"';
  final message =
      'Hola, te invito a unirte al grupo "${group.name}" en Book Sharing. Usa el código ${invitation.code} o escanea el QR para entrar.';

  await Share.share(
    message,
    subject: subject,
  );
}

Future<GroupFormResult?> _showGroupFormDialog(BuildContext context) {
  return showDialog<GroupFormResult>(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) => const GroupFormDialog(),
  );
}

Future<String?> _showJoinGroupByCodeDialog(BuildContext context) {
  return showDialog<String>(
    context: context,
    barrierDismissible: false,
    useRootNavigator: true,
    builder: (_) => const _JoinGroupByCodeDialog(),
  );
}

class _JoinGroupByCodeDialog extends StatefulWidget {
  const _JoinGroupByCodeDialog();

  @override
  State<_JoinGroupByCodeDialog> createState() => _JoinGroupByCodeDialogState();
}

class _JoinGroupByCodeDialogState extends State<_JoinGroupByCodeDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _codeController;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _codeController = TextEditingController();
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_isSubmitting || !(_formKey.currentState?.validate() ?? false)) {
      return;
    }
    setState(() => _isSubmitting = true);
    FocusScope.of(context).unfocus();
    final trimmedCode = _codeController.text.trim();
    Navigator.of(context, rootNavigator: true).pop(trimmedCode);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Unirse por código'),
      content: Form(
        key: _formKey,
        child: TextFormField(
          controller: _codeController,
          decoration: const InputDecoration(
            labelText: 'Código de invitación',
            hintText: 'Ej. 123e4567-e89b-12d3-a456-426614174000',
          ),
          autofocus: true,
          textInputAction: TextInputAction.done,
          onFieldSubmitted: (_) => _submit(),
          validator: (value) {
            final trimmed = value?.trim() ?? '';
            if (trimmed.isEmpty) {
              return 'Introduce un código válido.';
            }
            if (trimmed.length < 6) {
              return 'El código es demasiado corto.';
            }
            return null;
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSubmitting
              ? null
              : () => Navigator.of(context, rootNavigator: true).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: _isSubmitting ? null : _submit,
          child: _isSubmitting
              ? const SizedBox(
                  height: 16,
                  width: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Unirse'),
        ),
      ],
    );
  }
}

class _AddMemberResult {
  const _AddMemberResult({required this.user, required this.role});

  final LocalUser user;
  final String role;
}

class _InvitationFormResult {
  const _InvitationFormResult({required this.role, required this.expiresAt});

  final String role;
  final DateTime expiresAt;
}