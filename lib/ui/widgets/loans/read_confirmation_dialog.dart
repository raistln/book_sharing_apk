import 'package:flutter/material.dart';

class ReadConfirmationDialog {
  static Future<bool> show(BuildContext context, String bookTitle) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false, // Must answer
      builder: (context) => AlertDialog(
        title: const Text('¿Has leído este libro?'),
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
              'Esta información se usará para tus estadísticas de lectura.',
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
            child: const Text('No lo he leído'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Sí, lo he leído'),
          ),
        ],
      ),
    );
    return result ?? false; // Default to false if somehow dismissed
  }
}
