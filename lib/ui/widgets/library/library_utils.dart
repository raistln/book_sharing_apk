import 'package:file_saver/file_saver.dart';
import 'package:flutter/material.dart';

import '../empty_state.dart';

/// Export action enum for library export
enum ExportAction { share, download }

/// Shows a feedback snackbar with the given message
void showFeedbackSnackBar({
  required BuildContext context,
  required String message,
  required bool isError,
}) {
  final theme = Theme.of(context);
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor:
          isError ? theme.colorScheme.error : theme.colorScheme.primary,
    ),
  );
}

/// Maps file extension to MimeType for file_saver
MimeType mapMimeType(String extension) {
  switch (extension.toLowerCase()) {
    case 'pdf':
      return MimeType.pdf;
    case 'json':
      return MimeType.json;
    case 'csv':
      return MimeType.csv;
    default:
      return MimeType.other;
  }
}

/// Empty state widget for library
class EmptyLibraryState extends StatelessWidget {
  const EmptyLibraryState({super.key, required this.onAddBook});

  final VoidCallback onAddBook;

  @override
  Widget build(BuildContext context) {
    return EmptyState(
      icon: Icons.menu_book_outlined,
      title: 'Tu biblioteca está vacía',
      message:
          'Registra tu primer libro para organizar préstamos y compartir lecturas con tu grupo.',
      action: EmptyStateAction(
        label: 'Registrar libro',
        icon: Icons.add_circle_outline,
        onPressed: onAddBook,
      ),
    );
  }
}
