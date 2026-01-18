import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import 'package:intl/intl.dart';
import '../../../data/local/database.dart';
import '../../../models/book_genre.dart';
import '../../../providers/book_providers.dart';
import 'book_form_sheet.dart';
import 'review_dialog.dart';

class BookDetailsPage extends ConsumerWidget {
  const BookDetailsPage({
    super.key,
    required this.bookId,
  });

  final int bookId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the specific book to react to changes
    final bookAsync = ref.watch(bookStreamProvider(bookId));
    final reviewsAsync = ref.watch(bookReviewsProvider(bookId));

    return Scaffold(
      appBar: AppBar(
        actions: [
          bookAsync.when(
            data: (book) => book != null
                ? IconButton(
                    icon: const Icon(Icons.edit_outlined),
                    tooltip: 'Editar',
                    onPressed: () => _openEditSheet(context, book),
                  )
                : const SizedBox.shrink(),
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),
          bookAsync.when(
            data: (book) => book != null
                ? IconButton(
                    icon: const Icon(Icons.share_outlined),
                    tooltip: 'Compartir',
                    onPressed: () => _shareBook(book),
                  )
                : const SizedBox.shrink(),
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),
        ],
      ),
      body: bookAsync.when(
        data: (book) {
          if (book == null) {
            return const Center(child: Text('Libro no encontrado'));
          }
          final reviews = reviewsAsync.asData?.value ?? [];
          return _BookDetailsContent(book: book, reviews: reviews);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text('Error al cargar el libro: $error'),
        ),
      ),
    );
  }

  void _openEditSheet(BuildContext context, Book book) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => BookFormSheet(initialBook: book),
    );
  }

  void _shareBook(Book book) {
    final text = 'Me he acordado de ti al leer este libro 📚\n\n'
        '"${book.title}"${book.author != null ? ' de ${book.author}' : ''}\n\n'
        '¡Descárgate PassTheBook para compartir lecturas!';
    unawaited(Share.share(text));
  }
}

class _BookDetailsContent extends ConsumerWidget {
  const _BookDetailsContent({required this.book, required this.reviews});

  final Book book;
  final List<BookReview> reviews;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 200,
                maxHeight: 300,
              ),
              child: Hero(
                tag: 'book_cover_${book.id}',
                child: Material(
                  elevation: 8,
                  shadowColor: Colors.black26,
                  borderRadius: BorderRadius.circular(12),
                  clipBehavior: Clip.antiAlias,
                  child: book.coverPath != null
                      ? Image.file(
                          File(book.coverPath!),
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                              _buildPlaceholder(theme),
                        )
                      : _buildPlaceholder(theme),
                ),
              ),
            ),
          ),
          const SizedBox(height: 32),
          Text(
            book.title,
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          if (book.author != null) ...[
            const SizedBox(height: 8),
            Text(
              book.author!,
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.secondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
          if (book.pageCount != null || book.publicationYear != null) ...[
            const SizedBox(height: 4),
            Text(
              [
                if (book.pageCount != null) '${book.pageCount} páginas',
                if (book.publicationYear != null) '${book.publicationYear}',
              ].join(' • '),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
          const SizedBox(height: 24),
          Center(
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: [
                ...BookGenre.fromCsv(book.genre).map((g) => Chip(
                      avatar: const Icon(Icons.category_outlined, size: 18),
                      label: Text(g.label),
                    )),
                if (!book.isPhysical)
                  Chip(
                    avatar: const Icon(Icons.tablet_mac,
                        size: 18, color: Colors.purple),
                    label: const Text('Digital',
                        style: TextStyle(
                            color: Colors.purple, fontWeight: FontWeight.bold)),
                    backgroundColor: Colors.purple.shade50,
                    side: BorderSide(color: Colors.purple.shade200),
                  ),
                if (book.isPhysical)
                  Chip(
                    avatar:
                        const Icon(Icons.book, size: 18, color: Colors.blue),
                    label: const Text('Físico',
                        style: TextStyle(
                            color: Colors.blue, fontWeight: FontWeight.bold)),
                    backgroundColor: Colors.blue.shade50,
                    side: BorderSide(color: Colors.blue.shade200),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          _buildInfoSection(theme, 'Estado de lectura'),
          const SizedBox(height: 16),
          SwitchListTile(
            title: const Text('Marcar como leído'),
            subtitle: Text(book.isRead
                ? 'Ya has leído este libro'
                : 'Aún no has leído este libro'),
            value: book.isRead,
            onChanged: (val) => _toggleReadStatus(ref, book),
            secondary: Icon(
                book.isRead ? Icons.check_circle : Icons.radio_button_unchecked,
                color: book.isRead ? Colors.green : null),
          ),
          const SizedBox(height: 32),
          _buildInfoSection(theme, 'Detalles'),
          const SizedBox(height: 16),
          _buildDetailRow(context, 'ISBN', book.isbn ?? '-'),
          if (book.barcode != null && book.barcode != book.isbn)
            _buildDetailRow(context, 'Código barras', book.barcode!),
          _buildDetailRow(context, 'Estado', _getStatusLabel(book.status)),
          if (book.notes != null && book.notes!.isNotEmpty) ...[
            const SizedBox(height: 32),
            _buildInfoSection(theme, 'Notas'),
            const SizedBox(height: 16),
            Text(
              book.notes!,
              style: theme.textTheme.bodyLarge,
            ),
          ],
          const SizedBox(height: 32),
          _buildReviewsHeader(context, ref, theme),
          const SizedBox(height: 16),
          _buildReviewsList(context, ref, theme),
        ],
      ),
    );
  }

  Widget _buildReviewsHeader(
      BuildContext context, WidgetRef ref, ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Reseñas',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        TextButton.icon(
          onPressed: () => showAddReviewDialog(context, ref, book),
          icon: const Icon(Icons.add_comment_outlined),
          label: const Text('Añadir reseña'),
        ),
      ],
    );
  }

  Widget _buildReviewsList(
      BuildContext context, WidgetRef ref, ThemeData theme) {
    if (reviews.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: Column(
            children: [
              Icon(Icons.reviews_outlined,
                  size: 48,
                  color: theme.colorScheme.onSurfaceVariant.withOpacity(0.5)),
              const SizedBox(height: 12),
              Text(
                'Sin reseñas todavía',
                style: theme.textTheme.bodyMedium
                    ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
              ),
            ],
          ),
        ),
      );
    }

    final avg = reviews.map((r) => r.rating).fold<double>(0, (p, c) => p + c) /
        reviews.length;

    return Column(
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Column(
                  children: [
                    Text(
                      avg.toStringAsFixed(1),
                      style: theme.textTheme.displaySmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary),
                    ),
                    Text(
                      'de 5',
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
                const SizedBox(width: 24),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _RatingStars(average: avg),
                      const SizedBox(height: 4),
                      Text(
                        'Basado en ${reviews.length} ${reviews.length == 1 ? 'reseña' : 'reseñas'}',
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        ...reviews.take(3).map((review) => _ReviewTile(review: review)),
        if (reviews.length > 3)
          TextButton(
            onPressed: () => showReviewsListDialog(context, ref, book),
            child: const Text('Ver todas las reseñas'),
          ),
      ],
    );
  }

  void _toggleReadStatus(WidgetRef ref, Book book) {
    ref.read(bookDaoProvider).toggleReadStatus(book.id, !book.isRead);
    ref.invalidate(bookListProvider);
  }

  Widget _buildPlaceholder(ThemeData theme) {
    return Container(
      color: theme.colorScheme.surfaceContainerHighest,
      child: Center(
        child: Icon(
          Icons.book,
          size: 64,
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }

  Widget _buildInfoSection(ThemeData theme, String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const Divider(),
      ],
    );
  }

  Widget _buildDetailRow(BuildContext context, String label, String value) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }

  String _getStatusLabel(String status) {
    switch (status) {
      case 'available':
        return 'Disponible';
      case 'loaned':
        return 'Prestado';
      case 'private':
        return 'Privado';
      case 'archived':
        return 'Archivado';
      default:
        return status;
    }
  }
}

class _ReviewTile extends ConsumerWidget {
  const _ReviewTile({required this.review});
  final BookReview review;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ...List.generate(
                  5,
                  (index) => Icon(
                        index < review.rating ? Icons.star : Icons.star_border,
                        size: 16,
                        color: Colors.amber,
                      )),
              const SizedBox(width: 8),
              Text(
                DateFormat.yMMMd().format(review.createdAt),
                style: theme.textTheme.bodySmall,
              ),
            ],
          ),
          if (review.review != null && review.review!.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(review.review!, style: theme.textTheme.bodyMedium),
          ],
        ],
      ),
    );
  }
}

class _RatingStars extends StatelessWidget {
  const _RatingStars({required this.average});
  final double average;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        if (index < average.floor()) {
          return const Icon(Icons.star, color: Colors.amber, size: 20);
        } else if (index < average && (average - index) >= 0.5) {
          return const Icon(Icons.star_half, color: Colors.amber, size: 20);
        } else {
          return const Icon(Icons.star_border, color: Colors.amber, size: 20);
        }
      }),
    );
  }
}
