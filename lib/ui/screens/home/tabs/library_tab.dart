import 'dart:async';

import 'package:drift/drift.dart' show Value;
import 'package:file_saver/file_saver.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;
import 'package:share_plus/share_plus.dart';
import 'package:uuid/uuid.dart';

import '../../../../data/local/database.dart';
import '../../../../providers/book_providers.dart';
import '../../../../providers/permission_providers.dart';
import '../../../../providers/api_providers.dart';
import '../../../../services/book_export_service.dart';
import '../../../../services/cover_image_service_base.dart';
import '../../../../services/google_books_client.dart';
import '../../../../services/open_library_client.dart';
import '../../../../ui/widgets/barcode_scanner_sheet.dart';
import '../../../../ui/widgets/cover_preview.dart';
import '../../../../ui/widgets/empty_state.dart';

enum _BookSource { openLibrary, googleBooks }

class _BookCandidate {
  const _BookCandidate({
    required this.title,
    this.author,
    this.isbn,
    this.description,
    this.coverUrl,
    required this.source,
  });

  factory _BookCandidate.fromOpenLibrary(OpenLibraryBookResult result) {
    return _BookCandidate(
      title: result.title,
      author: result.author,
      isbn: result.isbn,
      coverUrl: result.coverUrl,
      source: _BookSource.openLibrary,
    );
  }

  factory _BookCandidate.fromGoogleBooks(GoogleBooksVolume volume) {
    return _BookCandidate(
      title: volume.title,
      author: volume.primaryAuthor,
      isbn: volume.isbn,
      description: volume.description,
      coverUrl: volume.thumbnailUrl,
      source: _BookSource.googleBooks,
    );
  }

  final String title;
  final String? author;
  final String? isbn;
  final String? description;
  final String? coverUrl;
  final _BookSource source;
}

class _ReviewDraft {
  const _ReviewDraft({required this.rating, this.review});

  final int rating;
  final String? review;
}

enum _BookFormResult {
  saved,
  deleted,
}

enum _ExportAction { share, download }

void _showFeedbackSnackBar({
  required BuildContext context,
  required String message,
  required bool isError,
}) {
  final theme = Theme.of(context);
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor:
          isError ? theme.colorScheme.error : theme.colorScheme.primary,
    ),
  );
}


MimeType _mapMimeType(String extension) {
  switch (extension.toLowerCase()) {
    case 'pdf':
      return MimeType.pdf;
    case 'json':
      return MimeType.json;
    case 'csv':
      return MimeType.csv;
    default:
      return MimeType.other;
  }
}

class _EmptyLibraryState extends StatelessWidget {
  const _EmptyLibraryState({required this.onAddBook});

  final VoidCallback onAddBook;

  @override
  Widget build(BuildContext context) {
    return EmptyState(
      icon: Icons.menu_book_outlined,
      title: 'Tu biblioteca está vacía',
      message:
          'Registra tu primer libro para organizar préstamos y compartir lecturas con tu grupo.',
      action: EmptyStateAction(
        label: 'Registrar libro',
        icon: Icons.add_circle_outline,
        onPressed: onAddBook,
      ),
    );
  }

}

class _RatingStars extends StatelessWidget {
  const _RatingStars({required this.average});

  final double average;

  @override
  Widget build(BuildContext context) {
    final stars = List<Widget>.generate(5, (index) {
      final starValue = index + 1;
      IconData icon;
      if (average >= starValue) {
        icon = Icons.star;
      } else if (average >= starValue - 0.5) {
        icon = Icons.star_half;
      } else {
        icon = Icons.star_border;
      }
      return Icon(icon, color: Colors.amber, size: 18);
    });

    return Row(mainAxisSize: MainAxisSize.min, children: stars);
  }
}

class _BookListTile extends ConsumerWidget {
  const _BookListTile({
    required this.book,
    required this.onTap,
    required this.onAddReview,
    required this.onCreateManualLoan,
  });

  final Book book;
  final VoidCallback onTap;
  final VoidCallback onAddReview;
  final VoidCallback onCreateManualLoan;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statusLabel = _statusLabel(book.status);
    final subtitleParts = [
      if (book.author?.isNotEmpty == true) book.author,
      if (book.isbn?.isNotEmpty == true) 'ISBN ${book.isbn}',
      if (book.barcode?.isNotEmpty == true) 'Código ${book.barcode}',
    ].whereType<String>().toList();

    final reviewsAsync = ref.watch(bookReviewsProvider(book.id));
    final theme = Theme.of(context);

    final subtitleWidgets = <Widget>[];
    if (subtitleParts.isNotEmpty) {
      subtitleWidgets.add(Text(subtitleParts.join(' · ')));
    }

    subtitleWidgets.add(
      Padding(
        padding: EdgeInsets.only(top: subtitleParts.isNotEmpty ? 4 : 0),
        child: reviewsAsync.when(
          data: (reviews) {
            if (reviews.isEmpty) {
              return Text(
                'Sin reseñas todavía',
                style: theme.textTheme.bodySmall,
              );
            }
            final avg = reviews
                    .map((r) => r.rating)
                    .fold<double>(0, (prev, value) => prev + value) /
                reviews.length;
            return Row(
              children: [
                _RatingStars(average: avg),
                const SizedBox(width: 8),
                Text(
                  '${avg.toStringAsFixed(1)} / 5 · ${reviews.length} reseñas',
                  style: theme.textTheme.bodySmall,
                ),
              ],
            );
          },
          loading: () => const SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          error: (err, _) => Text(
            'Error cargando reseñas',
            style: theme.textTheme.bodySmall
                ?.copyWith(color: theme.colorScheme.error),
          ),
        ),
      ),
    );

    subtitleWidgets.add(
      Padding(
        padding: const EdgeInsets.only(top: 8),
        child: Wrap(
          spacing: 8,
          runSpacing: 4,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Chip(
              label: Text(statusLabel),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              visualDensity: VisualDensity.compact,
              labelStyle: theme.textTheme.labelSmall
                  ?.copyWith(color: theme.colorScheme.primary),
            ),
            Text(
              DateFormat.yMMMd().format(book.updatedAt),
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );

    return Card(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: buildCoverPreview(
              book.coverPath,
              size: 48,
              borderRadius: BorderRadius.circular(8),
            ),
            title: Text(
              book.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: subtitleWidgets,
            ),
            onTap: onTap,
          ),
          OverflowBar(
            alignment: MainAxisAlignment.end,
            children: [
              OutlinedButton.icon(
                onPressed: onAddReview,
                icon: const Icon(Icons.rate_review_outlined),
                label: const Text('Añadir reseña'),
              ),
              if (book.status == 'available')
                FilledButton.icon(
                  onPressed: onCreateManualLoan,
                  icon: const Icon(Icons.person_add_outlined),
                  label: const Text('Préstamo manual'),
                ),
            ],
          ),
        ],
      ),
    );
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'available':
        return 'Disponible';
      case 'loaned':
        return 'Prestado';
      case 'archived':
        return 'Archivado';
      case 'private':
        return 'Privado';
      default:
        return status;
    }
  }
}

class BookFormSheet extends ConsumerStatefulWidget {
  const BookFormSheet({super.key, this.initialBook});

  final Book? initialBook;

  @override
  ConsumerState<BookFormSheet> createState() => BookFormSheetState();
}

class BookFormSheetState extends ConsumerState<BookFormSheet> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _authorController = TextEditingController();
  final _isbnController = TextEditingController();
  final _barcodeController = TextEditingController();
  final _notesController = TextEditingController();
  String _status = 'available';
  bool _submitting = false;
  String? _coverPath;
  late final String? _initialCoverPath;
  final Set<String> _temporaryCoverPaths = <String>{};
  bool _didSubmit = false;
  bool _shouldDeleteInitialOnSave = false;
  bool _isSearching = false;
  String? _searchError;
  late final CoverImageService _coverImageService;

  bool get _isEditing => widget.initialBook != null;

  @override
  void initState() {
    super.initState();
    _coverImageService = ref.read(coverImageServiceProvider);
    final book = widget.initialBook;
    _initialCoverPath = book?.coverPath;
    _coverPath = _initialCoverPath;
    if (book != null) {
      _titleController.text = book.title;
      _authorController.text = book.author ?? '';
      _isbnController.text = book.isbn ?? '';
      _barcodeController.text = book.barcode ?? '';
      _notesController.text = book.notes ?? '';
      _status = book.status;
    }
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
    _isbnController.dispose();
    _barcodeController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final coverService = ref.watch(coverImageServiceProvider);

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _isEditing ? 'Editar libro' : 'Añadir libro',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _titleController,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Título',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'El título es obligatorio.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _authorController,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Autor',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _isbnController,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        labelText: 'ISBN',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _barcodeController,
                      textInputAction: TextInputAction.next,
                      decoration: InputDecoration(
                        labelText: 'Código barras',
                        border: const OutlineInputBorder(),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.qr_code_scanner),
                          tooltip: 'Escanear código',
                          onPressed: () async {
                            final result = await showModalBottomSheet<String>(
                              context: context,
                              isScrollControlled: true,
                              useSafeArea: true,
                              builder: (context) => const BarcodeScannerSheet(),
                            );
                            if (result != null && mounted) {
                              setState(() {
                                _barcodeController.text = result;
                              });
                            }
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    OutlinedButton.icon(
                      onPressed: _isSearching ? null : () => _handleSearch(context),
                      icon: _isSearching
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.search),
                      label: Text(_isSearching ? 'Buscando…' : 'Buscar datos del libro'),
                    ),
                    if (_searchError != null)
                      Text(
                        _searchError!,
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(color: Theme.of(context).colorScheme.error),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              _CoverField(
                coverPath: _coverPath,
                onPick: coverService.supportsPicking ? _handlePickCover : null,
                onRemove: _coverPath != null ? _handleRemoveCover : null,
                pickingSupported: coverService.supportsPicking,
              ),
              const SizedBox(height: 12),
              if (_status == 'loaned')
                TextFormField(
                  enabled: false,
                  initialValue: 'Prestado',
                  decoration: const InputDecoration(
                    labelText: 'Estado',
                    border: OutlineInputBorder(),
                    helperText: 'No se puede cambiar mientras hay un préstamo activo',
                  ),
                )
              else
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Estado',
                    border: OutlineInputBorder(),
                  ),
                  initialValue: _status,
                  items: const [
                    DropdownMenuItem(value: 'available', child: Text('Disponible')),
                    DropdownMenuItem(value: 'loaned', child: Text('Prestado')),
                    DropdownMenuItem(value: 'archived', child: Text('Archivado')),
                    DropdownMenuItem(value: 'private', child: Text('Privado')),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _status = value;
                      });
                    }
                  },
                ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _notesController,
                minLines: 3,
                maxLines: 5,
                decoration: const InputDecoration(
                  labelText: 'Notas',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (_isEditing) ...[
                    TextButton.icon(
                      onPressed: _submitting ? null : () => _delete(context),
                      icon: const Icon(Icons.delete_outline),
                      label: const Text('Eliminar'),
                    ),
                    const SizedBox(width: 12),
                  ],
                  TextButton(
                    onPressed:
                        _submitting ? null : () => Navigator.of(context).maybePop(),
                    child: const Text('Cancelar'),
                  ),
                  const SizedBox(width: 12),
                  FilledButton(
                    onPressed: _submitting ? null : () => _submit(context),
                    child: _submitting
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Guardar'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submit(BuildContext context) async {
    final navigator = Navigator.of(context);
    if (_submitting) return;

    final valid = _formKey.currentState?.validate() ?? false;
    if (!valid) return;

    setState(() {
      _submitting = true;
    });

    final repository = ref.read(bookRepositoryProvider);
    final coverService = ref.read(coverImageServiceProvider);

    try {
      final title = _titleController.text.trim();
      final author = _authorController.text.trim();
      final isbn = _isbnController.text.trim();
      final barcode = _barcodeController.text.trim();
      final notes = _notesController.text.trim();

      final activeUser = ref.read(activeUserProvider).value;

      if (!_isEditing && activeUser == null) {
        if (context.mounted) {
          _showFeedbackSnackBar(
            context: context,
            message: 'Necesitas un usuario activo para compartir tus libros.',
            isError: true,
          );
        }
        return;
      }

      if (_isEditing) {
        final book = widget.initialBook!;
        final updated = book.copyWith(
          title: title,
          author: Value(author.isEmpty ? null : author),
          isbn: Value(isbn.isEmpty ? null : isbn),
          barcode: Value(barcode.isEmpty ? null : barcode),
          coverPath: Value(_coverPath),
          notes: Value(notes.isEmpty ? null : notes),
          status: _status,
          updatedAt: DateTime.now(),
        );

        await repository.updateBook(updated);
      } else {
        await repository.addBook(
          title: title,
          author: author.isEmpty ? null : author,
          isbn: isbn.isEmpty ? null : isbn,
          barcode: barcode.isEmpty ? null : barcode,
          coverPath: _coverPath,
          notes: notes.isEmpty ? null : notes,
          status: _status,
          owner: activeUser,
        );
      }

      final initialPath = _initialCoverPath;
      if (_shouldDeleteInitialOnSave && initialPath != null) {
        await coverService.deleteCover(initialPath);
      }

      _didSubmit = true;
      if (_coverPath != null) {
        _temporaryCoverPaths.remove(_coverPath);
      }

      if (!mounted) return;
      if (context.mounted) {
        navigator.pop(_BookFormResult.saved);
      }
    } catch (err) {
      if (context.mounted) {
        _showFeedbackSnackBar(
          context: context,
          message: 'Error al guardar el libro: $err',
          isError: true,
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _submitting = false;
        });
      }
    }
  }

  Future<void> _delete(BuildContext context) async {
    final book = widget.initialBook;
    if (book == null) return;

    final navigator = Navigator.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar libro'),
        content: Text('¿Seguro que deseas eliminar "${book.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() {
      _submitting = true;
    });

    final repository = ref.read(bookRepositoryProvider);
    final coverService = ref.read(coverImageServiceProvider);

    try {
      final removedSharedBooks = await repository.deleteBook(book);
      if (removedSharedBooks.isNotEmpty) {
        final grouped = <int, List<int>>{};
        for (final shared in removedSharedBooks) {
          grouped.putIfAbsent(shared.groupId, () => <int>[]).add(shared.id);
        }
        for (final entry in grouped.entries) {
          ref
              .read(discoverGroupControllerProvider(entry.key).notifier)
              .invalidateSharedBooks(entry.value);
        }
      }
      final existingCover = book.coverPath;
      if (existingCover != null) {
        await coverService.deleteCover(existingCover);
      }
      if (!context.mounted) return;
      navigator.pop(_BookFormResult.deleted);
    } catch (err) {
      if (!context.mounted) return;
      _showFeedbackSnackBar(
        context: context,
        message: 'No se pudo eliminar: $err',
        isError: true,
      );
    } finally {
      if (context.mounted) {
        setState(() {
          _submitting = false;
        });
      }
    }
  }

  Future<void> _handlePickCover() async {
    final permissionService = ref.read(permissionServiceProvider);
    final granted = await permissionService.ensureCameraPermission();
    if (!granted) {
      if (!mounted) return;
      _showFeedbackSnackBar(
        context: context,
        message: 'Necesitas habilitar la cámara para seleccionar una portada.',
        isError: true,
      );
      return;
    }

    final coverService = ref.read(coverImageServiceProvider);
    final newPath = await coverService.pickCover();
    if (newPath == null) return;

    final previousPath = _coverPath;

    if (previousPath != null && previousPath != _initialCoverPath) {
      _temporaryCoverPaths.remove(previousPath);
      unawaited(coverService.deleteCover(previousPath));
    }

    if (previousPath == _initialCoverPath) {
      _shouldDeleteInitialOnSave = true;
    }

    setState(() {
      _coverPath = newPath;
      if (newPath != _initialCoverPath) {
        _temporaryCoverPaths.add(newPath);
      }
    });
  }

  Future<void> _handleRemoveCover() async {
    final coverService = ref.read(coverImageServiceProvider);
    final current = _coverPath;
    if (current == null) return;

    if (current == _initialCoverPath) {
      _shouldDeleteInitialOnSave = true;
    } else {
      _temporaryCoverPaths.remove(current);
      unawaited(coverService.deleteCover(current));
    }

    setState(() {
      _coverPath = null;
    });
  }

  Future<void> _handleSearch(BuildContext context) async {
    final pickerContext = context;
    final query = _titleController.text.trim();
    final isbnInput = _isbnController.text.trim();
    final barcodeInput = _barcodeController.text.trim();
    final isbn = isbnInput.isNotEmpty
        ? isbnInput
        : (barcodeInput.length >= 10 ? barcodeInput : null);

    if (query.isEmpty && (isbn == null || isbn.isEmpty)) {
      setState(() {
        _searchError = 'Introduce al menos un título o ISBN.';
      });
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
      final candidates = <_BookCandidate>[];

      try {
        final olResults = await openLibrary.search(
          query: query.isEmpty ? null : query,
          isbn: isbn,
          limit: 10,
        );
        candidates.addAll(olResults.map(_BookCandidate.fromOpenLibrary));
      } catch (err) {
        // Guardamos el error pero no rompemos el flujo.
        debugPrint('OpenLibrary search failed: $err');
      }

      try {
        final gbResults = await googleBooks.search(
          query: query.isEmpty ? null : query,
          isbn: isbn,
          maxResults: 10,
        );
        candidates.addAll(gbResults.map(_BookCandidate.fromGoogleBooks));
      } on GoogleBooksMissingApiKeyException {
        setState(() {
          _searchError =
              'Google Books necesita una API key. Añádela en Configuración > Integraciones externas.';
        });
        debugPrint('GoogleBooks search omitido por falta de API key');
      } catch (err) {
        debugPrint('GoogleBooks search failed: $err');
      }

      if (candidates.isEmpty) {
        if (!mounted) return;
        setState(() {
          _searchError = 'Sin resultados en los catálogos consultados.';
        });
        return;
      }

      if (!mounted || !pickerContext.mounted) return;
      final candidate = await _pickCandidate(pickerContext, candidates);
      if (candidate == null) {
        return;
      }

      await _applyCandidate(candidate, coverService);
    } finally {
      if (mounted) {
        setState(() {
          _isSearching = false;
        });
      }
    }
  }

  Future<_BookCandidate?> _pickCandidate(
    BuildContext context,
    List<_BookCandidate> candidates,
  ) async {
    if (candidates.length == 1) {
      return candidates.first;
    }

    return showModalBottomSheet<_BookCandidate>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Selecciona un resultado',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 12),
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: candidates.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final candidate = candidates[index];
                      return ListTile(
                        leading: candidate.coverUrl != null
                            ? SizedBox(
                                width: 48,
                                height: 48,
                                child: Image.network(
                                  candidate.coverUrl!,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => const Icon(Icons.book_outlined),
                                ),
                              )
                            : const Icon(Icons.book_outlined),
                        title: Text(candidate.title),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (candidate.author != null && candidate.author!.isNotEmpty)
                              Text(candidate.author!),
                            if (candidate.isbn != null && candidate.isbn!.isNotEmpty)
                              Text('ISBN: ${candidate.isbn}'),
                            Text(
                              'Fuente: ${switch (candidate.source) {
                                _BookSource.openLibrary => 'Open Library',
                                _BookSource.googleBooks => 'Google Books',
                              }}',
                            ),
                          ],
                        ),
                        onTap: () => Navigator.of(context).pop(candidate),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _applyCandidate(
    _BookCandidate candidate,
    CoverImageService coverService,
  ) async {
    String? newCoverPath = _coverPath;

    if (candidate.coverUrl != null && candidate.coverUrl!.isNotEmpty) {
      final downloaded = await coverService.saveRemoteCover(candidate.coverUrl!);
      if (downloaded != null) {
        if (newCoverPath != null && newCoverPath != _initialCoverPath) {
          _temporaryCoverPaths.remove(newCoverPath);
          unawaited(coverService.deleteCover(newCoverPath));
        }
        if (newCoverPath == _initialCoverPath) {
          _shouldDeleteInitialOnSave = true;
        }

        newCoverPath = downloaded;
        if (downloaded != _initialCoverPath) {
          _temporaryCoverPaths.add(downloaded);
        }
      }
    }

    setState(() {
      _titleController.text = candidate.title;
      if (candidate.author != null) {
        _authorController.text = candidate.author!;
      }
      if (candidate.isbn != null) {
        _isbnController.text = candidate.isbn!;
      }
      if (candidate.description != null && candidate.description!.isNotEmpty) {
        _notesController.text = candidate.description!;
      }
      _coverPath = newCoverPath;
      _searchError = null;
    });
  }
}

class _CoverField extends StatelessWidget {
  const _CoverField({
    required this.coverPath,
    required this.pickingSupported,
    this.onPick,
    this.onRemove,
  });

  final String? coverPath;
  final bool pickingSupported;
  final Future<void> Function()? onPick;
  final Future<void> Function()? onRemove;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        buildCoverPreview(
          coverPath,
          size: 72,
          borderRadius: BorderRadius.circular(12),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                coverPath == null ? 'Sin portada' : 'Portada seleccionada',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 4),
              Text(
                coverPath ?? 'Añade una imagen para identificar mejor tus libros.',
                style: Theme.of(context).textTheme.bodySmall,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  if (pickingSupported)
                    FilledButton.icon(
                      onPressed: onPick,
                      icon: const Icon(Icons.photo_library_outlined),
                      label: Text(coverPath == null ? 'Seleccionar' : 'Cambiar'),
                    ),
                  if (!pickingSupported)
                    const Chip(
                      avatar: Icon(Icons.info_outline, size: 18),
                      label: Text('Portadas no disponibles en esta plataforma'),
                    ),
                  if (coverPath != null && onRemove != null)
                    OutlinedButton.icon(
                      onPressed: onRemove,
                      icon: const Icon(Icons.delete_outline),
                      label: const Text('Eliminar'),
                    ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class LibraryTab extends ConsumerStatefulWidget {
  const LibraryTab({super.key, required this.onOpenForm});

  final Future<void> Function({Book? book}) onOpenForm;

  @override
  ConsumerState<LibraryTab> createState() => _LibraryTabState();
}

class _LibraryTabState extends ConsumerState<LibraryTab> {
  @override
  Widget build(BuildContext context) {
    final booksAsync = ref.watch(bookListProvider);
    final theme = Theme.of(context);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: booksAsync.when(
          data: (books) {
            if (books.isEmpty) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Mi biblioteca', style: theme.textTheme.headlineMedium),
                  const SizedBox(height: 8),
                  Text(
                    'Añade tus libros para gestionarlos desde aquí.',
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 16),
                  Align(
                    alignment: Alignment.centerRight,
                    child: _ExportButton(onExport: () => _handleExport()),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: _EmptyLibraryState(
                      onAddBook: () => widget.onOpenForm(),
                    ),
                  ),
                ],
              );
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Mi biblioteca', style: theme.textTheme.headlineMedium),
                const SizedBox(height: 8),
                Text(
                  'Gestiona tus libros guardados y prepara los préstamos.',
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 16),
                Align(
                  alignment: Alignment.centerRight,
                  child: _ExportButton(onExport: () => _handleExport()),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: ListView.separated(
                    itemCount: books.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final book = books[index];
                      return _BookListTile(
                        book: book,
                        onTap: () => widget.onOpenForm(book: book),
                        onAddReview: () => _showAddReviewDialog(context, book),
                        onCreateManualLoan: () => _showManualLoanDialog(context, book),
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

  Future<void> _showAddReviewDialog(BuildContext context, Book book) async {
    final repository = ref.read(bookRepositoryProvider);
    final theme = Theme.of(context);
    final controller = TextEditingController();
    var rating = 5;

    _ReviewDraft? draft;

    try {
      draft = await showDialog<_ReviewDraft>(
        context: context,
        builder: (dialogContext) => StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Añadir reseña a "${book.title}"'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Puntuación',
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(5, (index) {
                      final starValue = index + 1;
                      final isActive = starValue <= rating;
                      return IconButton(
                        onPressed: () => setState(() {
                          rating = starValue;
                        }),
                        icon: Icon(
                          isActive ? Icons.star : Icons.star_border,
                          color: Colors.amber,
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: controller,
                    minLines: 2,
                    maxLines: 5,
                    decoration: const InputDecoration(
                      labelText: 'Escribe una reseña (opcional)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancelar'),
                ),
                FilledButton(
                  onPressed: () {
                    Navigator.of(context).pop(
                      _ReviewDraft(
                        rating: rating,
                        review: controller.text.trim().isEmpty
                            ? null
                            : controller.text.trim(),
                      ),
                    );
                  },
                  child: const Text('Guardar'),
                ),
              ],
            );
          },
        ),
      );
    } finally {
      controller.dispose();
    }

    if (draft == null) {
      return;
    }

    final activeUser = await ref.read(userRepositoryProvider).getActiveUser();
    if (activeUser == null) {
      if (!context.mounted) return;
      _showFeedbackSnackBar(
        context: context,
        message: 'Crea un usuario antes de añadir reseñas.',
        isError: true,
      );
      return;
    }

    try {
      await repository.addReview(
        book: book,
        rating: draft.rating,
        review: draft.review,
        author: activeUser,
      );
      if (!context.mounted) return;
      _showFeedbackSnackBar(
        context: context,
        message: 'Reseña añadida.',
        isError: false,
      );
    } catch (err) {
      if (!context.mounted) return;
      _showFeedbackSnackBar(
        context: context,
        message: 'Error al guardar reseña: $err',
        isError: true,
      );
    }
  }

  Future<void> _showManualLoanDialog(BuildContext context, Book book) async {
    final loanRepository = ref.read(loanRepositoryProvider);
    final groupDao = ref.read(groupDaoProvider);
    final theme = Theme.of(context);
    // ignore: prefer_const_constructors
    final uuid = Uuid();
    
    final nameController = TextEditingController();
    final contactController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    DateTime? selectedDueDate;

    try {
      final result = await showDialog<Map<String, dynamic>>(
        context: context,
        builder: (dialogContext) => StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Préstamo manual de "${book.title}"'),
              content: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Prestar a alguien sin la app',
                      style: theme.textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'Nombre del prestatario *',
                        hintText: 'Ej: Juan Pérez',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'El nombre es requerido';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: contactController,
                      decoration: const InputDecoration(
                        labelText: 'Contacto (opcional)',
                        hintText: 'Teléfono o email',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now().add(const Duration(days: 14)),
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(const Duration(days: 365)),
                        );
                        if (picked != null) {
                          setState(() => selectedDueDate = picked);
                        }
                      },
                      icon: const Icon(Icons.calendar_today),
                      label: Text(
                        selectedDueDate == null
                            ? 'Seleccionar fecha de devolución *'
                            : 'Vence: ${DateFormat.yMMMd().format(selectedDueDate!)}',
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancelar'),
                ),
                FilledButton(
                  onPressed: () {
                    if (formKey.currentState?.validate() ?? false) {
                      if (selectedDueDate == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Selecciona una fecha de devolución'),
                          ),
                        );
                        return;
                      }
                      Navigator.pop(context, {
                        'name': nameController.text.trim(),
                        'contact': contactController.text.trim(),
                        'dueDate': selectedDueDate,
                      });
                    }
                  },
                  child: const Text('Crear préstamo'),
                ),
              ],
            );
          },
        ),
      );

      if (result == null) return;

      // Get active user and first shared book for this book
      final activeUser = await ref.read(userRepositoryProvider).getActiveUser();
      if (activeUser == null) {
        if (!context.mounted) return;
        _showFeedbackSnackBar(
          context: context,
          message: 'Necesitas un usuario activo.',
          isError: true,
        );
        return;
      }

      // Find a shared book for this book (or create one if needed)
      final sharedBooks = await groupDao.findSharedBooksByBookId(book.id);
      SharedBook? sharedBook;
      
      if (sharedBooks.isNotEmpty) {
        sharedBook = sharedBooks.first;
      } else {
        // Need to create a shared book first - get user's groups
        final groups = await groupDao.getGroupsForUser(activeUser.id);
        if (groups.isEmpty) {
          if (!context.mounted) return;
          _showFeedbackSnackBar(
            context: context,
            message: 'Necesitas estar en un grupo para crear préstamos.',
            isError: true,
          );
          return;
        }
        
        // Create shared book in first group
        final group = groups.first;
        final now = DateTime.now();
        final sharedBookId = await groupDao.insertSharedBook(
          SharedBooksCompanion.insert(
            uuid: uuid.v4(),
            groupId: group.id,
            groupUuid: group.uuid,
            bookId: book.id,
            bookUuid: book.uuid,
            ownerUserId: activeUser.id,
            ownerRemoteId: activeUser.remoteId != null
                ? Value(activeUser.remoteId!)
                : const Value.absent(),
            isAvailable: const Value(true),
            visibility: const Value('group'),
            isDirty: const Value(true),
            isDeleted: const Value(false),
            syncedAt: const Value(null),
            createdAt: Value(now),
            updatedAt: Value(now),
          ),
        );
        sharedBook = await groupDao.findSharedBookById(sharedBookId);
      }

      if (sharedBook == null) {
        if (!context.mounted) return;
        _showFeedbackSnackBar(
          context: context,
          message: 'No se pudo preparar el libro para préstamo.',
          isError: true,
        );
        return;
      }

      // Create the manual loan
      await loanRepository.createManualLoan(
        sharedBook: sharedBook,
        owner: activeUser,
        borrowerName: result['name'] as String,
        borrowerContact: (result['contact'] as String).isNotEmpty
            ? result['contact'] as String
            : null,
        dueDate: result['dueDate'] as DateTime,
      );

      // Sync to update book status in groups
      await ref.read(groupSyncControllerProvider.notifier).syncGroups();

      if (!context.mounted) return;
      _showFeedbackSnackBar(
        context: context,
        message: 'Préstamo manual creado correctamente.',
        isError: false,
      );
    } finally {
      nameController.dispose();
      contactController.dispose();
    }
  }

  Future<void> _handleExport() async {
    if (!mounted) return;
    final ctx = context;

    try {
      final repository = ref.read(bookRepositoryProvider);
      final exportService = ref.read(bookExportServiceProvider);

      final activeUser = ref.read(activeUserProvider).value;
      final books = await repository.fetchActiveBooks(ownerUserId: activeUser?.id);
      if (books.isEmpty) {
        if (!ctx.mounted) return;
        _showFeedbackSnackBar(
          context: ctx,
          message: 'No hay libros para exportar.',
          isError: true,
        );
        return;
      }

      final reviews = await repository.fetchActiveReviews();

      if (!ctx.mounted) return;
      final format = await showModalBottomSheet<BookExportFormat>(
        context: ctx,
        builder: (sheetContext) => SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.table_rows_outlined),
                title: const Text('Exportar como CSV'),
                onTap: () => Navigator.of(sheetContext).pop(BookExportFormat.csv),
              ),
              ListTile(
                leading: const Icon(Icons.code),
                title: const Text('Exportar como JSON'),
                onTap: () => Navigator.of(sheetContext).pop(BookExportFormat.json),
              ),
              ListTile(
                leading: const Icon(Icons.picture_as_pdf_outlined),
                title: const Text('Exportar como PDF'),
                onTap: () => Navigator.of(sheetContext).pop(BookExportFormat.pdf),
              ),
            ],
          ),
        ),
      );

      if (format == null) {
        return;
      }

      if (!ctx.mounted) return;
      final action = await showModalBottomSheet<_ExportAction>(
        context: ctx,
        builder: (sheetContext) => SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.ios_share),
                title: const Text('Compartir archivo'),
                subtitle: const Text('Enviar el archivo generado a otras apps.'),
                onTap: () => Navigator.of(sheetContext).pop(_ExportAction.share),
              ),
              ListTile(
                leading: const Icon(Icons.download_outlined),
                title: const Text('Descargar archivo'),
                subtitle: const Text('Guardar el archivo localmente en el dispositivo.'),
                onTap: () => Navigator.of(sheetContext).pop(_ExportAction.download),
              ),
            ],
          ),
        ),
      );

      if (action == null) {
        return;
      }

      final result = await exportService.export(
        books: books,
        reviews: reviews,
        format: format,
      );

      if (action == _ExportAction.share) {
        final file = XFile.fromData(
          result.bytes,
          mimeType: result.mimeType,
          name: result.fileName,
        );

        await Share.shareXFiles(
          [file],
          subject: 'Mi biblioteca exportada',
          text: 'Te comparto mi biblioteca en formato ${format.name.toUpperCase()}.',
        );
      } else {
        final name = p.basenameWithoutExtension(result.fileName);
        final extension = p.extension(result.fileName).replaceFirst('.', '');
        await FileSaver.instance.saveFile(
          name: name,
          bytes: result.bytes,
          ext: extension,
          mimeType: _mapMimeType(extension),
        );

        if (!ctx.mounted) return;
        _showFeedbackSnackBar(
          context: ctx,
          message: 'Archivo guardado como ${result.fileName}.',
          isError: false,
        );
      }
    } catch (err) {
      if (!ctx.mounted) return;
      _showFeedbackSnackBar(
        context: ctx,
        message: 'No se pudo exportar: $err',
        isError: true,
      );
    }
  }

}

class _ExportButton extends StatelessWidget {
  const _ExportButton({required this.onExport});

  final VoidCallback onExport;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onExport,
      icon: const Icon(Icons.file_upload_outlined),
      label: const Text('Exportar biblioteca'),
    );
  }
}

