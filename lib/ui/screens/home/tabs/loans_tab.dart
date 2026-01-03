import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../data/local/database.dart';
import '../../../../data/local/group_dao.dart';
import '../../../../providers/loans_providers.dart';
import '../../../../providers/book_providers.dart';
import '../../../widgets/loans/loan_confirmation_card.dart';
import '../../../widgets/loans/manual_loan_sheet.dart';

import '../../../widgets/loan_feedback_banner.dart';
import '../../../widgets/empty_state.dart';
import '../../../../design_system/evocative_texts.dart';
import '../../../../design_system/literary_animations.dart';

class LoansTab extends ConsumerWidget {
  const LoansTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeUser = ref.watch(activeUserProvider).value;

    if (activeUser == null) {
      return const Center(child: CircularProgressIndicator());
    }

    // Watch all necessary providers
    final incomingRequests = ref.watch(incomingLoanRequestsProvider);
    final outgoingRequests = ref.watch(outgoingLoanRequestsProvider);
    final activeLender = ref.watch(activeLoansAsLenderProvider);
    final activeBorrower = ref.watch(activeLoansAsBorrowerProvider);
    final history = ref.watch(loanHistoryProvider);
    final loanState = ref.watch(loanControllerProvider);

    final hasIncoming = incomingRequests.isNotEmpty;
    final hasOutgoing = outgoingRequests.isNotEmpty;
    final hasActiveLender = activeLender.isNotEmpty;
    final hasActiveBorrower = activeBorrower.isNotEmpty;
    final hasHistory = history.isNotEmpty;

    final isEmpty = !hasIncoming &&
        !hasOutgoing &&
        !hasActiveLender &&
        !hasActiveBorrower &&
        !hasHistory;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            title: const Text('Préstamos'),
            floating: true,
            actions: [
              IconButton(
                icon: const Icon(Icons.history),
                onPressed: () {
                  // TODO: Implement full history screen with filtering
                },
                tooltip: 'Historial completo',
              ),
            ],
          ),
          if (loanState.lastError != null)
            SliverToBoxAdapter(
              child: LoanFeedbackBanner(
                message: loanState.lastError!,
                isError: true,
                onDismiss: () =>
                    ref.read(loanControllerProvider.notifier).dismissError(),
              ),
            )
          else if (loanState.lastSuccess != null)
            SliverToBoxAdapter(
              child: LoanFeedbackBanner(
                message: loanState.lastSuccess!,
                isError: false,
                onDismiss: () =>
                    ref.read(loanControllerProvider.notifier).dismissSuccess(),
              ),
            ),
          if (isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: FadeScaleIn(
                child: EmptyState(
                  icon: Icons.import_contacts,
                  title: EvocativeTexts.emptyLoansTitle,
                  message: EvocativeTexts.emptyLoansMessage,
                  action: EmptyStateAction(
                    label: EvocativeTexts.emptyLoansAction,
                    icon: Icons.add_circle_outline,
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        useSafeArea: true,
                        builder: (context) => const ManualLoanSheet(),
                      );
                    },
                  ),
                ),
              ),
            ),
          if (!isEmpty) ...[
            // Summary Cards can go here if requested, currently just sections

            if (hasIncoming)
              _buildSectionHeader(context,
                  'Solicitudes Recibidas (${incomingRequests.length})'),
            if (hasIncoming)
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => _buildRequestCard(
                      context, ref, incomingRequests[index], true),
                  childCount: incomingRequests.length,
                ),
              ),

            if (hasOutgoing)
              _buildSectionHeader(
                  context, 'Solicitudes Enviadas (${outgoingRequests.length})'),
            if (hasOutgoing)
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => _buildRequestCard(
                      context, ref, outgoingRequests[index], false),
                  childCount: outgoingRequests.length,
                ),
              ),

            if (hasActiveLender)
              _buildSectionHeader(context, 'Prestados por ti'),
            if (hasActiveLender)
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => LoanConfirmationCard(
                    detail: activeLender[index],
                    activeUser: activeUser,
                  ),
                  childCount: activeLender.length,
                ),
              ),

            if (hasActiveBorrower) _buildSectionHeader(context, 'Te prestaron'),
            if (hasActiveBorrower)
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => LoanConfirmationCard(
                    detail: activeBorrower[index],
                    activeUser: activeUser,
                  ),
                  childCount: activeBorrower.length,
                ),
              ),

            if (hasHistory) _buildSectionHeader(context, 'Recientes'),
            if (hasHistory)
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) =>
                      _buildHistoryItem(context, history[index], activeUser),
                  childCount:
                      history.length > 5 ? 5 : history.length, // Limit to 5
                ),
              ),

            const SliverPadding(
                padding: EdgeInsets.only(bottom: 80)), // Space for FAB
          ],
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            useSafeArea: true,
            builder: (context) => const ManualLoanSheet(),
          );
        },
        label: const Text('Préstamo Manual'),
        icon: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
        child: Text(
          title,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
        ),
      ),
    );
  }

  Widget _buildRequestCard(
      BuildContext context, WidgetRef ref, LoanDetail detail, bool isIncoming) {
    final theme = Theme.of(context);
    final bookTitle = detail.book?.title ?? 'Libro';
    final otherName = isIncoming
        ? (detail.borrower?.username ?? 'Alguien')
        : (detail.owner?.username ?? 'Propietario');
    final loan = detail.loan;
    final loanController = ref.read(loanControllerProvider.notifier);

    // Actions
    final List<Widget> actions = [];

    if (isIncoming) {
      // I am the owner, I can Accept or Reject
      actions.add(
        OutlinedButton.icon(
          onPressed: () =>
              loanController.rejectLoan(loan: loan, owner: detail.owner!),
          icon: const Icon(Icons.close),
          label: const Text('Rechazar'),
          style: OutlinedButton.styleFrom(
              foregroundColor: theme.colorScheme.error),
        ),
      );
      actions.add(
        FilledButton.icon(
          onPressed: () => _handleAcceptLoan(context, ref, detail),
          icon: const Icon(Icons.check),
          label: const Text('Aceptar'),
        ),
      );
    } else {
      // I am the borrower, I can Cancel
      actions.add(
        TextButton.icon(
          onPressed: () =>
              loanController.cancelLoan(loan: loan, borrower: detail.borrower!),
          icon: const Icon(Icons.cancel_outlined),
          label: const Text('Cancelar solicitud'),
          style: TextButton.styleFrom(foregroundColor: theme.colorScheme.error),
        ),
      );
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              children: [
                Icon(
                  isIncoming ? Icons.arrow_downward : Icons.arrow_upward,
                  color: isIncoming ? Colors.orange : Colors.blue,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(bookTitle, style: theme.textTheme.titleMedium),
                      Text(
                        isIncoming
                            ? 'Solicitado por $otherName'
                            : 'Solicitado a $otherName',
                        style: theme.textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (actions.isNotEmpty) ...[
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Wrap(
                    spacing: 8,
                    children: actions,
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _handleAcceptLoan(
      BuildContext context, WidgetRef ref, LoanDetail detail) async {
    DateTime dueDate = DateTime.now().add(const Duration(days: 14));
    bool isIndefinite = false;

    final result = await showDialog<DateTime?>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          final theme = Theme.of(context);
          return AlertDialog(
            title: const Text('Aceptar Préstamo'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Selecciona una fecha de vencimiento:'),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Indefinido', style: theme.textTheme.bodyMedium),
                    Switch(
                      value: isIndefinite,
                      onChanged: (val) => setState(() => isIndefinite = val),
                    ),
                  ],
                ),
                if (!isIndefinite)
                  InkWell(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: dueDate,
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (picked != null) {
                        setState(() => dueDate = picked);
                      }
                    },
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.calendar_today),
                      ),
                      child: Text(
                        DateFormat.yMMMd().format(dueDate),
                        style: theme.textTheme.bodyLarge,
                      ),
                    ),
                  ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancelar'),
              ),
              FilledButton(
                onPressed: () {
                  Navigator.pop(
                      context,
                      isIndefinite
                          ? DateTime.now().add(const Duration(days: 365 * 10))
                          : dueDate);
                },
                child: const Text('Confirmar'),
              ),
            ],
          );
        },
      ),
    );

    if (result != null) {
      ref.read(loanControllerProvider.notifier).acceptLoan(
            loan: detail.loan,
            owner: detail.owner!,
            dueDate: result,
          );
    }
  }

  Widget _buildHistoryItem(
      BuildContext context, LoanDetail detail, LocalUser activeUser) {
    final isLender = detail.loan.lenderUserId == activeUser.id;
    final action = isLender ? 'Prestaste' : 'Te prestaron';
    final bookTitle = detail.book?.title ?? 'Libro';
    final otherName = detail.loan.externalBorrowerName ??
        (isLender ? detail.borrower?.username : detail.owner?.username) ??
        'Alguien';

    IconData icon;
    Color color;

    switch (detail.loan.status) {
      case 'returned':
        icon = Icons.check_circle_outline;
        color = Colors.green;
        break;
      case 'rejected':
      case 'cancelled':
        icon = Icons.cancel_outlined;
        color = Colors.grey;
        break;
      default:
        icon = Icons.history;
        color = Colors.grey;
    }

    return ListTile(
      leading: Icon(icon, color: color),
      title: Text('$action "$bookTitle"'),
      subtitle: Text('A: $otherName · ${detail.loan.status}'),
    );
  }
}
