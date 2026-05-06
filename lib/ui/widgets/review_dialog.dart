import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/local/database.dart';
import '../../providers/book_providers.dart';
import '../../l10n/generated/app_localizations.dart';

/// Dialog for creating or editing a book review
class ReviewDialog extends ConsumerStatefulWidget {
  const ReviewDialog({
    required this.book,
    this.existingReview,
    super.key,
  });

  final Book book;
  final BookReview? existingReview;

  @override
  ConsumerState<ReviewDialog> createState() => _ReviewDialogState();
}

class _ReviewDialogState extends ConsumerState<ReviewDialog> {
  late int _rating;
  late TextEditingController _reviewController;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _rating = widget.existingReview?.rating ?? 3;
    _reviewController = TextEditingController(
      text: widget.existingReview?.review ?? '',
    );
  }

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }

  Future<void> _submitReview() async {
    if (_isSubmitting) return;

    setState(() => _isSubmitting = true);

    try {
      final activeUser = await ref.read(userRepositoryProvider).getActiveUser();
      if (activeUser == null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(S.of(context).reviewWidgetActiveUser)),
        );
        return;
      }

      await ref.read(bookRepositoryProvider).addReview(
            book: widget.book,
            rating: _rating,
            review: _reviewController.text.trim().isEmpty
                ? null
                : _reviewController.text.trim(),
            author: activeUser,
          );

      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(S.of(context).errorGeneric(error.toString()))),
      );
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      title: Text(widget.existingReview == null
          ? S.of(context).reviewDialogWriteTitle
          : S.of(context).reviewListEdit),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.book.title,
              style: theme.textTheme.titleMedium,
            ),
            if (widget.book.author != null) ...[
              const SizedBox(height: 4),
              Text(
                S.of(context).reviewDialogByAuthor(widget.book.author!),
                style: theme.textTheme.bodySmall,
              ),
            ],
            const SizedBox(height: 24),
            Text(
              S.of(context).reviewWidgetRating,
              style: theme.textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                final starValue = index + 1;
                return IconButton(
                  icon: Icon(
                    starValue <= _rating ? Icons.star : Icons.star_border,
                    color: Colors.amber,
                    size: 32,
                  ),
                  onPressed: () {
                    setState(() => _rating = starValue);
                  },
                );
              }),
            ),
            const SizedBox(height: 16),
            Text(
              S.of(context).reviewDialogOptionalComment,
              style: theme.textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _reviewController,
              maxLines: 4,
              maxLength: 500,
              decoration: InputDecoration(
                hintText: S.of(context).reviewDialogCommentHint,
                border: const OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSubmitting ? null : () => Navigator.pop(context),
          child: Text(S.of(context).cancel),
        ),
        FilledButton(
          onPressed: _isSubmitting ? null : _submitReview,
          child: _isSubmitting
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(S.of(context).save),
        ),
      ],
    );
  }
}
