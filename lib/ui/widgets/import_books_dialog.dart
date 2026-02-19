import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as path;

import '../../providers/book_providers.dart';
import '../../providers/import_providers.dart';

class ImportBooksDialog extends ConsumerStatefulWidget {
  const ImportBooksDialog({super.key});

  @override
  ConsumerState<ImportBooksDialog> createState() => _ImportBooksDialogState();
}

class _ImportBooksDialogState extends ConsumerState<ImportBooksDialog> {
  bool _isImporting = false;
  String? _error;
  String? _successMessage;

  Future<void> _importFile() async {
    try {
      setState(() {
        _isImporting = true;
        _error = null;
        _successMessage = null;
      });

      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv', 'json'],
        allowMultiple: false,
      );

      if (result == null || result.files.isEmpty) {
        setState(() {
          _isImporting = false;
        });
        return;
      }

      final file = result.files.single;
      final fileData = File(file.path!).readAsBytesSync();
      final extension = path.extension(file.name).toLowerCase();
      final activeUser = ref.read(activeUserProvider).value;

      if (activeUser == null) {
        setState(() {
          _error = 'No hay usuario activo para importar los libros.';
        });
        return;
      }

      final importService = ref.read(bookImportServiceProvider);
      final importResult = extension == '.csv'
          ? await importService.importFromCsv(fileData, owner: activeUser)
          : extension == '.json'
              ? await importService.importFromJson(fileData, owner: activeUser)
              : throw UnsupportedError('Formato de archivo no soportado');

      setState(() {
        if (importResult.successCount > 0) {
          var message =
              'Se importaron ${importResult.successCount} libros correctamente';
          if (importResult.failureCount > 0) {
            message = '$message (${importResult.failureCount} fallidos)';
          }
          _successMessage = message;
        } else {
          var error = 'No se pudo importar ningún libro';
          if (importResult.errors.isNotEmpty) {
            final errorMsg = importResult.errors.first;
            final moreErrors = importResult.errors.length > 1
                ? ' (y ${importResult.errors.length - 1} más...)'
                : '';
            error = '$errorMsg$moreErrors';
          }
          _error = error;
        }
      });
    } catch (e) {
      setState(() {
        _error = 'Error al importar: $e';
      });
    } finally {
      setState(() {
        _isImporting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Importar libros'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
                'Selecciona un archivo CSV o JSON para importar tus libros.'),
            const SizedBox(height: 16),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Text(
                  _error!,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                  ),
                ),
              ),
            if (_successMessage != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Text(
                  _successMessage!,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isImporting ? null : () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: _isImporting ? null : _importFile,
          child: _isImporting
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Seleccionar archivo'),
        ),
      ],
    );
  }
}
