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
    this.scrollToTimeline = false,
  });

  final int bookId;
  final bool scrollToTimeline;

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
          return _BookDetailsContent(
            book: book,
            reviews: reviews,
            scrollToTimeline: scrollToTimeline,
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text('Error al cargar el libro: $error'),
        ),
      ),
    );
  }

  Future<void> _openEditSheet(BuildContext context, Book book) async {
    final deleted = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => BookFormSheet(initialBook: book),
    );

    if (deleted == true && context.mounted) {
      Navigator.of(context).pop();
    }
  }
}

class _BookDetailsContent extends ConsumerStatefulWidget {
  const _BookDetailsContent({
    required this.book,
    required this.reviews,
    this.scrollToTimeline = false,
  });

  final Book book;
  final List<ReviewWithAuthor> reviews;
  final bool scrollToTimeline;

  @override
  ConsumerState<_BookDetailsContent> createState() =>
      _BookDetailsContentState();
}

class _BookDetailsContentState extends ConsumerState<_BookDetailsContent> {
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _timelineKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    if (widget.scrollToTimeline) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToTimeline();
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToTimeline() {
    final context = _timelineKey.currentContext;
    if (context != null) {
      Scrollable.ensureVisible(
        context,
        duration: const Duration(milliseconds: 800),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final book = widget.book;
    final reviews = widget.reviews;

    return SingleChildScrollView(
      controller: _scrollController,
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 🔝 HEADER SECTION
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 160,
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

          if (book.genre != null && book.genre!.isNotEmpty) ...[
            Center(
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.center,
                children: BookGenre.fromCsv(book.genre)
                    .map((g) => Chip(
                          label: Text(g.label,
                              style: const TextStyle(fontSize: 11)),
                          visualDensity: VisualDensity.compact,
                          padding: EdgeInsets.zero,
                          backgroundColor: theme
                              .colorScheme.surfaceContainerHighest
                              .withValues(alpha: 0.5),
                          side: BorderSide(
                              color: theme.colorScheme.outlineVariant
                                  .withValues(alpha: 0.5)),
                        ))
                    .toList(),
              ),
            ),
            const SizedBox(height: 16),
          ],

          Center(
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: [
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
                _buildAvailabilityChip(context, book),
              ],
            ),
          ),

          const SizedBox(height: 24),

          ReadingStatusSelector(
            book: book,
            userId: ref.watch(activeUserProvider).value?.id ?? 0,
          ),

          if (['reading', 'rereading', 'finished']
              .contains(book.readingStatus)) ...[
            const SizedBox(height: 16),
            _ReadingStatsChips(bookId: book.id),
          ],

          const SizedBox(height: 24),

          ReadingTimelineWidget(
            key: _timelineKey,
            book: book,
            userId: ref.watch(activeUserProvider).value?.id ?? 0,
          ),

          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 24),

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

          _buildReviewsHeader(context, ref, theme, reviews, book),
          const SizedBox(height: 16),
          _buildReviewsList(context, ref, theme, reviews, book),

          const SizedBox(height: 48),
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

  Widget _buildReviewsHeader(BuildContext context, WidgetRef ref,
      ThemeData theme, List<ReviewWithAuthor> reviews, Book book) {
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

  Widget _buildReviewsList(BuildContext context, WidgetRef ref, ThemeData theme,
      List<ReviewWithAuthor> reviews, Book book) {
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

class _ReadingStatsChips extends ConsumerWidget {
  const _ReadingStatsChips({required this.bookId});
  final int bookId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(bookReadingStatsProvider(bookId));

    return statsAsync.when(
      data: (stats) {
        if (stats == null) return const SizedBox.shrink();

        final format = DateFormat.yMMMd();
        final items = <_StatItem>[
          if (stats.startDate != null)
            _StatItem(
              icon: Icons.play_circle_outline,
              label: 'Empezado',
              value: format.format(stats.startDate!),
              color: Colors.green,
            ),
          if (stats.finishDate != null)
            _StatItem(
              icon: Icons.check_circle_outline,
              label: 'Terminado',
              value: format.format(stats.finishDate!),
              color: Colors.teal,
            ),
          if (stats.totalDays > 0)
            _StatItem(
              icon: Icons.calendar_today_outlined,
              label: 'Duración',
              value: '${stats.totalDays} días',
              color: Colors.indigo,
            ),
          if (stats.totalPages > 0)
            _StatItem(
              icon: Icons.menu_book_outlined,
              label: 'Páginas leídas',
              value: '${stats.totalPages} págs',
              color: Colors.blue,
            ),
          if (stats.pagesPerDay > 0)
            _StatItem(
              icon: Icons.speed_outlined,
              label: 'Ritmo medio',
              value: '${stats.pagesPerDay.toStringAsFixed(1)} p/día',
              color: Colors.orange,
            ),
        ];

        if (items.isEmpty) return const SizedBox.shrink();

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: LayoutBuilder(
            builder: (context, constraints) {
              // Dos columnas, filas dinámicas
              final halfWidth = (constraints.maxWidth - 12) / 2;
              final rows = <Widget>[];
              for (int i = 0; i < items.length; i += 2) {
                rows.add(
                  Row(
                    children: [
                      _StatCard(item: items[i], width: halfWidth),
                      const SizedBox(width: 12),
                      if (i + 1 < items.length)
                        _StatCard(item: items[i + 1], width: halfWidth)
                      else
                        SizedBox(width: halfWidth),
                    ],
                  ),
                );
                if (i + 2 < items.length) const SizedBox(height: 8);
                if (i + 2 < items.length) rows.add(const SizedBox(height: 8));
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: rows,
              );
            },
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}

class _StatItem {
  final IconData icon;
  final String label;
  final String value;
  final MaterialColor color;

  const _StatItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.item, required this.width});
  final _StatItem item;
  final double width;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: width,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: item.color.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: item.color.shade100),
      ),
      child: Row(
        children: [
          Icon(item.icon, size: 20, color: item.color.shade600),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.label,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: item.color.shade700,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  item.value,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: item.color.shade900,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
