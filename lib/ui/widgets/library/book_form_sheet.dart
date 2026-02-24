import 'dart:async';
import 'dart:developer' as developer;

import 'package:drift/drift.dart' show Value;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import '../../../data/local/database.dart';
import '../../../models/book_genre.dart';
import '../../../models/reading_status.dart';
import '../../../providers/api_providers.dart';
import '../../../providers/book_providers.dart';
import '../../../providers/permission_providers.dart';
import '../../../services/cover_image_service_base.dart';
import '../../../services/google_books_api_controller.dart';
import '../../../services/google_books_client.dart';
import '../../../services/open_library_client.dart';
import '../../../utils/isbn_utils.dart';
import '../barcode_scanner_sheet.dart';
import '../cover_preview.dart';
import 'library_utils.dart';

/// Book source enum for search results
enum BookSource { openLibrary, googleBooks }

/// Book candidate model for search results
class BookCandidate {
  const BookCandidate({
    required this.title,
    this.author,
    this.isbn,
    this.description,
    this.coverUrl,
    this.categories = const [],
    this.pageCount,
    this.publicationYear,
    this.workKey,
    this.editionKey,
    required this.source,
  });

  factory BookCandidate.fromOpenLibrary(OpenLibraryBookResult result) {
    return BookCandidate(
      title: result.title,
      author: result.author,
      isbn: result.isbn,
      coverUrl: result.coverUrl,
      categories: result.subjects,
      pageCount: result.pageCount,
      publicationYear: _extractYear(result.publishedDate),
      workKey: result.key,
      editionKey: result.editionKey,
      source: BookSource.openLibrary,
    );
  }

  factory BookCandidate.fromGoogleBooks(GoogleBooksVolume volume) {
    return BookCandidate(
      title: volume.title,
      author: volume.primaryAuthor,
      isbn: volume.isbn,
      description: volume.description,
      coverUrl: volume.thumbnailUrl,
      categories: volume.categories,
      pageCount: volume.pageCount,
      publicationYear: _extractYear(volume.publishedDate),
      source: BookSource.googleBooks,
    );
  }

  final String title;
  final String? author;
  final String? isbn;
  final String? description;
  final String? coverUrl;
  final List<String> categories;
  final int? pageCount;
  final int? publicationYear;
  final String? workKey;
  final String? editionKey;
  final BookSource source;

  /// Extracts year from date string (e.g., "2020-01-15" -> 2020)
  static int? _extractYear(String? dateString) {
    if (dateString == null || dateString.isEmpty) return null;
    final match = RegExp(r'\d{4}').firstMatch(dateString);
    return match != null ? int.tryParse(match.group(0)!) : null;
  }
}

/// Book form sheet for creating/editing books
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
  final _pageCountController = TextEditingController();
  final _publicationYearController = TextEditingController();
  String _status = 'available';
  bool _isRead = false;
  bool _submitting = false;
  String? _coverPath;
  List<BookGenre> _selectedGenres = [];
  bool _isPhysical = true;
  late final String? _initialCoverPath;
  final Set<String> _temporaryCoverPaths = <String>{};
  bool _didSubmit = false;
  bool _shouldDeleteInitialOnSave = false;
  bool _isSearching = false;
  String? _searchError;
  late final CoverImageService _coverImageService;
  bool _hasActiveLoans = false;

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
      _notesController.text = book.description ?? '';
      _status = book.status == 'archived' ? 'private' : book.status;
      _isRead = book.isRead;
      // Inconsistency safety check: if the book is being read, it shouldn't be "read"
      final rStatus = ReadingStatus.fromValue(book.readingStatus);
      if (_isRead &&
          rStatus != ReadingStatus.finished &&
          rStatus != ReadingStatus.rereading) {
        _isRead = false;
      }
      _selectedGenres = BookGenre.fromCsv(book.genre);
      _isPhysical = book.isPhysical;
      _pageCountController.text = book.pageCount?.toString() ?? '';
      _publicationYearController.text = book.publicationYear?.toString() ?? '';

      // Verificar si el libro tiene préstamos activos
      _checkActiveLoans(book);
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
    _pageCountController.dispose();
    _publicationYearController.dispose();
    super.dispose();
  }

  /// Verifica si el libro tiene préstamos activos
  Future<void> _checkActiveLoans(Book book) async {
    try {
      final groupDao = ref.read(groupDaoProvider);
      final sharedBooks = await groupDao.findSharedBooksByBookId(book.id);

      for (final sharedBook in sharedBooks) {
        final activeLoans =
            await groupDao.getActiveLoansForSharedBook(sharedBook.id);
        if (activeLoans.isNotEmpty) {
          setState(() {
            _hasActiveLoans = true;
            _status =
                'loaned'; // Mostrar como prestado cuando tiene préstamos activos
          });
          return;
        }
      }

      setState(() {
        _hasActiveLoans = false;
        // Si no hay préstamos activos, mantener el estado original del libro
        _status = book.status == 'archived' ? 'private' : book.status;
      });
    } catch (e) {
      // Si hay error, asumimos que no hay préstamos activos para no bloquear innecesariamente
      setState(() {
        _hasActiveLoans = false;
        _status = book.status == 'archived' ? 'private' : book.status;
      });
    }
  }

  int? _parsePageCount() {
    final text = _pageCountController.text.trim();
    return text.isEmpty ? null : int.tryParse(text);
  }

  int? _parsePublicationYear() {
    final text = _publicationYearController.text.trim();
    return text.isEmpty ? null : int.tryParse(text);
  }

  Widget _buildGenreAndTypeSelectors(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Géneros', style: theme.textTheme.titleSmall),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ..._selectedGenres.map((genre) => Chip(
                      label: Text(genre.label),
                      onDeleted: () {
                        setState(() {
                          _selectedGenres.remove(genre);
                        });
                      },
                    )),
                ActionChip(
                  avatar: const Icon(Icons.add, size: 18),
                  label: const Text('Añadir género'),
                  onPressed: () => _showGenreSelector(context),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 16),
        SwitchListTile(
          title: Text(
            _isPhysical ? 'Libro Físico' : 'Libro Digital',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color:
                  _isPhysical ? Colors.blue.shade700 : Colors.purple.shade700,
            ),
          ),
          subtitle: Text(_isPhysical
              ? 'Este libro se podrá compartir con tus grupos.'
              : 'Los libros digitales son privados y no se comparten.'),
          value: _isPhysical,
          secondary: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _isPhysical ? Colors.blue.shade50 : Colors.purple.shade50,
              shape: BoxShape.circle,
            ),
            child: Icon(
              _isPhysical ? Icons.menu_book_rounded : Icons.vibration_rounded,
              color: _isPhysical ? Colors.blue : Colors.purple,
            ),
          ),
          onChanged: (value) {
            setState(() {
              _isPhysical = value;
              // Lógica automática de estado
              if (value) {
                _status = 'available';
              } else {
                _status = 'private';
              }
            });
          },
        ),
      ],
    );
  }

  Future<void> _showGenreSelector(BuildContext context) async {
    final selected = await showDialog<List<BookGenre>>(
      context: context,
      builder: (context) {
        return _GenreMultiSelectDialog(
          initialSelection: _selectedGenres,
        );
      },
    );

    if (selected != null) {
      setState(() {
        _selectedGenres = selected;
      });
    }
  }

  /// Construye la lista de items para el dropdown dinámicamente
  List<DropdownMenuItem<String>> _buildDropdownItems() {
    final items = <DropdownMenuItem<String>>[
      const DropdownMenuItem(
        value: 'available',
        child: Row(
          children: [
            Icon(Icons.check_circle_outline, color: Colors.blue, size: 20),
            SizedBox(width: 8),
            Text('Disponible'),
          ],
        ),
      ),
// Archived option removed as per simplification request

      const DropdownMenuItem(
        value: 'private',
        child: Row(
          children: [
            Icon(Icons.lock_outline, color: Colors.purple, size: 20),
            SizedBox(width: 8),
            Text('Privado'),
          ],
        ),
      ),
    ];

    // Solo añadir la opción 'prestado' si hay préstamos activos
    if (_hasActiveLoans) {
      items.insert(
          1,
          const DropdownMenuItem(
            value: 'loaned',
            child: Row(
              children: [
                Icon(Icons.swap_horiz_outlined, color: Colors.red, size: 20),
                SizedBox(width: 8),
                Text('Prestado'),
              ],
            ),
          ));
    }

    return items;
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
              Row(
                children: [
                  Expanded(
                    child: Text(
                      _isEditing ? 'Editar libro' : 'Añadir libro',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                  ),
                  if (_isEditing)
                    IconButton(
                      icon: const Icon(Icons.share_outlined),
                      tooltip: 'Compartir libro',
                      onPressed: () {
                        final book = widget.initialBook!;
                        final text =
                            'Me he acordado de ti al leer este libro 📚\n\n'
                            '"${book.title}"${book.author != null ? ' de ${book.author}' : ''}\n\n'
                            '¡Descárgate PassTheBook para compartir lecturas!';
                        unawaited(Share.share(text));
                      },
                    ),
                ],
              ),
              const SizedBox(height: 16),
              _buildGenreAndTypeSelectors(context),
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
                            final searchContext = context;
                            final result = await showModalBottomSheet<String>(
                              context: context,
                              isScrollControlled: true,
                              useSafeArea: true,
                              builder: (context) => BarcodeScannerSheet(
                                onScanned: (barcode) {
                                  // Callback for immediate feedback if needed
                                },
                              ),
                            );
                            if (result != null && mounted) {
                              setState(() {
                                _barcodeController.text = result;
                                // Also fill ISBN field if empty and barcode looks like ISBN
                                if (_isbnController.text.trim().isEmpty &&
                                    result.length >= 10) {
                                  _isbnController.text = result;
                                }
                              });
                              // Auto-search directly from Google Books API after scanning
                              if (searchContext.mounted) {
                                await _handleGoogleBooksSearch(
                                    searchContext, result);
                              }
                            }
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _pageCountController,
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        labelText: 'Páginas',
                        border: OutlineInputBorder(),
                        hintText: 'Ej: 350',
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _publicationYearController,
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        labelText: 'Año publicación',
                        border: OutlineInputBorder(),
                        hintText: 'Ej: 2020',
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
                    if (!_isEditing)
                      TextButton.icon(
                        onPressed: _submitting ? null : () => _clearForm(),
                        icon: const Icon(Icons.clear_all_outlined),
                        label: const Text('Limpiar formulario'),
                      ),
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
                      label: Text(_isSearching
                          ? 'Buscando…'
                          : 'Buscar datos del libro'),
                    ),
                    if (_searchError != null)
                      Text(
                        _searchError!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.error),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              CoverField(
                coverPath: _coverPath,
                onPick: coverService.supportsPicking ? _handlePickCover : null,
                onPickFromCamera: coverService.supportsPicking
                    ? _handlePickCoverFromCamera
                    : null,
                onRemove: _coverPath != null ? _handleRemoveCover : null,
                pickingSupported: coverService.supportsPicking,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _status,
                decoration: InputDecoration(
                  labelText: 'Estado del libro',
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.bookmark_outline),
                  suffixText:
                      (_hasActiveLoans || !_isPhysical) ? '🔒 Bloqueado' : null,
                  helperText: _hasActiveLoans
                      ? 'El libro tiene préstamos activos y no se puede modificar el estado'
                      : !_isPhysical
                          ? 'Los libros digitales son siempre privados'
                          : null,
                  helperStyle: TextStyle(
                    color:
                        (_hasActiveLoans || !_isPhysical) ? Colors.red : null,
                    fontSize: 12,
                  ),
                ),
                items: _buildDropdownItems(),
                onChanged: (_hasActiveLoans || !_isPhysical)
                    ? null
                    : (value) {
                        if (value != null) {
                          setState(() => _status = value);
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
              const SizedBox(height: 12),
              SwitchListTile(
                title: const Text('Estado de lectura'),
                subtitle: Text(_isRead
                    ? 'Leído · Para quitarlo, usa este switch'
                    : 'No leído · Solo aquí puedes desmarcarlo'),
                value: _isRead,
                onChanged: (value) => setState(() => _isRead = value),
                secondary: Icon(
                  _isRead ? Icons.check_circle : Icons.circle_outlined,
                  color: _isRead ? Colors.green : Colors.grey,
                ),
                activeThumbColor: Colors.green,
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
                    onPressed: _submitting
                        ? null
                        : () => Navigator.of(context).maybePop(),
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
              // Extra space for scrolling comfort
              const SizedBox(height: 60),
            ],
          ),
        ),
      ),
    );
  }

  /// Clears all form fields to their default values
  void _clearForm() {
    setState(() {
      _titleController.clear();
      _authorController.clear();
      _isbnController.clear();
      _barcodeController.clear();
      _notesController.clear();
      _status = 'available';
      _isRead = false;
      _searchError = null;

      // Clear cover image if it's not the initial cover (shouldn't happen for new books)
      if (_coverPath != null && _coverPath != _initialCoverPath) {
        _temporaryCoverPaths.remove(_coverPath);
        unawaited(_coverImageService.deleteCover(_coverPath!));
      }
      _coverPath = null;
    });
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
          showFeedbackSnackBar(
            context: context,
            message: 'Necesitas un usuario activo para compartir tus libros.',
            isError: true,
          );
        }
        return;
      }

      if (_isEditing) {
        final book = widget.initialBook!;
        String newReadingStatus = book.readingStatus;

        // Sync readingStatus with the isRead toggle
        // If it was reading/paused/etc and user marks it as read, it becomes finished
        if (_isRead &&
            newReadingStatus != 'finished' &&
            newReadingStatus != 'rereading') {
          newReadingStatus = 'finished';
        } else if (!_isRead &&
            (newReadingStatus == 'finished' ||
                newReadingStatus == 'rereading')) {
          // If it was finished and user unchecks it, revert to pending
          newReadingStatus = 'pending';
        }

        // If status actually changed via the toggle, notify ReadingTimelineService
        // to create appropriate events (start, finish, etc.)
        if (newReadingStatus != book.readingStatus && activeUser != null) {
          final timelineService = ref.read(readingTimelineServiceProvider);
          try {
            await timelineService.onReadingStatusChanged(
              book: book,
              oldStatus: ReadingStatus.fromValue(book.readingStatus),
              newStatus: ReadingStatus.fromValue(newReadingStatus),
              userId: activeUser.id,
            );
          } catch (e) {
            developer.log('Error updating reading status via service: $e',
                name: 'BookFormSheet');
          }
        }

        final updated = book.copyWith(
          title: title,
          author: Value(author.isEmpty ? null : author),
          isbn: Value(isbn.isEmpty ? null : isbn),
          barcode: Value(barcode.isEmpty ? null : barcode),
          coverPath: Value(_coverPath),
          description: Value(notes.isEmpty ? null : notes),
          status: _status,
          isRead: _isRead,
          readingStatus: newReadingStatus,
          syncedAt: const Value(null),
          updatedAt: DateTime.now(),
          genre: Value(BookGenre.toCsv(_selectedGenres)),
          isPhysical: _isPhysical,
          pageCount: Value(_parsePageCount()),
          publicationYear: Value(_parsePublicationYear()),
        );

        await repository.updateBook(updated);
      } else {
        await repository.addBook(
          title: title,
          author: author.isEmpty ? null : author,
          isbn: isbn.isEmpty ? null : isbn,
          barcode: barcode.isEmpty ? null : barcode,
          coverPath: _coverPath,
          description: notes.isEmpty ? null : notes,
          status: _status,
          isRead: _isRead,
          readingStatus: _isRead ? 'finished' : 'pending',
          owner: activeUser,
          genre: BookGenre.toCsv(_selectedGenres),
          isPhysical: _isPhysical,
          pageCount: _parsePageCount(),
          publicationYear: _parsePublicationYear(),
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
        navigator.pop();
      }
    } catch (err) {
      if (context.mounted) {
        final errorMessage = err.toString();

        // Check if it's a duplicate book error
        if (errorMessage.contains('Ya tienes ese libro')) {
          await showDialog(
            context: context,
            builder: (context) => AlertDialog(
              icon:
                  const Icon(Icons.info_outline, size: 48, color: Colors.blue),
              title: const Text('Libro duplicado'),
              content: Text(errorMessage.replaceAll('Exception: ', '')),
              actions: [
                FilledButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Entendido'),
                ),
              ],
            ),
          );
        } else {
          // Show error SnackBar for other errors
          showFeedbackSnackBar(
            context: context,
            message: 'Error al guardar el libro: $err',
            isError: true,
          );
        }
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
      navigator.pop(true); // Return true to indicate deletion
    } catch (err) {
      if (!context.mounted) return;
      showFeedbackSnackBar(
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
      showFeedbackSnackBar(
        context: context,
        message: 'Necesitas habilitar permisos para seleccionar una portada.',
        isError: true,
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
      showFeedbackSnackBar(
        context: context,
        message: 'Necesitas habilitar la cámara para tomar una foto.',
        isError: true,
      );
      return;
    }

    final coverService = ref.read(coverImageServiceProvider);
    final newPath = await coverService.pickCoverFromCamera();
    if (newPath == null) return;

    _updateCoverPath(newPath);
  }

  void _updateCoverPath(String newPath) {
    final previousPath = _coverPath;

    if (previousPath != null && previousPath != _initialCoverPath) {
      _temporaryCoverPaths.remove(previousPath);
      unawaited(_coverImageService.deleteCover(previousPath));
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

  Future<void> _handleGoogleBooksSearch(
      BuildContext context, String barcode) async {
    setState(() {
      _isSearching = true;
      _searchError = null;
    });

    try {
      // Expand ISBN to include both ISBN-13 and ISBN-10 variants
      final isbnCandidates = IsbnUtils.expandCandidates(barcode);

      if (isbnCandidates.isEmpty) {
        setState(() {
          _searchError = 'El código escaneado no es un ISBN válido.';
        });
        return;
      }

      // Debug: Show which ISBN candidates we're trying
      if (kDebugMode) {
        debugPrint('Barcode scanner candidates: ${isbnCandidates.join(", ")}');
      }

      final apiKeyState = ref.read(googleBooksApiKeyControllerProvider);
      final apiKey = apiKeyState.valueOrNull;
      final openLibrary = ref.read(openLibraryClientProvider);
      final coverService = ref.read(coverImageServiceProvider);

      final candidates = <BookCandidate>[];
      bool googleBooksFailed = false;

      // Search Google Books for all ISBN variants (priority source)
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
            googleBooksFailed = true;
            if (kDebugMode) {
              debugPrint('Google Books API failed for ISBN $isbn: $err');
            }
          }
        }
      } else {
        googleBooksFailed = true;
      }

      // Always search OpenLibrary for additional results (even if Google Books succeeded)
      // This provides backup data and potentially different editions/formats
      for (final isbn in isbnCandidates) {
        try {
          final openResults = await openLibrary.search(
            query: null,
            isbn: isbn,
            limit: 5,
          );
          candidates.addAll(openResults.map(BookCandidate.fromOpenLibrary));
        } catch (err) {
          if (kDebugMode) {
            debugPrint('OpenLibrary search failed for ISBN $isbn: $err');
          }
        }
      }

      // Deduplicate candidates
      final uniqueCandidates = <String, BookCandidate>{};
      for (final candidate in candidates) {
        final key = candidate.isbn ?? '${candidate.title}|${candidate.author}';
        if (!uniqueCandidates.containsKey(key)) {
          uniqueCandidates[key] = candidate;
        }
      }
      final finalCandidates = uniqueCandidates.values.toList();

      if (finalCandidates.isEmpty) {
        setState(() {
          if (googleBooksFailed && apiKey == null) {
            _searchError =
                'No se encontraron resultados. Configura una API key de Google Books en Configuración para mejores resultados.';
          } else {
            _searchError =
                'No se encontró el libro con ninguno de los ISBNs: ${isbnCandidates.join(", ")}\n\nPrueba buscando manualmente por título si conoces el nombre del libro.';
          }
        });
        return;
      }

      // Show picker dialog for user to select the correct book
      if (!mounted || !context.mounted) return;

      final selectedCandidate = await _pickCandidate(context, finalCandidates);
      if (selectedCandidate == null) {
        // User cancelled selection
        return;
      }

      // Apply the selected candidate
      await _applyCandidate(selectedCandidate, coverService);

      // Show success feedback
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Libro encontrado y datos cargados'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (err) {
      setState(() {
        _searchError = 'Error al buscar el libro: $err';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isSearching = false;
        });
      }
    }
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
      final candidates = <BookCandidate>[];

      // Google Books first (priority source)
      try {
        final isbnCandidates = IsbnUtils.expandCandidates(isbn);

        if (isbnCandidates.isNotEmpty) {
          // If we have ISBNs, search for each variant
          for (final candidateIsbn in isbnCandidates) {
            try {
              final gbResults = await googleBooks.search(
                query: query.isEmpty ? null : query,
                isbn: candidateIsbn,
                maxResults: 10,
              );
              candidates.addAll(gbResults.map(BookCandidate.fromGoogleBooks));
            } catch (e) {
              if (kDebugMode) {
                debugPrint(
                    'GoogleBooks search failed for ISBN $candidateIsbn: $e');
              }
            }
          }
        } else {
          // If no ISBN, just search by query
          final gbResults = await googleBooks.search(
            query: query.isEmpty ? null : query,
            isbn: null,
            maxResults: 10,
          );
          candidates.addAll(gbResults.map(BookCandidate.fromGoogleBooks));
        }
      } on GoogleBooksMissingApiKeyException {
        setState(() {
          _searchError =
              'Google Books necesita una API key. Añádela en Configuración > Integraciones externas.';
        });
        if (kDebugMode) {
          debugPrint('GoogleBooks search omitido por falta de API key');
        }
      } catch (err) {
        if (kDebugMode) {
          debugPrint('GoogleBooks search failed: $err');
        }
      }

      // OpenLibrary always runs for additional results and backup data
      try {
        final olResults = await openLibrary.search(
          query: query.isEmpty ? null : query,
          isbn: isbn,
          limit: 10,
        );
        candidates.addAll(olResults.map(BookCandidate.fromOpenLibrary));
      } catch (err) {
        if (kDebugMode) {
          debugPrint('OpenLibrary search failed: $err');
        }
      }

      // Deduplicate candidates
      final uniqueCandidates = <String, BookCandidate>{};
      for (final candidate in candidates) {
        // Use ISBN as primary key, fallback to Title+Author
        final key = candidate.isbn ?? '${candidate.title}|${candidate.author}';
        if (!uniqueCandidates.containsKey(key)) {
          uniqueCandidates[key] = candidate;
        }
      }
      final finalCandidates = uniqueCandidates.values.toList();

      if (finalCandidates.isEmpty) {
        if (!mounted) return;
        setState(() {
          _searchError = 'Sin resultados en los catálogos consultados.';
        });
        return;
      }

      if (!mounted || !pickerContext.mounted) return;
      final candidate = await _pickCandidate(pickerContext, finalCandidates);
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

  Future<BookCandidate?> _pickCandidate(
    BuildContext context,
    List<BookCandidate> candidates,
  ) async {
    if (candidates.length == 1) {
      return candidates.first;
    }

    return showModalBottomSheet<BookCandidate>(
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
                                  errorBuilder: (_, __, ___) =>
                                      const Icon(Icons.book_outlined),
                                ),
                              )
                            : const Icon(Icons.book_outlined),
                        title: Text(candidate.title),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (candidate.author != null &&
                                candidate.author!.isNotEmpty)
                              Text(candidate.author!),
                            if (candidate.isbn != null &&
                                candidate.isbn!.isNotEmpty)
                              Text('ISBN: ${candidate.isbn}'),
                            Text(
                              'Fuente: ${switch (candidate.source) {
                                BookSource.openLibrary => 'Open Library',
                                BookSource.googleBooks => 'Google Books',
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
    BookCandidate candidate,
    CoverImageService coverService,
  ) async {
    String? newCoverPath = _coverPath;

    if (candidate.coverUrl != null && candidate.coverUrl!.isNotEmpty) {
      final downloaded =
          await coverService.saveRemoteCover(candidate.coverUrl!);
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

      // Extract and map genres
      final mappedGenres =
          BookGenre.fromExternalCategories(candidate.categories);
      if (mappedGenres.isNotEmpty) {
        _selectedGenres = mappedGenres;
      }

      // Populate pageCount and publicationYear from current candidate
      if (candidate.pageCount != null) {
        _pageCountController.text = candidate.pageCount.toString();
      }
      if (candidate.publicationYear != null) {
        _publicationYearController.text = candidate.publicationYear.toString();
      }
    });

    // --- Deep Metadata Fetch (Discovery) ---
    // If it's an Open Library candidate, we might need a second call for description/pages
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
            // Only fill if not already present or if we want better data
            if (_isbnController.text.isEmpty && detail.isbn != null) {
              _isbnController.text = detail.isbn!;
            }
            if (_notesController.text.isEmpty && detail.description != null) {
              _notesController.text = detail.description!;
            }
            if (_pageCountController.text.isEmpty && detail.pageCount != null) {
              _pageCountController.text = detail.pageCount.toString();
            }
            if (_publicationYearController.text.isEmpty &&
                detail.publishDate != null) {
              final match = RegExp(r'\d{4}').firstMatch(detail.publishDate!);
              if (match != null) {
                _publicationYearController.text = match.group(0)!;
              }
            }

            // Merge subjects
            if (detail.subjects.isNotEmpty) {
              final extraGenres =
                  BookGenre.fromExternalCategories(detail.subjects);
              final allGenres = <BookGenre>{..._selectedGenres, ...extraGenres};
              _selectedGenres = allGenres.toList();
            }

            // Fallback cover if still missing
            if (_coverPath == null && detail.coverUrl != null) {
              downloadAndSetCover(detail.coverUrl!);
            }
          });
        }
      } catch (err) {
        if (kDebugMode) {
          debugPrint('Deep metadata fetch failed: $err');
        }
      }
    }
  }

  Future<void> downloadAndSetCover(String url) async {
    final coverService = ref.read(coverImageServiceProvider);
    final downloaded = await coverService.saveRemoteCover(url);
    if (downloaded != null && mounted) {
      setState(() {
        _coverPath = downloaded;
        _temporaryCoverPaths.add(downloaded);
      });
    }
  }
}

/// Cover field widget for book form
class CoverField extends StatelessWidget {
  const CoverField({
    super.key,
    required this.coverPath,
    required this.pickingSupported,
    this.onPick,
    this.onPickFromCamera,
    this.onRemove,
  });

  final String? coverPath;
  final bool pickingSupported;
  final Future<void> Function()? onPick;
  final Future<void> Function()? onPickFromCamera;
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
                coverPath ??
                    'Añade una imagen para identificar mejor tus libros.',
                style: Theme.of(context).textTheme.bodySmall,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  if (pickingSupported) ...[
                    FilledButton.tonalIcon(
                      onPressed: onPick,
                      icon: const Icon(Icons.photo_library_outlined, size: 20),
                      label: const Text('Galería'),
                    ),
                    FilledButton.tonalIcon(
                      onPressed: onPickFromCamera,
                      icon: const Icon(Icons.camera_alt_outlined, size: 20),
                      label: const Text('Cámara'),
                    ),
                  ],
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

class _GenreMultiSelectDialog extends StatefulWidget {
  const _GenreMultiSelectDialog({required this.initialSelection});

  final List<BookGenre> initialSelection;

  @override
  State<_GenreMultiSelectDialog> createState() =>
      _GenreMultiSelectDialogState();
}

class _GenreMultiSelectDialogState extends State<_GenreMultiSelectDialog> {
  late final List<BookGenre> _selected;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _selected = List.from(widget.initialSelection);
  }

  @override
  Widget build(BuildContext context) {
    var filtered = BookGenre.values;
    if (_searchQuery.isNotEmpty) {
      filtered = filtered
          .where(
              (g) => g.label.toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();
    }

    return AlertDialog(
      title: const Text('Seleccionar géneros'),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: const InputDecoration(
                hintText: 'Buscar género...',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (value) => setState(() => _searchQuery = value),
            ),
            const SizedBox(height: 16),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: filtered.length,
                itemBuilder: (context, index) {
                  final genre = filtered[index];
                  final isSelected = _selected.contains(genre);
                  return CheckboxListTile(
                    title: Text(genre.label),
                    value: isSelected,
                    onChanged: (value) {
                      setState(() {
                        if (value == true) {
                          _selected.add(genre);
                        } else {
                          _selected.remove(genre);
                        }
                      });
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(_selected),
          child: const Text('Aceptar'),
        ),
      ],
    );
  }
}
