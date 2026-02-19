import 'dart:math';

import 'package:flutter/material.dart';

import '../../services/coach_marks/coach_mark_models.dart';

class CoachMarkOverlay extends StatelessWidget {
  const CoachMarkOverlay({
    super.key,
    required this.display,
    required this.onPrimary,
    required this.onSkip,
    this.onSecondary,
    this.onBarrierTap,
  });

  final CoachMarkDisplay display;
  final VoidCallback onPrimary;
  final VoidCallback onSkip;
  final VoidCallback? onSecondary;
  final VoidCallback? onBarrierTap;

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final size = mediaQuery.size;
    final safeInsets = mediaQuery.padding;

    final rawRect = display.targetRect;
    final clampedRect = Rect.fromLTRB(
      rawRect.left.clamp(0.0, max(0.0, size.width)),
      rawRect.top.clamp(0.0, max(0.0, size.height)),
      rawRect.right.clamp(0.0, max(0.0, size.width)),
      rawRect.bottom.clamp(0.0, max(0.0, size.height)),
    );

    final cardMaxWidth = min(size.width - 32, 360.0);
    final cardLeft = (clampedRect.center.dx - cardMaxWidth / 2)
        .clamp(16.0, size.width - 16.0 - cardMaxWidth);

    final availableTop = clampedRect.top - safeInsets.top;
    final availableBottom =
        size.height - safeInsets.bottom - clampedRect.bottom;
    const estimatedCardHeight = 200.0;

    bool placeAbove;
    switch (display.config.contentPosition) {
      case CoachMarkContentPosition.above:
        placeAbove = true;
        break;
      case CoachMarkContentPosition.below:
        placeAbove = false;
        break;
      case CoachMarkContentPosition.auto:
        if (availableBottom >= estimatedCardHeight ||
            availableBottom >= availableTop) {
          placeAbove = false;
        } else {
          placeAbove = true;
        }
        break;
    }

    final card = Positioned(
      left: cardLeft,
      width: cardMaxWidth,
      top:
          placeAbove ? null : max(clampedRect.bottom + 16, safeInsets.top + 16),
      bottom: placeAbove
          ? max(size.height - clampedRect.top + 16, safeInsets.bottom + 16)
          : null,
      child: _CoachMarkCard(
        title: display.config.title,
        description: display.config.description,
        primaryLabel: display.config.primaryActionLabel ?? 'Entendido',
        secondaryLabel: display.config.secondaryActionLabel,
        onPrimary: onPrimary,
        onSecondary: onSecondary,
        onSkip: onSkip,
      ),
    );

    return IgnorePointer(
      ignoring: onBarrierTap == null,
      child: Stack(
        fit: StackFit.expand,
        children: [
          _CoachMarkBarrier(
            rect: clampedRect,
            cornerRadius: display.config.cornerRadius,
            onBarrierTap: onBarrierTap,
          ),
          Positioned.fromRect(
            rect: clampedRect,
            child: IgnorePointer(
              ignoring: true,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(
                      Radius.circular(display.config.cornerRadius)),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.8),
                    width: 2,
                  ),
                ),
              ),
            ),
          ),
          card,
        ],
      ),
    );
  }
}

class _CoachMarkBarrier extends StatelessWidget {
  const _CoachMarkBarrier({
    required this.rect,
    required this.cornerRadius,
    this.onBarrierTap,
  });

  final Rect rect;
  final double cornerRadius;
  final VoidCallback? onBarrierTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onBarrierTap,
      child: CustomPaint(
        painter: _CoachMarkBarrierPainter(
          rect: rect,
          cornerRadius: cornerRadius,
          overlayColor: Colors.black.withValues(alpha: 0.65),
        ),
      ),
    );
  }
}

class _CoachMarkBarrierPainter extends CustomPainter {
  _CoachMarkBarrierPainter({
    required this.rect,
    required this.cornerRadius,
    required this.overlayColor,
  });

  final Rect rect;
  final double cornerRadius;
  final Color overlayColor;

  @override
  void paint(Canvas canvas, Size size) {
    final backgroundPath = Path()..addRect(Offset.zero & size);
    final highlightPath = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          rect,
          Radius.circular(cornerRadius),
        ),
      );

    final overlayPath = Path.combine(
      PathOperation.difference,
      backgroundPath,
      highlightPath,
    );

    final paint = Paint()
      ..color = overlayColor
      ..style = PaintingStyle.fill;

    canvas.drawPath(overlayPath, paint);
  }

  @override
  bool shouldRepaint(covariant _CoachMarkBarrierPainter oldDelegate) {
    return rect != oldDelegate.rect ||
        cornerRadius != oldDelegate.cornerRadius ||
        overlayColor != oldDelegate.overlayColor;
  }
}

class _CoachMarkCard extends StatelessWidget {
  const _CoachMarkCard({
    required this.title,
    required this.description,
    required this.primaryLabel,
    required this.onPrimary,
    required this.onSkip,
    this.secondaryLabel,
    this.onSecondary,
  });

  final String title;
  final String description;
  final String primaryLabel;
  final String? secondaryLabel;
  final VoidCallback onPrimary;
  final VoidCallback onSkip;
  final VoidCallback? onSecondary;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Material(
      elevation: 6,
      borderRadius: BorderRadius.circular(16),
      color: theme.colorScheme.surface,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: onSkip,
                  child: const Text('Saltar'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                if (secondaryLabel != null && onSecondary != null)
                  TextButton(
                    onPressed: onSecondary,
                    child: Text(secondaryLabel!),
                  ),
                const Spacer(),
                FilledButton(
                  onPressed: onPrimary,
                  child: Text(primaryLabel),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
