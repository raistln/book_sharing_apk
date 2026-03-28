import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../providers/book_providers.dart';

class LoanStatsCard extends ConsumerWidget {
  const LoanStatsCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(loanStatisticsProvider);
    final theme = Theme.of(context);

    return statsAsync.when(
      data: (stats) {
        final loansMade30d = stats['loansMade30Days'] as int? ?? 0;
        final loansMade1y = stats['loansMadeYear'] as int? ?? 0;
        final loansRequested30d = stats['loansRequested30Days'] as int? ?? 0;
        final loansRequested1y = stats['loansRequestedYear'] as int? ?? 0;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Resumen de Actividad',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _PremiumStatCard(
                      title: 'Préstamos',
                      subtitle: 'Realizados',
                      icon: Icons.outbox_rounded,
                      color: Colors.orange,
                      count30d: loansMade30d,
                      count1y: loansMade1y,
                      theme: theme,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _PremiumStatCard(
                      title: 'Solicitudes',
                      subtitle: 'Aceptados',
                      icon: Icons.inbox_rounded,
                      color: Colors.purple,
                      count30d: loansRequested30d,
                      count1y: loansRequested1y,
                      theme: theme,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
      loading: () => const Center(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: CircularProgressIndicator(),
        ),
      ),
      error: (e, st) => Padding(
        padding: const EdgeInsets.all(24.0),
        child: Text('Error al cargar estadísticas: $e'),
      ),
    );
  }
}

class _PremiumStatCard extends StatelessWidget {
  const _PremiumStatCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.count30d,
    required this.count1y,
    required this.theme,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final int count30d;
  final int count1y;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardTheme.color ?? theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: color.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 20, color: color),
              ),
              if (count30d > 0)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '+$count30d',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: color,
                      fontWeight: FontWeight.bold,
                      fontSize: 9,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
              height: 1.1,
            ),
          ),
          Text(
            subtitle,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontSize: 10,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _buildMetric(
                label: '30 d',
                value: '$count30d',
                theme: theme,
              ),
              _buildMetric(
                label: 'Total año',
                value: '$count1y',
                theme: theme,
                isSecondary: true,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetric({
    required String label,
    required String value,
    required ThemeData theme,
    bool isSecondary = false,
  }) {
    return Column(
      crossAxisAlignment:
          isSecondary ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: isSecondary ? theme.colorScheme.onSurfaceVariant : color,
            height: 1,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
            fontSize: 8,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
