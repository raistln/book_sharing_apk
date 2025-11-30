import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../data/local/database.dart';

/// Widget to display a single book review
class ReviewListTile extends StatelessWidget {
  const ReviewListTile({
    required this.review,
    required this.authorName,
    this.onEdit,
    this.canEdit = false,
    super.key,
  });

  final BookReview review;
  final String authorName;
  final VoidCallback? onEdit;
  final bool canEdit;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        authorName,
                        style: theme.textTheme.titleSmall,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          ...List.generate(5, (index) {
                            return Icon(
                              index < review.rating
                                  ? Icons.star
                                  : Icons.star_border,
                              color: Colors.amber,
                              size: 16,
                            );
                          }),
                          const SizedBox(width: 8),
                          Text(
                            DateFormat.yMMMd().format(review.createdAt),
                            style: theme.textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (canEdit && onEdit != null)
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: onEdit,
                    tooltip: 'Editar reseña',
                  ),
              ],
            ),
            if (review.review != null && review.review!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                review.review!,
                style: theme.textTheme.bodyMedium,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
