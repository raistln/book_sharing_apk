import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../data/local/database.dart';
import '../../../utils/reading_rhythm_helper.dart'; // Import helper

class ReadingRhythmChart extends StatelessWidget {
  final ReadingRhythmData data;
  final Function(Book) onBookTap;

  const ReadingRhythmChart({
    super.key,
    required this.data,
    required this.onBookTap,
  });

  @override
  Widget build(BuildContext context) {
    if (data.rows.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Text(
            'No hay suficientes datos de lectura recientes.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = constraints.maxWidth;
        final chartWidth = maxWidth - 60; // Leave space for covers and padding

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Insight Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Theme.of(context)
                    .colorScheme
                    .primaryContainer
                    .withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.ssid_chart,
                    size: 18,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      data.insight,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Chart Rows
            Column(
              children: data.rows
                  .map((row) => _buildRow(context, row, chartWidth))
                  .toList(),
            ),

            const SizedBox(height: 16),

            // Months labels
            _buildMonthLabels(context, chartWidth),
          ],
        );
      },
    );
  }

  Widget _buildRow(BuildContext context, RhythmRow row, double chartWidth) {
    const rowHeight = 48.0;
    final totalDuration =
        data.endDate.difference(data.startDate).inMilliseconds;
    final safeDuration = totalDuration == 0 ? 1 : totalDuration;

    return InkWell(
      onTap: () => onBookTap(row.book),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        height: rowHeight,
        margin: const EdgeInsets.only(bottom: 8),
        child: Row(
          children: [
            // Book Cover placeholder
            Container(
              width: 32,
              height: 48,
              decoration: BoxDecoration(
                color: _getBookColor(context, row.book).withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(4),
                image: row.book.coverPath != null
                    ? DecorationImage(
                        image: FileImage(File(row.book.coverPath!)),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
            ),
            const SizedBox(width: 12),

            // Timeline Stack
            Expanded(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Divider(
                      color: Theme.of(context)
                          .dividerColor
                          .withValues(alpha: 0.1)),

                  // Title
                  IgnorePointer(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text(
                        row.book.title,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withValues(alpha: 0.35),
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                            ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),

                  // segments
                  ...row.segments.map((segment) {
                    final startOffset = segment.start
                            .difference(data.startDate)
                            .inMilliseconds /
                        safeDuration;
                    final durationPercent =
                        segment.end.difference(segment.start).inMilliseconds /
                            safeDuration;

                    final left =
                        (startOffset * chartWidth).clamp(0.0, chartWidth);
                    final width =
                        (durationPercent * chartWidth).clamp(2.0, chartWidth);

                    return Positioned(
                      left: left,
                      width: width,
                      height: 12,
                      child: Container(
                        decoration: BoxDecoration(
                          color: _getBookColor(context, row.book)
                              .withValues(alpha: segment.isPause ? 0.3 : 1.0),
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthLabels(BuildContext context, double chartWidth) {
    final months = <DateTime>[];
    DateTime current = DateTime(data.startDate.year, data.startDate.month, 1);
    while (current.isBefore(data.endDate)) {
      if (current.isAfter(data.startDate) ||
          current.month == data.startDate.month) {
        months.add(current);
      }
      current = DateTime(current.year, current.month + 1, 1);
    }

    if (months.isEmpty) return const SizedBox.shrink();

    final totalDuration =
        data.endDate.difference(data.startDate).inMilliseconds;
    final safeDuration = totalDuration == 0 ? 1 : totalDuration;

    return Padding(
      padding: const EdgeInsets.only(left: 44.0),
      child: SizedBox(
        height: 20,
        width: chartWidth,
        child: Stack(
          children: months.map((m) {
            double startOffset =
                m.difference(data.startDate).inMilliseconds / safeDuration;
            // Adjust for months that start slightly before the window
            if (startOffset < 0) startOffset = 0;

            final left = (startOffset * chartWidth).clamp(0.0, chartWidth);

            return Positioned(
              left: left,
              child: Text(
                DateFormat('MMM', 'es').format(m).toUpperCase(),
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.6),
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Color _getBookColor(BuildContext context, Book book) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final colors = isDark
        ? [
            Colors.blue.shade200,
            Colors.red.shade200,
            Colors.green.shade200,
            Colors.orange.shade200,
            Colors.purple.shade200,
            Colors.teal.shade200,
            Colors.indigo.shade200,
          ]
        : [
            Colors.blue.shade400,
            Colors.red.shade400,
            Colors.green.shade400,
            Colors.orange.shade400,
            Colors.purple.shade400,
            Colors.teal.shade400,
            Colors.indigo.shade400,
          ];

    return colors[book.id % colors.length];
  }
}
