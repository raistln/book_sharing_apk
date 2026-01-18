import 'dart:io';
import 'package:flutter/material.dart';
import '../../../../data/local/database.dart';
import '../../../../design_system/literary_shadows.dart';
import '../../../../design_system/literary_animations.dart';

class BookGridView extends StatelessWidget {
  const BookGridView({
    super.key,
    required this.books,
    required this.onBookTap,
  });

  final List<Book> books;
  final Function(Book) onBookTap;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.only(bottom: 16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 0.65,
        mainAxisSpacing: 16,
        crossAxisSpacing: 12,
      ),
      itemCount: books.length,
      itemBuilder: (context, index) {
        final book = books[index];
        return BookGridItem(
          book: book,
          onTap: () => onBookTap(book),
        );
      },
    );
  }
}

class BookGridItem extends StatelessWidget {
  const BookGridItem({
    super.key,
    required this.book,
    required this.onTap,
  });

  final Book book;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return TapAnimation(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: theme.colorScheme.surfaceContainerHighest,
                boxShadow: book.coverPath != null
                    ? LiteraryShadows.bookCoverShadow(context)
                    : null,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: book.coverPath != null
                    ? Image.file(
                        File(book.coverPath!),
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _buildPlaceholder(theme),
                      )
                    : _buildPlaceholder(theme),
              ),
            ),
          ),
          const SizedBox(height: 8),
          // Fixed height container for text footer to ensure alignment
          SizedBox(
            height: 54, // Adjusted height for ~3 lines of text
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                // Title: Reserves 2 lines.
                // Using a maxLines: 2 Text widget naturally takes up space.
                // To enforce "blank line if 1 line", we can't easily do it with standard Text widget
                // without advanced layout. However, the user said "solo en el caso que el titulo quepa en una fila".
                // Actually they said "los que le sobra una, que la ultima linea este en blanco."
                // This means checking text length? No, too complex.
                // Simpler: Just give the Text widget a fixed height for 2 lines.
                SizedBox(
                  height: 36, // Approx 2 lines * 18px
                  child: Text(
                    book.title,
                    style: theme.textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      height: 1.2,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (book.author != null)
                  Text(
                    book.author!,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      height: 1.2,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholder(ThemeData theme) {
    return Center(
      child: Icon(
        Icons.menu_book,
        size: 32,
        color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
      ),
    );
  }
}
