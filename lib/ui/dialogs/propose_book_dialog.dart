import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/local/database.dart';
import '../../providers/book_providers.dart';
import '../../providers/clubs_provider.dart';
import '../../services/google_books_api_controller.dart';
import '../../providers/api_providers.dart';

class ProposeBookDialog extends ConsumerStatefulWidget {
  const ProposeBookDialog({super.key, required this.clubUuid});

  final String clubUuid;

  @override
  ConsumerState<ProposeBookDialog> createState() => _ProposeBookDialogState();
}

class _ProposeBookDialogState extends ConsumerState<ProposeBookDialog> {
  final _searchController = TextEditingController();
  final _chaptersController = TextEditingController();

  Book? _selectedBook;
  GoogleBook? _selectedGoogleBook;

  bool _isLoading = false;
  List<Book> _localResults = [];
  List<GoogleBook> _googleResults = [];
  bool _isSearching = false;

  @override
  void dispose() {
    _searchController.dispose();
    _chaptersController.dispose();
    super.dispose();
  }

  Future<void> _searchBooks(String query) async {
    if (query.isEmpty) {
      setState(() {
        _localResults = [];
        _googleResults = [];
      });
      return;
    }

    setState(() => _isSearching = true);
    try {
      final repo = ref.read(bookRepositoryProvider);
      final keyController = ref.read(googleBooksApiKeyControllerProvider);
      final apiKey = keyController.value;

      final results = await Future.wait([
        repo.searchBooks(query),
        GoogleBooksApiController.searchBooks(query: query, apiKey: apiKey),
      ]);

      if (mounted) {
        setState(() {
          _localResults = results[0] as List<Book>;
          _googleResults = results[1] as List<GoogleBook>;
        });
      }
    } catch (e) {
      debugPrint('Error searching books: $e');
    } finally {
      if (mounted) setState(() => _isSearching = false);
    }
  }

  Future<void> _submit() async {
    if (_selectedBook == null && _selectedGoogleBook == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona un libro')),
      );
      return;
    }

    final chapters = int.tryParse(_chaptersController.text);
    if (chapters == null || chapters <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ingresa un número válido de capítulos')),
      );
      return;
    }

    final user = ref.read(activeUserProvider).value;
    if (user == null || user.remoteId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Usuario no identificado o sin ID remoto')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      String bookUuid;

      if (_selectedGoogleBook != null) {
        final repo = ref.read(bookRepositoryProvider);

        try {
          final bookId = await repo.addBook(
            title: _selectedGoogleBook!.title,
            author: _selectedGoogleBook!.authors.isNotEmpty
                ? _selectedGoogleBook!.authors.first
                : null,
            isbn: _selectedGoogleBook!.primaryIsbn,
            coverPath: _selectedGoogleBook!.thumbnailUrl,
            status: 'available',
            description: _selectedGoogleBook!.description,
            pageCount: _selectedGoogleBook!.pageCount,
            publicationYear: _selectedGoogleBook!.publishedDate != null
                ? int.tryParse(
                    _selectedGoogleBook!.publishedDate!.substring(0, 4))
                : null,
            owner: user,
          );

          final book = await repo.findById(bookId);
          if (book == null) throw Exception('Error al importar el libro');
          bookUuid = book.uuid;
        } catch (e) {
          if (e.toString().contains('Ya tienes ese libro') ||
              e.toString().contains('UNIQUE constraint failed')) {
            final existing = await repo.searchBooks(_selectedGoogleBook!.title);
            if (existing.isNotEmpty) {
              bookUuid = existing.first.uuid;
            } else {
              rethrow;
            }
          } else {
            rethrow;
          }
        }
      } else {
        bookUuid = _selectedBook!.uuid;
      }

      final clubService = ref.read(clubServiceProvider);
      await clubService.proposeBook(
        clubUuid: widget.clubUuid,
        bookUuid: bookUuid,
        userUuid: user.remoteId!,
        totalChapters: chapters,
      );

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Libro propuesto exitosamente')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(24),
        constraints: const BoxConstraints(maxWidth: 400, maxHeight: 600),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Proponer Libro',
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            if (_selectedBook == null && _selectedGoogleBook == null)
              _buildSearchStep()
            else
              _buildConfigStep(),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchStep() {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              labelText: 'Buscar libro (Local o Google Books)',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: IconButton(
                icon: const Icon(Icons.search),
                onPressed: () => _searchBooks(_searchController.text),
              ),
              border: const OutlineInputBorder(),
            ),
            onSubmitted: _searchBooks,
          ),
          const SizedBox(height: 12),
          if (_isSearching)
            const Expanded(child: Center(child: CircularProgressIndicator()))
          else if (_localResults.isEmpty &&
              _googleResults.isEmpty &&
              _searchController.text.isNotEmpty)
            const Expanded(
                child: Center(child: Text('No se encontraron libros')))
          else
            Expanded(
              child: ListView(
                children: [
                  if (_localResults.isNotEmpty) ...[
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8.0),
                      child: Text('En tu biblioteca',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, color: Colors.grey)),
                    ),
                    ..._localResults.map((book) => ListTile(
                          leading: book.coverPath != null
                              ? Image.network(book.coverPath!,
                                  width: 40, fit: BoxFit.cover)
                              : const Icon(Icons.book),
                          title: Text(book.title,
                              maxLines: 1, overflow: TextOverflow.ellipsis),
                          subtitle: Text(book.author ?? 'Desconocido'),
                          onTap: () {
                            setState(() {
                              _selectedBook = book;
                              _selectedGoogleBook = null;
                            });
                          },
                        )),
                  ],
                  if (_googleResults.isNotEmpty) ...[
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8.0),
                      child: Text('En Google Books',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, color: Colors.blue)),
                    ),
                    ..._googleResults.map((book) => ListTile(
                          leading: book.thumbnailUrl != null
                              ? Image.network(book.thumbnailUrl!,
                                  width: 40, fit: BoxFit.cover)
                              : const Icon(Icons.book),
                          title: Text(book.title,
                              maxLines: 1, overflow: TextOverflow.ellipsis),
                          subtitle: Text(book.authors.join(', ')),
                          onTap: () {
                            setState(() {
                              _selectedGoogleBook = book;
                              _selectedBook = null;
                            });
                          },
                        )),
                  ],
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildConfigStep() {
    final title = _selectedBook?.title ?? _selectedGoogleBook?.title ?? '';
    final author =
        _selectedBook?.author ?? _selectedGoogleBook?.authors.join(', ') ?? '';
    final cover = _selectedBook?.coverPath ?? _selectedGoogleBook?.thumbnailUrl;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: cover != null
                ? Image.network(cover, width: 40, fit: BoxFit.cover)
                : const Icon(Icons.book),
            title: Text(title,
                style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(author),
            trailing: IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => setState(() {
                _selectedBook = null;
                _selectedGoogleBook = null;
              }),
            ),
          ),
          const Divider(),
          const SizedBox(height: 16),
          TextFormField(
            controller: _chaptersController,
            decoration: const InputDecoration(
              labelText: 'Número de Capítulos',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed:
                    _isLoading ? null : () => Navigator.of(context).pop(),
                child: const Text('Cancelar'),
              ),
              const SizedBox(width: 16),
              FilledButton(
                onPressed: _isLoading ? null : _submit,
                child: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2))
                    : const Text('Proponer'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
