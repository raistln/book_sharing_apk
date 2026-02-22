import 'package:flutter/material.dart';

import '../../models/book_genre.dart';

// ---------------------------------------------------------------------------
// Result
// ---------------------------------------------------------------------------

/// Result data class for group form dialog.
class GroupFormResult {
  const GroupFormResult({
    required this.name,
    this.description,
    this.allowedGenres,
    this.primaryColor,
  });

  final String name;
  final String? description;

  /// JSON-encoded list of allowed genre names, e.g. '["fantasy","horror"]'.
  /// Null or empty means no genre filter (general group).
  final String? allowedGenres;

  /// Hex color string of the primary genre, e.g. '#7B5EA7'. Null if no genres.
  final String? primaryColor;
}

// ---------------------------------------------------------------------------
// Dialog
// ---------------------------------------------------------------------------

/// Dialog for creating a new group (also used for editing via [initialName],
/// [initialDescription], [initialGenres]).
class GroupFormDialog extends StatefulWidget {
  const GroupFormDialog({
    super.key,
    this.initialName,
    this.initialDescription,
    this.initialGenres = const [],
  });

  final String? initialName;
  final String? initialDescription;

  /// Pre-selected genres (used when editing an existing group).
  final List<BookGenre> initialGenres;

  @override
  State<GroupFormDialog> createState() => _GroupFormDialogState();
}

class _GroupFormDialogState extends State<GroupFormDialog> {
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  final _formKey = GlobalKey<FormState>();
  late List<BookGenre> _selectedGenres;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName);
    _descriptionController =
        TextEditingController(text: widget.initialDescription);
    _selectedGenres = List.of(widget.initialGenres);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _toggleGenre(BookGenre genre) {
    setState(() {
      if (_selectedGenres.contains(genre)) {
        _selectedGenres.remove(genre);
      } else {
        _selectedGenres.add(genre);
      }
    });
  }

  /// Converts the stored hex string (e.g. '#7B5EA7') to a Flutter [Color].
  Color _hexToColor(String hex) {
    final clean = hex.replaceFirst('#', '');
    return Color(int.parse('FF$clean', radix: 16));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEditing = widget.initialName != null;

    // Determine preview color from first selected genre
    final primaryHex =
        _selectedGenres.isNotEmpty ? _selectedGenres.first.primaryHex : null;
    final previewColor = primaryHex != null ? _hexToColor(primaryHex) : null;

    return AlertDialog(
      title: Text(isEditing ? 'Editar grupo' : 'Crear grupo'),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ---- Name -----------------------------------------------
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Nombre del grupo',
                  ),
                  autofocus: !isEditing,
                  textInputAction: TextInputAction.next,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Introduce un nombre válido.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),

                // ---- Description ----------------------------------------
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Descripción (opcional)',
                  ),
                  maxLines: 2,
                  textInputAction: TextInputAction.done,
                ),
                const SizedBox(height: 20),

                // ---- Genre filter section --------------------------------
                Row(
                  children: [
                    Icon(Icons.local_library_outlined,
                        size: 18, color: theme.colorScheme.primary),
                    const SizedBox(width: 6),
                    Text(
                      'Géneros permitidos',
                      style: theme.textTheme.titleSmall,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '(opcional)',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Si eliges géneros, solo los libros de esos géneros serán visibles en este grupo. Sin selección, se muestran todos.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 10),

                // Color preview
                if (previewColor != null) ...[
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    height: 6,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(3),
                      color: previewColor.withValues(alpha: 0.7),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],

                // Genre chips
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: BookGenre.values.map((genre) {
                    final selected = _selectedGenres.contains(genre);
                    final chipColor =
                        selected ? _hexToColor(genre.primaryHex) : null;
                    return FilterChip(
                      label: Text(genre.label),
                      selected: selected,
                      onSelected: (_) => _toggleGenre(genre),
                      selectedColor: chipColor?.withValues(alpha: 0.25),
                      checkmarkColor: chipColor,
                      labelStyle: selected
                          ? TextStyle(
                              color: chipColor,
                              fontWeight: FontWeight.w600,
                            )
                          : null,
                      side: selected
                          ? BorderSide(color: chipColor!, width: 1.4)
                          : null,
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      visualDensity: VisualDensity.compact,
                    );
                  }).toList(),
                ),

                if (!isEditing) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Puedes cambiar los géneros más tarde desde el menú del grupo.',
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: _submit,
          child: Text(isEditing ? 'Guardar' : 'Crear'),
        ),
      ],
    );
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final trimmedName = _nameController.text.trim();
    final trimmedDescription = _descriptionController.text.trim();

    final genres = List<BookGenre>.of(_selectedGenres);
    final genresJson =
        genres.isNotEmpty ? BookGenre.encodeToJson(genres) : null;
    final primaryColor = genres.isNotEmpty ? genres.first.primaryHex : null;

    Navigator.of(context).pop(
      GroupFormResult(
        name: trimmedName,
        description: trimmedDescription.isEmpty ? null : trimmedDescription,
        allowedGenres: genresJson,
        primaryColor: primaryColor,
      ),
    );
  }
}
