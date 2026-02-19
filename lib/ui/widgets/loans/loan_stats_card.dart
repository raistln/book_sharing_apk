import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../providers/book_providers.dart';

class LoanStatsCard extends ConsumerWidget {
  const LoanStatsCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(loanStatisticsProvider);
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 0,
      color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.bar_chart, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'Estadísticas de Préstamos',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            statsAsync.when(
              data: (stats) {
                final loansMade30d = stats['loansMade30Days'] as int? ?? 0;
                final loansMade1y = stats['loansMadeYear'] as int? ?? 0;
                final loansRequested30d =
                    stats['loansRequested30Days'] as int? ?? 0;
                final loansRequested1y =
                    stats['loansRequestedYear'] as int? ?? 0;

                return Column(
                  children: [
                    _buildStatSection(
                      context,
                      title: 'Préstamos realizados',
                      icon: Icons.outbox,
                      color: Colors.orange,
                      count30d: loansMade30d,
                      count1y: loansMade1y,
                      isFirst: true,
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12.0),
                      child: Divider(height: 1),
                    ),
                    _buildStatSection(
                      context,
                      title: 'Solicitudes recibidas',
                      icon: Icons.inbox,
                      color: Colors.purple,
                      count30d: loansRequested30d,
                      count1y: loansRequested1y,
                      isFirst: false,
                    ),
                  ],
                );
              },
              loading: () => const Center(
                  child: Padding(
                padding: EdgeInsets.all(16.0),
                child: CircularProgressIndicator(),
              )),
              error: (e, st) => Text('Error al cargar estadísticas: $e'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatSection(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
    required int count30d,
    required int count1y,
    required bool isFirst,
  }) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(isFirst ? Icons.arrow_upward : Icons.arrow_downward,
                size: 16, color: color),
            const SizedBox(width: 8),
            Text(title,
                style: theme.textTheme.labelLarge
                    ?.copyWith(fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: theme.dividerColor),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Expanded(
                child: _buildTimeBox(
                  context,
                  count: count30d,
                  label: 'Últimos 30d',
                  showBorder: true,
                ),
              ),
              Expanded(
                child: _buildTimeBox(
                  context,
                  count: count1y,
                  label: 'Último año',
                  showBorder: false,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTimeBox(
    BuildContext context, {
    required int count,
    required String label,
    required bool showBorder,
  }) {
    final theme = Theme.of(context);
    return Container(
      decoration: showBorder
          ? BoxDecoration(
              border: Border(right: BorderSide(color: theme.dividerColor)),
            )
          : null,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      child: Column(
        children: [
          Text(
            count.toString(),
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
