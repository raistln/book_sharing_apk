import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:intl/intl.dart';
import '../../../data/local/database.dart';
import '../../../data/local/book_dao.dart';
import '../../../models/book_genre.dart';
import '../../../models/recommendation_level.dart';
import '../../../providers/book_providers.dart';
import 'book_form_sheet.dart';
import 'review_dialog.dart';
import 'reading_status_selector.dart';
import 'reading_timeline_widget.dart';

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
}

class _BookDetailsContent extends ConsumerWidget {
  const _BookDetailsContent({required this.book, required this.reviews});

  final Book book;
  final List<ReviewWithAuthor> reviews;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 🔝 HEADER SECTION
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 160, // Sligthly smaller
                maxHeight: 240,
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
          const SizedBox(height: 24),
          Text(
            book.title,
            style: theme.textTheme.headlineSmall?.copyWith(
              // Slightly smaller headline
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

          // Pages, Year, ISBN
          const SizedBox(height: 8),
          Text(
            [
              if (book.pageCount != null) '${book.pageCount} págs',
              if (book.publicationYear != null) '${book.publicationYear}',
              if (book.isbn != null) 'ISBN: ${book.isbn}',
            ].join(' • '),
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 20),

          // FORMAT & AVAILABILITY CHIPS
          Center(
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: [
                // Format Chip
                if (!book.isPhysical)
                  Chip(
                    avatar: const Icon(Icons.tablet_mac,
                        size: 16, color: Colors.purple),
                    label: const Text('Digital',
                        style: TextStyle(fontSize: 12, color: Colors.purple)),
                    backgroundColor: Colors.purple.shade50,
                    side: BorderSide(color: Colors.purple.shade200),
                    visualDensity: VisualDensity.compact,
                    padding: EdgeInsets.zero,
                  )
                else
                  Chip(
                    avatar:
                        const Icon(Icons.book, size: 16, color: Colors.blue),
                    label: const Text('Físico',
                        style: TextStyle(fontSize: 12, color: Colors.blue)),
                    backgroundColor: Colors.blue.shade50,
                    side: BorderSide(color: Colors.blue.shade200),
                    visualDensity: VisualDensity.compact,
                    padding: EdgeInsets.zero,
                  ),

                // Availability Chip
                _buildAvailabilityChip(context, book),

                // Existing Genres (Optional, maybe keep them but smaller?)
                ...BookGenre.fromCsv(book.genre).map((g) => Chip(
                      label:
                          Text(g.label, style: const TextStyle(fontSize: 12)),
                      visualDensity: VisualDensity.compact,
                      padding: EdgeInsets.zero,
                    )),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Reading Status Selector
          ReadingStatusSelector(
            book: book,
            userId: ref.watch(activeUserProvider).value?.id ?? 0,
          ),

          const SizedBox(height: 24),

          // 📍 READING TIMELINE (Prioritized)
          // Always show, or collapsed? Widget handles it?
          // We pass it. If not reading/finished, maybe it shows empty state or 'Start reading'.
          ReadingTimelineWidget(
            book: book,
            userId: ref.watch(activeUserProvider).value?.id ?? 0,
          ),

          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 24),

          // 📘 DESCRIPTION SECTION
          if (book.description != null && book.description!.isNotEmpty) ...[
            Text(
              'Sinopsis',
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              book.description!,
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 32),
          ],

          // ✍️ REVIEWS SECTION
          _buildReviewsHeader(context, ref, theme),
          const SizedBox(height: 16),
          _buildReviewsList(context, ref, theme),
        ],
      ),
    );
  }

  Widget _buildAvailabilityChip(BuildContext context, Book book) {
    // Logic for availability label
    String label;
    Color color;
    IconData icon;

    if (book.isBorrowedExternal) {
      label = book.externalLenderName != null
          ? 'De ${book.externalLenderName}'
          : 'Prestado (Ext)';
      color = Colors.indigo;
      icon = Icons.input;
    } else {
      switch (book.status) {
        case 'available':
          label = 'Disponible';
          color = Colors.teal;
          icon = Icons.check_circle_outline;
          break;
        case 'loaned':
          label = 'Prestado';
          color = Colors.orange;
          icon = Icons.outbox;
          break;
        case 'private':
          label = 'Privado';
          color = Colors.grey;
          icon = Icons.lock_outline;
          break;
        case 'archived':
          label = 'Archivado';
          color = Colors.blueGrey;
          icon = Icons.archive_outlined;
          break;
        default:
          label = book.status;
          color = Colors.grey;
          icon = Icons.info_outline;
      }
    }

    return Chip(
      avatar: Icon(icon, size: 16, color: color),
      label: Text(label,
          style: TextStyle(
              fontSize: 12, color: color, fontWeight: FontWeight.bold)),
      backgroundColor: color.withValues(alpha: 0.1),
      side: BorderSide(color: color.withValues(alpha: 0.3)),
      visualDensity: VisualDensity.compact,
      padding: EdgeInsets.zero,
    );
  }

  Widget _buildReviewsHeader(
      BuildContext context, WidgetRef ref, ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '¿Quién lo ha leído?',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (reviews.isNotEmpty)
                Text(
                  '${reviews.length} ${reviews.length == 1 ? 'persona' : 'personas'} han opinado',
                  style: theme.textTheme.bodySmall,
                ),
            ],
          ),
        ),
        TextButton.icon(
          onPressed: () => showAddReviewDialog(context, ref, book),
          icon: const Icon(Icons.add_comment_outlined),
          label: const Text('Opinar'),
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
              Icon(Icons.person_outline,
                  size: 48,
                  color: theme.colorScheme.onSurfaceVariant
                      .withValues(alpha: 0.5)),
              const SizedBox(height: 12),
              Text(
                'Nadie ha opinado todavía',
                style: theme.textTheme.bodyMedium
                    ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: [
        ...reviews.take(5).map((item) => _ReviewTile(item: item)),
        if (reviews.length > 5)
          TextButton(
            onPressed: () => showReviewsListDialog(context, ref, book),
            child: const Text('Ver todas las opiniones'),
          ),
      ],
    );
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
}

class _ReviewTile extends ConsumerWidget {
  const _ReviewTile({required this.item});
  final ReviewWithAuthor item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final review = item.review;
    final author = item.author;
    final level = RecommendationLevel.fromValue(review.rating);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundColor: level.color.withValues(alpha: 0.1),
            child: Icon(level.icon, color: level.color, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        author.username,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Text(
                      DateFormat.yMMMd().format(review.createdAt),
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
                Text(
                  level.label,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: level.color,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (review.review != null && review.review!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    review.review!,
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Remove _RatingStars class as it's no longer used
