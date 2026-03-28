import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/local/group_dao.dart';

class PremiumGroupStats extends ConsumerWidget {
  const PremiumGroupStats({
    super.key,
    required this.groupId,
    this.members,
    this.sharedBooks,
    this.loans,
    this.currentUserId,
    this.accentColor,
  });

  final int groupId;
  final List<GroupMemberDetail>? members;
  final List<SharedBookDetail>? sharedBooks;
  final List<LoanDetail>? loans;
  final int? currentUserId;
  final Color? accentColor;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final primary = accentColor ?? colorScheme.primary;

    // Calculate stats if provided, otherwise show placeholders
    final membersCount = members?.length ?? 0;
    final booksCount = sharedBooks?.length ?? 0;

    final myBooksCount = sharedBooks
            ?.where((sb) => sb.sharedBook.ownerUserId == currentUserId)
            .length ??
        0;

    final activeLoansCount = loans
            ?.where((l) =>
                l.loan.status == 'active' || l.loan.status == 'requested')
            .length ??
        0;

    final availableBooksCount = sharedBooks
            ?.where((sb) =>
                sb.sharedBook.isAvailable &&
                !(loans?.any((l) =>
                        l.loan.sharedBookId == sb.sharedBook.id &&
                        (l.loan.status == 'active' ||
                            l.loan.status == 'requested')) ??
                    false))
            .length ??
        0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GridView.count(
          crossAxisCount: 3,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.1,
          children: [
            _StatCard(
              label: 'Miembros',
              value: '$membersCount',
              icon: Icons.people_outline,
              color: primary,
              theme: theme,
            ),
            _StatCard(
              label: 'Libros',
              value: '$booksCount',
              icon: Icons.menu_book_outlined,
              color: Colors.orange,
              theme: theme,
            ),
            _StatCard(
              label: 'Libres',
              value: '$availableBooksCount',
              icon: Icons.check_circle_outline,
              color: Colors.green,
              theme: theme,
            ),
          ],
        ),
        if (currentUserId != null) ...[
          const SizedBox(height: 16),
          _ContributionBanner(
            count: myBooksCount,
            total: booksCount,
            activeLoans: activeLoansCount,
            color: primary,
            theme: theme,
          ),
        ],
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    required this.theme,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: theme.cardTheme.color ?? theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.12),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: color.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 20, color: color),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
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

class _ContributionBanner extends StatelessWidget {
  const _ContributionBanner({
    required this.count,
    required this.total,
    required this.activeLoans,
    required this.color,
    required this.theme,
  });

  final int count;
  final int total;
  final int activeLoans;
  final Color color;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withValues(alpha: 0.15),
            color.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.stars, size: 20, color: color),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tu aporte al grupo',
                  style: theme.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                Text(
                  'Has compartido $count libros y hay $activeLoans en préstamo.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          if (count > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${((count / (total > 0 ? total : 1)) * 100).toInt()}%',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
