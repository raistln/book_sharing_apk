import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../data/local/database.dart';

/// Card displaying a single timeline entry
class TimelineEntryCard extends StatelessWidget {
  const TimelineEntryCard({
    super.key,
    required this.entry,
    required this.isFirst,
    required this.isLast,
    this.onEdit,
    this.onDelete,
  });

  final ReadingTimelineEntry entry;
  final bool isFirst;
  final bool isLast;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Timeline indicator
        SizedBox(
          width: 40,
          child: Column(
            children: [
              if (!isFirst)
                Container(
                  width: 2,
                  height: 20,
                  color: theme.colorScheme.outlineVariant,
                ),
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: _getEventColor(theme),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: theme.colorScheme.outline,
                    width: 2,
                  ),
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    color: theme.colorScheme.outlineVariant,
                  ),
                ),
            ],
          ),
        ),
        // Content
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 24),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          _getEventIcon(),
                          size: 18,
                          color: _getEventColor(theme),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _getEventLabel(),
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: _getEventColor(theme),
                          ),
                        ),
                        const Spacer(),
                        if (onEdit != null || onDelete != null)
                          PopupMenuButton<String>(
                            itemBuilder: (context) => [
                              if (onEdit != null)
                                const PopupMenuItem(
                                  value: 'edit',
                                  child: Text('Editar'),
                                ),
                              if (onDelete != null)
                                const PopupMenuItem(
                                  value: 'delete',
                                  child: Text('Eliminar'),
                                ),
                            ],
                            onSelected: (value) {
                              if (value == 'edit') {
                                onEdit?.call();
                              } else if (value == 'delete') {
                                onDelete?.call();
                              }
                            },
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      DateFormat.yMMMd('es').add_Hm().format(entry.eventDate),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    if (entry.currentPage != null ||
                        entry.percentageRead != null) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          if (entry.currentPage != null) ...[
                            Icon(
                              Icons.bookmark_outline,
                              size: 16,
                              color: theme.colorScheme.secondary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Página ${entry.currentPage}',
                              style: theme.textTheme.bodyMedium,
                            ),
                          ],
                          if (entry.percentageRead != null) ...[
                            if (entry.currentPage != null)
                              const SizedBox(width: 16),
                            Icon(
                              Icons.pie_chart_outline,
                              size: 16,
                              color: theme.colorScheme.secondary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${entry.percentageRead}%',
                              style: theme.textTheme.bodyMedium,
                            ),
                          ],
                        ],
                      ),
                    ],
                    if (entry.note != null && entry.note!.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.format_quote,
                              size: 16,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                entry.note!,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  IconData _getEventIcon() {
    switch (entry.eventType) {
      case 'start':
        return Icons.play_circle_outline;
      case 'progress':
        return Icons.trending_up;
      case 'pause':
        return Icons.pause_circle_outline;
      case 'resume':
        return Icons.play_arrow;
      case 'finish':
        return Icons.check_circle_outline;
      default:
        return Icons.circle_outlined;
    }
  }

  String _getEventLabel() {
    switch (entry.eventType) {
      case 'start':
        return 'Inicio';
      case 'progress':
        return 'Progreso';
      case 'pause':
        return 'Pausa';
      case 'resume':
        return 'Reanudación';
      case 'finish':
        return 'Finalizado';
      default:
        return entry.eventType;
    }
  }

  Color _getEventColor(ThemeData theme) {
    switch (entry.eventType) {
      case 'start':
        return Colors.green;
      case 'progress':
        return Colors.blue;
      case 'pause':
        return Colors.orange;
      case 'resume':
        return Colors.teal;
      case 'finish':
        return Colors.purple;
      default:
        return theme.colorScheme.primary;
    }
  }
}
