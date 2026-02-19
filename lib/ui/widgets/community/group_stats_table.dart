import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../data/local/group_dao.dart';

class GroupStatsTable extends StatelessWidget {
  const GroupStatsTable({
    super.key,
    required this.members,
    required this.sharedBooks,
    required this.loansAsync,
    required this.currentUserId,
  });

  final List<GroupMemberDetail> members;
  final List<SharedBookDetail> sharedBooks;
  final AsyncValue<List<LoanDetail>> loansAsync;
  final int? currentUserId;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final myBooksCount = sharedBooks
        .where((sb) => sb.sharedBook.ownerUserId == currentUserId)
        .length;
    final availableBooksCount =
        sharedBooks.where((sb) => sb.sharedBook.isAvailable).length;
    final activeLoansCount = loansAsync.asData?.value
            .where((l) => l.loan.status == 'active') // FIXED: active
            .length ??
        0;

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: theme.colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Table(
        defaultVerticalAlignment: TableCellVerticalAlignment.middle,
        border: TableBorder(
          verticalInside: BorderSide(color: theme.colorScheme.outlineVariant),
          horizontalInside: BorderSide(color: theme.colorScheme.outlineVariant),
        ),
        children: [
          TableRow(
            children: [
              _buildCell(context, 'Miembros', '${members.length}'),
              _buildCell(context, 'Libros', '${sharedBooks.length}'),
              _buildCell(context, 'Mis Libros', '$myBooksCount'),
            ],
          ),
          TableRow(
            children: [
              _buildCell(context, 'Disponibles', '$availableBooksCount'),
              _buildCell(context, 'Préstamos', '$activeLoansCount'),
              const SizedBox(), // Empty cell to balance 2 cols if needed, or structured differently
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCell(BuildContext context, String label, String value) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
