import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../providers/stats_providers.dart';
import '../../../../services/stats_service.dart';
import '../../../widgets/loans/active_loans_list.dart';
import '../../read_books_screen.dart';

/// Stats tab showing library statistics
///
/// Displays:
/// - Total books, loans, active loans, returned, expired
/// - Active loans list
/// - Top borrowed books
class StatsTab extends StatelessWidget {
  const StatsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const _StatsView();
  }
}

class _StatsView extends ConsumerWidget {
  const _StatsView();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaryAsync = ref.watch(statsSummaryProvider);

    return SafeArea(
      child: summaryAsync.when(
        data: (summary) => _StatsContent(summary: summary),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => _StatsError(message: '$error'),
      ),
    );
  }
}

class _StatsContent extends ConsumerWidget {
  const _StatsContent({required this.summary});

  final StatsSummary summary;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Estadísticas generales', style: theme.textTheme.headlineSmall),
          const SizedBox(height: 16),
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              _StatHighlight(
                icon: Icons.menu_book,
                label: 'Libros totales',
                value: summary.totalBooks,
              ),
              _StatHighlight(
                icon: Icons.auto_stories,
                label: 'Libros leídos',
                value: summary.totalBooksRead,
              ),
              _StatHighlight(
                icon: Icons.check_circle_outline,
                label: 'Disponibles',
                value: summary.availableBooks,
              ),
              _StatHighlight(
                icon: Icons.swap_horiz,
                label: 'Préstamos totales',
                value: summary.totalLoans,
              ),
              _StatHighlight(
                icon: Icons.playlist_add_check_circle,
                label: 'Préstamos activos',
                value: summary.activeLoans,
              ),
              _StatHighlight(
                icon: Icons.assignment_turned_in,
                label: 'Devueltos',
                value: summary.returnedLoans,
              ),
              _StatHighlight(
                icon: Icons.hourglass_bottom,
                label: 'Expirados',
                value: summary.expiredLoans,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerRight,
            child: OutlinedButton.icon(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const ReadBooksScreen()),
                );
              },
              icon: const Icon(Icons.list),
              label: const Text('Ver historial de lecturas'),
            ),
          ),
          const SizedBox(height: 28),
          Text('Préstamos activos', style: theme.textTheme.headlineSmall),
          const SizedBox(height: 12),
          ActiveLoansList(loans: summary.activeLoanDetails),
          const SizedBox(height: 28),
          Text('Libros más prestados', style: theme.textTheme.headlineSmall),
          const SizedBox(height: 12),
          _TopBooksList(topBooks: summary.topBooks),
        ],
      ),
    );
  }
}

class _StatHighlight extends StatelessWidget {
  const _StatHighlight({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final int value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 140),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, size: 28, color: theme.colorScheme.primary),
              const SizedBox(height: 12),
              Text(
                '$value',
                style: theme.textTheme.headlineMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(label, style: theme.textTheme.titleSmall),
            ],
          ),
        ),
      ),
    );
  }
}

class _TopBooksList extends StatelessWidget {
  const _TopBooksList({required this.topBooks});

  final List<StatsTopBook> topBooks;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (topBooks.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Icon(Icons.insights_outlined, color: theme.colorScheme.primary),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Cuando registres préstamos aparecerán aquí tus libros más populares.',
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
      itemCount: topBooks.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final book = topBooks[index];
        return Card(
          child: ListTile(
            leading: CircleAvatar(child: Text('${index + 1}')),
            title: Text(book.title),
            subtitle: Text('Préstamos registrados: ${book.loanCount}'),
          ),
        );
      },
    );
  }
}

class _StatsError extends StatelessWidget {
  const _StatsError({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 64, color: theme.colorScheme.error),
            const SizedBox(height: 12),
            Text(
              'No pudimos cargar las estadísticas.',
              style: theme.textTheme.titleLarge
                  ?.copyWith(color: theme.colorScheme.error),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
