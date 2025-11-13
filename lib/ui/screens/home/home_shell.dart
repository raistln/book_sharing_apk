import 'dart:async';

import 'package:drift/drift.dart' show Value;
import 'package:file_saver/file_saver.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../config/supabase_defaults.dart';
import '../../../data/local/database.dart';
import '../../../data/local/group_dao.dart';
import '../../../providers/api_providers.dart';
import '../../../providers/auth_providers.dart';
import '../../../providers/book_providers.dart';
import '../../../providers/permission_providers.dart';
import '../../../providers/stats_providers.dart';
import '../../../providers/settings_providers.dart';
import '../../../providers/theme_providers.dart';
import '../../../providers/notification_providers.dart';
import '../../../services/book_export_service.dart';
import '../../../services/cover_image_service_base.dart';
import '../../../services/google_books_client.dart';
import '../../../services/loan_controller.dart';
import '../../../services/open_library_client.dart';
import '../../../services/notification_service.dart';
import '../../../services/stats_service.dart';
import '../../widgets/cover_preview.dart';
import '../../widgets/import_books_dialog.dart';
import '../auth/pin_setup_screen.dart';

final _currentTabProvider = StateProvider<int>((ref) => 0);

enum _BookFormResult { saved, deleted }

enum _ExportAction { share, download }

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

class _ThemeSection extends ConsumerWidget {
  const _ThemeSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final preferenceAsync = ref.watch(themeSettingsProvider);
    final notifier = ref.read(themeSettingsProvider.notifier);

    return preferenceAsync.when(
      loading: () => const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Center(child: CircularProgressIndicator()),
        ),
      ),
      error: (error, __) => Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'No pudimos cargar la preferencia de tema.',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(color: Theme.of(context).colorScheme.error),
              ),
              const SizedBox(height: 8),
              Text('$error'),
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: () => ref.invalidate(themeSettingsProvider),
                icon: const Icon(Icons.refresh),
                label: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      ),
      data: (preference) {
        final segments = ThemePreference.values.map((value) {
          return ButtonSegment<ThemePreference>(
            value: value,
            label: Text(
              switch (value) {
                ThemePreference.system => 'Usar tema del sistema',
                ThemePreference.light => 'Modo claro',
                ThemePreference.dark => 'Modo oscuro',
              },
            ),
            icon: Icon(
              switch (value) {
                ThemePreference.system => Icons.phone_android,
                ThemePreference.light => Icons.wb_sunny_outlined,
                ThemePreference.dark => Icons.dark_mode_outlined,
              },
            ),
          );
        }).toList(growable: false);

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SegmentedButton<ThemePreference>(
                  segments: segments,
                  selected: {preference},
                  onSelectionChanged: (selection) {
                    if (selection.isEmpty) {
                      return;
                    }
                    final selected = selection.first;
                    if (selected != preference) {
                      notifier.update(selected);
                    }
                  },
                ),
                const SizedBox(height: 12),
                Text(
                  'Elige cómo se ve la app. Puedes seguir el sistema o forzar un tema.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

GroupMemberDetail? _findMemberDetail(List<GroupMemberDetail> members, int userId) {
  for (final detail in members) {
    final user = detail.user;
    if (user != null && user.id == userId) {
      return detail;
    }
  }
  return null;
}

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

enum _BookSource { openLibrary, googleBooks }

class _ReviewDraft {
  const _ReviewDraft({required this.rating, this.review});

  final int rating;
  final String? review;
}

class _GroupFormResult {
  const _GroupFormResult({required this.name, this.description});

  final String name;
  final String? description;
}

class _GroupFormDialog extends StatefulWidget {
  const _GroupFormDialog({
    this.dialogTitle,
    this.confirmLabel,
    this.initialName,
    this.initialDescription,
  });

  final String? dialogTitle;
  final String? confirmLabel;
  final String? initialName;
  final String? initialDescription;

  @override
  State<_GroupFormDialog> createState() => _GroupFormDialogState();
}

class _GroupFormDialogState extends State<_GroupFormDialog> {
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName ?? '');
    _descriptionController =
        TextEditingController(text: widget.initialDescription ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isCreating = widget.initialName == null;
    final titleText = widget.dialogTitle ?? (isCreating ? 'Crear grupo' : 'Editar grupo');
    final submitLabel = widget.confirmLabel ?? (isCreating ? 'Crear' : 'Guardar');

    return AlertDialog(
      title: Text(titleText),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Nombre del grupo',
              ),
              autofocus: true,
              textInputAction: TextInputAction.next,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Introduce un nombre válido.';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Descripción (opcional)',
              ),
              maxLines: 3,
              textInputAction: TextInputAction.done,
            ),
            if (widget.initialDescription == null || widget.initialDescription!.isEmpty) ...[
              const SizedBox(height: 8),
              Text(
                'Puedes actualizar la descripción más tarde desde el menú.',
                style: theme.textTheme.bodySmall,
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: _submit,
          child: Text(submitLabel),
        ),
      ],
    );
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }
    final trimmedName = _nameController.text.trim();
    final trimmedDescription = _descriptionController.text.trim();
    Navigator.of(context).pop(
      _GroupFormResult(
        name: trimmedName,
        description: trimmedDescription.isEmpty ? null : trimmedDescription,
      ),
    );
  }
}

class _AddMemberResult {
  const _AddMemberResult({required this.user, required this.role});

  final LocalUser user;
  final String role;
}

class _InvitationFormResult {
  const _InvitationFormResult({required this.role, required this.expiresAt});

  final String role;
  final DateTime expiresAt;
}

enum _GroupMenuAction {
  edit,
  transferOwnership,
  manageMembers,
  manageInvitations,
  delete,
}

enum _MemberAction {
  promoteToAdmin,
  demoteToMember,
  remove,
}

const _kRoleAdmin = 'admin';
const _kRoleMember = 'member';
const _kInvitationStatusPending = 'pending';

class HomeShell extends ConsumerWidget {
  const HomeShell({super.key});

  static const routeName = '/home';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen<NotificationIntent?>(notificationIntentProvider, (previous, next) {
      if (next == null) {
        return;
      }
      _handleNotificationIntent(context, ref, next);
    });

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
            label: 'Estadísticas',
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

  void _handleNotificationIntent(
    BuildContext context,
    WidgetRef ref,
    NotificationIntent intent,
  ) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final tabNotifier = ref.read(_currentTabProvider.notifier);

      switch (intent.type) {
        case NotificationType.loanDueSoon:
        case NotificationType.loanExpired:
          tabNotifier.state = 2;
          break;
        case NotificationType.groupInvitation:
          tabNotifier.state = 1;
          break;
      }

      ref.read(notificationIntentProvider.notifier).clear();
    });
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

class _SupabaseConfigCard extends StatelessWidget {
  const _SupabaseConfigCard();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
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
                  'Supabase oficial',
                  style: theme.textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Esta versión utiliza el espacio de Supabase mantenido por el proyecto. '
              'Las credenciales están integradas y no se pueden editar desde la app.',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 12),
            Text(
              'URL: $kSupabaseDefaultUrl',
              style: theme.textTheme.bodySmall,
            ),
            const SizedBox(height: 4),
            Text(
              'Anon key: ******',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Si deseas alojar tu propio backend, revisa la guía "docs/self_host_supabase.md" en el repositorio.',
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
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
    final permissionService = ref.read(permissionServiceProvider);
    final granted = await permissionService.ensureCameraPermission();
    if (!granted) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Necesitas habilitar la cámara para seleccionar una portada.'),
        ),
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
    final contextRef = context;

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

      if (!contextRef.mounted) return;
      final format = await showModalBottomSheet<BookExportFormat>(
        context: contextRef,
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

      if (!contextRef.mounted) return;
      final action = await showModalBottomSheet<_ExportAction>(
        context: contextRef,
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

        if (!mounted) return;
        messenger.showSnackBar(
          SnackBar(content: Text('Archivo guardado como ${result.fileName}.')),
        );
      }
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

class _LoanFeedbackBanner extends StatelessWidget {
  const _LoanFeedbackBanner({
    required this.message,
    required this.isError,
    required this.onDismiss,
  });

  final String message;
  final bool isError;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final background =
        isError ? colorScheme.errorContainer : colorScheme.primaryContainer;
    final textColor =
        isError ? colorScheme.onErrorContainer : colorScheme.onPrimaryContainer;
    final icon = isError ? Icons.error_outline : Icons.check_circle_outline;

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 8),
      child: Container(
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: textColor),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: theme.textTheme.bodyMedium?.copyWith(color: textColor),
              ),
            ),
            IconButton(
              icon: Icon(Icons.close, color: textColor),
              onPressed: onDismiss,
              tooltip: 'Cerrar',
            ),
          ],
        ),
      ),
    );
  }
}

Future<void> _onGroupMenuAction({
  required BuildContext context,
  required WidgetRef ref,
  required _GroupMenuAction action,
  required Group group,
}) async {
  switch (action) {
    case _GroupMenuAction.edit:
      await _handleEditGroup(context, ref, group);
      break;
    case _GroupMenuAction.transferOwnership:
      await _handleTransferOwnership(context, ref, group);
      break;
    case _GroupMenuAction.manageMembers:
      await _showManageMembersSheet(context, ref, group: group);
      break;
    case _GroupMenuAction.manageInvitations:
      await _showInvitationsSheet(context, ref, group: group);
      break;
    case _GroupMenuAction.delete:
      await _handleDeleteGroup(context, ref, group);
      break;
  }
}

Future<void> _handleEditGroup(BuildContext context, WidgetRef ref, Group group) async {
  final result = await _showGroupFormDialog(
    context,
    dialogTitle: 'Editar grupo',
    confirmLabel: 'Guardar',
    initialName: group.name,
    initialDescription: group.description,
  );

  if (result == null) {
    return;
  }

  final controller = ref.read(groupPushControllerProvider.notifier);
  try {
    await controller.updateGroup(
      group: group,
      name: result.name,
      description: result.description,
    );
  } catch (error) {
    if (!context.mounted) return;
    _showFeedbackSnackBar(
      context: context,
      message: error.toString(),
      isError: true,
    );
  }
}

Future<void> _handleTransferOwnership(
  BuildContext context,
  WidgetRef ref,
  Group group,
) async {
  final members = await ref.read(groupMemberDetailsProvider(group.id).future);
  if (!context.mounted) {
    return;
  }
  final candidates = members
      .where((detail) =>
          detail.user != null && detail.user!.id != group.ownerUserId)
      .toList();

  if (candidates.isEmpty) {
    if (!context.mounted) return;
    _showFeedbackSnackBar(
      context: context,
      message: 'No hay otros miembros disponibles para transferir la propiedad.',
      isError: true,
    );
    return;
  }

  final selected = await showDialog<GroupMemberDetail>(
    context: context,
    builder: (dialogContext) {
      return SimpleDialog(
        title: const Text('Transferir propiedad'),
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 4),
            child: Text('Selecciona a la persona que será la nueva propietaria.'),
          ),
          for (final detail in candidates)
            SimpleDialogOption(
              onPressed: () => Navigator.of(dialogContext).pop(detail),
              child: Text(detail.user?.username ?? 'Miembro'),
            ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancelar'),
          ),
        ],
      );
    },
  );

  if (!context.mounted) {
    return;
  }

  if (selected == null) {
    return;
  }

  final newOwner = selected.user;
  if (newOwner == null) {
    return;
  }

  final controller = ref.read(groupPushControllerProvider.notifier);
  try {
    await controller.transferOwnership(group: group, newOwner: newOwner);
  } catch (error) {
    if (!context.mounted) return;
    _showFeedbackSnackBar(
      context: context,
      message: error.toString(),
      isError: true,
    );
  }
}

Future<void> _handleDeleteGroup(
  BuildContext context,
  WidgetRef ref,
  Group group,
) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) {
      return AlertDialog(
        title: const Text('Eliminar grupo'),
        content: Text(
          '¿Seguro que deseas eliminar "${group.name}"? Esta acción solo afecta a la copia local y marcará el grupo para eliminación remota.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(dialogContext).colorScheme.error,
            ),
            child: const Text('Eliminar'),
          ),
        ],
      );
    },
  );

  if (confirmed != true) {
    return;
  }

  final controller = ref.read(groupPushControllerProvider.notifier);
  try {
    await controller.deleteGroup(group: group);
  } catch (error) {
    if (!context.mounted) return;
    _showFeedbackSnackBar(
      context: context,
      message: error.toString(),
      isError: true,
    );
  }
}

Future<void> _showManageMembersSheet(
  BuildContext context,
  WidgetRef ref, {
  required Group group,
}) async {
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (sheetContext) {
      final bottomInset = MediaQuery.of(sheetContext).viewInsets.bottom;
      return Padding(
        padding: EdgeInsets.only(bottom: bottomInset),
        child: Consumer(
          builder: (context, sheetRef, _) {
            final membersAsync = sheetRef.watch(groupMemberDetailsProvider(group.id));
            final actionState = sheetRef.watch(groupPushControllerProvider);
            final activeUser = sheetRef.watch(activeUserProvider).value;
            final isBusy = actionState.isLoading;

            return SafeArea(
              child: FractionallySizedBox(
                heightFactor: 0.85,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
                      child: Row(
                        children: [
                          const Expanded(
                            child: Text(
                              'Gestionar miembros',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                            ),
                          ),
                          IconButton(
                            onPressed: () => Navigator.of(sheetContext).pop(),
                            icon: const Icon(Icons.close),
                            tooltip: 'Cerrar',
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Text(
                        'Promueve, degrada o elimina miembros del grupo. Añade nuevos miembros sincronizados localmente.',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Row(
                        children: [
                          FilledButton.icon(
                            onPressed: isBusy
                                ? null
                                : () => _handleAddMember(sheetContext, sheetRef, group),
                            icon: const Icon(Icons.person_add_alt_1_outlined),
                            label: const Text('Añadir miembro'),
                          ),
                          const SizedBox(width: 12),
                          if (isBusy)
                            const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: membersAsync.when(
                        data: (members) {
                          if (members.isEmpty) {
                            return const Center(
                              child: Text('No hay miembros registrados.'),
                            );
                          }

                          return ListView.separated(
                            padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                            itemCount: members.length,
                            separatorBuilder: (_, __) => const Divider(),
                            itemBuilder: (context, index) {
                              final detail = members[index];
                              final user = detail.user;
                              final membership = detail.membership;
                              final isOwner = group.ownerUserId != null &&
                                  membership.memberUserId == group.ownerUserId;
                              final isAdmin = membership.role == _kRoleAdmin;
                              final displayName = user?.username ?? 'Usuario';
                              final roleLabel = isOwner
                                  ? 'Propietario'
                                  : isAdmin
                                      ? 'Admin'
                                      : 'Miembro';
                              final canEdit = !isOwner && activeUser != null;

                              return ListTile(
                                leading: CircleAvatar(
                                  child: Text(displayName.characters.first.toUpperCase()),
                                ),
                                title: Text(displayName),
                                subtitle: Text('Rol: $roleLabel'),
                                trailing: canEdit
                                    ? PopupMenuButton<_MemberAction>(
                                        onSelected: (action) => unawaited(
                                          _handleMemberAction(
                                            context: sheetContext,
                                            ref: sheetRef,
                                            detail: detail,
                                            action: action,
                                          ),
                                        ),
                                        enabled: !isBusy,
                                        itemBuilder: (context) {
                                          final entries = <PopupMenuEntry<_MemberAction>>[];
                                          if (!isAdmin) {
                                            entries.add(
                                              const PopupMenuItem<_MemberAction>(
                                                value: _MemberAction.promoteToAdmin,
                                                child: Text('Promover a admin'),
                                              ),
                                            );
                                          } else {
                                            entries.add(
                                              const PopupMenuItem<_MemberAction>(
                                                value: _MemberAction.demoteToMember,
                                                child: Text('Degradar a miembro'),
                                              ),
                                            );
                                          }
                                          entries.add(
                                            const PopupMenuItem<_MemberAction>(
                                              value: _MemberAction.remove,
                                              child: Text('Eliminar del grupo'),
                                            ),
                                          );
                                          return entries;
                                        },
                                        icon: const Icon(Icons.more_vert),
                                      )
                                    : null,
                              );
                            },
                          );
                        },
                        loading: () => const Center(child: CircularProgressIndicator()),
                        error: (error, _) => Center(
                          child: Text('Error al cargar miembros: $error'),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      );
    },
  );
}

Future<void> _handleAddMember(BuildContext context, WidgetRef ref, Group group) async {
  final members = await ref.read(groupMemberDetailsProvider(group.id).future);
  if (!context.mounted) {
    return;
  }
  final existingIds = members
      .map((detail) => detail.user?.id)
      .whereType<int>()
      .toSet();

  final users = await ref.read(userRepositoryProvider).getActiveUsers();
  if (!context.mounted) {
    return;
  }
  final candidates = users.where((user) => !existingIds.contains(user.id)).toList();

  if (candidates.isEmpty) {
    if (!context.mounted) return;
    _showFeedbackSnackBar(
      context: context,
      message: 'No hay usuarios locales disponibles para añadir.',
      isError: true,
    );
    return;
  }

  final result = await _showAddMemberDialog(context, candidates);
  if (!context.mounted) {
    return;
  }
  if (result == null) {
    return;
  }

  final controller = ref.read(groupPushControllerProvider.notifier);
  try {
    await controller.addMember(
      group: group,
      user: result.user,
      role: result.role,
    );
  } catch (error) {
    if (!context.mounted) return;
    _showFeedbackSnackBar(
      context: context,
      message: error.toString(),
      isError: true,
    );
  }
}

Future<_AddMemberResult?> _showAddMemberDialog(
  BuildContext context,
  List<LocalUser> candidates,
) async {
  final formKey = GlobalKey<FormState>();
  LocalUser? selectedUser = candidates.isNotEmpty ? candidates.first : null;
  String selectedRole = _kRoleMember;

  return showDialog<_AddMemberResult>(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) {
      return AlertDialog(
        title: const Text('Añadir miembro'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DropdownButtonFormField<LocalUser>(
                initialValue: selectedUser,
                items: candidates
                    .map(
                      (user) => DropdownMenuItem<LocalUser>(
                        value: user,
                        child: Text(user.username),
                      ),
                    )
                    .toList(),
                onChanged: (value) => selectedUser = value,
                decoration: const InputDecoration(
                  labelText: 'Usuario',
                ),
                validator: (value) => value == null ? 'Selecciona un usuario.' : null,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: selectedRole,
                items: const [
                  DropdownMenuItem(
                    value: _kRoleMember,
                    child: Text('Miembro'),
                  ),
                  DropdownMenuItem(
                    value: _kRoleAdmin,
                    child: Text('Admin'),
                  ),
                ],
                onChanged: (value) {
                  if (value != null) {
                    selectedRole = value;
                  }
                },
                decoration: const InputDecoration(labelText: 'Rol'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              if (!(formKey.currentState?.validate() ?? false)) {
                return;
              }
              Navigator.of(dialogContext).pop(
                _AddMemberResult(user: selectedUser!, role: selectedRole),
              );
            },
            child: const Text('Añadir'),
          ),
        ],
      );
    },
  );
}

Future<void> _handleMemberAction({
  required BuildContext context,
  required WidgetRef ref,
  required GroupMemberDetail detail,
  required _MemberAction action,
}) async {
  final controller = ref.read(groupPushControllerProvider.notifier);

  try {
    switch (action) {
      case _MemberAction.promoteToAdmin:
        await controller.updateMemberRole(
          member: detail.membership,
          role: _kRoleAdmin,
        );
        break;
      case _MemberAction.demoteToMember:
        await controller.updateMemberRole(
          member: detail.membership,
          role: _kRoleMember,
        );
        break;
      case _MemberAction.remove:
        await controller.removeMember(member: detail.membership);
        break;
    }
  } catch (error) {
    if (!context.mounted) return;
    _showFeedbackSnackBar(
      context: context,
      message: error.toString(),
      isError: true,
    );
  }
}

Future<void> _showInvitationsSheet(
  BuildContext context,
  WidgetRef ref, {
  required Group group,
}) async {
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (sheetContext) {
      final bottomInset = MediaQuery.of(sheetContext).viewInsets.bottom;
      return Padding(
        padding: EdgeInsets.only(bottom: bottomInset),
        child: Consumer(
          builder: (context, sheetRef, _) {
            final invitationsAsync = sheetRef.watch(groupInvitationDetailsProvider(group.id));
            final activeUser = sheetRef.watch(activeUserProvider).value;
            final actionState = sheetRef.watch(groupPushControllerProvider);
            final isBusy = actionState.isLoading;

            return SafeArea(
              child: FractionallySizedBox(
                heightFactor: 0.85,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
                      child: Row(
                        children: [
                          const Expanded(
                            child: Text(
                              'Invitaciones del grupo',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                            ),
                          ),
                          IconButton(
                            onPressed: () => Navigator.of(sheetContext).pop(),
                            icon: const Icon(Icons.close),
                            tooltip: 'Cerrar',
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Row(
                        children: [
                          FilledButton.icon(
                            onPressed: isBusy || activeUser == null
                                ? null
                                : () => _handleCreateInvitation(
                                      sheetContext,
                                      sheetRef,
                                      group: group,
                                      inviter: activeUser,
                                    ),
                            icon: const Icon(Icons.qr_code_2_outlined),
                            label: const Text('Nueva invitación'),
                          ),
                          const SizedBox(width: 12),
                          if (isBusy)
                            const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: invitationsAsync.when(
                        data: (invitations) {
                          if (invitations.isEmpty) {
                            return const Center(
                              child: Text('Aún no se han generado invitaciones.'),
                            );
                          }

                          return ListView.separated(
                            padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                            itemCount: invitations.length,
                            separatorBuilder: (_, __) => const Divider(),
                            itemBuilder: (context, index) {
                              final detail = invitations[index];
                              final invitation = detail.invitation;
                              final status = invitation.status;
                              final expiresAt = DateFormat.yMd().add_Hm().format(invitation.expiresAt);
                              final code = invitation.code;
                              final canCancel = status == _kInvitationStatusPending && !isBusy;

                              return ListTile(
                                leading: const Icon(Icons.qr_code_2_outlined),
                                title: Text('Código: $code'),
                                subtitle: Text('Rol: ${invitation.role} · Estado: $status · Expira: $expiresAt'),
                                contentPadding: EdgeInsets.zero,
                                isThreeLine: true,
                                trailing: SizedBox(
                                  width: 120,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          IconButton(
                                            tooltip: 'Copiar código',
                                            onPressed: () => _copyToClipboard(sheetContext, code),
                                            icon: const Icon(Icons.copy_outlined),
                                          ),
                                          IconButton(
                                            tooltip: 'Mostrar QR',
                                            onPressed: () => _showInvitationQrDialog(sheetContext, code),
                                            icon: const Icon(Icons.fullscreen),
                                          ),
                                          IconButton(
                                            tooltip: 'Compartir código',
                                            onPressed: () => _shareInvitationCode(
                                              context: sheetContext,
                                              group: group,
                                              invitation: invitation,
                                            ),
                                            icon: const Icon(Icons.share_outlined),
                                          ),
                                        ],
                                      ),
                                      if (canCancel)
                                        TextButton.icon(
                                          onPressed: () => _handleCancelInvitation(
                                            sheetContext,
                                            sheetRef,
                                            invitation: invitation,
                                          ),
                                          icon: const Icon(Icons.cancel_outlined),
                                          label: const Text('Cancelar'),
                                        ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          );
                        },
                        loading: () => const Center(child: CircularProgressIndicator()),
                        error: (error, _) => Center(
                          child: Text('Error al cargar invitaciones: $error'),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      );
    },
  );
}

Future<void> _handleCreateInvitation(
  BuildContext context,
  WidgetRef ref, {
  required Group group,
  required LocalUser inviter,
}) async {
  final result = await _showInvitationFormDialog(context);
  if (result == null) {
    return;
  }

  final controller = ref.read(groupPushControllerProvider.notifier);
  try {
    await controller.createInvitation(
      group: group,
      inviter: inviter,
      role: result.role,
      expiresAt: result.expiresAt,
    );
  } catch (error) {
    if (!context.mounted) return;
    _showFeedbackSnackBar(
      context: context,
      message: error.toString(),
      isError: true,
    );
  }
}

Future<_InvitationFormResult?> _showInvitationFormDialog(BuildContext context) async {
  final formKey = GlobalKey<FormState>();
  String role = _kRoleMember;
  final durationOptions = <Duration, String>{
    const Duration(days: 1): '1 día',
    const Duration(days: 7): '7 días',
    const Duration(days: 30): '30 días',
  };
  Duration selectedDuration = const Duration(days: 7);

  return showDialog<_InvitationFormResult>(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) {
      return AlertDialog(
        title: const Text('Crear invitación'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                initialValue: role,
                items: const [
                  DropdownMenuItem(
                    value: _kRoleMember,
                    child: Text('Miembro'),
                  ),
                  DropdownMenuItem(
                    value: _kRoleAdmin,
                    child: Text('Admin'),
                  ),
                ],
                onChanged: (value) {
                  if (value != null) {
                    role = value;
                  }
                },
                decoration: const InputDecoration(labelText: 'Rol asignado'),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<Duration>(
                initialValue: selectedDuration,
                items: durationOptions.entries
                    .map(
                      (entry) => DropdownMenuItem<Duration>(
                        value: entry.key,
                        child: Text('Expira en ${entry.value}'),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    selectedDuration = value;
                  }
                },
                decoration: const InputDecoration(labelText: 'Duración'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              if (!(formKey.currentState?.validate() ?? false)) {
                return;
              }
              Navigator.of(dialogContext).pop(
                _InvitationFormResult(
                  role: role,
                  expiresAt: DateTime.now().add(selectedDuration),
                ),
              );
            },
            child: const Text('Crear'),
          ),
        ],
      );
    },
  );
}

Future<void> _handleCancelInvitation(
  BuildContext context,
  WidgetRef ref, {
  required GroupInvitation invitation,
}) async {
  final controller = ref.read(groupPushControllerProvider.notifier);
  try {
    await controller.cancelInvitation(invitation: invitation);
  } catch (error) {
    if (!context.mounted) return;
    _showFeedbackSnackBar(
      context: context,
      message: error.toString(),
      isError: true,
    );
  }
}

Future<void> _showInvitationQrDialog(BuildContext context, String code) {
  final data = 'group-invite://$code';
  return showDialog<void>(
    context: context,
    builder: (dialogContext) {
      return AlertDialog(
        title: const Text('Código QR de invitación'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            QrImageView(
              data: data,
              size: 220,
              backgroundColor: Colors.white,
            ),
            const SizedBox(height: 12),
            Text(
              code,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'Escanea este código o comparte el código alfanumérico para unirse al grupo.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => _copyToClipboard(dialogContext, code),
            child: const Text('Copiar código'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cerrar'),
          ),
        ],
      );
    },
  );
}

void _copyToClipboard(BuildContext context, String value) {
  Clipboard.setData(ClipboardData(text: value));
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('Código copiado al portapapeles.')),
  );
}

Future<void> _shareInvitationCode({
  required BuildContext context,
  required Group group,
  required GroupInvitation invitation,
}) async {
  final subject = 'Únete al grupo "${group.name}"';
  final message =
      'Hola, te invito a unirte al grupo "${group.name}" en Book Sharing. Usa el código ${invitation.code} o escanea el QR para entrar.';

  await Share.share(
    message,
    subject: subject,
  );
}

Future<void> _performSync(BuildContext context, WidgetRef ref) async {
  final controller = ref.read(groupSyncControllerProvider.notifier);
  await controller.syncGroups();
  if (!context.mounted) return;

  final state = ref.read(groupSyncControllerProvider);
  if (state.lastError != null) {
    _showFeedbackSnackBar(
      context: context,
      message: 'Error de sincronización: ${state.lastError}',
      isError: true,
    );
    return;
  }

  _showFeedbackSnackBar(
    context: context,
    message: 'Sincronización completada.',
    isError: false,
  );
}

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

Future<_GroupFormResult?> _showGroupFormDialog(
  BuildContext context, {
  String? dialogTitle,
  String? confirmLabel,
  String? initialName,
  String? initialDescription,
}) {
  return showDialog<_GroupFormResult>(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) => _GroupFormDialog(
      dialogTitle: dialogTitle,
      confirmLabel: confirmLabel,
      initialName: initialName,
      initialDescription: initialDescription,
    ),
  );
}

Future<String?> _showJoinGroupByCodeDialog(BuildContext context) async {
  final formKey = GlobalKey<FormState>();
  final codeController = TextEditingController();

  try {
    return showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Unirse por código'),
          content: Form(
            key: formKey,
            child: TextFormField(
              controller: codeController,
              decoration: const InputDecoration(
                labelText: 'Código de invitación',
                hintText: 'Ej. 123e4567-e89b-12d3-a456-426614174000',
              ),
              autofocus: true,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Introduce un código válido.';
                }
                if (value.trim().length < 6) {
                  return 'El código es demasiado corto.';
                }
                return null;
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () {
                if (!(formKey.currentState?.validate() ?? false)) {
                  return;
                }
                Navigator.of(dialogContext).pop(codeController.text.trim());
              },
              child: const Text('Unirse'),
            ),
          ],
        );
      },
    );
  } finally {
    codeController.dispose();
  }
}

Future<void> _handleCreateGroup(
  BuildContext context,
  WidgetRef ref,
  LocalUser owner,
) async {
  final result = await _showGroupFormDialog(context);
  if (result == null) {
    return;
  }

  final controller = ref.read(groupPushControllerProvider.notifier);
  try {
    await controller.createGroup(
      name: result.name,
      description: result.description,
      owner: owner,
    );
  } catch (error) {
    if (!context.mounted) {
      return;
    }
    _showFeedbackSnackBar(
      context: context,
      message: error.toString(),
      isError: true,
    );
  }
}

Future<void> _handleJoinGroupByCode(
  BuildContext context,
  WidgetRef ref,
  LocalUser user,
) async {
  final code = await _showJoinGroupByCodeDialog(context);
  if (code == null) {
    return;
  }

  final controller = ref.read(groupPushControllerProvider.notifier);
  try {
    await controller.acceptInvitationByCode(
      code: code,
      user: user,
    );
  } catch (error) {
    if (!context.mounted) {
      return;
    }
    _showFeedbackSnackBar(
      context: context,
      message: error.toString(),
      isError: true,
    );
  }
}

String _resolveUserName(LocalUser? user) {
  return user?.username ?? 'Usuario desconocido';
}

class _CommunityTab extends ConsumerWidget {
  const _CommunityTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groupsAsync = ref.watch(groupListProvider);
    final loanActionState = ref.watch(loanControllerProvider);
    final groupActionState = ref.watch(groupPushControllerProvider);
    final activeUser = ref.watch(activeUserProvider).value;
    final isGroupBusy = groupActionState.isLoading;

    return SafeArea(
      child: Column(
        children: [
          if (groupActionState.lastError != null)
            _LoanFeedbackBanner(
              message: groupActionState.lastError!,
              isError: true,
              onDismiss: () => ref.read(groupPushControllerProvider.notifier).dismissError(),
            )
          else if (groupActionState.lastSuccess != null)
            _LoanFeedbackBanner(
              message: groupActionState.lastSuccess!,
              isError: false,
              onDismiss: () => ref.read(groupPushControllerProvider.notifier).dismissSuccess(),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 8),
            child: Wrap(
              spacing: 12,
              runSpacing: 12,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                FilledButton.icon(
                  onPressed: activeUser == null || isGroupBusy
                      ? null
                      : () => _handleCreateGroup(context, ref, activeUser),
                  icon: const Icon(Icons.group_add_outlined),
                  label: const Text('Crear grupo'),
                ),
                OutlinedButton.icon(
                  onPressed: activeUser == null || isGroupBusy
                      ? null
                      : () => _handleJoinGroupByCode(context, ref, activeUser),
                  icon: const Icon(Icons.qr_code_2_outlined),
                  label: const Text('Unirse por código'),
                ),
                if (isGroupBusy)
                  const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2.5),
                  ),
              ],
            ),
          ),
          if (loanActionState.lastError != null)
            _LoanFeedbackBanner(
              message: loanActionState.lastError!,
              isError: true,
              onDismiss: () => ref.read(loanControllerProvider.notifier).dismissError(),
            )
          else if (loanActionState.lastSuccess != null)
            _LoanFeedbackBanner(
              message: loanActionState.lastSuccess!,
              isError: false,
              onDismiss: () =>
                  ref.read(loanControllerProvider.notifier).dismissSuccess(),
            ),
          Expanded(
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
                      return _GroupCard(
                        group: group,
                        onSync: () => _syncNow(context, ref),
                      );
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
          ),
        ],
      ),
    );
  }

  Future<void> _syncNow(BuildContext context, WidgetRef ref) async {
    await _performSync(context, ref);
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
    final invitationsAsync = ref.watch(groupInvitationDetailsProvider(group.id));
    final activeUserAsync = ref.watch(activeUserProvider);
    final activeUser = activeUserAsync.value;
    final groupActionState = ref.watch(groupPushControllerProvider);
    final isGroupBusy = groupActionState.isLoading;
    final loanController = ref.watch(loanControllerProvider.notifier);
    final loanState = ref.watch(loanControllerProvider);

    final members = membersAsync.asData?.value ?? const <GroupMemberDetail>[];
    final isOwner = activeUser != null && group.ownerUserId != null && group.ownerUserId == activeUser.id;
    final currentMembership = activeUser != null
        ? _findMemberDetail(members, activeUser.id)
        : null;
    final isAdmin = isOwner || currentMembership?.membership.role == _kRoleAdmin;

    final menuEntries = <PopupMenuEntry<_GroupMenuAction>>[];
    if (activeUser != null && isAdmin) {
      menuEntries
        ..add(
          const PopupMenuItem<_GroupMenuAction>(
            value: _GroupMenuAction.edit,
            child: Text('Editar grupo'),
          ),
        )
        ..add(
          const PopupMenuItem<_GroupMenuAction>(
            value: _GroupMenuAction.manageMembers,
            child: Text('Gestionar miembros'),
          ),
        )
        ..add(
          const PopupMenuItem<_GroupMenuAction>(
            value: _GroupMenuAction.manageInvitations,
            child: Text('Gestionar invitaciones'),
          ),
        );
    }
    if (activeUser != null && isOwner) {
      if (menuEntries.isNotEmpty) {
        menuEntries.add(const PopupMenuDivider());
      }
      menuEntries
        ..add(
          const PopupMenuItem<_GroupMenuAction>(
            value: _GroupMenuAction.transferOwnership,
            child: Text('Transferir propiedad'),
          ),
        )
        ..add(
          const PopupMenuItem<_GroupMenuAction>(
            value: _GroupMenuAction.delete,
            child: Text('Eliminar grupo'),
          ),
        );
    }

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
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      onPressed: isGroupBusy ? null : () => onSync(),
                      icon: const Icon(Icons.sync_outlined),
                      tooltip: 'Sincronizar grupo',
                    ),
                    if (menuEntries.isNotEmpty)
                      PopupMenuButton<_GroupMenuAction>(
                        icon: const Icon(Icons.more_vert),
                        tooltip: 'Acciones del grupo',
                        enabled: !isGroupBusy,
                        itemBuilder: (context) => menuEntries,
                        onSelected: (action) {
                          unawaited(
                            _onGroupMenuAction(
                              context: context,
                              ref: ref,
                              action: action,
                              group: group,
                            ),
                          );
                        },
                      ),
                  ],
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
                _AsyncCountChip(
                  icon: Icons.qr_code_2_outlined,
                  label: 'Invitaciones',
                  value: invitationsAsync,
                ),
              ],
            ),
            const SizedBox(height: 16),
            _SharedBooksSection(sharedBooksAsync: sharedBooksAsync),
            const SizedBox(height: 12),
            _LoansSection(
              loansAsync: loansAsync,
              activeUser: activeUser,
              loanController: loanController,
              loanState: loanState,
              onFeedback: (message, isError) {
                _showFeedbackSnackBar(
                  context: context,
                  message: message,
                  isError: isError,
                );
              },
            ),
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
  const _LoansSection({
    required this.loansAsync,
    required this.activeUser,
    required this.loanController,
    required this.loanState,
    required this.onFeedback,
  });

  final AsyncValue<List<LoanDetail>> loansAsync;
  final LocalUser? activeUser;
  final LoanController loanController;
  final LoanActionState loanState;
  final void Function(String message, bool isError) onFeedback;

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
              final isBorrower = activeUser != null && loan.fromUserId == activeUser!.id;
              final isOwner = activeUser != null && loan.toUserId == activeUser!.id;

              return Card(
                margin: EdgeInsets.zero,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.swap_horiz_outlined),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              '$bookTitle · ${status.toUpperCase()}',
                              style: theme.textTheme.titleSmall,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text('Inicio: $start · Vence: $due',
                          style: theme.textTheme.bodySmall),
                      if (detail.borrower != null || detail.owner != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          'Solicitante: ${_resolveUserName(detail.borrower)} · '
                          'Propietario: ${_resolveUserName(detail.owner)}',
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          if (isBorrower && loan.status == 'pending')
                            OutlinedButton.icon(
                              onPressed: loanState.isLoading
                                  ? null
                                  : () => _cancelLoan(context, detail),
                              icon: const Icon(Icons.cancel_outlined),
                              label: const Text('Cancelar solicitud'),
                            ),
                          if (isOwner && loan.status == 'pending') ...[
                            FilledButton.icon(
                              onPressed: loanState.isLoading
                                  ? null
                                  : () => _acceptLoan(context, detail),
                              icon: const Icon(Icons.check_circle_outlined),
                              label: const Text('Aceptar'),
                            ),
                            OutlinedButton.icon(
                              onPressed: loanState.isLoading
                                  ? null
                                  : () => _rejectLoan(context, detail),
                              icon: const Icon(Icons.cancel_schedule_send_outlined),
                              label: const Text('Rechazar'),
                            ),
                          ],
                          if ((isOwner || isBorrower) && loan.status == 'accepted') ...[
                            FilledButton.icon(
                              onPressed: loanState.isLoading
                                  ? null
                                  : () => _markReturned(context, detail),
                              icon: const Icon(Icons.assignment_turned_in_outlined),
                              label: const Text('Marcar devuelto'),
                            ),
                            OutlinedButton.icon(
                              onPressed: loanState.isLoading
                                  ? null
                                  : () => _expireLoan(context, detail),
                              icon: const Icon(Icons.hourglass_top_outlined),
                              label: const Text('Marcar expirado'),
                            ),
                          ],
                          if (detail.sharedBook != null &&
                              detail.sharedBook!.ownerUserId != activeUser?.id &&
                              detail.sharedBook!.isAvailable &&
                              loan.status == 'pending')
                            FilledButton.icon(
                              onPressed: loanState.isLoading
                                  ? null
                                  : () => _requestLoan(context, detail),
                              icon: const Icon(Icons.handshake_outlined),
                              label: const Text('Solicitar préstamo'),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
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

  Future<void> _cancelLoan(BuildContext context, LoanDetail detail) async {
    final borrower = detail.borrower;
    if (borrower == null) {
      onFeedback('No pudimos identificar al solicitante.', true);
      return;
    }

    try {
      await loanController.cancelLoan(loan: detail.loan, borrower: borrower);
      if (!context.mounted) return;
      onFeedback('Solicitud cancelada.', false);
    } catch (error) {
      if (!context.mounted) return;
      onFeedback('No se pudo cancelar la solicitud: $error', true);
    }
  }

  Future<void> _acceptLoan(BuildContext context, LoanDetail detail) async {
    final owner = detail.owner;
    if (owner == null) {
      onFeedback('No pudimos identificar al propietario.', true);
      return;
    }

    try {
      await loanController.acceptLoan(loan: detail.loan, owner: owner);
      if (!context.mounted) return;
      onFeedback('Préstamo aceptado.', false);
    } catch (error) {
      if (!context.mounted) return;
      onFeedback('No se pudo aceptar el préstamo: $error', true);
    }
  }

  Future<void> _rejectLoan(BuildContext context, LoanDetail detail) async {
    final owner = detail.owner;
    if (owner == null) {
      onFeedback('No pudimos identificar al propietario.', true);
      return;
    }

    try {
      await loanController.rejectLoan(loan: detail.loan, owner: owner);
      if (!context.mounted) return;
      onFeedback('Solicitud rechazada.', false);
    } catch (error) {
      if (!context.mounted) return;
      onFeedback('No se pudo rechazar la solicitud: $error', true);
    }
  }

  Future<void> _markReturned(BuildContext context, LoanDetail detail) async {
    final actor = activeUser;
    if (actor == null) {
      onFeedback('No pudimos identificar al usuario activo.', true);
      return;
    }

    try {
      await loanController.markReturned(loan: detail.loan, actor: actor);
      if (!context.mounted) return;
      onFeedback('Préstamo marcado como devuelto.', false);
    } catch (error) {
      if (!context.mounted) return;
      onFeedback('No se pudo marcar como devuelto: $error', true);
    }
  }

  Future<void> _expireLoan(BuildContext context, LoanDetail detail) async {
    try {
      await loanController.expireLoan(loan: detail.loan);
      if (!context.mounted) return;
      onFeedback('Préstamo marcado como expirado.', false);
    } catch (error) {
      if (!context.mounted) return;
      onFeedback('No se pudo marcar como expirado: $error', true);
    }
  }

  Future<void> _requestLoan(BuildContext context, LoanDetail detail) async {
    final sharedBook = detail.sharedBook;
    final borrower = activeUser;
    if (sharedBook == null || borrower == null) {
      onFeedback('No pudimos preparar la solicitud para este libro.', true);
      return;
    }

    try {
      await loanController.requestLoan(sharedBook: sharedBook, borrower: borrower);
      if (!context.mounted) return;
      onFeedback('Solicitud enviada.', false);
    } catch (error) {
      if (!context.mounted) return;
      onFeedback('No se pudo enviar la solicitud: $error', true);
    }
  }
}

class _LoansTab extends ConsumerWidget {
  const _LoansTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groupsAsync = ref.watch(groupListProvider);
    final loanActionState = ref.watch(loanControllerProvider);

    return SafeArea(
      child: Column(
        children: [
          if (loanActionState.lastError != null)
            _LoanFeedbackBanner(
              message: loanActionState.lastError!,
              isError: true,
              onDismiss: () =>
                  ref.read(loanControllerProvider.notifier).dismissError(),
            )
          else if (loanActionState.lastSuccess != null)
            _LoanFeedbackBanner(
              message: loanActionState.lastSuccess!,
              isError: false,
              onDismiss: () =>
                  ref.read(loanControllerProvider.notifier).dismissSuccess(),
            ),
          Expanded(
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
                      return _GroupCard(
                        group: group,
                        onSync: () => _syncNow(context, ref),
                      );
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
          ),
        ],
      ),
    );
  }

  Future<void> _syncNow(BuildContext context, WidgetRef ref) async {
    await _performSync(context, ref);
  }
}

class _StatsTab extends StatelessWidget {
  const _StatsTab();

  @override
  Widget build(BuildContext context) {
    return const _StatsView();
  }
}

class _StatsView extends ConsumerWidget {
  const _StatsView();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaryAsync = ref.watch(statsSummaryProvider);

    return SafeArea(
      child: summaryAsync.when(
        data: (summary) => _StatsContent(summary: summary),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => _StatsError(message: '$error'),
      ),
    );
  }
}

class _StatsContent extends StatelessWidget {
  const _StatsContent({required this.summary});

  final StatsSummary summary;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Estadísticas generales', style: theme.textTheme.headlineSmall),
          const SizedBox(height: 16),
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              _StatHighlight(
                icon: Icons.menu_book,
                label: 'Libros totales',
                value: summary.totalBooks,
              ),
              _StatHighlight(
                icon: Icons.swap_horiz,
                label: 'Préstamos totales',
                value: summary.totalLoans,
              ),
              _StatHighlight(
                icon: Icons.playlist_add_check_circle,
                label: 'Préstamos activos',
                value: summary.activeLoans,
              ),
              _StatHighlight(
                icon: Icons.assignment_turned_in,
                label: 'Devueltos',
                value: summary.returnedLoans,
              ),
              _StatHighlight(
                icon: Icons.hourglass_bottom,
                label: 'Expirados',
                value: summary.expiredLoans,
              ),
            ],
          ),
          const SizedBox(height: 28),
          Text('Libros más prestados', style: theme.textTheme.headlineSmall),
          const SizedBox(height: 12),
          _TopBooksList(topBooks: summary.topBooks),
        ],
      ),
    );
  }
}

class _StatHighlight extends StatelessWidget {
  const _StatHighlight({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final int value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 140),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, size: 28, color: theme.colorScheme.primary),
              const SizedBox(height: 12),
              Text(
                '$value',
                style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(label, style: theme.textTheme.titleSmall),
            ],
          ),
        ),
      ),
    );
  }
}

class _TopBooksList extends StatelessWidget {
  const _TopBooksList({required this.topBooks});

  final List<StatsTopBook> topBooks;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (topBooks.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Icon(Icons.insights_outlined, color: theme.colorScheme.primary),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Cuando registres préstamos aparecerán aquí tus libros más populares.',
                  style: theme.textTheme.bodyMedium,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: topBooks.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final book = topBooks[index];
        return Card(
          child: ListTile(
            leading: CircleAvatar(child: Text('${index + 1}')),
            title: Text(book.title),
            subtitle: Text('Préstamos registrados: ${book.loanCount}'),
          ),
        );
      },
    );
  }
}

class _StatsError extends StatelessWidget {
  const _StatsError({required this.message});

  final String message;

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
              'No pudimos cargar las estadísticas.',
              style: theme.textTheme.titleLarge?.copyWith(color: theme.colorScheme.error),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
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
              // Sección de importación de libros
              Text(
                'Biblioteca',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 12),
              Text(
                'Importa o exporta tu biblioteca de libros.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.import_export),
                  title: const Text('Importar libros'),
                  subtitle: const Text('Importa libros desde un archivo CSV o JSON'),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) => const ImportBooksDialog(),
                    );
                  },
                ),
              ),
              const SizedBox(height: 32),

              // Sección de seguridad
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
                'Apariencia',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 12),
              const _ThemeSection(),
              const SizedBox(height: 16),
              Text(
                'Apoya el proyecto',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 12),
              _buildDonationCard(context, ref),
              const SizedBox(height: 24),
              Text(
                'Integraciones externas',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 12),
              const _SupabaseConfigCard(),
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

  Widget _buildDonationCard(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final donationUrl = ref.watch(donationUrlProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.local_cafe_outlined,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Invítame a un café',
                  style: theme.textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Si esta app te resulta útil, puedes apoyar su desarrollo con una donación.',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: () => _openDonationLink(context, donationUrl),
              icon: const Icon(Icons.open_in_new),
              label: const Text('Invítame a un café'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openDonationLink(
      BuildContext context, String donationUrl) async {
    final uri = Uri.tryParse(donationUrl);
    if (uri == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('El enlace de donación no es válido.')),
      );
      return;
    }

    try {
      final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!launched && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se pudo abrir el enlace de donación.')),
        );
      }
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al abrir el enlace: $e')),
      );
    }
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
            : theme.colorScheme.surfaceContainerHighest;

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
