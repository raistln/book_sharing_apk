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

  /// Devuelve los estados visibles según si el libro ya fue leído alguna vez.
  ///
  /// - Si [isRead] es false: se muestra `reading`, se oculta `rereading`.
  /// - Si [isRead] es true:  se muestra `rereading`, se oculta `reading`.
  List<ReadingStatus> _visibleStatuses(bool isRead) {
    return ReadingStatus.values.where((status) {
      if (isRead && status == ReadingStatus.reading) return false;
      if (!isRead && status == ReadingStatus.rereading) return false;
      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final currentStatus = ReadingStatus.fromValue(book.readingStatus);
    final visibleStatuses = _visibleStatuses(book.isRead);

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
              children: visibleStatuses.map((status) {
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
      // Actualizar el estado en BD
      await bookDao.updateReadingStatus(book.id, newStatus.value);

      // Gestionar eventos de timeline e is_read
      await timelineService.onReadingStatusChanged(
        book: book,
        oldStatus: oldStatus,
        newStatus: newStatus,
        userId: userId,
      );

      // Refrescar datos
      ref.invalidate(bookStreamProvider(book.id));
      ref.invalidate(readingTimelineProvider(book.id));

      ref
          .read(unifiedSyncCoordinatorProvider)
          .markPendingChanges(SyncEntity.books);
      ref
          .read(unifiedSyncCoordinatorProvider)
          .markPendingChanges(SyncEntity.timeline);

      if (!context.mounted) return;

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
