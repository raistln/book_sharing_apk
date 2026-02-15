import 'package:flutter/material.dart';
import '../../../models/bookshelf_models.dart';

class BookshelfHeader extends StatelessWidget {
  final int bookCount;
  final ShelfThemeConfig themeConfig;

  const BookshelfHeader({
    super.key,
    required this.bookCount,
    required this.themeConfig,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                '$bookCount ${bookCount == 1 ? 'historia vivida' : 'historias vividas'}',
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: themeConfig.textColor,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Georgia',
                ),
              ),
              const Spacer(),
              Icon(
                Icons.auto_stories,
                color: themeConfig.accentColor.withValues(alpha: 0.5),
                size: 28,
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Cada lomo es un fragmento de tu vida',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: themeConfig.textColor.withValues(alpha: 0.6),
              fontStyle: FontStyle.italic,
              fontFamily: 'Georgia',
            ),
          ),
        ],
      ),
    );
  }
}
