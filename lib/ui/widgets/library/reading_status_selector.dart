import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/local/database.dart';
import '../../../models/global_sync_state.dart';
import '../../../models/reading_status.dart';
import '../../../providers/book_providers.dart';
import '../../../providers/sync_providers.dart';

/// Widget for selecting and changing reading status
class ReadingStatusSelector extends ConsumerWidget {
  const ReadingStatusSelector({
    super.key,
    required this.book,
    required this.userId,
  });

  final Book book;
  final int userId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final currentStatus = ReadingStatus.fromValue(book.readingStatus);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  currentStatus.icon,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 12),
                Text(
                  'Estado de lectura',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: ReadingStatus.values.map((status) {
                final isSelected = status == currentStatus;
                return FilterChip(
                  selected: isSelected,
                  label: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        status.icon,
                        size: 16,
                        color: isSelected
                            ? theme.colorScheme.onSecondaryContainer
                            : theme.colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 6),
                      Text(status.label),
                    ],
                  ),
                  onSelected: (selected) {
                    if (selected && status != currentStatus) {
                      _handleStatusChange(context, ref, currentStatus, status);
                    }
                  },
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleStatusChange(
    BuildContext context,
    WidgetRef ref,
    ReadingStatus oldStatus,
    ReadingStatus newStatus,
  ) async {
    final timelineService = ref.read(readingTimelineServiceProvider);
    final bookDao = ref.read(bookDaoProvider);

    try {
      // Update book status in database
      await bookDao.updateReadingStatus(book.id, newStatus.value);

      // Handle timeline events
      await timelineService.onReadingStatusChanged(
        book: book,
        oldStatus: oldStatus,
        newStatus: newStatus,
        userId: userId,
      );

      // Refresh book data
      ref.invalidate(bookStreamProvider(book.id));
      ref.invalidate(readingTimelineProvider(book.id));

      ref
          .read(unifiedSyncCoordinatorProvider)
          .markPendingChanges(SyncEntity.books);
      ref
          .read(unifiedSyncCoordinatorProvider)
          .markPendingChanges(SyncEntity.timeline);

      if (!context.mounted) return;

      // Show feedback
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Estado cambiado a: ${newStatus.label}'),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al cambiar estado: $error'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }
}
