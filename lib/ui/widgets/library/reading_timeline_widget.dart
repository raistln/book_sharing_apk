import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/local/database.dart';
import '../../../providers/book_providers.dart';
import 'reading_insight_banner.dart';
import 'timeline_entry_card.dart';
import 'add_timeline_entry_sheet.dart';

/// Main widget displaying the reading timeline
class ReadingTimelineWidget extends ConsumerStatefulWidget {
  const ReadingTimelineWidget({
    super.key,
    required this.book,
    required this.userId,
  });

  final Book book;
  final int userId;

  @override
  ConsumerState<ReadingTimelineWidget> createState() =>
      _ReadingTimelineWidgetState();
}

class _ReadingTimelineWidgetState extends ConsumerState<ReadingTimelineWidget> {
  bool _isExpanded = true;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final timelineAsync = ref.watch(readingTimelineProvider(widget.book.id));
    final insightAsync = ref.watch(readingInsightProvider(widget.book.id));

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          InkWell(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(
                    Icons.timeline_outlined,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Línea temporal de lectura',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    _isExpanded ? Icons.expand_less : Icons.expand_more,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ],
              ),
            ),
          ),
          if (_isExpanded) ...[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Insight banner
                  insightAsync.when(
                    data: (insight) {
                      if (insight == null) return const SizedBox.shrink();
                      return ReadingInsightBanner(insight: insight);
                    },
                    loading: () => const SizedBox.shrink(),
                    error: (_, __) => const SizedBox.shrink(),
                  ),
                  // Add progress button - ONLY if reading or paused
                  if (widget.book.readingStatus == 'reading' ||
                      widget.book.readingStatus == 'paused')
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: () => _showAddEntrySheet(context),
                        icon: const Icon(Icons.add),
                        label: const Text('Actualizar progreso'),
                      ),
                    ),
                  const SizedBox(height: 24),
                  // Timeline entries
                  timelineAsync.when(
                    data: (entries) {
                      if (entries.isEmpty) {
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 32),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.auto_stories_outlined,
                                  size: 48,
                                  color: theme.colorScheme.onSurfaceVariant
                                      .withValues(alpha: 0.5),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'Aún no has registrado ningún progreso',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Añade tu primer hito de lectura',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        );
                      }

                      return Column(
                        children: [
                          for (int i = 0; i < entries.length; i++)
                            TimelineEntryCard(
                              entry: entries[i],
                              isFirst: i == 0,
                              isLast: i == entries.length - 1,
                              onEdit: () =>
                                  _showEditEntrySheet(context, entries[i]),
                              onDelete: () =>
                                  _confirmDelete(context, entries[i]),
                            ),
                        ],
                      );
                    },
                    loading: () => const Center(
                      child: Padding(
                        padding: EdgeInsets.all(32),
                        child: CircularProgressIndicator(),
                      ),
                    ),
                    error: (error, _) => Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Text('Error: $error'),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _showAddEntrySheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => AddTimelineEntrySheet(
        book: widget.book,
        userId: widget.userId,
      ),
    );
  }

  void _showEditEntrySheet(BuildContext context, ReadingTimelineEntry entry) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => AddTimelineEntrySheet(
        book: widget.book,
        userId: widget.userId,
        existingEntry: entry,
      ),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    ReadingTimelineEntry entry,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar evento'),
        content: const Text(
            '¿Estás seguro de eliminar este evento de la línea temporal?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      final dao = ref.read(timelineEntryDaoProvider);
      await dao.deleteEntry(entry.id);
      ref.invalidate(readingTimelineProvider(widget.book.id));
      ref.invalidate(readingInsightProvider(widget.book.id));
    }
  }
}
