import 'package:flutter/material.dart';
import '../../../../data/local/database.dart';

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
        return ListTile(
          onTap: () => onBookTap(book),
          dense: true,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
          title: Text(
            book.title,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
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
        );
      },
    );
  }
}
