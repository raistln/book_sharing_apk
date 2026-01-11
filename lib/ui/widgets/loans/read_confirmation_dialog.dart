import 'package:flutter/material.dart';

class ReadConfirmationDialog {
  static Future<bool> show(BuildContext context, String bookTitle,
      {String? borrowerName}) async {
    final titleText = borrowerName != null
        ? '¿$borrowerName ha leído este libro?'
        : '¿Has leído este libro?';

    final noText = borrowerName != null ? 'No, no lo leyó' : 'No lo he leído';
    final yesText = borrowerName != null ? 'Sí, lo leyó' : 'Sí, lo he leído';

    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false, // Must answer
      builder: (context) => AlertDialog(
        title: Text(titleText),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              bookTitle,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Esta información se usará para las estadísticas de lectura.',
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(noText),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(yesText),
          ),
        ],
      ),
    );
    return result ?? false; // Default to false if somehow dismissed
  }
}
