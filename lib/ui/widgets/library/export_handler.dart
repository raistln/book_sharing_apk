import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../providers/book_providers.dart';
import '../../../services/book_export_service.dart';
import '../../../utils/file_export_helper.dart';
import 'library_utils.dart';

/// Handles library export functionality
class ExportHandler {
  /// Handles the export process for the library
  static Future<void> handle(BuildContext context, WidgetRef ref) async {
    final ctx = context;

    try {
      final repository = ref.read(bookRepositoryProvider);
      final exportService = ref.read(bookExportServiceProvider);

      final activeUser = ref.read(activeUserProvider).value;
      final books =
          await repository.fetchActiveBooks(ownerUserId: activeUser?.id);
      if (books.isEmpty) {
        if (!ctx.mounted) return;
        showFeedbackSnackBar(
          context: ctx,
          message: 'No hay libros para exportar.',
          isError: true,
        );
        return;
      }

      final reviews = await repository.fetchActiveReviews();

      if (!ctx.mounted) return;
      final format = await showModalBottomSheet<BookExportFormat>(
        context: ctx,
        builder: (sheetContext) => SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.table_rows_outlined),
                title: const Text('Exportar como CSV'),
                onTap: () =>
                    Navigator.of(sheetContext).pop(BookExportFormat.csv),
              ),
              ListTile(
                leading: const Icon(Icons.code),
                title: const Text('Exportar como JSON'),
                onTap: () =>
                    Navigator.of(sheetContext).pop(BookExportFormat.json),
              ),
              ListTile(
                leading: const Icon(Icons.picture_as_pdf_outlined),
                title: const Text('Exportar como PDF'),
                onTap: () =>
                    Navigator.of(sheetContext).pop(BookExportFormat.pdf),
              ),
            ],
          ),
        ),
      );

      if (format == null) {
        return;
      }

      if (!ctx.mounted) return;

      final action = await FileExportHelper.showExportActionSheet(ctx);
      if (action == null) return;

      final result = await exportService.export(
        books: books,
        reviews: reviews,
        format: format,
      );

      if (!ctx.mounted) return;

      await FileExportHelper.handleFileExport(
        context: ctx,
        bytes: result.bytes,
        fileName: result.fileName,
        mimeType: result.mimeType,
        action: action,
        onFeedback: (message, isError) {
          showFeedbackSnackBar(
            context: ctx,
            message: message,
            isError: isError,
          );
        },
      );
    } catch (err) {
      if (!ctx.mounted) return;
      showFeedbackSnackBar(
        context: ctx,
        message: 'No se pudo exportar: $err',
        isError: true,
      );
    }
  }
}
