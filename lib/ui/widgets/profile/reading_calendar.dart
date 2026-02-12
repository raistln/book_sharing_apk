import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ReadingCalendar extends StatelessWidget {
  const ReadingCalendar({super.key, required this.readBooks});

  final List<dynamic> readBooks; // List<Book>

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final months = <DateTime>[];
    for (int i = 11; i >= 0; i--) {
      months.add(DateTime(now.year, now.month - i, 1));
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        childAspectRatio: 1.0,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
      ),
      itemCount: 12,
      itemBuilder: (context, index) {
        final monthDate = months[index];
        final count = readBooks.where((b) {
          final date = (b.readAt as DateTime?);
          if (date == null) return false;
          return date.year == monthDate.year && date.month == monthDate.month;
        }).length;

        final isCurrentMonth =
            monthDate.month == now.month && monthDate.year == now.year;

        return ZenMonthTile(
          monthDate: monthDate,
          bookCount: count,
          isCurrentMonth: isCurrentMonth,
        );
      },
    );
  }
}

class ZenMonthTile extends StatelessWidget {
  final DateTime monthDate;
  final int bookCount;
  final bool isCurrentMonth;

  const ZenMonthTile({
    super.key,
    required this.monthDate,
    required this.bookCount,
    required this.isCurrentMonth,
  });

  @override
  Widget build(BuildContext context) {
    final baseColor = _getSeasonalColor(monthDate.month);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Tooltip(
      message:
          '${DateFormat('MMMM yyyy', 'es').format(monthDate)}: $bookCount ${bookCount == 1 ? 'libro' : 'libros'}',
      child: Container(
        decoration: BoxDecoration(
          color: isDark
              ? Colors.grey.shade900.withValues(alpha: 0.3)
              : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(16),
          border: isCurrentMonth
              ? Border.all(
                  color: baseColor.withValues(alpha: 0.6),
                  width: 2,
                )
              : Border.all(
                  color: Theme.of(context)
                      .colorScheme
                      .outlineVariant
                      .withValues(alpha: 0.2),
                  width: 1,
                ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              DateFormat('MMM', 'es').format(monthDate).toLowerCase(),
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.5),
                    letterSpacing: 0.5,
                  ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: Center(
                child: _buildStoneCairn(context, bookCount, baseColor),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStoneCairn(BuildContext context, int count, Color baseColor) {
    if (count == 0) {
      return CustomPaint(
        size: const Size(32, 32),
        painter: EnsoCirclePainter(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
        ),
      );
    }

    final stonesToShow = count > 5 ? 5 : count;
    final hasMore = count > 5;

    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.end,
      children: List.generate(stonesToShow, (i) {
        final isLast = i == stonesToShow - 1;
        final stoneIndex = stonesToShow - 1 - i;
        final size = _getStoneSize(stoneIndex, hasMore && isLast);
        final opacity = 0.4 + (i * 0.15);

        return Padding(
          padding: const EdgeInsets.only(bottom: 2.0),
          child: Stone(
            size: size,
            color: baseColor.withValues(alpha: opacity),
            hasNumber: hasMore && isLast,
            number: count,
          ),
        );
      }).reversed.toList(),
    );
  }

  double _getStoneSize(int index, bool isSpecial) {
    if (isSpecial) return 28;
    const baseSizes = [24.0, 20.0, 16.0, 14.0, 12.0];
    return baseSizes[index.clamp(0, baseSizes.length - 1)];
  }

  Color _getSeasonalColor(int month) {
    if (month >= 3 && month <= 5) {
      return const Color(0xFF8DA399);
    } else if (month >= 6 && month <= 8) {
      return const Color(0xFFA7C5EB);
    } else if (month >= 9 && month <= 11) {
      return const Color(0xFFE6C9A8);
    } else {
      return const Color(0xFFB5B5A6);
    }
  }
}

class Stone extends StatelessWidget {
  final double size;
  final Color color;
  final bool hasNumber;
  final int number;

  const Stone({
    super.key,
    required this.size,
    required this.color,
    this.hasNumber = false,
    this.number = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size * 0.7,
      decoration: BoxDecoration(
        gradient: RadialGradient(
          colors: [
            color.withValues(alpha: 0.9),
            color,
            color.withValues(alpha: 0.7),
          ],
          stops: const [0.0, 0.6, 1.0],
          center: const Alignment(-0.3, -0.3),
        ),
        borderRadius: BorderRadius.all(Radius.elliptical(size, size * 0.7)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: hasNumber
          ? Center(
              child: Text(
                '$number',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: size * 0.35,
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      blurRadius: 2,
                    ),
                  ],
                ),
              ),
            )
          : null,
    );
  }
}

class EnsoCirclePainter extends CustomPainter {
  final Color color;
  EnsoCirclePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 2;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -3.14 / 4,
      3.14 * 1.8,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
