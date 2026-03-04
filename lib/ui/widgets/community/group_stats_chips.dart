import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/local/group_dao.dart';
import '../../../providers/book_providers.dart';

class GroupStatsChips extends ConsumerWidget {
  const GroupStatsChips({
    super.key,
    required this.groupId,
    required this.membersAsync,
    required this.sharedBooksAsync,
    required this.loansAsync,
    required this.invitationsAsync,
  });

  final int groupId;
  final AsyncValue<List<dynamic>> membersAsync;
  final AsyncValue<List<dynamic>> sharedBooksAsync;
  final AsyncValue<List<dynamic>> loansAsync;
  final AsyncValue<List<dynamic>> invitationsAsync;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeUser = ref.watch(activeUserProvider).value;
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _StatBlock(
                icon: Icons.people_outline,
                label: 'Miembros',
                value: membersAsync.when(
                  data: (items) => '${items.length}',
                  loading: () => '...',
                  error: (_, __) => '!',
                ),
                color: Colors.blue,
              ),
              _buildVerticalDivider(context),
              _StatBlock(
                icon: Icons.menu_book_outlined,
                label: 'Libros',
                value: sharedBooksAsync.when(
                  data: (items) => '${items.length}',
                  loading: () => '...',
                  error: (_, __) => '!',
                ),
                color: Colors.orange,
              ),
              _buildVerticalDivider(context),
              _StatBlock(
                icon: Icons.check_circle_outline,
                label: 'Disponibles',
                value: _calculateAvailable(loansAsync, sharedBooksAsync),
                color: Colors.green,
              ),
            ],
          ),
          if (activeUser != null) ...[
            const Divider(height: 24),
            Row(
              children: [
                Icon(
                  Icons.person_outline,
                  size: 16,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 8),
                Text(
                  'Has aportado ',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                sharedBooksAsync.when(
                  data: (books) {
                    final myBooks = (books as List<SharedBookDetail>)
                        .where((detail) =>
                            detail.sharedBook.ownerUserId == activeUser.id)
                        .length;
                    return Text(
                      '$myBooks libros',
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    );
                  },
                  loading: () => const Text('...'),
                  error: (_, __) => const Text('!'),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  String _calculateAvailable(
    AsyncValue<List<dynamic>> loansAsync,
    AsyncValue<List<dynamic>> sharedBooksAsync,
  ) {
    if (loansAsync.hasValue && sharedBooksAsync.hasValue) {
      final loans = loansAsync.value as List<LoanDetail>;
      final sharedBooks = sharedBooksAsync.value as List<SharedBookDetail>;

      final activeLoans = loans.where((detail) =>
          detail.loan.status == 'requested' || detail.loan.status == 'active');

      final loanedBookIds = activeLoans
          .map((detail) => detail.sharedBook?.id)
          .whereType<int>()
          .toSet();

      final available = sharedBooks
          .where((detail) =>
              detail.sharedBook.isAvailable &&
              !loanedBookIds.contains(detail.sharedBook.id))
          .length;

      return '$available';
    }
    return '...';
  }

  Widget _buildVerticalDivider(BuildContext context) {
    return Container(
      height: 32,
      width: 1,
      color:
          Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.5),
    );
  }
}

class _StatBlock extends StatelessWidget {
  const _StatBlock({
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
    final theme = Theme.of(context);
    return Expanded(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 4),
              Text(
                value,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}
