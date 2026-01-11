import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../providers/stats_providers.dart';
import '../widgets/library/review_dialog.dart';
// For ReadBookItem

class ReadBooksScreen extends ConsumerWidget {
  const ReadBooksScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final readBooksAsync = ref.watch(readBooksProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Libros leídos'),
      ),
      body: readBooksAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(
          child: Text('Error: $err',
              style: TextStyle(color: theme.colorScheme.error)),
        ),
        data: (items) {
          if (items.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.auto_stories_outlined,
                      size: 64, color: theme.colorScheme.secondary),
                  const SizedBox(height: 16),
                  Text(
                    'Aún no has marcado ningún libro como leído.',
                    style: theme.textTheme.bodyLarge,
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final item = items[index];
              return Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  side: BorderSide(color: theme.colorScheme.outlineVariant),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.check_circle,
                              color: Colors.green.shade700),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(item.title,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold)),
                                Text(item.author),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    if (item.personalRating != null) ...[
                                      ...List.generate(5, (index) {
                                        return Icon(
                                          index < item.personalRating!
                                              ? Icons.star
                                              : Icons.star_border,
                                          size: 16,
                                          color: Colors.amber,
                                        );
                                      }),
                                      const SizedBox(width: 8),
                                    ],
                                    Text(
                                      'Leído el ${DateFormat.yMMMd().format(item.readAt)}',
                                      style:
                                          theme.textTheme.bodySmall?.copyWith(
                                        color:
                                            theme.colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          if (item.isBorrowed)
                            Tooltip(
                                message: 'Prestado',
                                child: Icon(Icons.swap_horiz,
                                    size: 16,
                                    color: theme.colorScheme.primary)),
                        ],
                      ),
                      if (item.book != null) ...[
                        const Divider(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton.icon(
                              onPressed: () => showReviewsListDialog(
                                  context, ref, item.book!),
                              icon: const Icon(Icons.forum_outlined, size: 18),
                              label: const Text('Ver reseñas'),
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 8),
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                            ),
                            const SizedBox(width: 8),
                            TextButton.icon(
                              onPressed: () =>
                                  showAddReviewDialog(context, ref, item.book!),
                              icon: Icon(
                                  item.personalRating == null
                                      ? Icons.rate_review_outlined
                                      : Icons.edit_outlined,
                                  size: 18),
                              label: Text(item.personalRating == null
                                  ? 'Valorar'
                                  : 'Editar reseña'),
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 8),
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
