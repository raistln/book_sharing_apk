import 'package:flutter/material.dart';
import '../../design_system/literary_animations.dart';

class EmptyStateAction {
  const EmptyStateAction({
    required this.label,
    required this.onPressed,
    this.icon,
    this.variant = EmptyStateActionVariant.filled,
  });

  final String label;
  final VoidCallback onPressed;
  final IconData? icon;
  final EmptyStateActionVariant variant;
}

enum EmptyStateActionVariant { filled, text }

class EmptyState extends StatelessWidget {
  const EmptyState({
    required this.icon,
    required this.title,
    required this.message,
    this.iconColor,
    this.padding = const EdgeInsets.all(24),
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.textAlign = TextAlign.center,
    this.action,
    this.secondaryAction,
    super.key,
  });

  final IconData icon;
  final String title;
  final String message;
  final Color? iconColor;
  final EdgeInsetsGeometry padding;
  final CrossAxisAlignment crossAxisAlignment;
  final TextAlign textAlign;
  final EmptyStateAction? action;
  final EmptyStateAction? secondaryAction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final iconColor = this.iconColor ?? theme.colorScheme.primary;

    return Padding(
      padding: padding,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: crossAxisAlignment,
          children: [
            FadeScaleIn(
              child: Icon(icon, size: 72, color: iconColor),
            ),
            const SizedBox(height: 16),
            FadeScaleIn(
              delay: const Duration(milliseconds: 100),
              child: Text(
                title,
                style: theme.textTheme.titleMedium,
                textAlign: textAlign,
              ),
            ),
            const SizedBox(height: 8),
            FadeScaleIn(
              delay: const Duration(milliseconds: 200),
              child: Text(
                message,
                style: theme.textTheme.bodyMedium,
                textAlign: textAlign,
              ),
            ),
            if (action != null || secondaryAction != null) ...[
              const SizedBox(height: 24),
              FadeScaleIn(
                delay: const Duration(milliseconds: 300),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildAction(context, action),
                    if (secondaryAction != null) ...[
                      const SizedBox(height: 12),
                      _buildAction(context, secondaryAction),
                    ],
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAction(BuildContext context, EmptyStateAction? action) {
    if (action == null) {
      return const SizedBox.shrink();
    }

    final icon = action.icon != null ? Icon(action.icon) : null;

    switch (action.variant) {
      case EmptyStateActionVariant.filled:
        return icon != null
            ? FilledButton.icon(
                onPressed: action.onPressed,
                icon: icon,
                label: Text(action.label),
              )
            : FilledButton(
                onPressed: action.onPressed,
                child: Text(action.label),
              );
      case EmptyStateActionVariant.text:
        return icon != null
            ? TextButton.icon(
                onPressed: action.onPressed,
                icon: icon,
                label: Text(action.label),
              )
            : TextButton(
                onPressed: action.onPressed,
                child: Text(action.label),
              );
    }
  }
}
