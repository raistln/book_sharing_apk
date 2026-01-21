import 'package:flutter/material.dart';

import '../../../services/reading_rhythm_analyzer.dart';

/// Banner displaying narrative reading insight
class ReadingInsightBanner extends StatelessWidget {
  const ReadingInsightBanner({
    super.key,
    required this.insight,
  });

  final ReadingInsight insight;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            insight.color.withValues(alpha: 0.15),
            insight.color.withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: insight.color.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: insight.color.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                insight.icon,
                color: insight.color,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                insight.text,
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontStyle: FontStyle.italic,
                  color: theme.colorScheme.onSurface,
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
