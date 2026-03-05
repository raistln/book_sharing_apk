import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../providers/api_providers.dart';
import '../../../providers/book_providers.dart';
import '../../../providers/permission_providers.dart';
import '../../../services/cover_image_service_base.dart';
import '../../../services/google_books_api_controller.dart';
import '../../../utils/isbn_utils.dart';
import '../barcode_scanner_sheet.dart';
import '../library/cover_field.dart';
import '../library/library_utils.dart';

class ReceiveExternalLoanSheet extends ConsumerStatefulWidget {
  const ReceiveExternalLoanSheet({super.key});

  @override
  ConsumerState<ReceiveExternalLoanSheet> createState() =>
      _ReceiveExternalLoanSheetState();
}

class _ReceiveExternalLoanSheetState
    extends ConsumerState<ReceiveExternalLoanSheet> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _authorController = TextEditingController();
  final _lenderNameController = TextEditingController();
  final _lenderContactController = TextEditingController();
  final _isbnController = TextEditingController();

  DateTime _dueDate = DateTime.now().add(const Duration(days: 15));
  bool _isIndefinite = false;

  String? _coverPath;
  bool _isSearching = false;
  String? _searchError;
  final Set<String> _temporaryCoverPaths = <String>{};
  bool _didSubmit = false;

  late final CoverImageService _coverImageService;

  @override
  void initState() {
    super.initState();
    _coverImageService = ref.read(coverImageServiceProvider);
  }

  @override
  void dispose() {
    if (!_didSubmit) {
      for (final path in _temporaryCoverPaths) {
        unawaited(_coverImageService.deleteCover(path));
      }
    }
    _titleController.dispose();
    _authorController.dispose();
    _lenderNameController.dispose();
    _lenderContactController.dispose();
    _isbnController.dispose();
    super.dispose();
  }

  void _updateCoverPath(String newPath) {
    final previousPath = _coverPath;

    if (previousPath != null) {
      _temporaryCoverPaths.remove(previousPath);
      unawaited(_coverImageService.deleteCover(previousPath));
    }

    setState(() {
      _coverPath = newPath;
      _temporaryCoverPaths.add(newPath);
    });
  }

  Future<void> _handlePickCover() async {
    final permissionService = ref.read(permissionServiceProvider);
    final granted = await permissionService.ensureCameraPermission();
    if (!granted) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Permiso de cámara denegado')),
      );
      return;
    }

    final coverService = ref.read(coverImageServiceProvider);
    final newPath = await coverService.pickCover();
    if (newPath == null) return;

    _updateCoverPath(newPath);
  }

  Future<void> _handlePickCoverFromCamera() async {
    final permissionService = ref.read(permissionServiceProvider);
    final granted = await permissionService.ensureCameraPermission();
    if (!granted) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Permiso de cámara denegado')),
      );
      return;
    }

    final coverService = ref.read(coverImageServiceProvider);
    final newPath = await coverService.pickCoverFromCamera();
    if (newPath == null) return;

    _updateCoverPath(newPath);
  }

  Future<void> _handleRemoveCover() async {
    final coverService = ref.read(coverImageServiceProvider);
    final current = _coverPath;
    if (current == null) return;

    _temporaryCoverPaths.remove(current);
    unawaited(coverService.deleteCover(current));

    setState(() {
      _coverPath = null;
    });
  }

  Future<void> _handleGoogleBooksSearch(
      BuildContext context, String barcode) async {
    setState(() {
      _isSearching = true;
      _searchError = null;
    });

    try {
      final isbnCandidates = IsbnUtils.expandCandidates(barcode);
      if (isbnCandidates.isEmpty) {
        setState(() => _searchError = 'ISBN no válido');
        return;
      }

      final apiKeyState = ref.read(googleBooksApiKeyControllerProvider);
      final apiKey = apiKeyState.valueOrNull;
      final openLibrary = ref.read(openLibraryClientProvider);
      final coverService = ref.read(coverImageServiceProvider);

      final candidates = <BookCandidate>[];

      if (apiKey != null && apiKey.isNotEmpty) {
        for (final isbn in isbnCandidates) {
          try {
            final googleResults = await GoogleBooksApiController.searchBooks(
              query: isbn,
              apiKey: apiKey,
              maxResults: 5,
            );
            candidates.addAll(googleResults.map((book) => BookCandidate(
                  title: book.title,
                  author:
                      book.authors.isNotEmpty ? book.authors.join(', ') : null,
                  isbn: book.isbn13 ?? book.isbn,
                  description: book.description,
                  coverUrl: book.thumbnailUrl,
                  source: BookSource.googleBooks,
                )));
          } catch (err) {
            if (kDebugMode) debugPrint('Google Books failed: $err');
          }
        }
      }

      // Fallback/Extra: OpenLibrary
      for (final isbn in isbnCandidates) {
        try {
          final openResults = await openLibrary.search(isbn: isbn, limit: 5);
          candidates.addAll(openResults.map(BookCandidate.fromOpenLibrary));
        } catch (err) {
          if (kDebugMode) debugPrint('OpenLibrary failed: $err');
        }
      }

      final uniqueCandidates = <String, BookCandidate>{};
      for (final c in candidates) {
        uniqueCandidates[c.isbn ?? '${c.title}|${c.author}'] = c;
      }
      final finalCandidates = uniqueCandidates.values.toList();

      if (finalCandidates.isEmpty) {
        setState(() => _searchError = 'No se encontró el libro');
        return;
      }

      if (!mounted || !context.mounted) return;
      final selected = await _pickCandidate(context, finalCandidates);
      if (selected != null) {
        await _applyCandidate(selected, coverService);
      }
    } catch (err) {
      setState(() => _searchError = 'Error: $err');
    } finally {
      if (mounted) setState(() => _isSearching = false);
    }
  }

  Future<void> _handleSearch(BuildContext context) async {
    final query = _titleController.text.trim();
    final isbn = _isbnController.text.trim();

    if (query.isEmpty && isbn.isEmpty) {
      setState(() => _searchError = 'Introduce título o ISBN');
      return;
    }

    setState(() {
      _isSearching = true;
      _searchError = null;
    });

    final openLibrary = ref.read(openLibraryClientProvider);
    final googleBooks = ref.read(googleBooksClientProvider);
    final coverService = ref.read(coverImageServiceProvider);

    try {
      final candidates = <BookCandidate>[];

      // Google Books
      try {
        final gbResults = await googleBooks.search(
          query: query.isEmpty ? null : query,
          isbn: isbn.isEmpty ? null : isbn,
        );
        candidates.addAll(gbResults.map(BookCandidate.fromGoogleBooks));
      } catch (e) {
        if (kDebugMode) debugPrint('GB Search failed: $e');
      }

      // OpenLibrary
      try {
        final olResults = await openLibrary.search(
          query: query.isEmpty ? null : query,
          isbn: isbn.isEmpty ? null : isbn,
        );
        candidates.addAll(olResults.map(BookCandidate.fromOpenLibrary));
      } catch (e) {
        if (kDebugMode) debugPrint('OL Search failed: $e');
      }

      final uniqueCandidates = <String, BookCandidate>{};
      for (final c in candidates) {
        uniqueCandidates[c.isbn ?? '${c.title}|${c.author}'] = c;
      }
      final finalCandidates = uniqueCandidates.values.toList();

      if (finalCandidates.isEmpty) {
        setState(() => _searchError = 'Sin resultados');
        return;
      }

      if (!mounted || !context.mounted) return;
      final selected = await _pickCandidate(context, finalCandidates);
      if (selected != null) {
        await _applyCandidate(selected, coverService);
      }
    } finally {
      if (mounted) setState(() => _isSearching = false);
    }
  }

  Future<BookCandidate?> _pickCandidate(
      BuildContext context, List<BookCandidate> candidates) async {
    if (candidates.length == 1) return candidates.first;

    return showModalBottomSheet<BookCandidate>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Selecciona un resultado',
                  style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 12),
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: candidates.length,
                  separatorBuilder: (_, __) => const Divider(),
                  itemBuilder: (context, index) {
                    final c = candidates[index];
                    return ListTile(
                      leading: c.coverUrl != null
                          ? Image.network(c.coverUrl!,
                              width: 40, fit: BoxFit.cover)
                          : const Icon(Icons.book),
                      title: Text(c.title),
                      subtitle: Text(c.author ?? 'Autor desconocido'),
                      onTap: () => Navigator.pop(context, c),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _applyCandidate(
      BookCandidate candidate, CoverImageService coverService) async {
    String? newCoverPath = _coverPath;

    if (candidate.coverUrl != null && candidate.coverUrl!.isNotEmpty) {
      final downloaded =
          await coverService.saveRemoteCover(candidate.coverUrl!);
      if (downloaded != null) {
        if (newCoverPath != null) {
          _temporaryCoverPaths.remove(newCoverPath);
          unawaited(coverService.deleteCover(newCoverPath));
        }
        newCoverPath = downloaded;
        _temporaryCoverPaths.add(downloaded);
      }
    }

    setState(() {
      _titleController.text = candidate.title;
      if (candidate.author != null) _authorController.text = candidate.author!;
      if (candidate.isbn != null) _isbnController.text = candidate.isbn!;
      _coverPath = newCoverPath;
      _searchError = null;
    });

    // Smart additional fetch for OpenLibrary
    if (candidate.source == BookSource.openLibrary &&
        (candidate.workKey != null || candidate.editionKey != null)) {
      try {
        final openLibrary = ref.read(openLibraryClientProvider);
        final detail = await openLibrary.getSmartMetadata(
          isbn: candidate.isbn,
          workKey: candidate.workKey,
          editionKey: candidate.editionKey,
        );
        if (detail != null && mounted) {
          setState(() {
            if (_isbnController.text.isEmpty && detail.isbn != null) {
              _isbnController.text = detail.isbn!;
            }
          });
        }
      } catch (_) {}
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final currentUser = ref.read(activeUserProvider).asData?.value;
    if (currentUser == null) return;

    final loanController = ref.read(loanControllerProvider.notifier);

    // Close sheet first
    Navigator.pop(context);

    try {
      await loanController.receiveExternalLoan(
        user: currentUser,
        title: _titleController.text.trim(),
        author: _authorController.text.trim(),
        lenderName: _lenderNameController.text.trim(),
        dueDate: _isIndefinite
            ? DateTime.now().add(const Duration(days: 365 * 10))
            : _dueDate,
        lenderContact: _lenderContactController.text.trim(),
        isbn: _isbnController.text.trim().isEmpty
            ? null
            : _isbnController.text.trim(),
        coverPath: _coverPath,
      );

      _didSubmit = true;
      _temporaryCoverPaths.clear();

      if (mounted) {
        await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            icon: const Icon(Icons.check_circle_outline,
                color: Colors.green, size: 48),
            title: const Text('Préstamo registrado'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDetailRow(context, 'Libro:', _titleController.text),
                const SizedBox(height: 8),
                _buildDetailRow(
                    context, 'Propietario:', _lenderNameController.text),
                const SizedBox(height: 8),
                _buildDetailRow(
                  context,
                  'Vence:',
                  _isIndefinite
                      ? 'Indefinido'
                      : DateFormat.yMMMd().format(_dueDate),
                ),
              ],
            ),
            actions: [
              FilledButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Entendido'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al registrar: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  Widget _buildDetailRow(BuildContext context, String label, String value) {
    return RichText(
      text: TextSpan(
        style: Theme.of(context).textTheme.bodyMedium,
        children: [
          TextSpan(
              text: '$label ',
              style: const TextStyle(fontWeight: FontWeight.bold)),
          TextSpan(text: value),
        ],
      ),
    );
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
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Registrar libro prestado',
                style: theme.textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                'Registra un libro que alguien (fuera de la app) te ha prestado.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 24),

              // Book Details
              Text('Detalles del libro', style: theme.textTheme.titleMedium),
              const SizedBox(height: 12),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Título del libro *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.book_outlined),
                ),
                textCapitalization: TextCapitalization.sentences,
                validator: (value) => value == null || value.trim().isEmpty
                    ? '¿Cómo se llama la historia?'
                    : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _authorController,
                decoration: const InputDecoration(
                  labelText: 'Autor',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person_outline),
                ),
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _isbnController,
                      decoration: const InputDecoration(
                        labelText: 'ISBN',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.qr_code_scanner_outlined),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filledTonal(
                    onPressed: () async {
                      final result = await showModalBottomSheet<String>(
                        context: context,
                        isScrollControlled: true,
                        useSafeArea: true,
                        builder: (context) => BarcodeScannerSheet(
                          onScanned: (_) {},
                        ),
                      );
                      if (result != null && mounted) {
                        if (!context.mounted) return;
                        _isbnController.text = result;
                        await _handleGoogleBooksSearch(context, result);
                      }
                    },
                    icon: const Icon(Icons.qr_code_scanner),
                    tooltip: 'Escanear código',
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: Wrap(
                  spacing: 8,
                  children: [
                    OutlinedButton.icon(
                      onPressed:
                          _isSearching ? null : () => _handleSearch(context),
                      icon: _isSearching
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.search),
                      label:
                          Text(_isSearching ? 'Buscando...' : 'Buscar datos'),
                    ),
                  ],
                ),
              ),
              if (_searchError != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    _searchError!,
                    style:
                        TextStyle(color: theme.colorScheme.error, fontSize: 12),
                    textAlign: TextAlign.right,
                  ),
                ),
              const SizedBox(height: 16),
              CoverField(
                coverPath: _coverPath,
                onPick: _handlePickCover,
                onPickFromCamera: _handlePickCoverFromCamera,
                onRemove: _coverPath != null ? _handleRemoveCover : null,
                pickingSupported: true,
              ),

              const SizedBox(height: 24),

              // Lender Details
              Text('¿Quién te lo prestó?', style: theme.textTheme.titleMedium),
              const SizedBox(height: 12),
              TextFormField(
                controller: _lenderNameController,
                decoration: const InputDecoration(
                  labelText: 'Nombre del propietario *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.account_circle_outlined),
                ),
                textCapitalization: TextCapitalization.words,
                validator: (value) => value == null || value.trim().isEmpty
                    ? '¿Quién es el guardián de este libro?'
                    : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _lenderContactController,
                decoration: const InputDecoration(
                  labelText: 'Contacto (Opcional)',
                  hintText: 'Teléfono, email, etc.',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.contact_phone_outlined),
                ),
              ),

              const SizedBox(height: 24),

              // Due Date
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Fecha de devolución',
                      style: theme.textTheme.titleMedium),
                  Row(
                    children: [
                      Text('Indefinido', style: theme.textTheme.bodySmall),
                      Switch(
                        value: _isIndefinite,
                        onChanged: (val) => setState(() => _isIndefinite = val),
                      ),
                    ],
                  )
                ],
              ),
              const SizedBox(height: 8),
              Opacity(
                opacity: _isIndefinite ? 0.5 : 1.0,
                child: IgnorePointer(
                  ignoring: _isIndefinite,
                  child: InkWell(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _dueDate,
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (picked != null) {
                        setState(() => _dueDate = picked);
                      }
                    },
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.calendar_today),
                      ),
                      child: Text(
                        _isIndefinite
                            ? 'Sin fecha límite'
                            : DateFormat.yMMMd().format(_dueDate),
                        style: theme.textTheme.bodyLarge,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 32),

              FilledButton.icon(
                onPressed: _submit,
                icon: const Icon(Icons.save_alt),
                label: const Text('Registrar préstamo'),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
