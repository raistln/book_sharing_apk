import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../data/local/database.dart'; // For LocalUser, Loan classes if distinct
import '../../../data/local/group_dao.dart';
import '../../../providers/book_providers.dart';

class LoanConfirmationCard extends ConsumerWidget {
  const LoanConfirmationCard({
    super.key,
    required this.detail,
    required this.activeUser,
  });

  final LoanDetail detail;
  final LocalUser activeUser;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final loan = detail.loan;
    final loanController = ref.watch(loanControllerProvider.notifier);
    final loanState = ref.watch(loanControllerProvider);

    final isOwner = loan.lenderUserId == activeUser.id;
    final isManual =
        loan.borrowerUserId == null; // Manual loans have no borrowerUser

    // Determine state
    final isExternalReceived = detail.book?.isBorrowedExternal ?? false;

    final borrowerName = isExternalReceived
        ? (detail.borrower?.username ?? 'Tú')
        : (isManual
            ? (loan.externalBorrowerName ?? 'Prestatario')
            : (detail.borrower?.username ?? 'Usuario'));

    final ownerName = isExternalReceived
        ? (detail.book?.externalLenderName ?? 'Alguien')
        : (detail.owner?.username ?? 'Propietario');

    final dueDateStr = loan.dueDate != null
        ? DateFormat.yMMMd().format(loan.dueDate!)
        : 'Indefinido';

    final loanInfo = isExternalReceived
        ? 'Recibido de: $ownerName\nVence: $dueDateStr'
        : 'Prestado a: $borrowerName\nPrestado de: $ownerName\nVence: $dueDateStr';

    final otherName =
        (isOwner && !isExternalReceived) ? borrowerName : ownerName;

    final myConfirmation =
        isOwner ? loan.lenderReturnedAt : loan.borrowerReturnedAt;
    final otherConfirmation =
        isOwner ? loan.borrowerReturnedAt : loan.lenderReturnedAt;

    final iHaveConfirmed = myConfirmation != null;
    final otherHasConfirmed = otherConfirmation != null;

    // Manual Loan Case: Simple return
    if (isManual) {
      if (!isOwner) return const SizedBox.shrink(); // Should not happen
      final bookTitle = detail.book?.title ?? 'Libro desconocido';

      final sub = '$loanInfo\n\n(Préstamo manual)';

      return _buildActionCard(
        context,
        theme,
        icon: Icons.book_outlined, // Better icon
        title: bookTitle, // Show book title
        subtitle: sub,
        actions: [
          FilledButton.icon(
            onPressed: loanState.isLoading
                ? null
                : () =>
                    loanController.markReturned(loan: loan, actor: activeUser),
            icon: const Icon(Icons.check),
            label: const Text('Marcar Devuelto'),
          ),
        ],
      );
    }

    // Double Confirmation Logic
    if (iHaveConfirmed && otherHasConfirmed) {
      // Should be 'returned' status, but if we are here it might be lagging or strictly 'active'
      return const SizedBox.shrink();
    }

    if (!iHaveConfirmed && !otherHasConfirmed) {
      // Neihter has confirmed
      return _buildActionCard(
        context,
        theme,
        icon: Icons.swap_horiz,
        title: detail.book?.title ?? 'Devolución',
        subtitle:
            '$loanInfo\n\nCuando se complete la devolución, ambos debéis confirmarlo.',
        actions: [
          OutlinedButton.icon(
            onPressed: loanState.isLoading
                ? null
                : () async {
                    await loanController.markReturned(
                        loan: loan, actor: activeUser, wasRead: null);
                  },
            icon: const Icon(Icons.check_circle_outlined),
            label: const Text('Confirmar devolución'),
          ),
        ],
      );
    }

    if (iHaveConfirmed && !otherHasConfirmed) {
      // I confirmed, waiting for other
      // Check for force confirm eligibility (7 days)
      final daysSinceMyConfirm =
          DateTime.now().difference(myConfirmation).inDays;
      final canForce = isOwner && daysSinceMyConfirm >= 7;

      return _buildActionCard(
        context,
        theme,
        color: theme.colorScheme.surfaceContainerHighest,
        icon: Icons.hourglass_top,
        title: '${detail.book?.title ?? 'Préstamo'}: Esperando a $otherName',
        subtitle:
            '$loanInfo\n\nYa has confirmed la devolución el ${DateFormat.MMMd().format(myConfirmation)}.',
        actions: [
          if (canForce)
            FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: theme.colorScheme.error,
                foregroundColor: theme.colorScheme.onError,
              ),
              onPressed: loanState.isLoading
                  ? null
                  : () => loanController.ownerForceConfirmReturn(
                      loan: loan, owner: activeUser),
              icon: const Icon(Icons.warning_amber),
              label: const Text('Forzar finalización'),
            )
          else
            TextButton.icon(
              onPressed: loanState.isLoading
                  ? null
                  : () => loanController.sendReturnReminder(
                      loan: loan, actor: activeUser),
              icon: const Icon(Icons.notifications_active_outlined),
              label: const Text('Enviar recordatorio'),
            ),
        ],
      );
    }

    if (!iHaveConfirmed && otherHasConfirmed) {
      // Other confirmed, waiting for me
      return _buildActionCard(
        context,
        theme,
        color: theme.colorScheme.primaryContainer,
        icon: Icons.priority_high,
        title: '${detail.book?.title ?? 'Préstamo'}: ¡$otherName confirmó!',
        subtitle:
            '$loanInfo\n\nConfirma que has recibido/entregado el libro para finalizar.',
        actions: [
          FilledButton.icon(
            onPressed: loanState.isLoading
                ? null
                : () async {
                    await loanController.markReturned(
                        loan: loan, actor: activeUser, wasRead: null);
                  },
            icon: const Icon(Icons.check_circle),
            label: const Text('Confirmar y finalizar'),
          ),
        ],
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildActionCard(
    BuildContext context,
    ThemeData theme, {
    required IconData icon,
    required String title,
    required String subtitle,
    required List<Widget> actions,
    Color? color,
  }) {
    return Card(
      elevation: 0,
      color: color ?? theme.colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      margin: const EdgeInsets.only(top: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              children: [
                Icon(icon, size: 20, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: theme.colorScheme.onSurface,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const SizedBox(width: 28), // Indent to align with text above
                Expanded(
                  child: Text(
                    subtitle,
                    style: theme.textTheme.bodySmall,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: actions,
            ),
          ],
        ),
      ),
    );
  }
}
