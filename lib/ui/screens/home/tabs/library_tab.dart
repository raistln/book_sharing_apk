import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../data/local/database.dart';
import '../../../../providers/book_providers.dart';
import '../../../../ui/widgets/library/book_list.dart';
import '../../../../ui/widgets/library/empty_library_state.dart';
import '../../../../ui/widgets/library/cover_refresh_handler.dart';
import '../../../../ui/widgets/library/export_handler.dart';
import '../../../../ui/widgets/library/library_filters.dart';
import '../../../../ui/widgets/library/library_search_bar.dart';
import '../../../../ui/widgets/loans/manual_loan_sheet.dart';
import '../../../../ui/widgets/library/read_status_filter.dart';
import '../../../../ui/widgets/library/review_dialog.dart';

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
    if (_searchQuery.isEmpty) return filtered;

    return filtered.where((book) {
      final title = book.title.toLowerCase();
      final author = (book.author ?? '').toLowerCase();
      final query = _searchQuery.toLowerCase();
      return title.contains(query) || author.contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final booksAsync = ref.watch(bookListProvider);
    final theme = Theme.of(context);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: booksAsync.when(
          data: (books) {
            final filteredBooks = _filterBooks(books);
            if (books.isEmpty) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Mi biblioteca',
                      style: theme.textTheme.titleLarge
                          ?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(
                    'Añade tus libros para gestionarlos desde aquí.',
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 16),
                  Align(
                    alignment: Alignment.centerRight,
                    child: LibraryFilters(
                      onRefreshCovers: () =>
                          CoverRefreshHandler.handle(context, ref),
                      onExport: () => ExportHandler.handle(context, ref),
                    ),
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
                Text('Mi biblioteca',
                    style: theme.textTheme.titleLarge
                        ?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(
                  'Gestiona tus libros guardados y prepara los préstamos.',
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ReadStatusFilter(
                      selectedFilter: _readStatusFilter,
                      onChanged: (val) =>
                          setState(() => _readStatusFilter = val),
                    ),
                    LibraryFilters(
                      onRefreshCovers: () =>
                          CoverRefreshHandler.handle(context, ref),
                      onExport: () => ExportHandler.handle(context, ref),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: LibrarySearchBar(
                    controller: _searchController,
                    onChanged: (value) => setState(() => _searchQuery = value),
                  ),
                ),
                Expanded(
                  child: filteredBooks.isEmpty
                      ? Center(
                          child: Text(
                            'No se encontraron libros',
                            style: theme.textTheme.bodyMedium,
                          ),
                        )
                      : BookList(
                          books: filteredBooks,
                          onBookTap: (book) => widget.onOpenForm(book: book),
                          onAddReview: (book) =>
                              showAddReviewDialog(context, ref, book),
                          onViewReviews: (book) =>
                              showReviewsListDialog(context, ref, book),
                          onCreateManualLoan: (book) => showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            useSafeArea: true,
                            builder: (context) =>
                                ManualLoanSheet(initialBook: book),
                          ),
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
