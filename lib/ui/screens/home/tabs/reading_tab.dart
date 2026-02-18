import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../data/local/database.dart';

import '../../../../providers/reading_list_provider.dart';
import '../../../../providers/reading_providers.dart';
import '../../reading/start_session_sheet.dart';
import 'package:book_sharing_app/ui/widgets/reading/reading_stats_card.dart';

class ReadingTab extends ConsumerWidget {
  const ReadingTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final readingBooksAsync = ref.watch(readingBooksProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Header: Leyendo
              Text(
                'Leyendo',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Georgia',
                    ),
              ),
              const SizedBox(height: 16),

              // 2. Horizontal List of Books
              readingBooksAsync.when(
                data: (books) {
                  if (books.isEmpty) {
                    return _buildEmptyState(context);
                  }
                  return SizedBox(
                    height: 320, // Height for book cover + title + author
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: books.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(width: 16),
                      itemBuilder: (context, index) {
                        final book = books[index];
                        return _ReadingBookItem(book: book);
                      },
                    ),
                  );
                },
                loading: () => const SizedBox(
                  height: 320,
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (err, stack) => SizedBox(
                  height: 320,
                  child: Center(child: Text('Error: $err')),
                ),
              ),

              const SizedBox(height: 32),

              // 3. Header: Actividad
              Text(
                'Actividad',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Georgia',
                    ),
              ),
              const SizedBox(height: 16),

              // 4. Activity Card
              const ReadingStatsCard(),

              const SizedBox(height: 80), // Bottom padding for FAB
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Container(
      height: 200,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Theme.of(context)
            .colorScheme
            .surfaceContainerHighest
            .withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context)
              .colorScheme
              .outlineVariant
              .withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.menu_book,
            size: 48,
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 12),
          Text(
            'Sin lecturas activas',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            'Ve a tu biblioteca para empezar',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
        ],
      ),
    );
  }
}

class _ReadingBookItem extends ConsumerWidget {
  const _ReadingBookItem({required this.book});

  final Book book;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionAsync = ref.watch(activeSessionProvider(book.id));
    final progressAsync = ref.watch(bookProgressProvider(book.id));
    final isPaused = book.readingStatus == 'paused';

    return GestureDetector(
      onTap: () {
        // Show start session sheet
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (context) => StartSessionSheet(book: book),
        );
      },
      child: Container(
        width: 160,
        margin:
            const EdgeInsets.only(bottom: 8), // For shadow visibility if added
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cover
            Expanded(
              child: Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.grey[300],
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                      image: book.coverPath != null
                          ? DecorationImage(
                              image: File(book.coverPath!).existsSync()
                                  ? FileImage(File(book.coverPath!))
                                      as ImageProvider
                                  : NetworkImage(book.coverPath!),
                              fit: BoxFit.cover,
                              colorFilter: isPaused
                                  ? const ColorFilter.mode(
                                      Colors.grey, BlendMode.saturation)
                                  : null,
                              opacity: isPaused ? 0.7 : 1.0,
                            )
                          : null,
                    ),
                    child: book.coverPath == null
                        ? const Center(
                            child:
                                Icon(Icons.book, size: 40, color: Colors.grey))
                        : null,
                  ),
                  if (isPaused)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.6),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.pause, size: 12, color: Colors.white),
                            SizedBox(width: 4),
                            Text(
                              'Pausado',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Progress Bar
            progressAsync.when(
              data: (entry) => LinearProgressIndicator(
                value: entry?.percentageRead != null
                    ? (entry!.percentageRead! / 100.0)
                    : 0.0,
                backgroundColor:
                    Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(4),
                minHeight: 6,
              ),
              loading: () => const LinearProgressIndicator(value: 0),
              error: (_, __) => const SizedBox.shrink(),
            ),

            const SizedBox(height: 8),

            // Title
            Text(
              book.title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    height: 1.2,
                  ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),

            // Author
            if (book.author != null)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  book.author!,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),

            // Active Session Indicator
            sessionAsync.when(
              data: (session) {
                if (session != null) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Colors.green,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            'Leyendo ahora',
                            style: Theme.of(context)
                                .textTheme
                                .labelSmall
                                ?.copyWith(
                                  color: Colors.green,
                                  fontWeight: FontWeight.bold,
                                ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}
