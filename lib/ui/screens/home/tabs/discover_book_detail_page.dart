import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../data/local/database.dart';
import '../../../../data/local/group_dao.dart';
import '../../../../data/models/in_app_notification_status.dart';
import '../../../../providers/book_providers.dart';
import '../../../../services/coach_marks/coach_mark_controller.dart';
import '../../../../services/coach_marks/coach_mark_models.dart';
import '../../../../services/loan_controller.dart';
import '../../../../services/onboarding_service.dart';
import '../../../utils/ui_helpers.dart';
import '../../../widgets/coach_mark_target.dart';
import '../../../widgets/loan_feedback_banner.dart';
import '../../../widgets/notifications/in_app_notification_banner.dart';

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
                                  child: InAppNotificationBanner(notification: notification),
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
