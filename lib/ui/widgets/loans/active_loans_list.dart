import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../info_pop.dart';

import '../../../providers/book_providers.dart';
// ignore: unused_import
import '../../../providers/loan_providers.dart';
// ignore: unused_import
import '../../../providers/auth_providers.dart';
import '../../../services/stats_service.dart';
// ignore: unused_import
import '../../../services/loan_controller.dart';

/// Widget that displays a list of active loans
///
/// Shows loans in pending or accepted status with details like
/// borrower name, status, request date, and due date.
class ActiveLoansList extends ConsumerWidget {
  const ActiveLoansList({super.key, required this.loans});

  final List<StatsActiveLoan> loans;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    if (loans.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Icon(Icons.handshake_outlined, color: theme.colorScheme.primary),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'No tienes préstamos pendientes o en curso en este momento.',
                  style: theme.textTheme.bodyMedium,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: loans.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final loan = loans[index];
        final dueDate = loan.dueDate;
        final statusLabel = _statusLabel(loan.status);
        final statusColor = _statusColor(context, loan.status);

        return Card(
          child: Column(
            children: [
              ListTile(
                leading: Icon(Icons.inventory_2_outlined, color: statusColor),
                title: Text(loan.bookTitle),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Solicitante: ${loan.borrowerName}'),
                    Text('Estado: $statusLabel'),
                    Text(
                        'Solicitado: ${DateFormat.yMMMd().format(loan.requestedAt)}'),
                    Text(
                      dueDate != null
                          ? 'Vence: ${DateFormat.yMMMd().format(dueDate)}'
                          : 'Sin fecha límite',
                    ),
                  ],
                ),
                onTap: () {
                  // Navigate to book detail page
                  // This requires importing the book detail page widget and navigation logic
                  // For now, show a message to the user
                  InfoPop.show(context,
                      message: 'Navegación a detalle de préstamo');
                },
              ),
              if (loan.status == 'active')
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      FilledButton.icon(
                        onPressed: () => _markReturned(context, ref, loan),
                        icon: const Icon(Icons.assignment_turned_in_outlined),
                        label: const Text('Marcar devuelto'),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _markReturned(
      BuildContext context, WidgetRef ref, StatsActiveLoan loan) async {
    final activeUser = ref.read(activeUserProvider).value;
    if (activeUser == null) return;
    try {
      final controller = ref.read(loanControllerProvider.notifier);
      await controller.markReturned(loan: loan.loan, actor: activeUser);

      if (!context.mounted) return;
      if (!context.mounted) return;
      InfoPop.success(context, 'Préstamo marcado como devuelto');
    } catch (e) {
      if (!context.mounted) return;
      if (!context.mounted) return;
      InfoPop.error(context, 'Error: $e');
    }
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'requested':
        return 'Solicitado';
      case 'active':
        return 'En curso';
      case 'returned':
        return 'Devuelto';
      case 'cancelled':
        return 'Cancelado';
      case 'rejected':
        return 'Rechazado';
      case 'completed':
        return 'Completado';
      case 'expired':
        return 'Expirado';
      default:
        return status;
    }
  }

  Color _statusColor(BuildContext context, String status) {
    final colors = Theme.of(context).colorScheme;
    switch (status) {
      case 'requested':
      case 'active':
        return colors.primary;
      case 'returned':
      case 'completed':
        return colors.tertiary;
      case 'cancelled':
      case 'rejected':
      case 'expired':
        return colors.error;
      default:
        return colors.onSurfaceVariant;
    }
  }
}
