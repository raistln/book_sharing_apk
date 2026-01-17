import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../data/local/database.dart';
import '../../../../providers/book_providers.dart';
import '../../../../design_system/literary_shadows.dart';
import '../../../../design_system/literary_animations.dart';
import '../../../../models/book_genre.dart';

class BookList extends StatelessWidget {
  const BookList({
    super.key,
    required this.books,
    required this.onBookTap,
    required this.onAddReview,
    required this.onViewReviews,
    required this.onCreateManualLoan,
  });

  final List<Book> books;
  final Function(Book) onBookTap;
  final Function(Book) onAddReview;
  final Function(Book) onViewReviews;
  final Function(Book) onCreateManualLoan;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (books.isEmpty) {
      return Center(
        child: Text(
          'No se encontraron libros',
          style: theme.textTheme.bodyMedium,
        ),
      );
    }

    return ListView.separated(
      itemCount: books.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final book = books[index];
        return BookListTile(
          book: book,
          onTap: () => onBookTap(book),
          onAddReview: () => onAddReview(book),
          onViewReviews: () => onViewReviews(book),
          onCreateManualLoan: () => onCreateManualLoan(book),
        );
      },
    );
  }
}

class _RatingStars extends StatelessWidget {
  const _RatingStars({required this.average});

  final double average;

  @override
  Widget build(BuildContext context) {
    final stars = List<Widget>.generate(5, (index) {
      final starValue = index + 1;
      IconData icon;
      if (average >= starValue) {
        icon = Icons.star;
      } else if (average >= starValue - 0.5) {
        icon = Icons.star_half;
      } else {
        icon = Icons.star_border;
      }
      return Icon(icon, color: Colors.amber, size: 18);
    });

    return Row(mainAxisSize: MainAxisSize.min, children: stars);
  }
}

class BookListTile extends ConsumerWidget {
  const BookListTile({
    super.key,
    required this.book,
    required this.onTap,
    required this.onAddReview,
    required this.onViewReviews,
    required this.onCreateManualLoan,
  });

  final Book book;
  final VoidCallback onTap;
  final VoidCallback onAddReview;
  final VoidCallback onViewReviews;
  final VoidCallback onCreateManualLoan;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final statusColor = _getStatusColor(book.status, theme);
    final statusLabel = _getStatusLabel(book.status);

    return TapAnimation(
      onTap: onTap,
      child: Card(
        elevation: 0,
        shadowColor: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: theme.cardTheme.color ?? theme.colorScheme.surface,
            boxShadow: LiteraryShadows.forBookStatus(book.status, context),
          ),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Cover image
                  Container(
                    width: 60,
                    height: 90,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: theme.colorScheme.surfaceContainerHighest,
                      boxShadow: book.coverPath != null
                          ? LiteraryShadows.bookCoverShadow(context)
                          : null,
                    ),
                    child: book.coverPath != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.file(
                              File(book.coverPath!),
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) =>
                                  _buildPlaceholder(theme),
                            ),
                          )
                        : _buildPlaceholder(theme),
                  ),
                  const SizedBox(width: 16),
                  // Book info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          book.title,
                          style: theme.textTheme.titleMedium,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (book.author != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            book.author!,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                        if (book.genre != null) ...[
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.secondaryContainer,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              BookGenre.fromString(book.genre)?.label ??
                                  book.genre!,
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: theme.colorScheme.onSecondaryContainer,
                              ),
                            ),
                          ),
                        ],
                        if (book.isbn != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            'ISBN: ${book.isbn!}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                        // Reviews section
                        const SizedBox(height: 8),
                        _buildReviewsSection(context, ref, theme),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: statusColor.withValues(alpha: 0.6),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                    color: statusColor.withValues(alpha: 0.3)),
                              ),
                              child: Text(
                                statusLabel,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: statusColor,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            // Read status chip
                            InkWell(
                              onTap: () => _toggleReadStatus(ref, book),
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: book.isRead
                                      ? Colors.green.withValues(alpha: 0.2)
                                      : Colors.red.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color:
                                        book.isRead ? Colors.green : Colors.red,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      book.isRead
                                          ? Icons.check_circle
                                          : Icons.circle_outlined,
                                      size: 16,
                                      color: book.isRead
                                          ? Colors.green
                                          : Colors.red,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      book.isRead ? 'Leído' : 'No leído',
                                      style:
                                          theme.textTheme.bodySmall?.copyWith(
                                        color: book.isRead
                                            ? Colors.green
                                            : Colors.red,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const Spacer(),
                            // Action buttons
                            PopupMenuButton<String>(
                              icon: const Icon(Icons.more_vert),
                              onSelected: (action) {
                                switch (action) {
                                  case 'review':
                                    onAddReview();
                                    break;
                                  case 'reviews':
                                    onViewReviews();
                                    break;
                                  case 'loan':
                                    onCreateManualLoan();
                                    break;
                                }
                              },
                              itemBuilder: (context) => [
                                const PopupMenuItem(
                                  value: 'review',
                                  child: Row(
                                    children: [
                                      Icon(Icons.star_border),
                                      SizedBox(width: 8),
                                      Text('Añadir reseña'),
                                    ],
                                  ),
                                ),
                                const PopupMenuItem(
                                  value: 'reviews',
                                  child: Row(
                                    children: [
                                      Icon(Icons.rate_review),
                                      SizedBox(width: 8),
                                      Text('Ver reseñas'),
                                    ],
                                  ),
                                ),
                                if (book.status == 'available')
                                  const PopupMenuItem(
                                    value: 'loan',
                                    child: Row(
                                      children: [
                                        Icon(Icons.handshake_outlined),
                                        SizedBox(width: 8),
                                        Text('Crear préstamo manual'),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildReviewsSection(
      BuildContext context, WidgetRef ref, ThemeData theme) {
    final reviewsAsync = ref.watch(bookReviewsProvider(book.id));

    return reviewsAsync.when(
      data: (reviews) {
        if (reviews.isEmpty) {
          return Text(
            'Sin reseñas todavía',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          );
        }
        final avg = reviews
                .map((r) => r.rating)
                .fold<double>(0, (prev, value) => prev + value) /
            reviews.length;
        return InkWell(
          onTap: onViewReviews,
          borderRadius: BorderRadius.circular(4),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _RatingStars(average: avg),
                const SizedBox(width: 8),
                Text(
                  '${avg.toStringAsFixed(1)} / 5 · ${reviews.length} ${reviews.length == 1 ? 'reseña' : 'reseñas'}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Icon(Icons.chevron_right,
                    size: 14, color: theme.colorScheme.primary),
              ],
            ),
          ),
        );
      },
      loading: () => const SizedBox(
        width: 16,
        height: 16,
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
      error: (err, _) => Text(
        'Error cargando reseñas',
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.error,
        ),
      ),
    );
  }

  Widget _buildPlaceholder(ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: theme.colorScheme.surfaceContainerHighest,
      ),
      child: Icon(
        Icons.menu_book,
        size: 32,
        color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
      ),
    );
  }

  void _toggleReadStatus(WidgetRef ref, Book book) {
    ref.read(bookDaoProvider).toggleReadStatus(book.id, !book.isRead);
    // Invalidate provider to refresh UI
    ref.invalidate(bookListProvider);
  }

  Color _getStatusColor(String status, ThemeData theme) {
    switch (status) {
      case 'available':
        return Colors.blue; // Azul como en el formulario
      case 'loaned':
        return Colors.orange; // Naranja (consistente)
      case 'archived':
        return Colors.orange; // Naranja como en el formulario
      case 'private':
        return Colors.purple; // Púrpura como en el formulario
      default:
        return theme.colorScheme.outline;
    }
  }

  String _getStatusLabel(String status) {
    switch (status) {
      case 'available':
        return 'Disponible';
      case 'loaned':
        return 'Prestado';
      case 'archived':
        return 'Archivado';
      case 'private':
        return 'Privado';
      default:
        return status;
    }
  }
}
