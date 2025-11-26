import 'dart:async';


import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../data/local/database.dart';
import '../../../data/local/group_dao.dart';
import '../../../data/models/in_app_notification_status.dart';
import '../../../data/models/in_app_notification_type.dart';
import '../../../providers/auth_providers.dart';
import '../../../providers/book_providers.dart';
import '../../../providers/notification_providers.dart';
import '../../../services/coach_marks/coach_mark_controller.dart';
import '../../../services/coach_marks/coach_mark_models.dart';
import '../../../services/loan_controller.dart';
import '../../../services/notification_service.dart';
import '../../../services/onboarding_service.dart';
import '../../widgets/coach_mark_target.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/loan_feedback_banner.dart';
import '../../widgets/sync_banner.dart';
import '../../../ui/utils/ui_helpers.dart';
import '../auth/pin_setup_screen.dart';
import 'tabs/community_tab.dart';
import 'tabs/discovery_tab.dart';
import 'tabs/settings_tab.dart';
import 'tabs/stats_tab.dart';
import 'tabs/library_tab.dart';

/// Helper to resolve owner name
String _resolveOwnerName(LocalUser? ownerUser, int ownerIdFallback) {
  if (ownerUser != null) {
    final username = ownerUser.username.trim();
    if (username.isNotEmpty) {
      return username;
    }
  }
  return 'Usuario $ownerIdFallback';
}

/// Helper to resolve status display
_DiscoverStatusDisplay _resolveStatusDisplay({
  required ThemeData theme,
  required SharedBook sharedBook,
  LoanDetail? loanDetail,
}) {
  final colors = theme.colorScheme;

  if (loanDetail != null) {
    final status = loanDetail.loan.status;
    if (status == 'pending') {
      return _DiscoverStatusDisplay(
        label: 'Pendiente',
        icon: Icons.schedule_outlined,
        background: colors.secondaryContainer,
        foreground: colors.onSecondaryContainer,
        caption: 'Solicitud pendiente de aprobación',
      );
    } else if (status == 'accepted') {
      return _DiscoverStatusDisplay(
        label: 'En préstamo',
        icon: Icons.handshake_outlined,
        background: colors.primaryContainer,
        foreground: colors.onPrimaryContainer,
        caption: 'Préstamo activo',
      );
    }
  }

  if (sharedBook.isAvailable) {
    return _DiscoverStatusDisplay(
      label: 'Disponible',
      icon: Icons.check_circle_outlined,
      background: colors.tertiaryContainer,
      foreground: colors.onTertiaryContainer,
    );
  } else {
    return _DiscoverStatusDisplay(
      label: 'No disponible',
      icon: Icons.block_outlined,
      background: colors.surfaceContainerHighest,
      foreground: colors.onSurface,
    );
  }
}

/// Helper class for status display
class _DiscoverStatusDisplay {
  const _DiscoverStatusDisplay({
    required this.label,
    required this.icon,
    required this.background,
    required this.foreground,
    this.caption,
  });

  final String label;
  final IconData icon;
  final Color background;
  final Color foreground;
  final String? caption;
}

/// Status chip widget for discover page
class _DiscoverStatusChip extends StatelessWidget {
  const _DiscoverStatusChip({required this.display});

  final _DiscoverStatusDisplay display;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: display.background,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            display.icon,
            size: 16,
            color: display.foreground,
          ),
          const SizedBox(width: 4),
          Text(
            display.label,
            style: Theme.of(context)
                .textTheme
                .labelSmall
                ?.copyWith(color: display.foreground, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

class DiscoverBookDetailPage extends ConsumerStatefulWidget {
  const DiscoverBookDetailPage({super.key, required this.group, required this.sharedBookId});

  final Group group;
  final int sharedBookId;

  @override
  ConsumerState<DiscoverBookDetailPage> createState() => _DiscoverBookDetailPageState();
}

class _DiscoverBookDetailPageState extends ConsumerState<DiscoverBookDetailPage> {
  bool _pendingDetailCoach = false;
  bool _detailTargetsReady = false;
  bool _detailCoachTriggered = false;
  bool _waitingDetailCompletion = false;

  late ProviderSubscription<AsyncValue<OnboardingProgress>> _detailProgressSub;
  late ProviderSubscription<CoachMarkState> _detailCoachSub;

  @override
  void initState() {
    super.initState();

    _detailProgressSub = ref.listenManual<AsyncValue<OnboardingProgress>>(
      onboardingProgressProvider,
      (previous, next) {
        final progress = next.asData?.value;
        if (progress != null && progress.shouldShowDetailCoach) {
          _pendingDetailCoach = true;
          _maybeTriggerDetailCoach();
        }
      },
    );

    _detailCoachSub = ref.listenManual<CoachMarkState>(
      coachMarkControllerProvider,
      (previous, next) {
        if (_waitingDetailCompletion &&
            previous?.sequence == CoachMarkSequence.detail &&
            next.sequence != CoachMarkSequence.detail &&
            !next.isVisible &&
            next.queue.isEmpty) {
          _waitingDetailCompletion = false;
          _pendingDetailCoach = false;
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
    _detailProgressSub.close();
    _detailCoachSub.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final sharedBooksAsync = ref.watch(sharedBookDetailsProvider(widget.group.id));
    final loansAsync = ref.watch(userRelevantLoansProvider(widget.group.id));
    final membersAsync = ref.watch(groupMemberDetailsProvider(widget.group.id));
    final activeUser = ref.watch(activeUserProvider).value;
    final loanState = ref.watch(loanControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.group.name),
      ),
      body: SafeArea(
        child: sharedBooksAsync.when(
          data: (sharedDetails) {
            SharedBookDetail? detail;
            for (final candidate in sharedDetails) {
              if (candidate.sharedBook.id == widget.sharedBookId) {
                detail = candidate;
                break;
              }
            }

            if (detail == null) {
              return _buildInformationMessage(
                icon: Icons.error_outline,
                title: 'No encontramos este libro compartido.',
                subtitle:
                    'Puede que se haya retirado o que los datos hayan cambiado desde la última sincronización.',
              );
            }

            final sharedBook = detail.sharedBook;
            final book = detail.book;
            final members = membersAsync.asData?.value ?? const <GroupMemberDetail>[];
            LocalUser? ownerUser;
            for (final member in members) {
              if (member.membership.memberUserId == sharedBook.ownerUserId) {
                ownerUser = member.user;
                break;
              }
            }

            final loans = loansAsync.asData?.value ?? const <LoanDetail>[];
            LoanDetail? borrowerLoan;
            LoanDetail? otherActiveLoan;

            for (final loanDetail in loans) {
              if (loanDetail.loan.sharedBookId != sharedBook.id) {
                continue;
              }
              final status = loanDetail.loan.status;
              if (status != 'pending' && status != 'accepted') {
                continue;
              }

              if (activeUser != null && loanDetail.loan.borrowerUserId == activeUser.id) {
                borrowerLoan = loanDetail;
              } else {
                otherActiveLoan = loanDetail;
              }
            }

            final LocalUser? borrower = activeUser;
            final LoanDetail? borrowerLoanDetail = borrowerLoan;
            final hasOtherActiveLoan = otherActiveLoan != null;

            final notificationsAsync = ref.watch(inAppNotificationsProvider);
            final unreadBookNotifications = notificationsAsync.maybeWhen(
              data: (notifications) => notifications
                  .where((notification) =>
                      notification.sharedBookId == sharedBook.id &&
                      notification.status == InAppNotificationStatus.unread)
                  .toList(),
              orElse: () => const <InAppNotification>[],
            );

            final canRequest = borrower != null && borrowerLoanDetail == null && !hasOtherActiveLoan;
            final canCancel = borrower != null &&
                borrowerLoanDetail != null &&
                borrowerLoanDetail.loan.status == 'pending' &&
                borrowerLoanDetail.loan.borrowerUserId == borrower.id;
            final LocalUser? owner = ownerUser;
            final LoanDetail? pendingOwnerLoan = borrowerLoanDetail != null &&
                    owner != null &&
                    activeUser != null &&
                    owner.id == activeUser.id &&
                    borrowerLoanDetail.loan.status == 'pending' &&
                    borrowerLoanDetail.loan.lenderUserId == owner.id
                ? borrowerLoanDetail
                : null;

            final ownerName = _resolveOwnerName(ownerUser, sharedBook.ownerUserId);
            final author = (book?.author ?? '').trim();
            final isbn = book?.isbn?.trim();
            final description = book?.notes?.trim();
            final statusDisplay = _resolveStatusDisplay(
              theme: theme,
              sharedBook: sharedBook,
              loanDetail: borrowerLoanDetail ?? otherActiveLoan,
            );

            if (!_detailTargetsReady) {
              final hasRequestTarget = canRequest;
              final hasOwnerTarget = pendingOwnerLoan != null && owner != null;
              if (hasRequestTarget || hasOwnerTarget) {
                _detailTargetsReady = true;
                WidgetsBinding.instance.addPostFrameCallback((_) => _maybeTriggerDetailCoach());
              }
            }

            return CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (loanState.lastError != null)
                        LoanFeedbackBanner(
                          message: loanState.lastError!,
                          isError: true,
                          onDismiss: () =>
                              ref.read(loanControllerProvider.notifier).dismissError(),
                        )
                      else if (loanState.lastSuccess != null)
                        LoanFeedbackBanner(
                          message: loanState.lastSuccess!,
                          isError: false,
                          onDismiss: () =>
                              ref.read(loanControllerProvider.notifier).dismissSuccess(),
                        ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Text(
                                    book?.title ?? 'Libro sin título',
                                    style: theme.textTheme.headlineSmall,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                _DiscoverStatusChip(display: statusDisplay),
                              ],
                            ),
                            if (statusDisplay.caption != null) ...[
                              const SizedBox(height: 12),
                              Text(
                                statusDisplay.caption!,
                                style: theme.textTheme.bodyMedium,
                              ),
                            ],
                            if (author.isNotEmpty) ...[
                              const SizedBox(height: 12),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Icon(Icons.person_outline, size: 18),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      author,
                                      style: theme.textTheme.bodyMedium,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                            const SizedBox(height: 12),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(Icons.group_outlined, size: 18),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Propietario: $ownerName',
                                    style: theme.textTheme.bodyMedium,
                                  ),
                                ),
                              ],
                            ),
                            if (isbn != null && isbn.isNotEmpty) ...[
                              const SizedBox(height: 12),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: [
                                  Chip(
                                    avatar: const Icon(Icons.qr_code_2_outlined, size: 18),
                                    label: Text('ISBN $isbn'),
                                  ),
                                ],
                              ),
                            ],
                            const SizedBox(height: 16),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.surfaceContainerHighest,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                (description != null && description.isNotEmpty)
                                    ? description
                                    : 'Este libro no tiene una descripción añadida.',
                                style: theme.textTheme.bodyMedium,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Divider(height: 1),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (unreadBookNotifications.isNotEmpty) ...[
                              ...unreadBookNotifications.map(
                                (notification) => Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: _InAppNotificationBanner(notification: notification),
                                ),
                              ),
                              const SizedBox(height: 8),
                            ],
                            Text('Acciones', style: theme.textTheme.titleMedium),
                            const SizedBox(height: 12),
                            if (otherActiveLoan != null)
                              _buildInformationMessage(
                                icon: Icons.lock_clock_outlined,
                                title: 'Reservado por ${_resolveUserName(otherActiveLoan.borrower)}',
                                subtitle:
                                    'El préstamo está ${otherActiveLoan.loan.status == 'pending' ? 'pendiente de aprobación' : 'en curso'}. '
                                    'Podrás solicitarlo cuando vuelva a estar disponible.',
                              )
                            else if (activeUser == null)
                              _buildInformationMessage(
                                icon: Icons.info_outline,
                                title: 'Necesitas iniciar sesión local.',
                                subtitle:
                                    'Solo las personas registradas localmente pueden solicitar préstamos.',
                              ),
                            if (pendingOwnerLoan != null && owner != null)
                              Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: Card(
                                    color: theme.colorScheme.surfaceTint
                                        .withValues(alpha: 0.08),
                                    child: Padding(
                                      padding: const EdgeInsets.all(16),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Solicitud pendiente',
                                            style: theme.textTheme.titleSmall,
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            'Tienes una solicitud de ${_resolveUserName(pendingOwnerLoan.borrower)} para este libro.',
                                            style: theme.textTheme.bodyMedium,
                                          ),
                                          const SizedBox(height: 12),
                                          Wrap(
                                            spacing: 12,
                                            runSpacing: 8,
                                            children: [
                                              CoachMarkTarget(
                                                id: CoachMarkId.groupManageInvitations,
                                                child: FilledButton.icon(
                                                  onPressed: loanState.isLoading
                                                      ? null
                                                      : () => _handleOwnerAccept(
                                                            owner: owner,
                                                            detail: pendingOwnerLoan,
                                                          ),
                                                  icon: const Icon(Icons.check_circle_outline),
                                                  label: const Text('Aceptar solicitud'),
                                                ),
                                              ),
                                              OutlinedButton.icon(
                                                onPressed: loanState.isLoading
                                                    ? null
                                                    : () => _handleOwnerReject(
                                                          owner: owner,
                                                          detail: pendingOwnerLoan,
                                                        ),
                                                icon: const Icon(Icons.cancel_outlined),
                                                label: const Text('Rechazar'),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                            ..._buildLoanActionButtons(
                              canRequest: canRequest,
                              canCancel: canCancel,
                              borrower: borrower,
                              borrowerLoanDetail: borrowerLoanDetail,
                              loanState: loanState,
                              sharedBook: sharedBook,
                            ),
                            if (!canRequest && !canCancel && otherActiveLoan == null && activeUser != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Text(
                                  borrowerLoan != null
                                      ? 'Ya enviaste una solicitud para este libro y está ${borrowerLoan.loan.status == 'pending' ? 'pendiente de aprobación' : borrowerLoan.loan.status}.'
                                      : 'Este libro no está disponible en este momento.',
                                  style: theme.textTheme.bodyMedium,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => _buildInformationMessage(
            icon: Icons.error_outline,
            title: 'No pudimos cargar este libro.',
            subtitle: '$error',
          ),
        ),
      ),
    );
  }

  Future<void> _requestLoan({required SharedBook sharedBook, required LocalUser borrower}) async {
    final controller = ref.read(loanControllerProvider.notifier);
    try {
      await controller.requestLoan(sharedBook: sharedBook, borrower: borrower);
      if (!mounted) return;
      _showFeedbackSnackBar(
        context: context,
        message: 'Solicitud enviada.',
        isError: false,
      );
    } catch (error) {
      if (!mounted) return;
      _showFeedbackSnackBar(
        context: context,
        message: UIHelpers.getFriendlyErrorMessage(error),
        isError: true,
      );
    }
  }

  Future<void> _cancelLoan({required Loan loan, required LocalUser borrower}) async {
    // Confirm before canceling
    final confirmed = await UIHelpers.showConfirmDialog(
      context: context,
      title: '¿Cancelar solicitud?',
      message: '¿Estás seguro de que quieres cancelar esta solicitud de préstamo?',
      isDangerous: false,
    );
    if (!confirmed) return;
    
    final controller = ref.read(loanControllerProvider.notifier);
    try {
      await controller.cancelLoan(loan: loan, borrower: borrower);
      if (!mounted) return;
      _showFeedbackSnackBar(
        context: context,
        message: 'Solicitud cancelada.',
        isError: false,
      );
    } catch (error) {
      if (!mounted) return;
      _showFeedbackSnackBar(
        context: context,
        message: UIHelpers.getFriendlyErrorMessage(error),
        isError: true,
      );
    }
  }

  Future<void> _handleOwnerAccept({required LocalUser owner, required LoanDetail detail}) async {
    final controller = ref.read(loanControllerProvider.notifier);
    try {
      await controller.acceptLoan(loan: detail.loan, owner: owner);
      if (!mounted) return;
      _showFeedbackSnackBar(
        context: context,
        message: 'Solicitud aceptada.',
        isError: false,
      );
    } catch (error) {
      if (!mounted) return;
      _showFeedbackSnackBar(
        context: context,
        message: UIHelpers.getFriendlyErrorMessage(error),
        isError: true,
      );
    }
  }

  Future<void> _handleOwnerReject({required LocalUser owner, required LoanDetail detail}) async {
    // Confirm before rejecting
    final confirmed = await UIHelpers.showConfirmDialog(
      context: context,
      title: '¿Rechazar solicitud?',
      message: '¿Estás seguro de que quieres rechazar esta solicitud de préstamo?',
      isDangerous: false,
    );
    if (!confirmed) return;
    
    final controller = ref.read(loanControllerProvider.notifier);
    try {
      await controller.rejectLoan(loan: detail.loan, owner: owner);
      if (!mounted) return;
      _showFeedbackSnackBar(
        context: context,
        message: 'Solicitud rechazada.',
        isError: false,
      );
    } catch (error) {
      if (!mounted) return;
      _showFeedbackSnackBar(
        context: context,
        message: UIHelpers.getFriendlyErrorMessage(error),
        isError: true,
      );
    }
  }

  Widget _buildInformationMessage({
    required IconData icon,
    required String title,
    String? subtitle,
  }) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, size: 56, color: theme.colorScheme.primary),
          const SizedBox(height: 12),
          Text(
            title,
            style: theme.textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }

  Iterable<Widget> _buildLoanActionButtons({
    required bool canRequest,
    required bool canCancel,
    required LocalUser? borrower,
    required LoanDetail? borrowerLoanDetail,
    required LoanActionState loanState,
    required SharedBook sharedBook,
  }) sync* {
    if (canRequest && borrower != null) {
      final LocalUser borrowerNonNull = borrower;
      yield CoachMarkTarget(
        id: CoachMarkId.bookDetailRequestLoan,
        child: FilledButton.icon(
          onPressed: loanState.isLoading
              ? null
              : () => _requestLoan(
                    sharedBook: sharedBook,
                    borrower: borrowerNonNull,
                  ),
          icon: const Icon(Icons.handshake_outlined),
          label: const Text('Solicitar préstamo'),
        ),
      );
    }

    if (canCancel && borrower != null && borrowerLoanDetail != null) {
      final LocalUser borrowerNonNull = borrower;
      final LoanDetail loanDetailNonNull = borrowerLoanDetail;
      yield Padding(
        padding: const EdgeInsets.only(top: 12),
        child: OutlinedButton.icon(
          onPressed: loanState.isLoading
              ? null
              : () => _cancelLoan(
                    loan: loanDetailNonNull.loan,
                    borrower: borrowerNonNull,
                  ),
          icon: const Icon(Icons.cancel_outlined),
          label: const Text('Cancelar solicitud'),
        ),
      );
    }
  }

  void _maybeTriggerDetailCoach() {
    if (!_pendingDetailCoach || _detailCoachTriggered || !_detailTargetsReady) {
      return;
    }

    final controller = ref.read(coachMarkControllerProvider.notifier);
    _detailCoachTriggered = true;
    _waitingDetailCompletion = true;
    unawaited(controller.beginSequence(CoachMarkSequence.detail));
  }

  String _resolveUserName(LocalUser? user) {
    return user?.username ?? 'Usuario desconocido';
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
}

class _NotificationBell extends ConsumerWidget {
  const _NotificationBell({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncCount = ref.watch(unreadNotificationCountProvider);

    return asyncCount.when(
      data: (count) {
        final displayCount = count > 999 ? 999 : count;
        final icon = Icon(
          count > 0 ? Icons.notifications_active_outlined : Icons.notifications_none_outlined,
        );

        return Tooltip(
          message: count > 0 ? 'Tienes $count notificaciones' : 'Notificaciones',
          child: IconButton(
            onPressed: onPressed,
            icon: count > 0
                ? Badge.count(
                    count: displayCount,
                    child: icon,
                  )
                : icon,
          ),
        );
      },
      loading: () => const SizedBox(
        width: 36,
        height: 36,
        child: Padding(
          padding: EdgeInsets.all(8),
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
      error: (_, __) => IconButton(
        onPressed: onPressed,
        icon: const Icon(Icons.notifications_off_outlined),
        tooltip: 'Notificaciones',
      ),
    );
  }
}

class _NotificationsSheet extends ConsumerWidget {
  const _NotificationsSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationsAsync = ref.watch(inAppNotificationsProvider);
    final activeUser = ref.read(activeUserProvider).value;
    final repository = ref.read(notificationRepositoryProvider);
    final theme = Theme.of(context);
    final hasNotifications = notificationsAsync.maybeWhen(
      data: (notifications) => notifications.isNotEmpty,
      orElse: () => false,
    );

    void showSnack(String message) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }

    Future<void> clearAll() async {
      if (!hasNotifications) {
        showSnack('No hay notificaciones para limpiar.');
        return;
      }
      if (activeUser == null) {
        showSnack('Configura un usuario activo antes de limpiar.');
        return;
      }
      try {
        await repository.clearAllForUser(activeUser.id);
        if (!context.mounted) return;
        showSnack('Notificaciones borradas.');
      } catch (error) {
        if (!context.mounted) return;
        showSnack('No se pudieron borrar las notificaciones: $error');
      }
    }

    return DraggableScrollableSheet(
      expand: false,
      minChildSize: 0.25,
      initialChildSize: 0.6,
      builder: (context, controller) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Notificaciones',
                      style: theme.textTheme.titleLarge,
                    ),
                  ),
                  if (hasNotifications)
                    TextButton.icon(
                      onPressed: () => unawaited(clearAll()),
                      icon: const Icon(Icons.delete_sweep_outlined),
                      label: const Text('Vaciar'),
                      style: TextButton.styleFrom(
                        foregroundColor: theme.colorScheme.error,
                      ),
                    ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    tooltip: 'Cerrar',
                    onPressed: () => Navigator.of(context).maybePop(),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: notificationsAsync.when(
                data: (notifications) {
                  if (notifications.isEmpty) {
                    return const EmptyState(
                      icon: Icons.notifications_none_outlined,
                      title: 'Sin notificaciones',
                      message:
                          'Aquí verás las novedades sobre tus préstamos y solicitudes.',
                    );
                  }

                  return ListView.separated(
                    controller: controller,
                    padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
                    itemBuilder: (context, index) {
                      final notification = notifications[index];
                      return _NotificationListTile(notification: notification);
                    },
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemCount: notifications.length,
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, _) => EmptyState(
                  icon: Icons.error_outline,
                  title: 'No se pudieron cargar',
                  message: '$error',
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _NotificationListTile extends ConsumerWidget {
  const _NotificationListTile({required this.notification});

  final InAppNotification notification;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repository = ref.read(notificationRepositoryProvider);
    final loanController = ref.read(loanControllerProvider.notifier);
    final loanState = ref.watch(loanControllerProvider);
    final loanRepository = ref.read(loanRepositoryProvider);
    final activeUser = ref.watch(activeUserProvider).value;
    final visuals = _NotificationVisuals.fromNotification(context, notification);
    final type = InAppNotificationType.fromValue(notification.type);

    final isUnread = notification.status == InAppNotificationStatus.unread;
    final createdAt = DateFormat.yMMMd().add_Hm().format(notification.createdAt);
    final isLoanBusy = loanState.isLoading;

    Future<void> markRead() async {
      await repository.markAs(
        uuid: notification.uuid,
        status: InAppNotificationStatus.read,
      );
    }

    Future<void> dismiss() async {
      await repository.softDelete(uuid: notification.uuid);
    }

    void showSnack(String message, {bool isError = false}) {
      final theme = Theme.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: isError ? theme.colorScheme.errorContainer : null,
        ),
      );
    }

    Future<void> handleLoanDecision({required bool accept}) async {
      final owner = activeUser;
      final loanId = notification.loanId;
      if (owner == null) {
        showSnack('Necesitas un usuario activo para gestionar el préstamo.', isError: true);
        return;
      }
      if (loanId == null) {
        showSnack('No se encontró el préstamo asociado.', isError: true);
        return;
      }

      final loan = await loanRepository.findLoanById(loanId);
      if (loan == null) {
        if (!context.mounted) return;
        showSnack('El préstamo ya no está disponible.', isError: true);
        return;
      }

      try {
        if (accept) {
          await loanController.acceptLoan(loan: loan, owner: owner);
        } else {
          await loanController.rejectLoan(loan: loan, owner: owner);
        }
        if (!context.mounted) return;
        await markRead();
        if (!context.mounted) return;
        showSnack(accept ? 'Solicitud aceptada.' : 'Solicitud rechazada.');
      } catch (error) {
        if (!context.mounted) return;
        showSnack('No se pudo completar la acción: $error', isError: true);
      }
    }

    final canHandleLoanRequest =
        type == InAppNotificationType.loanRequest && activeUser?.id == notification.targetUserId;

    return Card(
      color: visuals.background,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(visuals.icon, color: visuals.iconColor),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        notification.title ?? visuals.defaultTitle,
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(color: visuals.textColor),
                      ),
                      if ((notification.message ?? '').isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Text(
                          notification.message!,
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(color: visuals.secondaryTextColor),
                        ),
                      ],
                      const SizedBox(height: 8),
                      Text(
                        createdAt,
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(color: visuals.secondaryTextColor),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 8,
              children: [
                if (canHandleLoanRequest && notification.loanId != null) ...[
                  FilledButton.icon(
                    onPressed: isLoanBusy ? null : () => handleLoanDecision(accept: true),
                    icon: const Icon(Icons.check_circle_outline),
                    label: const Text('Aceptar'),
                  ),
                  OutlinedButton.icon(
                    onPressed: isLoanBusy ? null : () => handleLoanDecision(accept: false),
                    icon: const Icon(Icons.cancel_outlined),
                    label: const Text('Rechazar'),
                  ),
                ],
                if (isUnread)
                  TextButton.icon(
                    onPressed: markRead,
                    icon: const Icon(Icons.mark_email_read_outlined),
                    label: const Text('Marcar como leído'),
                  ),
                TextButton.icon(
                  onPressed: dismiss,
                  icon: const Icon(Icons.close),
                  label: const Text('Descartar'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _InAppNotificationBanner extends ConsumerWidget {
  const _InAppNotificationBanner({required this.notification});

  final InAppNotification notification;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repository = ref.read(notificationRepositoryProvider);
    final visuals = _NotificationVisuals.fromNotification(context, notification);
    final isUnread = notification.status == InAppNotificationStatus.unread;

    Future<void> markRead() async {
      await repository.markAs(
        uuid: notification.uuid,
        status: InAppNotificationStatus.read,
      );
    }

    Future<void> dismiss() async {
      await repository.softDelete(uuid: notification.uuid);
    }

    return Material(
      color: visuals.background,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(visuals.icon, color: visuals.iconColor),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        notification.title ?? visuals.defaultTitle,
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(color: visuals.textColor),
                      ),
                      if ((notification.message ?? '').isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Text(
                          notification.message!,
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(color: visuals.secondaryTextColor),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 8,
              children: [
                if (isUnread)
                  TextButton.icon(
                    onPressed: markRead,
                    icon: const Icon(Icons.mark_email_read_outlined),
                    label: const Text('Marcar como leído'),
                    style: TextButton.styleFrom(foregroundColor: visuals.textColor),
                  ),
                TextButton.icon(
                  onPressed: dismiss,
                  icon: const Icon(Icons.close),
                  label: const Text('Descartar'),
                  style: TextButton.styleFrom(foregroundColor: visuals.textColor),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _NotificationVisuals {
  _NotificationVisuals({
    required this.icon,
    required this.background,
    required this.iconColor,
    required this.textColor,
    required this.secondaryTextColor,
    required this.defaultTitle,
  });

  final IconData icon;
  final Color background;
  final Color iconColor;
  final Color textColor;
  final Color secondaryTextColor;
  final String defaultTitle;

  static _NotificationVisuals fromNotification(
    BuildContext context,
    InAppNotification notification,
  ) {
    final scheme = Theme.of(context).colorScheme;
    final type = InAppNotificationType.fromValue(notification.type);

    Color background;
    Color iconColor;
    Color textColor;
    Color secondaryTextColor;
    IconData icon;
    String defaultTitle;

    switch (type) {
      case InAppNotificationType.loanAccepted:
        background = scheme.primaryContainer;
        iconColor = scheme.onPrimaryContainer;
        textColor = scheme.onPrimaryContainer;
        secondaryTextColor = scheme.onPrimaryContainer.withValues(alpha: 0.8);
        icon = Icons.check_circle_outline;
        defaultTitle = 'Préstamo aceptado';
        break;
      case InAppNotificationType.loanRejected:
        background = scheme.errorContainer;
        iconColor = scheme.onErrorContainer;
        textColor = scheme.onErrorContainer;
        secondaryTextColor = scheme.onErrorContainer.withValues(alpha: 0.8);
        icon = Icons.cancel_outlined;
        defaultTitle = 'Solicitud rechazada';
        break;
      case InAppNotificationType.loanCancelled:
        background = scheme.surfaceContainerHigh;
        iconColor = scheme.onSurface;
        textColor = scheme.onSurface;
        secondaryTextColor = scheme.onSurfaceVariant;
        icon = Icons.remove_circle_outline;
        defaultTitle = 'Solicitud cancelada';
        break;
      case InAppNotificationType.loanReturned:
        background = scheme.secondaryContainer;
        iconColor = scheme.onSecondaryContainer;
        textColor = scheme.onSecondaryContainer;
        secondaryTextColor = scheme.onSecondaryContainer.withValues(alpha: 0.8);
        icon = Icons.assignment_turned_in_outlined;
        defaultTitle = 'Préstamo devuelto';
        break;
      case InAppNotificationType.loanExpired:
        background = scheme.tertiaryContainer;
        iconColor = scheme.onTertiaryContainer;
        textColor = scheme.onTertiaryContainer;
        secondaryTextColor = scheme.onTertiaryContainer.withValues(alpha: 0.8);
        icon = Icons.schedule_outlined;
        defaultTitle = 'Préstamo vencido';
        break;
      case InAppNotificationType.loanRequest:
      default:
        background = scheme.surfaceContainerHighest;
        iconColor = scheme.primary;
        textColor = scheme.onSurface;
        secondaryTextColor = scheme.onSurfaceVariant;
        icon = Icons.mark_email_unread_outlined;
        defaultTitle = 'Nueva solicitud de préstamo';
        break;
    }

    return _NotificationVisuals(
      icon: icon,
      background: background,
      iconColor: iconColor,
      textColor: textColor,
      secondaryTextColor: secondaryTextColor,
      defaultTitle: defaultTitle,
    );
  }
}



class _GroupFormResult {
  const _GroupFormResult({required this.name, this.description});

  final String name;
  final String? description;
}

class _GroupFormDialog extends StatefulWidget {
  const _GroupFormDialog();

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
    _nameController = TextEditingController();
    _descriptionController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      title: const Text('Crear grupo'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Nombre del grupo',
              ),
              autofocus: true,
              textInputAction: TextInputAction.next,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Introduce un nombre válido.';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Descripción (opcional)',
              ),
              maxLines: 3,
              textInputAction: TextInputAction.done,
            ),
            const SizedBox(height: 8),
            Text(
              'Puedes actualizar la descripción más tarde desde el menú.',
              style: theme.textTheme.bodySmall,
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
          onPressed: _submit,
          child: const Text('Crear'),
        ),
      ],
    );
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }
    final trimmedName = _nameController.text.trim();
    final trimmedDescription = _descriptionController.text.trim();
    Navigator.of(context).pop(
      _GroupFormResult(
        name: trimmedName,
        description: trimmedDescription.isEmpty ? null : trimmedDescription,
      ),
    );
  }
}

enum _BookFormResult {
  saved,
  deleted,
}

final _currentTabProvider = StateProvider<int>((ref) => 0);





class HomeShell extends ConsumerWidget {
  const HomeShell({super.key});

  static const routeName = '/home';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen<NotificationIntent?>(notificationIntentProvider, (previous, next) {
      if (next == null) {
        return;
      }
      _handleNotificationIntent(context, ref, next);
    });

    final currentIndex = ref.watch(_currentTabProvider);

    return Scaffold(
      body: Column(
        children: [
          const SyncBanner(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Align(
              alignment: Alignment.centerRight,
              child: _NotificationBell(
                onPressed: () => _showNotificationsSheet(context, ref),
              ),
            ),
          ),
          Expanded(
            child: IndexedStack(
              index: currentIndex,
              children: [
                LibraryTab(onOpenForm: ({Book? book}) => _showBookFormSheet(context, ref, book: book)),
                const CommunityTab(),
                const DiscoverTab(),
                const StatsTab(),
                const SettingsTab(),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.menu_book_outlined),
            selectedIcon: Icon(Icons.menu_book),
            label: 'Biblioteca',
          ),
          NavigationDestination(
            icon: Icon(Icons.groups_outlined),
            selectedIcon: Icon(Icons.groups),
            label: 'Comunidad',
          ),
          NavigationDestination(
            icon: Icon(Icons.explore_outlined),
            selectedIcon: Icon(Icons.explore),
            label: 'Descubrir',
          ),
          NavigationDestination(
            icon: Icon(Icons.insights_outlined),
            selectedIcon: Icon(Icons.insights),
            label: 'Estadísticas',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Ajustes',
          ),
        ],
        onDestinationSelected: (value) {
          ref.read(_currentTabProvider.notifier).state = value;
        },
      ),
      floatingActionButton: _buildFab(context, ref, currentIndex),
    );
  }

  Widget? _buildFab(BuildContext context, WidgetRef ref, int currentIndex) {
    if (currentIndex == 0) {
      return FloatingActionButton.extended(
        onPressed: () => _showBookFormSheet(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('Añadir libro'),
      );
    }

    if (kDebugMode) {
      return FloatingActionButton.extended(
        onPressed: () => _clearPin(context, ref),
        icon: const Icon(Icons.dangerous_outlined),
        label: const Text('Debug: reset PIN'),
      );
    }

    return null;
  }

  void _handleNotificationIntent(
    BuildContext context,
    WidgetRef ref,
    NotificationIntent intent,
  ) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final tabNotifier = ref.read(_currentTabProvider.notifier);

      switch (intent.type) {
        case NotificationType.loanDueSoon:
        case NotificationType.loanExpired:
          tabNotifier.state = 2;
          break;
        case NotificationType.groupInvitation:
          tabNotifier.state = 1;
          break;
      }

      ref.read(notificationIntentProvider.notifier).clear();
    });
  }

  Future<void> _showNotificationsSheet(BuildContext context, WidgetRef ref) async {
    final theme = Theme.of(context);
    await showModalBottomSheet<void>(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      backgroundColor: theme.colorScheme.surface,
      builder: (context) => const _NotificationsSheet(),
    );
  }

  Future<void> _showBookFormSheet(BuildContext context, WidgetRef ref, {Book? book}) async {
    final result = await showModalBottomSheet<_BookFormResult>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => BookFormSheet(initialBook: book),
    );

    if (!context.mounted || result == null) return;

    switch (result) {
      case _BookFormResult.saved:
        _showFeedbackSnackBar(
          context: context,
          message: book == null
              ? 'Libro añadido a tu biblioteca.'
              : 'Libro actualizado correctamente.',
          isError: false,
        );
        break;
      case _BookFormResult.deleted:
        _showFeedbackSnackBar(
          context: context,
          message: 'Libro eliminado.',
          isError: false,
        );
        break;
    }
  }

  Future<void> _clearPin(BuildContext context, WidgetRef ref) async {
    await ref.read(authControllerProvider.notifier).clearPin();
    if (!context.mounted) return;
    _showFeedbackSnackBar(
      context: context,
      message: 'PIN borrado (solo debug).',
      isError: false,
    );
    Navigator.of(context)
        .pushNamedAndRemoveUntil(PinSetupScreen.routeName, (route) => false);
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

}
