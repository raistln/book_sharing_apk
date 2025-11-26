import 'package:flutter/material.dart';

class LoanFeedbackBanner extends StatelessWidget {
  const LoanFeedbackBanner({
    super.key,
    required this.message,
    required this.isError,
    required this.onDismiss,
  });

  final String message;
  final bool isError;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final background =
        isError ? colorScheme.errorContainer : colorScheme.primaryContainer;
    final textColor =
        isError ? colorScheme.onErrorContainer : colorScheme.onPrimaryContainer;
    final icon = isError ? Icons.error_outline : Icons.check_circle_outline;

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 8),
      child: Container(
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: textColor),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: theme.textTheme.bodyMedium?.copyWith(color: textColor),
              ),
            ),
            IconButton(
              icon: Icon(Icons.close, color: textColor),
              onPressed: onDismiss,
              tooltip: 'Cerrar',
            ),
          ],
        ),
      ),
    );
  }
}
