import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/bookshelf_models.dart';
import '../../../providers/bookshelf_providers.dart';
import '../textured_background.dart';
import 'bookshelf_header.dart';
import 'bookshelf_toolbar.dart';
import 'shelf_row_widget.dart';

class VirtualBookshelfSheet extends ConsumerWidget {
  const VirtualBookshelfSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Load saved preferences on init
    ref.watch(bookshelfPrefsLoaderProvider);

    final booksAsync = ref.watch(sortedBookshelfBooksProvider);
    final theme = ref.watch(bookshelfThemeProvider);
    final wall = ref.watch(bookshelfWallProvider);

    final themeConfig = ShelfThemeConfig.forTheme(theme);
    final wallConfig = WallThemeConfig.forTheme(wall);

    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.96,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: wallConfig.color,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: TexturedBackground(
            opacity: wallConfig.textureOpacity,
            child: ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(24)),
              child: CustomScrollView(
                controller: scrollController,
                slivers: [
                  // Decorative Handle
                  SliverToBoxAdapter(
                    child: Center(
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 12),
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: themeConfig.textColor.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                  ),

                  // Header
                  SliverToBoxAdapter(
                    child: booksAsync.when(
                      data: (books) => BookshelfHeader(
                        bookCount: books.length,
                        themeConfig: themeConfig,
                      ),
                      loading: () => const SizedBox.shrink(),
                      error: (_, __) => const SizedBox.shrink(),
                    ),
                  ),

                  // Toolbar
                  SliverToBoxAdapter(
                    child: BookshelfToolbar(themeConfig: themeConfig),
                  ),

                  // Shelves Content
                  booksAsync.when(
                    data: (books) {
                      if (books.isEmpty) {
                        return SliverFillRemaining(
                          hasScrollBody: false,
                          child: _buildEmptyState(context, themeConfig),
                        );
                      }

                      final int booksPerRow = _calculateBooksPerRow(context);
                      final int rowCount = (books.length / booksPerRow).ceil();

                      return SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            if (index >= rowCount) return null;

                            final startIndex = index * booksPerRow;
                            final endIndex = (startIndex + booksPerRow)
                                .clamp(0, books.length);
                            final rowBooks =
                                books.sublist(startIndex, endIndex);

                            return ShelfRowWidget(
                              books: rowBooks,
                              themeConfig: themeConfig,
                            );
                          },
                          childCount: rowCount,
                        ),
                      );
                    },
                    loading: () => const SliverFillRemaining(
                      child: Center(child: CircularProgressIndicator()),
                    ),
                    error: (err, _) => SliverFillRemaining(
                      child: Center(child: Text('Error: $err')),
                    ),
                  ),

                  const SliverPadding(padding: EdgeInsets.only(bottom: 60)),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  int _calculateBooksPerRow(BuildContext context) {
    final width = MediaQuery.of(context).size.width - 32; // Horizontal padding
    // Average spine width is ~45px.
    // 45 width + 2 spacing (1 per side) = 47px per book roughly.
    return (width / 47).floor().clamp(1, 15);
  }

  Widget _buildEmptyState(BuildContext context, ShelfThemeConfig themeConfig) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(48.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.auto_stories_outlined,
              size: 80,
              color: themeConfig.accentColor.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 24),
            Text(
              'Tu estantería está esperando nuevas memorias',
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium?.copyWith(
                color: themeConfig.textColor.withValues(alpha: 0.7),
                fontFamily: 'Georgia',
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Marca libros como "leídos" para verlos aparecer aquí como lomos decorativos.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: themeConfig.textColor.withValues(alpha: 0.5),
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
