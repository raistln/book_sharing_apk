import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../data/local/database.dart';
import '../../../../data/local/group_dao.dart';
import '../../../../data/models/in_app_notification_status.dart';
import '../../../../models/book_genre.dart';
import '../../../../providers/book_providers.dart';
import '../../../../services/coach_marks/coach_mark_controller.dart';
import '../../../../services/coach_marks/coach_mark_models.dart';
import '../../../../services/loan_controller.dart';
import '../../../../services/onboarding_service.dart';
import '../../../../data/local/book_dao.dart';
import '../../../utils/ui_helpers.dart';
import '../../../widgets/coach_mark_target.dart';
import '../../../widgets/library/review_dialog.dart';
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
    if (status == 'requested') {
      return _DiscoverStatusDisplay(
        label: 'Solicitado',
        icon: Icons.schedule_outlined,
        background: colors.secondaryContainer,
        foreground: colors.onSecondaryContainer,
        caption: 'Solicitud pendiente de aprobación',
      );
    } else if (status == 'active') {
      // FIXED: accepted -> active
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
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: display.foreground, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

class DiscoverBookDetailPage extends ConsumerStatefulWidget {
  const DiscoverBookDetailPage(
      {super.key, required this.group, required this.sharedBookId});

  final Group group;
  final int sharedBookId;

  @override
  ConsumerState<DiscoverBookDetailPage> createState() =>
      _DiscoverBookDetailPageState();
}

class _DiscoverBookDetailPageState
    extends ConsumerState<DiscoverBookDetailPage> {
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
    final sharedBooksAsync =
        ref.watch(sharedBookDetailsProvider(widget.group.id));
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
            final members =
                membersAsync.asData?.value ?? const <GroupMemberDetail>[];
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
              if (status != 'requested' && status != 'active') {
                // FIXED: accepted -> active
                continue;
              }

              if (activeUser != null &&
                  loanDetail.loan.borrowerUserId == activeUser.id) {
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

            final canRequest = borrower != null &&
                borrowerLoanDetail == null &&
                !hasOtherActiveLoan;
            final canCancel = borrower != null &&
                borrowerLoanDetail != null &&
                borrowerLoanDetail.loan.status == 'requested' &&
                borrowerLoanDetail.loan.borrowerUserId == borrower.id;
            final LocalUser? owner = ownerUser;
            final LoanDetail? pendingOwnerLoan = borrowerLoanDetail != null &&
                    owner != null &&
                    activeUser != null &&
                    owner.id == activeUser.id &&
                    borrowerLoanDetail.loan.status == 'requested' &&
                    borrowerLoanDetail.loan.lenderUserId == owner.id
                ? borrowerLoanDetail
                : null;

            final ownerName =
                _resolveOwnerName(ownerUser, sharedBook.ownerUserId);
            final author = (book?.author ?? '').trim();
            final isbn = book?.isbn?.trim();
            final description = book?.description?.trim();
            final pageCount = book?.pageCount;
            final publicationYear = book?.publicationYear;
            final statusDisplay = _resolveStatusDisplay(
              theme: theme,
              sharedBook: sharedBook,
              loanDetail: borrowerLoanDetail ?? otherActiveLoan,
            );

            final genres = BookGenre.fromCsv(book?.genre ?? '');

            if (!_detailTargetsReady) {
              final hasRequestTarget = canRequest;
              final hasOwnerTarget = pendingOwnerLoan != null && owner != null;
              if (hasRequestTarget || hasOwnerTarget) {
                _detailTargetsReady = true;
                WidgetsBinding.instance
                    .addPostFrameCallback((_) => _maybeTriggerDetailCoach());
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
                          onDismiss: () => ref
                              .read(loanControllerProvider.notifier)
                              .dismissError(),
                        )
                      else if (loanState.lastSuccess != null)
                        LoanFeedbackBanner(
                          message: loanState.lastSuccess!,
                          isError: false,
                          onDismiss: () => ref
                              .read(loanControllerProvider.notifier)
                              .dismissSuccess(),
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
                            if (pageCount != null ||
                                publicationYear != null) ...[
                              const SizedBox(height: 12),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Icon(Icons.info_outline, size: 18),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      [
                                        if (pageCount != null)
                                          '$pageCount páginas',
                                        if (publicationYear != null)
                                          '$publicationYear',
                                      ].join(' • '),
                                      style: theme.textTheme.bodyMedium,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                            const SizedBox(height: 12),
                            if (book != null)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: Consumer(
                                  builder: (context, ref, _) {
                                    final reviewsAsync =
                                        ref.watch(bookReviewsProvider(book.id));
                                    return reviewsAsync.when(
                                      data: (reviews) {
                                        final count = reviews.length;
                                        if (count == 0) {
                                          return Row(
                                            children: [
                                              Text(
                                                'Nadie ha opinado todavía',
                                                style: theme
                                                    .textTheme.bodyMedium
                                                    ?.copyWith(
                                                  color: theme.colorScheme
                                                      .onSurfaceVariant,
                                                ),
                                              ),
                                              const Spacer(),
                                              if (activeUser != null)
                                                _buildOpinarButton(
                                                    context, ref, book, null),
                                            ],
                                          );
                                        }

                                        final userReview = activeUser == null
                                            ? null
                                            : reviews.firstWhereOrNull((r) =>
                                                r.author.id == activeUser.id);

                                        return Row(
                                          children: [
                                            InkWell(
                                              onTap: () =>
                                                  showReviewsListDialog(
                                                      context, ref, book),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(4),
                                                child: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    Text(
                                                      '$count ${count == 1 ? 'opinión' : 'opiniones'}',
                                                      style: theme
                                                          .textTheme.bodyMedium
                                                          ?.copyWith(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: theme.colorScheme
                                                            .primary,
                                                      ),
                                                    ),
                                                    const SizedBox(width: 4),
                                                    Icon(
                                                      Icons.chevron_right,
                                                      size: 18,
                                                      color: theme
                                                          .colorScheme.primary,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            const Spacer(),
                                            if (activeUser != null)
                                              _buildOpinarButton(context, ref,
                                                  book, userReview),
                                          ],
                                        );
                                      },
                                      loading: () => const SizedBox.shrink(),
                                      error: (_, __) => const SizedBox.shrink(),
                                    );
                                  },
                                ),
                              ),
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
                            if ((isbn != null && isbn.isNotEmpty) ||
                                genres.isNotEmpty ||
                                book != null) ...[
                              const SizedBox(height: 12),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: [
                                  if (isbn != null && isbn.isNotEmpty)
                                    Chip(
                                      avatar: const Icon(
                                          Icons.qr_code_2_outlined,
                                          size: 18),
                                      label: Text('ISBN $isbn'),
                                    ),
                                  ...genres.map((g) => Chip(
                                        avatar: const Icon(
                                            Icons.category_outlined,
                                            size: 18),
                                        label: Text(g.label),
                                      )),
                                  if (book != null) ...[
                                    if (book.isPhysical)
                                      Chip(
                                        avatar: const Icon(Icons.book,
                                            size: 18, color: Colors.blue),
                                        label: const Text('Físico',
                                            style: TextStyle(
                                                color: Colors.blue,
                                                fontWeight: FontWeight.bold)),
                                        backgroundColor: Colors.blue.shade50,
                                        side: BorderSide(
                                            color: Colors.blue.shade200),
                                      )
                                    else
                                      Chip(
                                        avatar: const Icon(Icons.tablet_mac,
                                            size: 18, color: Colors.purple),
                                        label: const Text('Digital',
                                            style: TextStyle(
                                                color: Colors.purple,
                                                fontWeight: FontWeight.bold)),
                                        backgroundColor: Colors.purple.shade50,
                                        side: BorderSide(
                                            color: Colors.purple.shade200),
                                      ),
                                  ],
                                ],
                              ),
                            ],
                            const SizedBox(height: 16),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color:
                                    theme.colorScheme.surfaceContainerHighest,
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
                                  child: InAppNotificationBanner(
                                      notification: notification),
                                ),
                              ),
                              const SizedBox(height: 8),
                            ],
                            Text('Acciones',
                                style: theme.textTheme.titleMedium),
                            const SizedBox(height: 12),
                            if (otherActiveLoan != null)
                              _buildInformationMessage(
                                icon: Icons.lock_clock_outlined,
                                title:
                                    'Reservado por ${_resolveUserName(otherActiveLoan.borrower)}',
                                subtitle:
                                    'El préstamo está ${otherActiveLoan.loan.status == 'requested' ? 'pendiente de aprobación' : 'en curso'}. '
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
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
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
                                              id: CoachMarkId
                                                  .groupManageInvitations,
                                              child: FilledButton.icon(
                                                onPressed: loanState.isLoading
                                                    ? null
                                                    : () => _handleOwnerAccept(
                                                          owner: owner,
                                                          detail:
                                                              pendingOwnerLoan,
                                                        ),
                                                icon: const Icon(
                                                    Icons.check_circle_outline),
                                                label: const Text(
                                                    'Aceptar solicitud'),
                                              ),
                                            ),
                                            OutlinedButton.icon(
                                              onPressed: loanState.isLoading
                                                  ? null
                                                  : () => _handleOwnerReject(
                                                        owner: owner,
                                                        detail:
                                                            pendingOwnerLoan,
                                                      ),
                                              icon: const Icon(
                                                  Icons.cancel_outlined),
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
                              originalBookMetadata: book,
                            ),
                            if (!canRequest &&
                                !canCancel &&
                                otherActiveLoan == null &&
                                activeUser != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Text(
                                  borrowerLoan != null
                                      ? 'Ya enviaste una solicitud para este libro y está ${borrowerLoan.loan.status == 'requested' ? 'pendiente de aprobación' : borrowerLoan.loan.status}.'
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

  Future<void> _requestLoan(
      {required SharedBook sharedBook, required LocalUser borrower}) async {
    final controller = ref.read(loanControllerProvider.notifier);
    try {
      await controller.requestLoan(sharedBook: sharedBook, borrower: borrower);
      // Feedback is shown via LoanFeedbackBanner watching loanState
    } catch (error) {
      // Error feedback is shown via LoanFeedbackBanner watching loanState
    }
  }

  Future<void> _cancelLoan(
      {required Loan loan, required LocalUser borrower}) async {
    // Confirm before canceling
    final confirmed = await UIHelpers.showConfirmDialog(
      context: context,
      title: '¿Cancelar solicitud?',
      message:
          '¿Estás seguro de que quieres cancelar esta solicitud de préstamo?',
      isDangerous: false,
    );
    if (!confirmed) return;

    final controller = ref.read(loanControllerProvider.notifier);
    try {
      await controller.cancelLoan(loan: loan, borrower: borrower);
      // Feedback is shown via LoanFeedbackBanner watching loanState
    } catch (error) {
      // Error feedback is shown via LoanFeedbackBanner watching loanState
    }
  }

  Future<void> _handleOwnerAccept(
      {required LocalUser owner, required LoanDetail detail}) async {
    final controller = ref.read(loanControllerProvider.notifier);
    try {
      await controller.acceptLoan(loan: detail.loan, owner: owner);
      // Feedback is shown via LoanFeedbackBanner watching loanState
    } catch (error) {
      // Error feedback is shown via LoanFeedbackBanner watching loanState
    }
  }

  Future<void> _handleOwnerReject(
      {required LocalUser owner, required LoanDetail detail}) async {
    // Confirm before rejecting
    final confirmed = await UIHelpers.showConfirmDialog(
      context: context,
      title: '¿Rechazar solicitud?',
      message:
          '¿Estás seguro de que quieres rechazar esta solicitud de préstamo?',
      isDangerous: false,
    );
    if (!confirmed) return;

    final controller = ref.read(loanControllerProvider.notifier);
    try {
      await controller.rejectLoan(loan: detail.loan, owner: owner);
      // Feedback is shown via LoanFeedbackBanner watching loanState
    } catch (error) {
      // Error feedback is shown via LoanFeedbackBanner watching loanState
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

  Widget _buildOpinarButton(BuildContext context, WidgetRef ref, Book book,
      ReviewWithAuthor? userReview) {
    return TextButton.icon(
      onPressed: () => showAddReviewDialog(context, ref, book),
      icon: Icon(
        userReview != null ? Icons.edit_outlined : Icons.rate_review_outlined,
        size: 18,
      ),
      label: Text(userReview != null ? 'Editar' : 'Opinar'),
      style: TextButton.styleFrom(
        visualDensity: VisualDensity.compact,
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
    required Book? originalBookMetadata,
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

    // Always allow adding to library if not owned by self
    yield Padding(
      padding: const EdgeInsets.only(top: 12),
      child: OutlinedButton.icon(
        onPressed: () => _copyToLibrary(sharedBook, originalBookMetadata),
        icon: const Icon(Icons.library_add_outlined),
        label: const Text('Añadir a mi biblioteca'),
      ),
    );
  }

  Future<void> _copyToLibrary(
      SharedBook sharedBook, Book? originalBookMetadata) async {
    final activeUser = ref.read(activeUserProvider).value;
    if (activeUser == null) return;

    final theme = Theme.of(context);

    // Confirmación antes de copiar
    final confirmed = await UIHelpers.showConfirmDialog(
      context: context,
      title: '¿Añadir a mi biblioteca?',
      message: '¿Seguro que quieres pasar este libro a tu biblioteca personal?',
      isDangerous: false,
    );
    if (!confirmed) return;

    final repository = ref.read(bookRepositoryProvider);

    try {
      if (originalBookMetadata == null) {
        throw Exception('No se encontraron los metadatos del libro original');
      }

      await repository.addBook(
        title: originalBookMetadata.title,
        author: originalBookMetadata.author,
        isbn: originalBookMetadata.isbn,
        barcode: originalBookMetadata.barcode,
        coverPath: null,
        description: 'Añadido desde un grupo',
        status: 'private',
        isRead: false,
        owner: activeUser,
        genre: originalBookMetadata.genre,
        isPhysical: originalBookMetadata.isPhysical,
        pageCount: originalBookMetadata.pageCount,
        publicationYear: originalBookMetadata.publicationYear,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                      '"${originalBookMetadata.title}" añadido a tu biblioteca'),
                ),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        final errorMessage = e.toString();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage.contains('Ya tienes ese libro')
                ? 'Ya tienes este libro en tu biblioteca'
                : 'Error al añadir a la biblioteca: $e'),
            backgroundColor: errorMessage.contains('Ya tienes ese libro')
                ? theme.colorScheme.primary
                : theme.colorScheme.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
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
}
