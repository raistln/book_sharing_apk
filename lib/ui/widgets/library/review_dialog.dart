import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../data/local/database.dart';
import '../../../models/recommendation_level.dart';
import '../../../providers/book_providers.dart';
import '../../../utils/share_utils.dart';
import '../../../l10n/generated/app_localizations.dart';
import 'library_utils.dart';
import 'recommendation_selector.dart';

/// Review draft model
class ReviewDraft {
  const ReviewDraft({required this.level, this.review});

  final RecommendationLevel level;
  final String? review;
}

/// Shows dialog to add a review for a book
Future<void> showAddReviewDialog(
  BuildContext context,
  WidgetRef ref,
  Book book,
) async {
  final repository = ref.read(bookRepositoryProvider);
  final controller = TextEditingController();
  var selectedLevel = RecommendationLevel.recommendToSimilar;

  ReviewDraft? draft;

  try {
    draft = await showDialog<ReviewDraft>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) {
          final l10n = S.of(context);
          return AlertDialog(
            title: Text(l10n.reviewDialogTitle(book.title)),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RecommendationSelector(
                    selectedLevel: selectedLevel,
                    onChanged: (level) => setState(() {
                      selectedLevel = level;
                    }),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: controller,
                    minLines: 2,
                    maxLines: 5,
                    decoration: InputDecoration(
                      labelText: l10n.reviewDialogOptionalComment,
                      border: const OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(l10n.cancel),
              ),
              FilledButton(
                onPressed: () {
                  Navigator.of(context).pop(
                    ReviewDraft(
                      level: selectedLevel,
                      review: controller.text.trim().isEmpty
                          ? null
                          : controller.text.trim(),
                    ),
                  );
                },
                child: Text(l10n.save),
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
      message: S.of(context).reviewWidgetActiveUser,
      isError: true,
    );
    return;
  }

  try {
    await repository.addReview(
      book: book,
      rating: draft.level.value,
      review: draft.review,
      author: activeUser,
    );
    if (!context.mounted) return;
    showFeedbackSnackBar(
      context: context,
      message: S.of(context).reviewDialogAdded,
      isError: false,
    );

    // 💡 NEW: If recommendation is positive, ask to share
    if (draft.level == RecommendationLevel.recommendToSimilar ||
        draft.level == RecommendationLevel.mustRead) {
      if (!context.mounted) return;

      final bool? wantToShare = await showDialog<bool>(
        context: context,
        builder: (context) {
          final l10n = S.of(context);
          return AlertDialog(
            title: Text(l10n.reviewDialogRecommendTitle),
            content: Text(l10n.reviewDialogRecommendMessage),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(l10n.reviewDialogNotNow),
              ),
              FilledButton.icon(
                onPressed: () => Navigator.pop(context, true),
                icon: const Icon(Icons.share_outlined),
                label: Text(l10n.reviewDialogRecommend),
              ),
            ],
          );
        },
      );

      if (wantToShare == true) {
        await ShareUtils.shareBookRecommendation(book);
      }
    }
  } catch (err) {
    if (!context.mounted) return;
    showFeedbackSnackBar(
      context: context,
      message: S.of(context).reviewWidgetError(err.toString()),
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
        title: Text(S.of(context).reviewDialogListTitle(book.title)),
        content: SizedBox(
          width: double.maxFinite,
          child: Consumer(
            builder: (context, ref, child) {
              final reviewsAsync = ref.watch(bookReviewsProvider(book.id));
              final theme = Theme.of(context);

              return reviewsAsync.when(
                data: (reviews) {
                  if (reviews.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.reviews_outlined, size: 48),
                          const SizedBox(height: 16),
                          Text(
                            S.of(context).noReviewsYet,
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
                      final item = reviews[index];
                      final review = item.review;
                      final author = item.author;
                      final level =
                          RecommendationLevel.fromValue(review.rating);

                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: CircleAvatar(
                          backgroundColor: level.color.withValues(alpha: 0.1),
                          child: Icon(level.icon, color: level.color, size: 20),
                        ),
                        title: Row(
                          children: [
                            Expanded(
                              child: Text(
                                author.username,
                                style: theme.textTheme.titleSmall,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: level.color.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                    color: level.color.withValues(alpha: 0.2)),
                              ),
                              child: Text(
                                level.shortLabel(context),
                                style: theme.textTheme.labelSmall
                                    ?.copyWith(color: level.color),
                              ),
                            ),
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
                        S.of(context).reviewWidgetErrorLoad(error.toString()),
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
            child: Text(S.of(context).close),
          ),
        ],
      );
    },
  );
}
