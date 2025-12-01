import 'package:file_saver/file_saver.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:share_plus/share_plus.dart';

import '../../../providers/book_providers.dart';
import '../../../services/book_export_service.dart';
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
      final books = await repository.fetchActiveBooks(ownerUserId: activeUser?.id);
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
                onTap: () => Navigator.of(sheetContext).pop(BookExportFormat.csv),
              ),
              ListTile(
                leading: const Icon(Icons.code),
                title: const Text('Exportar como JSON'),
                onTap: () => Navigator.of(sheetContext).pop(BookExportFormat.json),
              ),
              ListTile(
                leading: const Icon(Icons.picture_as_pdf_outlined),
                title: const Text('Exportar como PDF'),
                onTap: () => Navigator.of(sheetContext).pop(BookExportFormat.pdf),
              ),
            ],
          ),
        ),
      );

      if (format == null) {
        return;
      }

      if (!ctx.mounted) return;
      final action = await showModalBottomSheet<ExportAction>(
        context: ctx,
        builder: (sheetContext) => SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.ios_share),
                title: const Text('Compartir archivo'),
                subtitle: const Text('Enviar el archivo generado a otras apps.'),
                onTap: () => Navigator.of(sheetContext).pop(ExportAction.share),
              ),
              ListTile(
                leading: const Icon(Icons.download_outlined),
                title: const Text('Descargar archivo'),
                subtitle: const Text('Guardar el archivo localmente en el dispositivo.'),
                onTap: () => Navigator.of(sheetContext).pop(ExportAction.download),
              ),
            ],
          ),
        ),
      );

      if (action == null) {
        return;
      }

      final result = await exportService.export(
        books: books,
        reviews: reviews,
        format: format,
      );

      if (action == ExportAction.share) {
        final file = XFile.fromData(
          result.bytes,
          mimeType: result.mimeType,
          name: result.fileName,
        );

        await Share.shareXFiles(
          [file],
          subject: 'Mi biblioteca exportada',
          text: 'Te comparto mi biblioteca en formato ${format.name.toUpperCase()}.',
        );
      } else {
        final name = p.basenameWithoutExtension(result.fileName);
        final extension = p.extension(result.fileName).replaceFirst('.', '');
        await FileSaver.instance.saveFile(
          name: name,
          bytes: result.bytes,
          ext: extension,
          mimeType: mapMimeType(extension),
        );

        if (!ctx.mounted) return;
        showFeedbackSnackBar(
          context: ctx,
          message: 'Archivo guardado como ${result.fileName}.',
          isError: false,
        );
      }
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
