import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../data/local/database.dart';

class LoansSection extends StatelessWidget {
  const LoansSection({
    super.key,
    required this.loansAsync,
    required this.activeUser,
    required this.loanController,
    required this.loanState,
    required this.onFeedback,
  });

  final AsyncValue<List<dynamic>> loansAsync;
  final dynamic activeUser;
  final dynamic loanController;
  final dynamic loanState;
  final Function(String, bool) onFeedback;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return loansAsync.when(
      data: (loans) {
        // Filter to show only loans where user is involved
        final userLoans = loans.where((detail) {
          final loan = detail.loan;
          return loan?.borrowerUserId == activeUser?.id ||
              loan?.lenderUserId == activeUser?.id;
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
              return LoanCard(
                detail: detail,
                activeUser: activeUser,
                loanState: loanState,
                onAction: (action) => _handleLoanAction(
                  context: context,
                  action: action,
                  detail: detail,
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
          style: theme.textTheme.bodySmall
              ?.copyWith(color: theme.colorScheme.error)),
    );
  }

  Future<void> _handleLoanAction({
    required BuildContext context,
    required LoanAction action,
    required dynamic detail,
  }) async {
    switch (action) {
      case LoanAction.cancel:
        await _cancelLoan(context, detail);
        break;
      case LoanAction.accept:
        await _acceptLoan(context, detail);
        break;
      case LoanAction.reject:
        await _rejectLoan(context, detail);
        break;
      case LoanAction.markReturned:
        await _markReturned(context, detail);
        break;
      case LoanAction.request:
        await _requestLoan(context, detail);
        break;
    }
  }

  Future<void> _cancelLoan(BuildContext context, dynamic detail) async {
    final borrower = detail.borrower;
    if (borrower == null) {
      onFeedback('No pudimos identificar al solicitante.', true);
      return;
    }

    try {
      await loanController.cancelLoan(loan: detail.loan!, borrower: borrower);
      if (!context.mounted) return;
      onFeedback('Solicitud cancelada.', false);
    } catch (error) {
      if (!context.mounted) return;
      onFeedback('No se pudo cancelar la solicitud: $error', true);
    }
  }

  Future<void> _acceptLoan(BuildContext context, dynamic detail) async {
    final owner = detail.owner;
    if (owner == null) {
      onFeedback('No pudimos identificar al propietario.', true);
      return;
    }

    try {
      await loanController.acceptLoan(loan: detail.loan!, owner: owner);
      if (!context.mounted) return;
      onFeedback('Préstamo aceptado.', false);
    } catch (error) {
      if (!context.mounted) return;
      onFeedback('No se pudo aceptar el préstamo: $error', true);
    }
  }

  Future<void> _rejectLoan(BuildContext context, dynamic detail) async {
    final owner = detail.owner;
    if (owner == null) {
      onFeedback('No pudimos identificar al propietario.', true);
      return;
    }

    try {
      await loanController.rejectLoan(loan: detail.loan!, owner: owner);
      if (!context.mounted) return;
      onFeedback('Solicitud rechazada.', false);
    } catch (error) {
      if (!context.mounted) return;
      onFeedback('No se pudo rechazar la solicitud: $error', true);
    }
  }

  Future<void> _markReturned(BuildContext context, dynamic detail) async {
    final actor = activeUser;
    if (actor == null) {
      onFeedback('No pudimos identificar al usuario activo.', true);
      return;
    }

    try {
      await loanController.markReturned(loan: detail.loan!, actor: actor);
      if (!context.mounted) return;
      onFeedback('Préstamo marcado como devuelto.', false);
    } catch (error) {
      if (!context.mounted) return;
      onFeedback('No se pudo marcar como devuelto: $error', true);
    }
  }

  Future<void> _requestLoan(BuildContext context, dynamic detail) async {
    final sharedBook = detail.sharedBook;
    final borrower = activeUser;
    if (sharedBook == null || borrower == null) {
      onFeedback('No pudimos preparar la solicitud para este libro.', true);
      return;
    }

    try {
      await loanController.requestLoan(
          sharedBook: sharedBook, borrower: borrower);
      if (!context.mounted) return;
      onFeedback('Solicitud enviada.', false);
    } catch (error) {
      if (!context.mounted) return;
      onFeedback('No se pudo enviar la solicitud: $error', true);
    }
  }
}

class LoanCard extends StatelessWidget {
  const LoanCard({
    super.key,
    required this.detail,
    required this.activeUser,
    required this.loanState,
    required this.onAction,
  });

  final dynamic detail;
  final dynamic activeUser;
  final dynamic loanState;
  final void Function(LoanAction action) onAction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loan = detail.loan!;
    final bookTitle = detail.book?.title ?? 'Libro';
    final status = loan.status;
    final start = DateFormat.yMd().format(loan.requestedAt);
    final due = loan.dueDate != null
        ? DateFormat.yMd().format(loan.dueDate!)
        : 'Sin fecha límite';
    final isBorrower =
        activeUser != null && loan.borrowerUserId == activeUser!.id;
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
              children: _buildActionButtons(
                  isBorrower, isOwner, isManualLoan, status),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildActionButtons(
      bool isBorrower, bool isOwner, bool isManualLoan, String status) {
    final buttons = <Widget>[];

    if (isBorrower && status == 'requested') {
      buttons.add(
        OutlinedButton.icon(
          onPressed:
              loanState.isLoading ? null : () => onAction(LoanAction.cancel),
          icon: const Icon(Icons.cancel_outlined),
          label: const Text('Cancelar solicitud'),
        ),
      );
    }

    if (isOwner && status == 'requested') {
      buttons.addAll([
        FilledButton.icon(
          onPressed:
              loanState.isLoading ? null : () => onAction(LoanAction.accept),
          icon: const Icon(Icons.check_circle_outlined),
          label: const Text('Aceptar'),
        ),
        OutlinedButton.icon(
          onPressed:
              loanState.isLoading ? null : () => onAction(LoanAction.reject),
          icon: const Icon(Icons.cancel_schedule_send_outlined),
          label: const Text('Rechazar'),
        ),
      ]);
    }

    if (((isOwner || isBorrower) && !isManualLoan ||
            (isOwner && isManualLoan)) &&
        status == 'active') {
      buttons.add(
        FilledButton.icon(
          onPressed: loanState.isLoading
              ? null
              : () => onAction(LoanAction.markReturned),
          icon: const Icon(Icons.assignment_turned_in_outlined),
          label: const Text('Marcar devuelto'),
        ),
      );
    }

    if (detail.sharedBook != null &&
        detail.sharedBook!.ownerUserId != activeUser?.id &&
        detail.sharedBook!.isAvailable &&
        status == 'requested') {
      buttons.add(
        FilledButton.icon(
          onPressed:
              loanState.isLoading ? null : () => onAction(LoanAction.request),
          icon: const Icon(Icons.handshake_outlined),
          label: const Text('Solicitar préstamo'),
        ),
      );
    }

    return buttons;
  }

  String _resolveUserName(LocalUser? user) {
    if (user == null) {
      return 'Usuario desconocido';
    }
    final username = user.username.trim();
    return username.isEmpty ? 'Usuario desconocido' : username;
  }
}

enum LoanAction {
  cancel,
  accept,
  reject,
  markReturned,
  request,
}
