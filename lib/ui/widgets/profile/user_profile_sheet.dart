import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../../providers/user_profile_provider.dart';
import '../../../providers/book_providers.dart';
import '../../screens/read_books_screen.dart';
import '../../screens/wishlist_screen.dart';
import '../library/book_details_page.dart';
import '../../../providers/stats_providers.dart';
import '../../widgets/profile/reading_rhythm_chart.dart';
import '../../widgets/profile/reading_calendar.dart';

class UserProfileSheet extends ConsumerStatefulWidget {
  const UserProfileSheet({super.key});

  @override
  ConsumerState<UserProfileSheet> createState() => _UserProfileSheetState();
}

class _UserProfileSheetState extends ConsumerState<UserProfileSheet> {
  bool _isEditing = false;
  int _selectedTabIndex = 0; // 0 = Calendar, 1 = Rhythm
  final _formKey = GlobalKey<FormState>();

  static const List<String> _provinces = [
    'Álava',
    'Albacete',
    'Alicante',
    'Almería',
    'Asturias',
    'Ávila',
    'Badajoz',
    'Baleares',
    'Barcelona',
    'Burgos',
    'Cáceres',
    'Cádiz',
    'Cantabria',
    'Castellón',
    'Ciudad Real',
    'Córdoba',
    'Cuenca',
    'Gerona',
    'Granada',
    'Guadalajara',
    'Guipúzcoa',
    'Huelva',
    'Huesca',
    'Jaén',
    'La Coruña',
    'La Rioja',
    'Las Palmas',
    'León',
    'Lérida',
    'Lugo',
    'Madrid',
    'Málaga',
    'Murcia',
    'Navarra',
    'Orense',
    'Palencia',
    'Pontevedra',
    'Salamanca',
    'Santa Cruz de Tenerife',
    'Segovia',
    'Sevilla',
    'Soria',
    'Tarragona',
    'Teruel',
    'Toledo',
    'Valencia',
    'Valladolid',
    'Vizcaya',
    'Zamora',
    'Zaragoza',
    'Ceuta',
    'Melilla',
  ];

  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _residenceController;
  late TextEditingController _favBookController;
  late TextEditingController _favGenreController;
  late TextEditingController _bioController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _residenceController = TextEditingController();
    _favBookController = TextEditingController();
    _favGenreController = TextEditingController();
    _bioController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _residenceController.dispose();
    _favBookController.dispose();
    _favGenreController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  void _initControllers(userProfile, String? activeUsername) {
    if (activeUsername != null) {
      _nameController.text = activeUsername;
    } else if (_nameController.text.isEmpty && !_isEditing) {
      _nameController.text = userProfile.name;
    }
    if (_emailController.text.isEmpty && !_isEditing) {
      _emailController.text = userProfile.email;
    }
    if (_residenceController.text.isEmpty && !_isEditing) {
      _residenceController.text = userProfile.residence;
    }
    if (_favBookController.text.isEmpty && !_isEditing) {
      _favBookController.text = userProfile.favoriteBook;
    }
    if (_favGenreController.text.isEmpty && !_isEditing) {
      _favGenreController.text = userProfile.favoriteGenre;
    }
    if (_bioController.text.isEmpty && !_isEditing) {
      _bioController.text = userProfile.bio;
    }
  }

  void _save() {
    if (_formKey.currentState!.validate()) {
      final notifier = ref.read(userProfileProvider.notifier);
      final current = ref.read(userProfileProvider).value;
      if (current != null) {
        notifier.save(current.copyWith(
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          residence: _residenceController.text.trim(),
          favoriteBook: _favBookController.text.trim(),
          favoriteGenre: _favGenreController.text.trim(),
          bio: _bioController.text.trim(),
        ));
      }
      setState(() {
        _isEditing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(userProfileProvider);
    final theme = Theme.of(context);

    // Load statistics
    final allBooksAsync = ref.watch(bookListProvider);
    final loanStatsAsync = ref.watch(loanStatisticsProvider);
    final readBooksHistoryAsync = ref.watch(readBooksProvider);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) {
          return profileAsync.when(
            data: (profile) {
              final activeUser = ref.watch(activeUserProvider).value;
              final displayName = activeUser?.username ?? profile.name;
              _initControllers(profile, activeUser?.username);
              return ListView(
                controller: scrollController,
                padding: const EdgeInsets.all(24),
                children: [
                  Center(
                    child: Container(
                      width: 48,
                      height: 4,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.outlineVariant,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Header & Avatar
                  Row(
                    children: [
                      // Avatar
                      Center(
                        child: Stack(
                          children: [
                            CircleAvatar(
                              radius: 50,
                              backgroundColor:
                                  theme.colorScheme.primaryContainer,
                              backgroundImage: profile.imagePath != null
                                  ? FileImage(File(profile.imagePath!))
                                  : null,
                              child: profile.imagePath == null
                                  ? Text(
                                      (displayName.isNotEmpty)
                                          ? displayName[0].toUpperCase()
                                          : 'U',
                                      style: theme.textTheme.displayMedium
                                          ?.copyWith(
                                        color: theme
                                            .colorScheme.onPrimaryContainer,
                                      ),
                                    )
                                  : null,
                            ),
                            if (_isEditing)
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: IconButton(
                                  onPressed: () async {
                                    final picker = ImagePicker();
                                    final pickedFile = await picker.pickImage(
                                        source: ImageSource.gallery);
                                    if (pickedFile != null) {
                                      ref
                                          .read(userProfileProvider.notifier)
                                          .save(profile.copyWith(
                                              imagePath: pickedFile.path));
                                    }
                                  },
                                  icon: const Icon(Icons.camera_alt),
                                  style: IconButton.styleFrom(
                                    backgroundColor: theme.colorScheme.primary,
                                    foregroundColor:
                                        theme.colorScheme.onPrimary,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              displayName.isNotEmpty
                                  ? displayName
                                  : 'Sin nombre',
                              style: theme.textTheme.headlineSmall,
                            ),
                            if (profile.residence.isNotEmpty)
                              Row(
                                children: [
                                  Icon(Icons.location_on_outlined,
                                      size: 16,
                                      color: theme.colorScheme.secondary),
                                  const SizedBox(width: 4),
                                  Text(profile.residence,
                                      style: theme.textTheme.bodyMedium),
                                ],
                              ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          setState(() {
                            _isEditing = !_isEditing;
                          });
                        },
                        icon: Icon(
                            _isEditing ? Icons.close : Icons.edit_outlined),
                      ),
                    ],
                  ),

                  // Editing Form
                  if (_isEditing) ...[
                    const SizedBox(height: 24),
                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          TextFormField(
                            controller: _nameController,
                            readOnly: true,
                            decoration: const InputDecoration(
                                labelText: 'Nombre (desde registro)',
                                border: OutlineInputBorder(),
                                suffixIcon: Icon(Icons.lock_outline, size: 20)),
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _emailController,
                            decoration: const InputDecoration(
                                labelText: 'Correo',
                                border: OutlineInputBorder()),
                          ),
                          const SizedBox(height: 12),
                          Autocomplete<String>(
                            initialValue: TextEditingValue(
                                text: _residenceController.text),
                            optionsBuilder:
                                (TextEditingValue textEditingValue) {
                              if (textEditingValue.text.isEmpty) {
                                return const Iterable<String>.empty();
                              }
                              return _provinces.where((String option) {
                                return option.toLowerCase().contains(
                                    textEditingValue.text.toLowerCase());
                              });
                            },
                            onSelected: (String selection) {
                              _residenceController.text = selection;
                            },
                            fieldViewBuilder: (context, controller, focusNode,
                                onFieldSubmitted) {
                              // Sync controllers
                              if (controller.text !=
                                      _residenceController.text &&
                                  _residenceController.text.isNotEmpty &&
                                  controller.text.isEmpty) {
                                controller.text = _residenceController.text;
                              }

                              return TextFormField(
                                controller: controller,
                                focusNode: focusNode,
                                decoration: const InputDecoration(
                                  labelText: 'Lugar de residencia (Provincia)',
                                  border: OutlineInputBorder(),
                                  suffixIcon: Icon(Icons.search, size: 20),
                                ),
                                onFieldSubmitted: (value) {
                                  onFieldSubmitted();
                                },
                                onChanged: (value) {
                                  _residenceController.text = value;
                                },
                              );
                            },
                            optionsViewBuilder: (context, onSelected, options) {
                              return Align(
                                alignment: Alignment.topLeft,
                                child: Material(
                                  elevation: 4.0,
                                  borderRadius: BorderRadius.circular(12),
                                  child: Container(
                                    width:
                                        MediaQuery.of(context).size.width - 48,
                                    margin: const EdgeInsets.only(top: 4),
                                    decoration: BoxDecoration(
                                      color: theme.colorScheme.surface,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    constraints:
                                        const BoxConstraints(maxHeight: 250),
                                    child: ListView.builder(
                                      padding: const EdgeInsets.all(8.0),
                                      shrinkWrap: true,
                                      itemCount: options.length,
                                      itemBuilder:
                                          (BuildContext context, int index) {
                                        final String option =
                                            options.elementAt(index);
                                        return ListTile(
                                          title: Text(option),
                                          onTap: () => onSelected(option),
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8)),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _favBookController,
                            decoration: const InputDecoration(
                                labelText: 'Libro favorito',
                                border: OutlineInputBorder()),
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _favGenreController,
                            decoration: const InputDecoration(
                                labelText: 'Género favorito',
                                border: OutlineInputBorder()),
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _bioController,
                            decoration: const InputDecoration(
                                labelText: 'Biografía / Notas',
                                border: OutlineInputBorder()),
                            maxLines: 3,
                          ),
                          const SizedBox(height: 16),
                          FilledButton.icon(
                            onPressed: _save,
                            icon: const Icon(Icons.save),
                            label: const Text('Guardar'),
                          ),
                        ],
                      ),
                    ),
                    const Divider(height: 48),
                  ],

                  const SizedBox(height: 32),

                  // Statistics Section
                  allBooksAsync.when(
                    data: (books) {
                      final ownedBooks =
                          books.where((b) => !b.isBorrowedExternal).toList();
                      final totalBooks = ownedBooks.length;
                      final readBooks =
                          ownedBooks.where((b) => b.isRead).toList();
                      // We need to fetch loans for full stats, but for now we use books

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Estadísticas',
                              style: theme.textTheme.titleLarge),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              _StatCard(
                                label: 'Libros',
                                value: totalBooks.toString(),
                                icon: Icons.library_books,
                                color: Colors.blue.shade100,
                                textColor: Colors.blue.shade900,
                              ),
                              const SizedBox(width: 12),
                              _StatCard(
                                label: 'Leídos',
                                value: readBooksHistoryAsync
                                        .asData?.value.length
                                        .toString() ??
                                    readBooks.length.toString(),
                                icon: Icons.check_circle_outline,
                                color: Colors.green.shade100,
                                textColor: Colors.green.shade900,
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          loanStatsAsync.when(
                            data: (stats) {
                              final made30d = stats['loansMade30Days'] as int;
                              final made1y = stats['loansMadeYear'] as int;
                              final requested30d =
                                  stats['loansRequested30Days'] as int;
                              final requested1y =
                                  stats['loansRequestedYear'] as int;
                              final mostLoaned =
                                  stats['mostLoanedBook'] as String?;
                              final mostLoanedCount =
                                  stats['mostLoanedBookCount'] as int;

                              return Column(
                                children: [
                                  Row(
                                    children: [
                                      _StatCard(
                                        label: 'Prestados (30d/1a)',
                                        value: '$made30d / $made1y',
                                        icon: Icons.outbox,
                                        color: Colors.orange.shade100,
                                        textColor: Colors.orange.shade900,
                                      ),
                                      const SizedBox(width: 12),
                                      _StatCard(
                                        label: 'Solicitados (30d/1a)',
                                        value: '$requested30d / $requested1y',
                                        icon: Icons.inbox,
                                        color: Colors.purple.shade100,
                                        textColor: Colors.purple.shade900,
                                      ),
                                    ],
                                  ),
                                  if (mostLoaned != null) ...[
                                    const SizedBox(height: 12),
                                    Container(
                                      padding: const EdgeInsets.all(16),
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                        color: theme
                                            .colorScheme.surfaceContainerHighest
                                            .withValues(alpha: 0.3),
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Icon(Icons.star_outline,
                                                  color: theme
                                                      .colorScheme.primary),
                                              const SizedBox(width: 8),
                                              Text(
                                                'Más prestado',
                                                style: theme
                                                    .textTheme.labelMedium
                                                    ?.copyWith(
                                                  color:
                                                      theme.colorScheme.primary,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            mostLoaned,
                                            style: theme.textTheme.titleMedium
                                                ?.copyWith(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Text(
                                            '$mostLoanedCount veces',
                                            style: theme.textTheme.bodySmall
                                                ?.copyWith(
                                              color: theme
                                                  .colorScheme.onSurfaceVariant,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ],
                              );
                            },
                            loading: () => const SizedBox.shrink(),
                            error: (e, st) => Text('Error stats préstamos: $e'),
                          ),
                          const SizedBox(height: 24),
                          Center(
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                FilledButton.tonalIcon(
                                  onPressed: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                          builder: (_) =>
                                              const ReadBooksScreen()),
                                    );
                                  },
                                  icon: const Icon(Icons.menu_book),
                                  label: const Text('Libros leídos'),
                                ),
                                const SizedBox(width: 12),
                                FilledButton.tonalIcon(
                                  onPressed: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                          builder: (_) =>
                                              const WishlistScreen()),
                                    );
                                  },
                                  icon: const Icon(Icons.favorite_border),
                                  label: const Text('Deseos'),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                          const SizedBox(height: 24),

                          // Tab Selector
                          Center(
                            child: SegmentedButton<int>(
                              segments: const [
                                ButtonSegment<int>(
                                  value: 0,
                                  label: Text('Calendario'),
                                  icon: Icon(Icons.calendar_month),
                                ),
                                ButtonSegment<int>(
                                  value: 1,
                                  label: Text('Ritmo'),
                                  icon: Icon(Icons.ssid_chart),
                                ),
                              ],
                              selected: {_selectedTabIndex},
                              onSelectionChanged: (Set<int> newSelection) {
                                setState(() {
                                  _selectedTabIndex = newSelection.first;
                                });
                              },
                              showSelectedIcon: false,
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Tab Content
                          if (_selectedTabIndex == 0) ...[
                            Text('Libros leídos el último año',
                                style: theme.textTheme.titleMedium),
                            const SizedBox(height: 16),
                            ReadingCalendar(
                                readBooks:
                                    readBooksHistoryAsync.asData?.value ?? []),
                          ] else ...[
                            Text('Tu ritmo de lectura reciente',
                                style: theme.textTheme.titleMedium),
                            const SizedBox(height: 16),
                            Consumer(
                              builder: (context, ref, child) {
                                final rhythmAsync =
                                    ref.watch(readingRhythmProvider);
                                return rhythmAsync.when(
                                  data: (data) => ReadingRhythmChart(
                                    data: data,
                                    onBookTap: (book) {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (_) => BookDetailsPage(
                                            bookId: book.id,
                                            scrollToTimeline: true,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                  loading: () => const Center(
                                      child: CircularProgressIndicator()),
                                  error: (e, st) =>
                                      Text('No se pudo cargar el ritmo: $e'),
                                );
                              },
                            ),
                          ],
                        ],
                      );
                    },
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (e, st) => Text('Error cargando estadísticas: $e'),
                  ),

                  const SizedBox(height: 48),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest
                          .withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.info_outline, size: 20),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Tus datos personales se guardan únicamente en este dispositivo.',
                            style: theme.textTheme.bodySmall,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) => Center(child: Text('Error: $err')),
          );
        },
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    required this.textColor,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: textColor),
            const SizedBox(height: 12),
            Text(value,
                style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: textColor)),
            Text(label,
                style: TextStyle(color: textColor.withValues(alpha: 0.8))),
          ],
        ),
      ),
    );
  }
}
