import 'dart:io';

import 'package:file_saver/file_saver.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';

import '../ui/widgets/library/library_utils.dart'; // For showFeedbackSnackBar if needed, or we implement a helper here

enum ExportAction { share, download }

class FileExportHelper {
  static Future<ExportAction?> showExportActionSheet(BuildContext context) {
    return showModalBottomSheet<ExportAction>(
      context: context,
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
              subtitle: const Text(
                'Guardar el archivo localmente en el dispositivo.',
              ),
              onTap: () =>
                  Navigator.of(sheetContext).pop(ExportAction.download),
            ),
          ],
        ),
      ),
    );
  }

  static Future<void> handleFileExport({
    required BuildContext context,
    required Uint8List bytes,
    required String fileName,
    required String mimeType,
    required ExportAction action,
    required Function(String message, bool isError) onFeedback,
  }) async {
    try {
      if (action == ExportAction.share) {
        final file = XFile.fromData(
          bytes,
          mimeType: mimeType,
          name: fileName,
        );

        await Share.shareXFiles(
          [file],
          subject: 'Archivo exportado',
          text: 'Te comparto este archivo exportado.',
        );
      } else {
        if (Platform.isAndroid) {
          // Attempt to save directly to Downloads folder on Android
          try {
            // Check storage permissions first
            // Note: On Android 13+, 'storage' permission is less relevant for writing to public downloads,
            // but we check it for compatibility with older versions (Android < 11).
            var status = await Permission.storage.status;
            if (!status.isGranted) {
              await Permission.storage.request();
            }

            // Explicitly target the standard Downloads directory
            final downloadDir = Directory('/storage/emulated/0/Download');
            if (!downloadDir.existsSync()) {
              // Try to create it if it doesn't exist (unlikely)
              try {
                downloadDir.createSync(recursive: true);
              } catch (_) {
                // Ignore creation error, it might already exist or be read-only root protected,
                // but usually /storage/emulated/0/Download is writable.
              }
            }

            final filePath = p.join(downloadDir.path, fileName);

            // Generate unique name if exists
            String finalPath = filePath;
            int counter = 1;
            while (await File(finalPath).exists()) {
              final name = p.basenameWithoutExtension(fileName);
              final ext = p.extension(fileName);
              finalPath = p.join(downloadDir.path, '$name ($counter)$ext');
              counter++;
            }

            final file = File(finalPath);
            await file.writeAsBytes(bytes);

            if (!context.mounted) return;
            onFeedback('Archivo guardado en: $finalPath', false);
            return; // Success, exit
          } catch (e) {
            if (kDebugMode) {
              debugPrint('Failed to save directly to Downloads: $e');
            }
            // If direct save fails (e.g. Scoped Storage restrictions on some weird devices),
            // fall back to FileSaver below.
          }
        }

        // Fallback or non-Android logic
        final name = p.basenameWithoutExtension(fileName);
        final extension = p.extension(fileName).replaceFirst('.', '');

        final savedPath = await FileSaver.instance.saveFile(
          name: name,
          bytes: bytes,
          ext: extension,
          mimeType: mapMimeType(extension),
        );

        if (!context.mounted) return;

        onFeedback(
          'Archivo guardado correctamente${savedPath.isNotEmpty ? ' en $savedPath' : '.'}',
          false,
        );
      }
    } catch (err) {
      if (kDebugMode) {
        debugPrint('Export Error: $err');
      }
      if (!context.mounted) return;
      onFeedback('Error al exportar: $err', true);
    }
  }
}
