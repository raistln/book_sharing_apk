import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../providers/book_providers.dart';
import '../../../providers/cover_refresh_providers.dart';
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
      builder: (context) => AlertDialog(
        title: const Text('Actualizar metadatos'),
        content: const Text(
          'Se buscarán portadas y datos faltantes (páginas, año, género) para tus libros. '
          'Esto puede tardar varios minutos dependiendo de cuántos libros tengas.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Actualizar'),
          ),
        ],
      ),
    );

    if (confirmed != true || !ctx.mounted) return;

    // Show progress dialog
    showDialog(
      context: ctx,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 20),
            Expanded(child: Text('Actualizando metadatos...')),
          ],
        ),
      ),
    );

    try {
      final result = await coverRefreshService.refreshMissingMetadata(
        ownerUserId: activeUser?.id,
      );

      if (!ctx.mounted) return;
      Navigator.pop(ctx); // Close progress dialog

      final message = result.totalProcessed == 0
          ? 'Todos los libros ya tienen metadatos completos.'
          : 'Metadatos actualizados: ${result.successCount} de ${result.totalProcessed}.';

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
        message: 'Error al actualizar metadatos: $e',
        isError: true,
      );
    }
  }
}
