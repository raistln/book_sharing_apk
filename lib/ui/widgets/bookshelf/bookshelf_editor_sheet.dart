import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/bookshelf_providers.dart';
import 'bookshelf_editor_book_item.dart';

class BookshelfEditorSheet extends ConsumerStatefulWidget {
  const BookshelfEditorSheet({super.key});

  @override
  ConsumerState<BookshelfEditorSheet> createState() => _BookshelfEditorSheetState();
}

class _BookshelfEditorSheetState extends ConsumerState<BookshelfEditorSheet> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final booksAsync = ref.watch(allLibraryBooksProvider);

    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Gestionar Estantería',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),

              // Search Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: SearchBar(
                  hintText: 'Buscar en toda la biblioteca...',
                  leading: const Icon(Icons.search),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value.toLowerCase();
                    });
                  },
                ),
              ),

              const Divider(),

              // List
              Expanded(
                child: booksAsync.when(
                  data: (books) {
                    final filteredBooks = books.where((b) {
                      return b.title.toLowerCase().contains(_searchQuery) ||
                          (b.author?.toLowerCase().contains(_searchQuery) ?? false);
                    }).toList();

                    if (filteredBooks.isEmpty) {
                      return Center(
                        child: Text(
                          _searchQuery.isEmpty 
                            ? 'No hay libros en tu biblioteca'
                            : 'No se encontraron resultados',
                          style: theme.textTheme.bodyMedium,
                        ),
                      );
                    }

                    return ListView.builder(
                      controller: scrollController,
                      itemCount: filteredBooks.length,
                      itemBuilder: (context, index) {
                        return BookshelfEditorBookItem(
                          book: filteredBooks[index],
                        );
                      },
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (err, stack) => Center(child: Text('Error: $err')),
                ),
              ),
              
              // Bottom padding for safe area
              SizedBox(height: MediaQuery.of(context).padding.bottom + 16),
            ],
          ),
        );
      },
    );
  }
}
