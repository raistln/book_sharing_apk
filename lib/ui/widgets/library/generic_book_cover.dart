import 'package:flutter/material.dart';

/// Reusable generic book cover using gradients and title hashing.
/// Inspired by the shared books in the discover groups view.
class GenericBookCover extends StatelessWidget {
  const GenericBookCover({
    super.key,
    required this.title,
    this.author,
  });

  final String title;
  final String? author;

  List<Color> _generateGradientColors() {
    final hash = title.hashCode;
    
    // Premium stable gradient palettes
    final palettes = [
      // Oceanic Blue
      [const Color(0xFF1E3C72), const Color(0xFF2A5298)],
      // Deep Purple
      [const Color(0xFF360033), const Color(0xFF0B8793)],
      // Forest Green
      [const Color(0xFF11998e), const Color(0xFF38ef7d)],
      // Sunset Orange
      [const Color(0xFFfc4a1a), const Color(0xFFf7b733)],
      // Royal Red-Pink
      [const Color(0xFF8A2387), const Color(0xFFE94057)],
      // Deep Space Cyan
      [const Color(0xFF0F2027), const Color(0xFF203A43)],
      // Warm Amber
      [const Color(0xFFF3904F), const Color(0xFF3B4371)],
      // Emerald Gold
      [const Color(0xFF0575E6), const Color(0xFF00F260)],
    ];
    
    final index = hash.abs() % palettes.length;
    return palettes[index];
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final gradientColors = _generateGradientColors();
    
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradientColors,
        ),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Soft bottom vignette for readability
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.05),
                  Colors.black.withValues(alpha: 0.5),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Spacer(flex: 2),
                Text(
                  title,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    height: 1.25,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                ),
                if (author != null && author!.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    author!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.white.withValues(alpha: 0.85),
                      fontSize: 9.5,
                      height: 1.15,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const Spacer(flex: 3),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
