import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../providers/book_providers.dart';
import '../../../providers/cover_refresh_providers.dart';
import '../../../l10n/generated/app_localizations.dart';
import 'library_utils.dart';

/// Handles cover refresh functionality for the library
class CoverRefreshHandler {
  /// Handles the cover refresh process
  static Future<void> handle(BuildContext context, WidgetRef ref) async {
    final ctx = context;

    final activeUser = ref.read(activeUserProvider).value;
    final coverRefreshService = ref.read(coverRefreshServiceProvider);

    if (!ctx.mounted) return;
    final confirmed = await showDialog<bool>(
      context: ctx,
      builder: (context) {
        final l10n = S.of(context);
        return AlertDialog(
          title: Text(l10n.refreshMetadata),
          content: Text(l10n.refreshMetadataWaitMessage),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, null),
              child: Text(l10n.cancel),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, false), // Normal
              child: Text(l10n.refreshOnlyMissing),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true), // Force
              child: Text(l10n.refreshForceAll),
            ),
          ],
        );
      },
    );

    if (confirmed == null || !ctx.mounted) return;

    // Show progress dialog
    showDialog(
      context: ctx,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Row(
          children: [
            const CircularProgressIndicator(),
            const SizedBox(width: 20),
            Expanded(child: Text(S.of(context).refreshingMetadata)),
          ],
        ),
      ),
    );

    try {
      final result = await coverRefreshService.refreshMissingMetadata(
        ownerUserId: activeUser?.id,
        force: confirmed,
      );

      if (!ctx.mounted) return;
      Navigator.pop(ctx); // Close progress dialog

      final l10n = S.of(ctx);
      final message = result.totalProcessed == 0
          ? l10n.refreshMetadataNone
          : l10n.refreshMetadataSuccess(result.successCount, result.totalProcessed);

      showFeedbackSnackBar(
        context: ctx,
        message: message,
        isError: result.successCount == 0 && result.totalProcessed > 0,
      );

      // Refresh the book list
      ref.invalidate(bookListProvider);
    } catch (e) {
      if (!ctx.mounted) return;
      Navigator.pop(ctx); // Close progress dialog
      showFeedbackSnackBar(
        context: ctx,
        message: S.of(ctx).refreshMetadataError(e.toString()),
        isError: true,
      );
    }
  }
}
