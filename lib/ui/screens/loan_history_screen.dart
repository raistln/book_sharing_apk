import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/loans_providers.dart';
import '../../data/local/group_dao.dart';
import '../../data/local/database.dart';
import '../../providers/book_providers.dart';

class LoanHistoryScreen extends ConsumerWidget {
  const LoanHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final history = ref.watch(successfulLoanHistoryProvider);
    final activeUser = ref.watch(activeUserProvider).value;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Historial de Préstamos'),
      ),
      body: activeUser == null
          ? const Center(child: CircularProgressIndicator())
          : history.isEmpty
              ? const Center(
                  child: Text(
                    'No hay préstamos activos o pasados.',
                    style: TextStyle(color: Colors.grey),
                  ),
                )
              : ListView.builder(
                  itemCount: history.length,
                  itemBuilder: (context, index) {
                    final detail = history[index];
                    return _HistoryLoanCard(
                        detail: detail, activeUser: activeUser);
                  },
                ),
    );
  }
}

class _HistoryLoanCard extends StatelessWidget {
  const _HistoryLoanCard({
    required this.detail,
    required this.activeUser,
  });

  final LoanDetail detail;
  final LocalUser activeUser;

  @override
  Widget build(BuildContext context) {
    final isExternalReceived = detail.book?.isBorrowedExternal ?? false;
    final isLender =
        detail.loan.lenderUserId == activeUser.id && !isExternalReceived;

    final bookTitle = detail.book?.title ?? 'Libro desconocido';
    final otherName = isExternalReceived
        ? (detail.book?.externalLenderName ?? 'Alguien')
        : (detail.loan.externalBorrowerName ??
            (isLender ? detail.borrower?.username : detail.owner?.username) ??
            'Alguien');

    final status = detail.loan.status;
    final isReturning = status == 'returned'; // One party confirmed
    final isCompleted = status == 'completed'; // Both confirmed
    final isActive = status == 'active';
    final isExpired = status == 'expired';

    IconData icon;
    Color color;
    String statusText;

    if (isActive) {
      icon = Icons.import_contacts;
      color = Colors.blue;
      statusText = 'Activo';
    } else if (isReturning) {
      icon = Icons.pending_actions;
      color = Colors.orange;
      statusText = 'En proceso de devolución';
    } else if (isCompleted) {
      icon = Icons.check_circle;
      color = Colors.green;
      statusText = 'Completado';
    } else if (isExpired) {
      icon = Icons.timer_off;
      color = Colors.red;
      statusText = 'Vencido';
    } else {
      icon = Icons.help_outline;
      color = Colors.grey;
      statusText = status;
    }

    // "Prestado a X", "Prestado por X" or "Recibido de X"
    final relationText = isExternalReceived
        ? 'Recibido de $otherName'
        : (isLender ? 'Prestado a $otherName' : 'Prestado por $otherName');

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.1),
          child: Icon(icon, color: color),
        ),
        title: Text(bookTitle,
            style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(relationText),
            Text(statusText, style: TextStyle(color: color, fontSize: 12)),
          ],
        ),
        trailing: Text(
          _formatDate(detail.loan.updatedAt),
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
