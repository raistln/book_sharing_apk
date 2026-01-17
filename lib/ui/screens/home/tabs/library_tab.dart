import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../data/local/database.dart';
import '../../../../models/book_genre.dart';
import '../../../../providers/book_providers.dart';
import '../../../../ui/widgets/library/empty_library_state.dart';
import '../../../../ui/widgets/library/cover_refresh_handler.dart';
import '../../../../ui/widgets/library/export_handler.dart';
import '../../../../ui/widgets/library/library_search_bar.dart';
import '../../../../ui/widgets/library/read_status_filter.dart';
import '../../../../ui/widgets/library/book_grid.dart';
import '../../../../ui/widgets/library/book_details_page.dart';
import '../../../../ui/widgets/library/book_text_list.dart';

enum LibrarySortOption {
  titleAz,
  titleZa,
  authorAz,
  authorZa,
  newest,
  oldest,
}

class LibraryTab extends ConsumerStatefulWidget {
  const LibraryTab({super.key, required this.onOpenForm});

  final Future<void> Function({Book? book}) onOpenForm;

  @override
  ConsumerState<LibraryTab> createState() => _LibraryTabState();
}

class _LibraryTabState extends ConsumerState<LibraryTab> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  bool? _readStatusFilter;
  BookGenre? _genreFilter;
  bool _isGridView = true; // Default to Grid
  LibrarySortOption _sortOption = LibrarySortOption.titleAz;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Book> _filterBooks(List<Book> books) {
    // Only show books owned by the user (exclude external borrowed books)
    var filtered = books.where((b) => !b.isBorrowedExternal).toList();

    // Filtrar por estado de lectura
    if (_readStatusFilter != null) {
      filtered = filtered.where((b) => b.isRead == _readStatusFilter).toList();
    }
    // Filtrar por género
    if (_genreFilter != null) {
      filtered = filtered.where((b) {
        final bookGenres = BookGenre.fromCsv(b.genre);
        return bookGenres.contains(_genreFilter);
      }).toList();
    }

    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filtered = filtered.where((book) {
        final title = book.title.toLowerCase();
        final author = (book.author ?? '').toLowerCase();
        return title.contains(query) || author.contains(query);
      }).toList();
    }

    // Aplicar ordenación
    switch (_sortOption) {
      case LibrarySortOption.titleAz:
        filtered.sort(
            (a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));
        break;
      case LibrarySortOption.titleZa:
        filtered.sort(
            (a, b) => b.title.toLowerCase().compareTo(a.title.toLowerCase()));
        break;
      case LibrarySortOption.authorAz:
        filtered.sort((a, b) => (a.author ?? '')
            .toLowerCase()
            .compareTo((b.author ?? '').toLowerCase()));
        break;
      case LibrarySortOption.authorZa:
        filtered.sort((a, b) => (b.author ?? '')
            .toLowerCase()
            .compareTo((a.author ?? '').toLowerCase()));
        break;
      case LibrarySortOption.newest:
        filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case LibrarySortOption.oldest:
        filtered.sort((a, b) => a.createdAt.compareTo(b.createdAt));
        break;
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final booksAsync = ref.watch(bookListProvider);
    final theme = Theme.of(context);

    return SafeArea(
      child: Padding(
        padding:
            const EdgeInsets.fromLTRB(20, 0, 20, 16), // Adjusted top padding
        child: booksAsync.when(
          data: (books) {
            final filteredBooks = _filterBooks(books);
            if (books.isEmpty) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text('Mi biblioteca',
                          style: theme.textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold)),
                      const SizedBox(width: 12),
                      IconButton(
                        onPressed: () =>
                            setState(() => _isGridView = !_isGridView),
                        icon: Icon(
                            _isGridView ? Icons.view_list : Icons.grid_view),
                        tooltip: _isGridView ? 'Ver lista' : 'Ver cuadrícula',
                        visualDensity: VisualDensity.compact,
                      ),
                      IconButton(
                        onPressed: () =>
                            CoverRefreshHandler.handle(context, ref),
                        icon: const Icon(Icons.refresh_rounded),
                        tooltip: 'Actualizar portadas',
                        visualDensity: VisualDensity.compact,
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: () => ExportHandler.handle(context, ref),
                        icon: const Icon(Icons.share_outlined),
                        tooltip: 'Exportar biblioteca',
                        visualDensity: VisualDensity.compact,
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Añade tus libros para gestionarlos desde aquí.',
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: EmptyLibraryState(
                      onAddBook: () => widget.onOpenForm(),
                    ),
                  ),
                ],
              );
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text('Mi biblioteca',
                        style: theme.textTheme.titleLarge
                            ?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(width: 12),
                    IconButton(
                      onPressed: () =>
                          setState(() => _isGridView = !_isGridView),
                      icon:
                          Icon(_isGridView ? Icons.view_list : Icons.grid_view),
                      tooltip: _isGridView ? 'Ver lista' : 'Ver cuadrícula',
                      visualDensity: VisualDensity.compact,
                    ),
                    IconButton(
                      onPressed: () => CoverRefreshHandler.handle(context, ref),
                      icon: const Icon(Icons.refresh_rounded),
                      tooltip: 'Actualizar portadas',
                      visualDensity: VisualDensity.compact,
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () => ExportHandler.handle(context, ref),
                      icon: const Icon(Icons.share_outlined),
                      tooltip: 'Exportar biblioteca',
                      visualDensity: VisualDensity.compact,
                    ),
                  ],
                ),
                Text(
                  'Gestiona tus libros guardados y prepara los préstamos.',
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 16),
                LibrarySearchBar(
                  controller: _searchController,
                  onChanged: (value) => setState(() => _searchQuery = value),
                ),
                const SizedBox(height: 12),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _SortSelector(
                        selected: _sortOption,
                        onSelected: (val) => setState(() => _sortOption = val),
                      ),
                      const SizedBox(width: 8),
                      ReadStatusFilter(
                        selectedFilter: _readStatusFilter,
                        onChanged: (val) =>
                            setState(() => _readStatusFilter = val),
                      ),
                      const SizedBox(width: 8),
                      _GenreSelector(
                        selected: _genreFilter,
                        onSelected: (val) => setState(() => _genreFilter = val),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: filteredBooks.isEmpty
                      ? Center(
                          child: Text(
                            'No se encontraron libros',
                            style: theme.textTheme.bodyMedium,
                          ),
                        )
                      : _isGridView
                          ? BookGridView(
                              books: filteredBooks,
                              onBookTap: (book) {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        BookDetailsPage(bookId: book.id),
                                  ),
                                );
                              },
                            )
                          : BookTextList(
                              books: filteredBooks,
                              onBookTap: (book) {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        BookDetailsPage(bookId: book.id),
                                  ),
                                );
                              },
                            ),
                ),
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stackTrace) => Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, size: 48),
                const SizedBox(height: 12),
                Text(
                  'No pudimos cargar tu biblioteca.',
                  style: theme.textTheme.titleMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  error.toString(),
                  style: theme.textTheme.bodySmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: () => ref.refresh(bookListProvider),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Reintentar'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SortSelector extends StatelessWidget {
  const _SortSelector({
    required this.selected,
    required this.onSelected,
  });

  final LibrarySortOption selected;
  final ValueChanged<LibrarySortOption> onSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return PopupMenuButton<LibrarySortOption>(
      initialValue: selected,
      onSelected: onSelected,
      tooltip: 'Ordenar libros',
      icon: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          Icons.sort,
          size: 20,
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
      itemBuilder: (context) => [
        _buildItem(LibrarySortOption.titleAz, 'Título (A-Z)'),
        _buildItem(LibrarySortOption.titleZa, 'Título (Z-A)'),
        _buildItem(LibrarySortOption.authorAz, 'Autor (A-Z)'),
        _buildItem(LibrarySortOption.authorZa, 'Autor (Z-A)'),
        _buildItem(LibrarySortOption.newest, 'Más recientes'),
        _buildItem(LibrarySortOption.oldest, 'Más antiguos'),
      ],
    );
  }

  PopupMenuItem<LibrarySortOption> _buildItem(
      LibrarySortOption value, String label) {
    return PopupMenuItem(
      value: value,
      child: Text(label),
    );
  }
}

class _GenreSelector extends StatelessWidget {
  const _GenreSelector({
    required this.selected,
    required this.onSelected,
  });

  final BookGenre? selected;
  final ValueChanged<BookGenre?> onSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<BookGenre?>(
          value: selected,
          onChanged: onSelected,
          style: theme.textTheme.bodyMedium,
          hint: const Text('Género'),
          items: [
            const DropdownMenuItem<BookGenre?>(
              value: null,
              child: Text('Todos los géneros'),
            ),
            ...BookGenre.values.map((genre) => DropdownMenuItem<BookGenre?>(
                  value: genre,
                  child: Text(genre.label),
                )),
          ],
        ),
      ),
    );
  }
}
