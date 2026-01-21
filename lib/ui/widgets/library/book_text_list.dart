import 'dart:io';
import 'package:flutter/material.dart';
import '../../../../data/local/database.dart';
import '../../../../design_system/library_visual_constants.dart';

class BookTextList extends StatelessWidget {
  const BookTextList({
    super.key,
    required this.books,
    required this.onBookTap,
  });

  final List<Book> books;
  final Function(Book) onBookTap;

  @override
  Widget build(BuildContext context) {
    if (books.isEmpty) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);

    return ListView.separated(
      padding: const EdgeInsets.only(bottom: 16),
      itemCount: books.length,
      separatorBuilder: (_, __) => Divider(
        height: 1,
        color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
      ),
      itemBuilder: (context, index) {
        final book = books[index];
        final tintColor = _getBackgroundColor(theme, book);
        final chip = _buildStatusChip(theme, book);

        return Container(
          color: tintColor,
          child: ListTile(
            onTap: () => onBookTap(book),
            dense: true,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            // Cover thumbnail could be added here if desired, prompt mentioned it but current impl doesn't have it.
            // Current impl: Title + Author.
            // If we want cover thumbnail:
            leading: book.coverPath != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: Image.file(
                      File(book.coverPath!),
                      width: 32,
                      height: 48,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          const Icon(Icons.book, size: 24),
                    ),
                  )
                : const Icon(Icons.book, size: 24, color: Colors.grey),
            title: Row(
              children: [
                Expanded(
                  child: Text(
                    book.title,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (chip != null) ...[
                  const SizedBox(width: 8),
                  chip,
                ],
              ],
            ),
            subtitle: book.author != null
                ? Text(
                    book.author!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  )
                : null,
            trailing: Icon(
              Icons.chevron_right,
              size: 16,
              color: theme.colorScheme.outline,
            ),
          ),
        );
      },
    );
  }

  Color _getBackgroundColor(ThemeData theme, Book book) {
    if (book.isBorrowedExternal) {
      return LibraryVisualConstants.getLoanedToYouTint(theme);
    }
    if (book.status == 'loaned') {
      return LibraryVisualConstants.getLoanedByYouTint(theme);
    }
    if (book.status == 'private' || !book.isPhysical) {
      return LibraryVisualConstants.getPrivateTint(theme);
    }
    return Colors.transparent; // Default list might be transparent or surface
  }

  Widget? _buildStatusChip(ThemeData theme, Book book) {
    String? label;
    Color? chipColor;
    Color? textColor;

    if (book.isBorrowedExternal) {
      label = book.externalLenderName != null
          ? 'De ${book.externalLenderName}'
          : 'Prestado';
      chipColor = LibraryVisualConstants.getLoanedToYouChipColor(theme);
      textColor = theme.colorScheme.primary;
    } else if (book.status == 'loaned') {
      label = 'Prestado';
      chipColor = LibraryVisualConstants.getLoanedChipColor(theme);
      textColor = theme.colorScheme.onSurface;
    } else if (book.status == 'private' || !book.isPhysical) {
      label = !book.isPhysical ? 'Digital' : 'Privado';
      chipColor = LibraryVisualConstants.getPrivateChipColor(theme);
      textColor = Colors.green.shade800;
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
}
