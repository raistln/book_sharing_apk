import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../data/local/database.dart';
import '../../../providers/book_providers.dart';
import 'library_utils.dart';

/// Review draft model
class ReviewDraft {
  const ReviewDraft({required this.rating, this.review});

  final int rating;
  final String? review;
}

/// Shows dialog to add a review for a book
Future<void> showAddReviewDialog(
  BuildContext context,
  WidgetRef ref,
  Book book,
) async {
  final repository = ref.read(bookRepositoryProvider);
  final theme = Theme.of(context);
  final controller = TextEditingController();
  var rating = 5;

  ReviewDraft? draft;

  try {
    draft = await showDialog<ReviewDraft>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text('Añadir reseña a "${book.title}"'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Puntuación',
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(5, (index) {
                    final starValue = index + 1;
                    final isActive = starValue <= rating;
                    return IconButton(
                      onPressed: () => setState(() {
                        rating = starValue;
                      }),
                      icon: Icon(
                        isActive ? Icons.star : Icons.star_border,
                        color: Colors.amber,
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: controller,
                  minLines: 2,
                  maxLines: 5,
                  decoration: const InputDecoration(
                    labelText: 'Escribe una reseña (opcional)',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancelar'),
              ),
              FilledButton(
                onPressed: () {
                  Navigator.of(context).pop(
                    ReviewDraft(
                      rating: rating,
                      review: controller.text.trim().isEmpty
                          ? null
                          : controller.text.trim(),
                    ),
                  );
                },
                child: const Text('Guardar'),
              ),
            ],
          );
        },
      ),
    );
  } finally {
    controller.dispose();
  }

  if (draft == null) {
    return;
  }

  final activeUser = await ref.read(userRepositoryProvider).getActiveUser();
  if (activeUser == null) {
    if (!context.mounted) return;
    showFeedbackSnackBar(
      context: context,
      message: 'Crea un usuario antes de añadir reseñas.',
      isError: true,
    );
    return;
  }

  try {
    await repository.addReview(
      book: book,
      rating: draft.rating,
      review: draft.review,
      author: activeUser,
    );
    if (!context.mounted) return;
    showFeedbackSnackBar(
      context: context,
      message: 'Reseña añadida.',
      isError: false,
    );
  } catch (err) {
    if (!context.mounted) return;
    showFeedbackSnackBar(
      context: context,
      message: 'Error al guardar reseña: $err',
      isError: true,
    );
  }
}

/// Shows dialog with list of reviews for a book
Future<void> showReviewsListDialog(
  BuildContext context,
  WidgetRef ref,
  Book book,
) async {
  await showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text('Reseñas de "${book.title}"'),
        content: SizedBox(
          width: double.maxFinite,
          child: Consumer(
            builder: (context, ref, child) {
              final reviewsAsync = ref.watch(bookReviewsProvider(book.id));
              final theme = Theme.of(context);

              return reviewsAsync.when(
                data: (reviews) {
                  if (reviews.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.all(32),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.reviews_outlined, size: 48),
                          SizedBox(height: 16),
                          Text(
                            'No hay reseñas todavía',
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.separated(
                    shrinkWrap: true,
                    itemCount: reviews.length,
                    separatorBuilder: (_, __) => const Divider(),
                    itemBuilder: (context, index) {
                      final review = reviews[index];
                      return FutureBuilder<LocalUser?>(
                        future: ref
                            .read(loanRepositoryProvider)
                            .findUserById(review.authorUserId),
                        builder: (context, snapshot) {
                          final authorName =
                              snapshot.data?.username ?? 'Usuario desconocido';

                          return ListTile(
                            contentPadding: EdgeInsets.zero,
                            title: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    authorName,
                                    style: theme.textTheme.titleSmall,
                                  ),
                                ),
                                ...List.generate(5, (starIndex) {
                                  return Icon(
                                    starIndex < review.rating
                                        ? Icons.star
                                        : Icons.star_border,
                                    color: Colors.amber,
                                    size: 16,
                                  );
                                }),
                              ],
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 4),
                                Text(
                                  DateFormat.yMMMd().format(review.createdAt),
                                  style: theme.textTheme.bodySmall,
                                ),
                                if (review.review != null &&
                                    review.review!.isNotEmpty) ...[
                                  const SizedBox(height: 8),
                                  Text(
                                    review.review!,
                                    style: theme.textTheme.bodyMedium,
                                  ),
                                ],
                              ],
                            ),
                          );
                        },
                      );
                    },
                  );
                },
                loading: () => const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: CircularProgressIndicator(),
                  ),
                ),
                error: (error, _) => Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.error_outline, size: 48),
                      const SizedBox(height: 16),
                      Text(
                        'Error al cargar reseñas: $error',
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      );
    },
  );
}
