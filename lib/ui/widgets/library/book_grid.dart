import 'dart:io';
import 'package:flutter/material.dart';
import '../../../../data/local/database.dart';
import '../../../../design_system/literary_shadows.dart';
import '../../../../design_system/literary_animations.dart';
import '../../../../design_system/library_visual_constants.dart';

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
    this.isListView = false,
  });

  final Book book;
  final VoidCallback onTap;
  final bool isListView;

  Color _getBackgroundColor(ThemeData theme) {
    if (book.isBorrowedExternal) {
      return LibraryVisualConstants.getLoanedToYouTint(theme);
    }
    if (book.status == 'loaned') {
      return LibraryVisualConstants.getLoanedByYouTint(theme);
    }
    if (book.status == 'private' || !book.isPhysical) {
      return LibraryVisualConstants.getPrivateTint(theme);
    }
    return LibraryVisualConstants.getOwnedBookTint(theme);
  }

  Widget? _buildStatusChip(ThemeData theme) {
    String? label;
    Color? chipColor;
    Color? textColor;

    // Prioridad de etiquetas
    if (book.isBorrowedExternal) {
      label = book.externalLenderName != null
          ? 'De ${book.externalLenderName}'
          : 'Prestado';
      chipColor = LibraryVisualConstants.getLoanedToYouChipColor(theme);
      textColor = theme.colorScheme.primary; // Blue-ish
    } else if (book.status == 'loaned') {
      label = 'Prestado';
      chipColor = LibraryVisualConstants.getLoanedChipColor(theme);
      textColor = theme.colorScheme.onSurface;
    } else if (book.status == 'private' || !book.isPhysical) {
      label = !book.isPhysical ? 'Digital' : 'Privado';
      chipColor = LibraryVisualConstants.getPrivateChipColor(theme);
      textColor = Colors.green.shade800; // Green-ish
      if (theme.brightness == Brightness.dark)
        textColor = Colors.green.shade200;
    }

    if (label == null) return null;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: chipColor,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelSmall?.copyWith(
          color: textColor,
          fontWeight: FontWeight.bold,
          fontSize: 9,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final backgroundColor = _getBackgroundColor(theme);

    return TapAnimation(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Stack(
              children: [
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: backgroundColor,
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
                            errorBuilder: (_, __, ___) =>
                                _buildPlaceholder(theme, backgroundColor),
                          )
                        : _buildPlaceholder(theme, backgroundColor),
                  ),
                ),
                // Status Chip Positioned
                if (_buildStatusChip(theme) != null)
                  Positioned(
                    top: 6,
                    right: 6,
                    child: _buildStatusChip(theme)!,
                  ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 54,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(
                  height: 36,
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

  Widget _buildPlaceholder(ThemeData theme, Color bgColor) {
    return Container(
      color: bgColor,
      child: Center(
        child: Icon(
          Icons.menu_book,
          size: 32,
          color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
        ),
      ),
    );
  }
}
