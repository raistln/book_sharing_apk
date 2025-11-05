import 'dart:async';

import 'package:drift/drift.dart' show Value;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

import '../../../config/supabase_defaults.dart';
import '../../../data/local/database.dart';
import '../../../data/local/group_dao.dart';
import '../../../providers/api_providers.dart';
import '../../../providers/auth_providers.dart';
import '../../../providers/book_providers.dart';
import '../../../services/book_export_service.dart';
import '../../../services/cover_image_service_base.dart';
import '../../../services/google_books_client.dart';
import '../../../services/open_library_client.dart';
import '../../../services/supabase_config_service.dart';
import '../../widgets/cover_preview.dart';
import '../auth/pin_setup_screen.dart';

final _currentTabProvider = StateProvider<int>((ref) => 0);

enum _BookFormResult { saved, deleted }

class _BookCandidate {
  const _BookCandidate({
    required this.title,
    this.author,
    this.isbn,
    this.description,
    this.coverUrl,
  });

  factory _BookCandidate.fromOpenLibrary(OpenLibraryBookResult result) {
    return _BookCandidate(
      title: result.title,
      author: result.author,
      isbn: result.isbn,
      coverUrl: result.coverUrl,
    );
  }

  factory _BookCandidate.fromGoogleBooks(GoogleBooksVolume volume) {
    return _BookCandidate(
      title: volume.title,
      author: volume.primaryAuthor,
      isbn: volume.isbn,
      description: volume.description,
      coverUrl: volume.thumbnailUrl,
    );
  }

  final String title;
  final String? author;
  final String? isbn;
  final String? description;
  final String? coverUrl;
}

class _ReviewDraft {
  const _ReviewDraft({required this.rating, this.review});

  final int rating;
  final String? review;
}

class HomeShell extends ConsumerWidget {
  const HomeShell({super.key});

  static const routeName = '/home';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(_currentTabProvider);

    return Scaffold(
      body: IndexedStack(
        index: currentIndex,
        children: [
          _LibraryTab(onOpenForm: ({Book? book}) => _showBookFormSheet(context, ref, book: book)),
          const _CommunityTab(),
          const _LoansTab(),
          const _StatsTab(),
          const _SettingsTab(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.menu_book_outlined),
            selectedIcon: Icon(Icons.menu_book),
            label: 'Biblioteca',
          ),
          NavigationDestination(
            icon: Icon(Icons.groups_outlined),
            selectedIcon: Icon(Icons.groups),
            label: 'Comunidad',
          ),
          NavigationDestination(
            icon: Icon(Icons.swap_horiz_outlined),
            selectedIcon: Icon(Icons.swap_horiz),
            label: 'Préstamos',
          ),
          NavigationDestination(
            icon: Icon(Icons.insights_outlined),
            selectedIcon: Icon(Icons.insights),
            label: 'Stats',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Ajustes',
          ),
        ],
        onDestinationSelected: (value) {
          ref.read(_currentTabProvider.notifier).state = value;
        },
      ),
      floatingActionButton: _buildFab(context, ref, currentIndex),
    );
  }

  Widget? _buildFab(BuildContext context, WidgetRef ref, int currentIndex) {
    if (currentIndex == 0) {
      return FloatingActionButton.extended(
        onPressed: () => _showBookFormSheet(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('Añadir libro'),
      );
    }

    if (kDebugMode) {
      return FloatingActionButton.extended(
        onPressed: () => _clearPin(context, ref),
        icon: const Icon(Icons.dangerous_outlined),
        label: const Text('Debug: reset PIN'),
      );
    }

    return null;
  }

  Future<void> _showBookFormSheet(BuildContext context, WidgetRef ref, {Book? book}) async {
    final result = await showModalBottomSheet<_BookFormResult>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => _BookFormSheet(initialBook: book),
    );

    if (!context.mounted || result == null) return;

    switch (result) {
      case _BookFormResult.saved:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(book == null
                ? 'Libro añadido a tu biblioteca.'
                : 'Libro actualizado correctamente.'),
          ),
        );
        break;
      case _BookFormResult.deleted:
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Libro eliminado.')),
        );
        break;
    }
  }

  Future<void> _clearPin(BuildContext context, WidgetRef ref) async {
    await ref.read(authControllerProvider.notifier).clearPin();
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('PIN borrado (solo debug).')),
    );
    Navigator.of(context)
        .pushNamedAndRemoveUntil(PinSetupScreen.routeName, (route) => false);
  }

}

class _EmptyLibraryState extends StatelessWidget {
  const _EmptyLibraryState({required this.onAddBook});

  final VoidCallback onAddBook;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.menu_book_outlined,
              size: 96, color: Theme.of(context).colorScheme.primary),
          const SizedBox(height: 16),
          const Text(
            'No tienes libros guardados todavía.',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Escanea códigos, busca en catálogos o añade datos manualmente.\nMientras tanto, puedes registrar uno a mano.',
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: onAddBook,
            icon: const Icon(Icons.add_circle_outline),
            label: const Text('Añadir primer libro'),
          ),
        ],
      ),
    );
  }
}

class _SupabaseConfigCard extends ConsumerWidget {
  const _SupabaseConfigCard({
    required this.onConfigure,
    required this.onReset,
  });

  final Future<void> Function() onConfigure;
  final Future<void> Function() onReset;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final configState = ref.watch(supabaseConfigControllerProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: configState.when(
          data: (config) {
            final theme = Theme.of(context);
            final usingDefaults = config.url == kSupabaseDefaultUrl &&
                config.anonKey == kSupabaseDefaultAnonKey;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.cloud_outlined,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Supabase',
                      style: theme.textTheme.titleMedium,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  usingDefaults
                      ? 'Usando la configuración predeterminada del proyecto.'
                      : 'Usando una configuración personalizada.',
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 12),
                Text(
                  'URL: ${config.url}',
                  style: theme.textTheme.bodySmall,
                ),
                const SizedBox(height: 4),
                Text(
                  'Anon key: ${_maskSupabaseAnonKey(config.anonKey)}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 12,
                  runSpacing: 8,
                  children: [
                    FilledButton.icon(
                      onPressed: () => unawaited(onConfigure()),
                      icon: const Icon(Icons.edit_outlined),
                      label: const Text('Configurar Supabase'),
                    ),
                    OutlinedButton.icon(
                      onPressed: usingDefaults
                          ? null
                          : () => unawaited(onReset()),
                      icon: const Icon(Icons.settings_backup_restore_outlined),
                      label: const Text('Restaurar valores por defecto'),
                    ),
                  ],
                ),
              ],
            );
          },
          loading: () => const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: CircularProgressIndicator(),
            ),
          ),
          error: (error, _) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.error_outline,
                      color: Theme.of(context).colorScheme.error,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'No se pudo cargar la configuración de Supabase.',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '$error',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: () =>
                      ref.invalidate(supabaseConfigControllerProvider),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Reintentar'),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

String _maskSupabaseAnonKey(String key) {
  if (key.length <= 8) {
    return '*' * key.length;
  }
  final prefix = key.substring(0, 6);
  final suffix = key.substring(key.length - 4);
  return '$prefix***$suffix';
}

class _SupabaseConfigDialog extends StatefulWidget {
  const _SupabaseConfigDialog({
    required this.ref,
    this.initialConfig,
  });

  final WidgetRef ref;
  final SupabaseConfig? initialConfig;

  @override
  State<_SupabaseConfigDialog> createState() => _SupabaseConfigDialogState();
}

class _SupabaseConfigDialogState extends State<_SupabaseConfigDialog> {
  late final TextEditingController _urlController;
  late final TextEditingController _anonKeyController;
  String? _urlError;
  String? _anonKeyError;
  String? _formError;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final initial = widget.initialConfig ??
        const SupabaseConfig(
          url: kSupabaseDefaultUrl,
          anonKey: kSupabaseDefaultAnonKey,
        );
    _urlController = TextEditingController(text: initial.url);
    _anonKeyController = TextEditingController(text: initial.anonKey);
  }

  @override
  void dispose() {
    _urlController.dispose();
    _anonKeyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      title: const Text('Configurar Supabase'),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Introduce la URL y la anon key de tu proyecto. Si no tienes una propia, puedes conservar la configuración predeterminada.',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _urlController,
              decoration: InputDecoration(
                labelText: 'Supabase URL',
                hintText: 'https://your-project.supabase.co',
                border: const OutlineInputBorder(),
                errorText: _urlError,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _anonKeyController,
              decoration: InputDecoration(
                labelText: 'Anon key',
                hintText: 'eyJhbGciOiJI...',
                border: const OutlineInputBorder(),
                errorText: _anonKeyError,
              ),
              maxLines: 3,
              minLines: 1,
            ),
            if (_formError != null) ...[
              const SizedBox(height: 12),
              Text(
                _formError!,
                style:
                    theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.error),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _saving
              ? null
              : () {
                  Navigator.of(context).pop(false);
                },
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: _saving ? null : _submit,
          child: _saving
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Guardar'),
        ),
      ],
    );
  }

  Future<void> _submit() async {
    final url = _urlController.text.trim();
    final anonKey = _anonKeyController.text.trim();

    setState(() {
      _urlError = url.isEmpty ? 'Introduce una URL válida.' : null;
      _anonKeyError = anonKey.isEmpty ? 'Introduce una anon key válida.' : null;
      _formError = null;
    });

    if (_urlError != null || _anonKeyError != null) {
      return;
    }

    setState(() {
      _saving = true;
    });

    final controller = widget.ref.read(supabaseConfigControllerProvider.notifier);
    await controller.saveConfig(url: url, anonKey: anonKey);

    final state = widget.ref.read(supabaseConfigControllerProvider);
    if (!mounted) {
      return;
    }

    if (state.hasError) {
      setState(() {
        _saving = false;
        _formError = 'No se pudo guardar: ${state.error}';
      });
      return;
    }

    Navigator.of(context).pop(true);
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
  });

  final Book book;
  final VoidCallback onTap;
  final VoidCallback onAddReview;

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
            title: Text(book.title),
            subtitle: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: subtitleWidgets,
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Chip(
                  label: Text(statusLabel),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  labelStyle: theme.textTheme.labelSmall
                      ?.copyWith(color: theme.colorScheme.primary),
                ),
                const SizedBox(height: 4),
                Text(
                  DateFormat.yMMMd().format(book.updatedAt),
                  style: theme.textTheme.bodySmall,
                ),
              ],
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
      default:
        return status;
    }
  }
}

class _BookFormSheet extends ConsumerStatefulWidget {
  const _BookFormSheet({this.initialBook});

  final Book? initialBook;

  @override
  ConsumerState<_BookFormSheet> createState() => _BookFormSheetState();
}

class _BookFormSheetState extends ConsumerState<_BookFormSheet> {
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

  bool get _isEditing => widget.initialBook != null;

  @override
  void initState() {
    super.initState();
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
      final service = ref.read(coverImageServiceProvider);
      for (final path in _temporaryCoverPaths) {
        unawaited(service.deleteCover(path));
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
                      decoration: const InputDecoration(
                        labelText: 'Código barras',
                        border: OutlineInputBorder(),
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
                    onPressed: _submitting
                        ? null
                        : () => Navigator.of(context).maybePop(false),
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
    final messenger = ScaffoldMessenger.of(context);
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
      navigator.pop(_BookFormResult.saved);
    } catch (err) {
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(content: Text('Error al guardar el libro: $err')),
      );
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
    final messenger = ScaffoldMessenger.of(context);
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
      await repository.deleteBook(book);
      final existingCover = book.coverPath;
      if (existingCover != null) {
        await coverService.deleteCover(existingCover);
      }
      if (!context.mounted) return;
      navigator.pop(_BookFormResult.deleted);
    } catch (err) {
      if (!context.mounted) return;
      messenger.showSnackBar(
        SnackBar(content: Text('No se pudo eliminar: $err')),
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
        candidates.addAll(olResults.map((result) => _BookCandidate.fromOpenLibrary(result)));
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
        candidates.addAll(gbResults.map((result) => _BookCandidate.fromGoogleBooks(result)));
      } on GoogleBooksMissingApiKeyException {
        // Sin API key, simplemente ignoramos Google Books.
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

class _LibraryTab extends ConsumerStatefulWidget {
  const _LibraryTab({required this.onOpenForm});

  final Future<void> Function({Book? book}) onOpenForm;

  @override
  ConsumerState<_LibraryTab> createState() => _LibraryTabState();
}

class _LibraryTabState extends ConsumerState<_LibraryTab> {
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Crea un usuario antes de añadir reseñas.')),
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Reseña añadida.')),
      );
    } catch (err) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al guardar reseña: $err')),
      );
    }
  }

  Future<void> _handleExport() async {
    if (!mounted) return;
    final messenger = ScaffoldMessenger.of(context);

    try {
      final repository = ref.read(bookRepositoryProvider);
      final exportService = ref.read(bookExportServiceProvider);

      final books = await repository.fetchActiveBooks();
      if (books.isEmpty) {
        messenger.showSnackBar(
          const SnackBar(content: Text('No hay libros para exportar.')),
        );
        return;
      }

      final reviews = await repository.fetchActiveReviews();

      if (!mounted) return;
      final format = await showModalBottomSheet<BookExportFormat>(
        context: context,
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

      final result = await exportService.export(
        books: books,
        reviews: reviews,
        format: format,
      );

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
    } catch (err) {
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(content: Text('No se pudo exportar: $err')),
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

class _CommunityTab extends ConsumerWidget {
  const _CommunityTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groupsAsync = ref.watch(groupListProvider);

    return SafeArea(
      child: groupsAsync.when(
        data: (groups) {
          if (groups.isEmpty) {
            return _EmptyCommunityState(onSync: () => _syncNow(context, ref));
          }

          return RefreshIndicator(
            onRefresh: () async => _syncNow(context, ref),
            child: ListView.separated(
              padding: const EdgeInsets.all(24),
              itemCount: groups.length,
              separatorBuilder: (_, __) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final group = groups[index];
                return _GroupCard(group: group, onSync: () => _syncNow(context, ref));
              },
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => _ErrorCommunityState(
          message: '$error',
          onRetry: () => _syncNow(context, ref),
        ),
      ),
    );
  }

  Future<void> _syncNow(BuildContext context, WidgetRef ref) async {
    final controller = ref.read(groupSyncControllerProvider.notifier);
    await controller.syncGroups();
    if (!context.mounted) return;

    final state = ref.read(groupSyncControllerProvider);
    if (state.lastError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error de sincronización: ${state.lastError}')),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Sincronización completada.')),
    );
  }
}

class _EmptyCommunityState extends StatelessWidget {
  const _EmptyCommunityState({required this.onSync});

  final Future<void> Function() onSync;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.groups_outlined, size: 88, color: theme.colorScheme.primary),
            const SizedBox(height: 16),
            Text(
              'Todavía no tienes grupos sincronizados.',
              style: theme.textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Sincroniza con Supabase para traer tus comunidades, miembros y libros compartidos.',
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: onSync,
              icon: const Icon(Icons.sync_outlined),
              label: const Text('Sincronizar ahora'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorCommunityState extends StatelessWidget {
  const _ErrorCommunityState({required this.message, required this.onRetry});

  final String message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 64, color: theme.colorScheme.error),
            const SizedBox(height: 12),
            Text(
              'No pudimos cargar tus grupos.',
              style: theme.textTheme.titleLarge?.copyWith(color: theme.colorScheme.error),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar sincronización'),
            ),
          ],
        ),
      ),
    );
  }
}

class _GroupCard extends ConsumerWidget {
  const _GroupCard({required this.group, required this.onSync});

  final Group group;
  final Future<void> Function() onSync;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final membersAsync = ref.watch(groupMemberDetailsProvider(group.id));
    final sharedBooksAsync = ref.watch(sharedBookDetailsProvider(group.id));
    final loansAsync = ref.watch(groupLoanDetailsProvider(group.id));

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(group.name, style: theme.textTheme.titleMedium),
                      if (group.ownerRemoteId != null) ...[
                        const SizedBox(height: 4),
                        Text('Propietario remoto: ${group.ownerRemoteId}',
                            style: theme.textTheme.bodySmall),
                      ],
                      const SizedBox(height: 4),
                      Text('Última actualización: ${DateFormat.yMd().add_Hm().format(group.updatedAt)}',
                          style: theme.textTheme.bodySmall),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => onSync(),
                  icon: const Icon(Icons.sync_outlined),
                  tooltip: 'Sincronizar grupo',
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 16,
              runSpacing: 8,
              children: [
                _AsyncCountChip(
                  icon: Icons.people_outline,
                  label: 'Miembros',
                  value: membersAsync,
                ),
                _AsyncCountChip(
                  icon: Icons.menu_book_outlined,
                  label: 'Libros compartidos',
                  value: sharedBooksAsync,
                ),
                _AsyncCountChip(
                  icon: Icons.swap_horiz_outlined,
                  label: 'Préstamos',
                  value: loansAsync,
                ),
              ],
            ),
            const SizedBox(height: 16),
            _SharedBooksSection(sharedBooksAsync: sharedBooksAsync),
            const SizedBox(height: 12),
            _LoansSection(loansAsync: loansAsync),
          ],
        ),
      ),
    );
  }
}

class _AsyncCountChip<T> extends StatelessWidget {
  const _AsyncCountChip({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final AsyncValue<List<T>> value;

  @override
  Widget build(BuildContext context) {
    return value.when(
      data: (items) => Chip(
        avatar: Icon(icon, size: 18),
        label: Text('$label: ${items.length}'),
      ),
      loading: () => const Chip(
        avatar: SizedBox(
          width: 16,
          height: 16,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
        label: Text('Cargando...'),
      ),
      error: (error, _) => Chip(
        avatar: const Icon(Icons.error_outline, size: 18),
        label: Text('Error $label'),
      ),
    );
  }
}

class _SharedBooksSection extends StatelessWidget {
  const _SharedBooksSection({required this.sharedBooksAsync});

  final AsyncValue<List<SharedBookDetail>> sharedBooksAsync;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return sharedBooksAsync.when(
      data: (books) {
        if (books.isEmpty) {
          return Text('No hay libros compartidos todavía.',
              style: theme.textTheme.bodyMedium);
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Libros compartidos', style: theme.textTheme.titleSmall),
            const SizedBox(height: 8),
            ...books.map((detail) {
              final bookTitle = detail.book?.title ?? 'Libro sin título';
              final visibility = detail.sharedBook.visibility;
              final availability = detail.sharedBook.isAvailable ? 'Disponible' : 'No disponible';
              return ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.menu_book_outlined),
                title: Text(bookTitle),
                subtitle: Text('Visibilidad: $visibility · $availability'),
              );
            }),
          ],
        );
      },
      loading: () => const Padding(
        padding: EdgeInsets.symmetric(vertical: 8),
        child: LinearProgressIndicator(),
      ),
      error: (error, _) => Text('Error cargando libros compartidos: $error',
          style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.error)),
    );
  }
}

class _LoansSection extends StatelessWidget {
  const _LoansSection({required this.loansAsync});

  final AsyncValue<List<LoanDetail>> loansAsync;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return loansAsync.when(
      data: (loans) {
        if (loans.isEmpty) {
          return Text('Sin préstamos registrados por ahora.',
              style: theme.textTheme.bodyMedium);
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Préstamos', style: theme.textTheme.titleSmall),
            const SizedBox(height: 8),
            ...loans.map((detail) {
              final loan = detail.loan;
              final bookTitle = detail.book?.title ?? 'Libro';
              final status = loan.status;
              final start = DateFormat.yMd().format(loan.startDate);
              final due = loan.dueDate != null
                  ? DateFormat.yMd().format(loan.dueDate!)
                  : 'Sin fecha límite';
              return ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.swap_horiz_outlined),
                title: Text('$bookTitle · $status'),
                subtitle: Text('Inicio: $start · Vence: $due'),
              );
            }),
          ],
        );
      },
      loading: () => const Padding(
        padding: EdgeInsets.symmetric(vertical: 8),
        child: LinearProgressIndicator(),
      ),
      error: (error, _) => Text('Error cargando préstamos: $error',
          style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.error)),
    );
  }
}

class _LoansTab extends StatelessWidget {
  const _LoansTab();

  @override
  Widget build(BuildContext context) {
    return const _PlaceholderTab(
      title: 'Préstamos',
      description:
          'Gestiona solicitudes, estados y recordatorios de préstamos de libros.',
    );
  }
}

class _StatsTab extends StatelessWidget {
  const _StatsTab();

  @override
  Widget build(BuildContext context) {
    return const _PlaceholderTab(
      title: 'Estadísticas',
      description:
          'Mostraremos métricas como libros más prestados y actividad reciente.',
    );
  }
}

class _SettingsTab extends ConsumerWidget {
  const _SettingsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Ajustes de seguridad',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 12),
              Text(
                'Gestiona tu PIN y controla el bloqueo automático por inactividad.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 24),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.password_outlined),
                  title: const Text('Cambiar PIN'),
                  subtitle: const Text('Vuelve a definir el código de acceso.'),
                  onTap: () {
                    Navigator.of(context).pushNamed(PinSetupScreen.routeName);
                  },
                ),
              ),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.cancel_outlined),
                  title: const Text('Eliminar PIN y bloquear'),
                  subtitle: const Text('Requiere configuración nuevamente.'),
                  onTap: () async {
                    final confirmed = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('¿Eliminar PIN?'),
                        content: const Text(
                          'La sesión se bloqueará y deberás configurar un nuevo PIN.',
                        ),
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

                    await ref.read(authControllerProvider.notifier).clearPin();
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('PIN eliminado.')),
                    );
                    Navigator.of(context).pushNamedAndRemoveUntil(
                      PinSetupScreen.routeName,
                      (route) => false,
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),
              _buildSyncStatusBanner(context, ref),
              const SizedBox(height: 16),
              Text(
                'Integraciones externas',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 12),
              _SupabaseConfigCard(
                onConfigure: () => _handleConfigureSupabase(context, ref),
                onReset: () => _handleResetSupabase(context, ref),
              ),
              const SizedBox(height: 16),
              _buildSyncActionsCard(context, ref),
              const SizedBox(height: 16),
              _GoogleBooksApiCard(onConfigure: () =>
                  _handleConfigureGoogleBooksKey(context, ref), onClear: () =>
                  _handleClearGoogleBooksKey(context, ref)),
              const SizedBox(height: 24),
              const _PlaceholderTab(
                title: 'Más configuraciones próximamente',
                description:
                    'Pronto podrás gestionar copias de seguridad, sincronización y preferencias.',
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSyncStatusBanner(BuildContext context, WidgetRef ref) {
    final state = ref.watch(groupSyncControllerProvider);
    final theme = Theme.of(context);

    final statusText = state.isSyncing
        ? 'Sincronizando grupos con Supabase...'
        : state.lastError != null
            ? 'Último error de sincronización: ${state.lastError}'
            : state.lastSyncedAt != null
                ? 'Última sincronización: ${DateFormat.yMd().add_Hm().format(state.lastSyncedAt!)}'
                : 'Aún no se ha sincronizado con Supabase.';

    final color = state.isSyncing
        ? theme.colorScheme.primaryContainer
        : state.lastError != null
            ? theme.colorScheme.errorContainer
            : theme.colorScheme.surfaceVariant;

    final icon = state.isSyncing
        ? const Icon(Icons.sync, color: Colors.white)
        : state.lastError != null
            ? const Icon(Icons.error_outline, color: Colors.white)
            : const Icon(Icons.cloud_done_outlined, color: Colors.white);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          icon,
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Estado de sincronización',
                  style: theme.textTheme.titleMedium?.copyWith(color: Colors.white),
                ),
                const SizedBox(height: 4),
                Text(
                  statusText,
                  style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white),
                ),
                if (state.hasPendingChanges && !state.isSyncing) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Hay cambios pendientes por sincronizar.',
                    style: theme.textTheme.bodySmall?.copyWith(color: Colors.white70),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSyncActionsCard(BuildContext context, WidgetRef ref) {
    final state = ref.watch(groupSyncControllerProvider);
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.groups_outlined, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'Sincronización de grupos',
                  style: theme.textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Trae de Supabase la información más reciente de tus grupos, miembros y libros compartidos. '
              'Este paso es necesario antes de habilitar la colaboración en la app.',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 8,
              children: [
                FilledButton.icon(
                  onPressed: state.isSyncing ? null : () => _handleSyncGroups(context, ref),
                  icon: state.isSyncing
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.sync_outlined),
                  label: Text(state.isSyncing ? 'Sincronizando...' : 'Sincronizar ahora'),
                ),
                if (state.lastError != null)
                  OutlinedButton.icon(
                    onPressed: state.isSyncing
                        ? null
                        : () =>
                            ref.read(groupSyncControllerProvider.notifier).clearError(),
                    icon: const Icon(Icons.clear_all_outlined),
                    label: const Text('Limpiar error'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleSyncGroups(BuildContext context, WidgetRef ref) async {
    final controller = ref.read(groupSyncControllerProvider.notifier);
    await controller.syncGroups();
    if (!context.mounted) return;

    final state = ref.read(groupSyncControllerProvider);
    if (state.lastError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error de sincronización: ${state.lastError}')),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Sincronización completada.')),
    );
  }

  Future<void> _handleConfigureSupabase(
      BuildContext context, WidgetRef ref) async {
    final currentConfig = ref.read(supabaseConfigControllerProvider).valueOrNull;
    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => _SupabaseConfigDialog(
        ref: ref,
        initialConfig: currentConfig,
      ),
    );

    if (result == true && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Configuración de Supabase guardada.')),
      );
    }
  }

  Future<void> _handleResetSupabase(
      BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Restablecer Supabase'),
        content: const Text(
          'Se restaurarán la URL y la anon key predeterminadas. ¿Deseas continuar?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Restablecer'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final controller = ref.read(supabaseConfigControllerProvider.notifier);
    await controller.resetToDefaults();

    if (!context.mounted) return;

    final state = ref.read(supabaseConfigControllerProvider);
    if (state.hasError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo restablecer: ${state.error}')),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Configuración de Supabase restablecida.')),
    );
  }

  Future<void> _handleConfigureGoogleBooksKey(
      BuildContext context, WidgetRef ref) async {
    final currentValue = ref.read(googleBooksApiKeyControllerProvider).valueOrNull;
    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => _GoogleBooksApiDialog(
        initialValue: currentValue,
        ref: ref,
      ),
    );

    if (result == true && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('API key de Google Books guardada.')),
      );
    }
  }

  Future<void> _handleClearGoogleBooksKey(
      BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Eliminar API key'),
        content: const Text(
          '¿Seguro que deseas eliminar la API key de Google Books? Las búsquedas que dependan de ella dejarán de funcionar hasta que añadas una nueva.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final controller =
        ref.read(googleBooksApiKeyControllerProvider.notifier);
    await controller.clearApiKey();

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('API key eliminada.')),
      );
    }
  }
}

class _GoogleBooksApiCard extends ConsumerWidget {
  const _GoogleBooksApiCard({
    required this.onConfigure,
    required this.onClear,
  });

  final Future<void> Function() onConfigure;
  final Future<void> Function() onClear;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final apiKeyState = ref.watch(googleBooksApiKeyControllerProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: apiKeyState.when(
          data: (key) {
            final hasKey = key != null && key.isNotEmpty;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.menu_book_outlined,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Google Books API',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  hasKey
                      ? 'Lista para realizar búsquedas en Google Books.'
                      : 'Agrega tu API key para habilitar búsquedas en Google Books.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 12),
                if (hasKey) ...[
                  Text(
                    'Clave almacenada: ${_maskApiKey(key)}',
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 12,
                    runSpacing: 8,
                    children: [
                      FilledButton.icon(
                        onPressed: onConfigure,
                        icon: const Icon(Icons.edit_outlined),
                        label: const Text('Actualizar clave'),
                      ),
                      OutlinedButton.icon(
                        onPressed: onClear,
                        icon: const Icon(Icons.delete_outline),
                        label: const Text('Eliminar'),
                      ),
                    ],
                  ),
                ] else ...[
                  FilledButton.icon(
                    onPressed: onConfigure,
                    icon: const Icon(Icons.add_circle_outline),
                    label: const Text('Agregar API key de Google Books'),
                  ),
                ],
              ],
            );
          },
          loading: () => const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: CircularProgressIndicator(),
            ),
          ),
          error: (error, _) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.error_outline,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'No se pudo cargar la API key.',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                '$error',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () =>
                    ref.invalidate(googleBooksApiKeyControllerProvider),
                icon: const Icon(Icons.refresh),
                label: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _maskApiKey(String key) {
    if (key.length <= 6) {
      return '*' * key.length;
    }
    final prefix = key.substring(0, 4);
    final suffix = key.substring(key.length - 2);
    return '$prefix***$suffix';
  }
}

class _GoogleBooksApiDialog extends StatefulWidget {
  const _GoogleBooksApiDialog({
    this.initialValue,
    required this.ref,
  });

  final String? initialValue;
  final WidgetRef ref;

  @override
  State<_GoogleBooksApiDialog> createState() => _GoogleBooksApiDialogState();
}

class _GoogleBooksApiDialogState extends State<_GoogleBooksApiDialog> {
  late final TextEditingController _controller;
  String? _errorText;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue ?? '');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Configurar API key de Google Books'),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Sigue estos pasos para generar tu API key:',
            ),
            const SizedBox(height: 8),
            const _InstructionList(),
            const SizedBox(height: 16),
            TextField(
              controller: _controller,
              autofocus: true,
              decoration: InputDecoration(
                labelText: 'API key',
                hintText: 'AIza...'
                    ' (pega aquí tu clave)',
                border: const OutlineInputBorder(),
                errorText: _errorText,
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _saving
              ? null
              : () {
                  Navigator.of(context).pop(false);
                },
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: _saving ? null : _submit,
          child: _saving
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Guardar'),
        ),
      ],
    );
  }

  Future<void> _submit() async {
    final value = _controller.text.trim();
    if (value.isEmpty) {
      setState(() {
        _errorText = 'Introduce una API key válida.';
      });
      return;
    }

    setState(() {
      _saving = true;
      _errorText = null;
    });

    try {
      await widget.ref
          .read(googleBooksApiKeyControllerProvider.notifier)
          .saveApiKey(value);
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (err) {
      setState(() {
        _saving = false;
        _errorText = 'No se pudo guardar: $err';
      });
    }
  }
}

class _InstructionList extends StatelessWidget {
  const _InstructionList();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _InstructionItem(
          index: 1,
          text: 'Accede a https://console.cloud.google.com e inicia sesión.',
        ),
        _InstructionItem(
          index: 2,
          text:
              'Crea un proyecto nuevo o usa uno existente para la aplicación.',
        ),
        _InstructionItem(
          index: 3,
          text: 'Habilita la "Books API" desde Biblioteca de APIs.',
        ),
        _InstructionItem(
          index: 4,
          text: 'Genera unas credenciales tipo "API key" para el proyecto.',
        ),
        _InstructionItem(
          index: 5,
          text:
              'Copia la clave generada y pégala en el campo inferior para guardarla.',
        ),
      ],
    );
  }
}

class _InstructionItem extends StatelessWidget {
  const _InstructionItem({required this.index, required this.text});

  final int index;
  final String text;

  @override
  Widget build(BuildContext context) {
    final textStyle = Theme.of(context).textTheme.bodyMedium;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$index.', style: textStyle),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: textStyle)),
        ],
      ),
    );
  }
}

class _PlaceholderTab extends StatelessWidget {
  const _PlaceholderTab({
    required this.title,
    required this.description,
  });

  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                Icons.library_books,
                size: 80,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 24),
              Text(
                title,
                style: Theme.of(context).textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                description,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
