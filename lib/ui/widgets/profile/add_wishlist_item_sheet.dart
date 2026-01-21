import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/book_providers.dart';
import '../../../providers/api_providers.dart';
import '../../../providers/permission_providers.dart';
import '../../../services/google_books_api_controller.dart';
import '../barcode_scanner_sheet.dart';

class AddWishlistItemSheet extends ConsumerStatefulWidget {
  const AddWishlistItemSheet({super.key});

  @override
  ConsumerState<AddWishlistItemSheet> createState() =>
      _AddWishlistItemSheetState();
}

class _AddWishlistItemSheetState extends ConsumerState<AddWishlistItemSheet> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _authorController = TextEditingController();
  final _notesController = TextEditingController();
  final _isbnController = TextEditingController();
  bool _isSaving = false;
  bool _isScanning = false;

  @override
  void dispose() {
    _titleController.dispose();
    _authorController.dispose();
    _notesController.dispose();
    _isbnController.dispose();
    super.dispose();
  }

  Future<void> _handleScan() async {
    final permissionService = ref.read(permissionServiceProvider);
    final granted = await permissionService.ensureCameraPermission();
    if (!granted) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text('Necesitas habilitar permisos de cámara para escanear.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (!mounted) return;

    final scannedCode = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (context) => BarcodeScannerSheet(onScanned: (_) {}),
    );

    if (scannedCode != null && mounted) {
      setState(() {
        _isbnController.text = scannedCode;
      });
      _searchBook(scannedCode);
    }
  }

  Future<void> _searchBook(String barcode) async {
    setState(() => _isScanning = true);

    try {
      final apiKeyState = ref.read(googleBooksApiKeyControllerProvider);
      final apiKey = apiKeyState.valueOrNull;

      // Search sequence similar to BookFormSheet but simplified for Wishlist
      // 1. Google Books
      var candidates = await GoogleBooksApiController.searchBooks(
        query: barcode,
        apiKey: apiKey,
        maxResults: 1,
      );

      String? title;
      String? author;

      if (candidates.isNotEmpty) {
        title = candidates.first.title;
        author = candidates.first.authorsText;
      } else {
        // 2. Open Library Fallback
        final openLibrary = ref.read(openLibraryClientProvider);
        final olResults = await openLibrary.search(
          isbn: barcode,
          limit: 1,
        );
        if (olResults.isNotEmpty) {
          title = olResults.first.title;
          author = olResults.first.author;
        }
      }

      if (title != null && mounted) {
        setState(() {
          _titleController.text = title!;
          if (author != null) {
            _authorController.text = author;
          }
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('📚 Encontrado: $title'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No se encontró información para este código.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al buscar: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isScanning = false);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final user = ref.read(activeUserProvider).value;
      if (user == null) throw Exception('No hay usuario activo');

      await ref.read(wishlistRepositoryProvider).addItem(
            userId: user.id,
            title: _titleController.text.trim(),
            author: _authorController.text.trim().isEmpty
                ? null
                : _authorController.text.trim(),
            isbn: _isbnController.text.trim().isEmpty
                ? null
                : _isbnController.text.trim(),
            notes: _notesController.text.trim().isEmpty
                ? null
                : _notesController.text.trim(),
          );

      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Error: $e'),
              backgroundColor: Theme.of(context).colorScheme.error),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 24,
        right: 24,
        top: 24,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Nuevo Deseo',
              style: theme.textTheme.headlineSmall
                  ?.copyWith(fontFamily: 'Georgia'),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: 'Título del libro',
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.book_outlined),
                suffixIcon: IconButton(
                  onPressed: _isScanning ? null : _handleScan,
                  tooltip: 'Escanear código de barras',
                  icon: _isScanning
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: Padding(
                            padding: EdgeInsets.all(4.0),
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        )
                      : const Icon(Icons.qr_code_scanner),
                ),
              ),
              validator: (v) =>
                  v == null || v.isEmpty ? 'El título es obligatorio' : null,
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _authorController,
              decoration: const InputDecoration(
                labelText: 'Autor (opcional)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person_outline),
              ),
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _isbnController,
              decoration: const InputDecoration(
                labelText: 'ISBN (opcional)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.qr_code),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Notas / Por qué lo quieres',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.notes),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _isSaving ? null : _submit,
              icon: _isSaving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.favorite_border),
              label: const Text('Añadir a deseos'),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
