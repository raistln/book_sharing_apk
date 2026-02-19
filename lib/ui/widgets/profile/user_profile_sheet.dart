import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../../providers/user_profile_provider.dart';
import '../../../providers/book_providers.dart';
import '../../screens/read_books_screen.dart';
import '../../screens/wishlist_screen.dart';

class UserProfileSheet extends ConsumerStatefulWidget {
  const UserProfileSheet({super.key});

  @override
  ConsumerState<UserProfileSheet> createState() => _UserProfileSheetState();
}

class _UserProfileSheetState extends ConsumerState<UserProfileSheet> {
  bool _isEditing = false;

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
    final allBooksAsync = ref.watch(bookListProvider);

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

              return CustomScrollView(
                controller: scrollController,
                slivers: [
                  // Pull-down handle indicator (Sliver)
                  SliverToBoxAdapter(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Container(
                          width: 48,
                          height: 4,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.outlineVariant,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Header with Gradient and Avatar
                  SliverToBoxAdapter(
                    child: !_isEditing
                        ? Container(
                            margin: const EdgeInsets.only(bottom: 24),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                // Background Gradient Header
                                Column(
                                  children: [
                                    Container(
                                      height: 120,
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                          colors: [
                                            theme.colorScheme.primary,
                                            theme.colorScheme.secondary,
                                          ],
                                        ),
                                        borderRadius: const BorderRadius.only(
                                          bottomLeft: Radius.circular(40),
                                          bottomRight: Radius.circular(40),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 60),
                                  ],
                                ),
                                // Avatar and Name
                                Positioned(
                                  top: 50,
                                  child: Column(
                                    children: [
                                      Stack(
                                        children: [
                                          Container(
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              border: Border.all(
                                                color:
                                                    theme.colorScheme.surface,
                                                width: 6,
                                              ),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black
                                                      .withValues(alpha: 0.15),
                                                  blurRadius: 15,
                                                  offset: const Offset(0, 8),
                                                ),
                                              ],
                                            ),
                                            child: CircleAvatar(
                                              radius: 65,
                                              backgroundColor: theme
                                                  .colorScheme.primaryContainer,
                                              backgroundImage: profile
                                                          .imagePath !=
                                                      null
                                                  ? FileImage(
                                                      File(profile.imagePath!))
                                                  : null,
                                              child: profile.imagePath == null
                                                  ? Text(
                                                      (displayName.isNotEmpty)
                                                          ? displayName[0]
                                                              .toUpperCase()
                                                          : 'U',
                                                      style: theme.textTheme
                                                          .displayMedium
                                                          ?.copyWith(
                                                        color: theme.colorScheme
                                                            .onPrimaryContainer,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    )
                                                  : null,
                                            ),
                                          ),
                                          Positioned(
                                            bottom: 4,
                                            right: 4,
                                            child: Material(
                                              elevation: 4,
                                              shape: const CircleBorder(),
                                              color: theme.colorScheme
                                                  .secondaryContainer,
                                              child: InkWell(
                                                onTap: () => setState(
                                                    () => _isEditing = true),
                                                customBorder:
                                                    const CircleBorder(),
                                                child: const Padding(
                                                  padding: EdgeInsets.all(8.0),
                                                  child: Icon(Icons.edit,
                                                      size: 20),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 12),
                                      Text(
                                        '@$displayName',
                                        style: theme.textTheme.headlineMedium
                                            ?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: -0.5,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          )
                        : const SizedBox.shrink(),
                  ),

                  if (!_isEditing) ...[
                    // Mi Actividad - Highlights Card
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 12),
                        child: Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surfaceContainer,
                            borderRadius: BorderRadius.circular(32),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.03),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: allBooksAsync.when(
                            data: (books) {
                              final ownedBooks = books
                                  .where((b) => !b.isBorrowedExternal)
                                  .toList();
                              final totalBooks = ownedBooks.length;
                              final readBooks =
                                  ownedBooks.where((b) => b.isRead).length;
                              final readingBooks = books
                                  .where((b) => b.readingStatus == 'reading')
                                  .length;

                              return Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  _buildCounter(
                                      context,
                                      'Libros',
                                      totalBooks.toString(),
                                      Icons.auto_stories),
                                  _buildCounter(context, 'Leídos',
                                      readBooks.toString(), Icons.verified),
                                  _buildCounter(
                                      context,
                                      'Leyendo',
                                      readingBooks.toString(),
                                      Icons.play_arrow_rounded),
                                ],
                              );
                            },
                            loading: () => const Center(
                                child: CircularProgressIndicator()),
                            error: (e, st) => Text('Error: $e'),
                          ),
                        ),
                      ),
                    ),

                    // Sobre Mí Section
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildSectionHeader(
                                context, 'Sobre mí', Icons.person_outline),
                            const SizedBox(height: 16),
                            Card(
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24),
                                side: BorderSide(
                                    color: theme.colorScheme.outlineVariant
                                        .withValues(alpha: 0.5)),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  children: [
                                    _buildInfoRow(context, Icons.book_rounded,
                                        'Libro favorito', profile.favoriteBook),
                                    const Divider(indent: 32),
                                    _buildInfoRow(
                                        context,
                                        Icons.local_library_rounded,
                                        'Género',
                                        profile.favoriteGenre),
                                    const Divider(indent: 32),
                                    _buildInfoRow(
                                        context,
                                        Icons.location_on_rounded,
                                        'Ubicación',
                                        profile.residence),
                                    const Divider(indent: 32),
                                    _buildInfoRow(
                                        context,
                                        Icons.alternate_email_rounded,
                                        'Contacto',
                                        profile.email),
                                  ],
                                ),
                              ),
                            ),
                            if (profile.bio.isNotEmpty) ...[
                              const SizedBox(height: 24),
                              _buildSectionHeader(context, 'Biografía',
                                  Icons.format_quote_rounded),
                              const SizedBox(height: 12),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 16),
                                child: Text(
                                  profile.bio,
                                  style: theme.textTheme.bodyLarge?.copyWith(
                                    height: 1.5,
                                    fontStyle: FontStyle.italic,
                                    color: theme.colorScheme.onSurface
                                        .withValues(alpha: 0.8),
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),

                    // Quick Access Section
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(24, 0, 24, 80),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildSectionHeader(
                                context, 'Accesos rápidos', Icons.bolt_rounded),
                            const SizedBox(height: 16),
                            _buildQuickLink(
                              context,
                              'Mis libros leídos',
                              Icons.history_edu_rounded,
                              () => Navigator.of(context).push(
                                  MaterialPageRoute(
                                      builder: (_) => const ReadBooksScreen())),
                            ),
                            const SizedBox(height: 8),
                            _buildQuickLink(
                              context,
                              'Lista de deseos',
                              Icons.auto_awesome_rounded,
                              () => Navigator.of(context).push(
                                  MaterialPageRoute(
                                      builder: (_) => const WishlistScreen())),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ] else ...[
                    // Edit Form - Still in SliverList
                    SliverPadding(
                      padding: const EdgeInsets.all(24),
                      sliver: SliverToBoxAdapter(
                        child: _buildEditForm(theme, profile),
                      ),
                    ),
                  ],
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

  Widget _buildEditForm(ThemeData theme, dynamic profile) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () {
                  setState(() {
                    _isEditing = false;
                  });
                },
                icon: const Icon(Icons.arrow_back),
              ),
              Text('Editar Perfil', style: theme.textTheme.titleLarge),
            ],
          ),
          const SizedBox(height: 24),
          Center(
            child: Stack(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: theme.colorScheme.primaryContainer,
                  backgroundImage: profile.imagePath != null
                      ? FileImage(File(profile.imagePath!))
                      : null,
                  child: profile.imagePath == null
                      ? const Icon(Icons.person, size: 50)
                      : null,
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: IconButton.filled(
                    onPressed: () async {
                      final picker = ImagePicker();
                      final pickedFile =
                          await picker.pickImage(source: ImageSource.gallery);
                      if (pickedFile != null) {
                        ref
                            .read(userProfileProvider.notifier)
                            .save(profile.copyWith(imagePath: pickedFile.path));
                      }
                    },
                    icon: const Icon(Icons.camera_alt, size: 18),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
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
                labelText: 'Correo', border: OutlineInputBorder()),
          ),
          const SizedBox(height: 12),
          Autocomplete<String>(
            initialValue: TextEditingValue(text: _residenceController.text),
            optionsBuilder: (TextEditingValue textEditingValue) {
              if (textEditingValue.text.isEmpty) {
                return const Iterable<String>.empty();
              }
              return _provinces.where((String option) {
                return option
                    .toLowerCase()
                    .contains(textEditingValue.text.toLowerCase());
              });
            },
            onSelected: (String selection) {
              _residenceController.text = selection;
            },
            fieldViewBuilder:
                (context, controller, focusNode, onFieldSubmitted) {
              if (controller.text != _residenceController.text &&
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
                onChanged: (value) => _residenceController.text = value,
              );
            },
            optionsViewBuilder: (context, onSelected, options) {
              return Align(
                alignment: Alignment.topLeft,
                child: Material(
                  elevation: 4.0,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    width: MediaQuery.of(context).size.width - 48,
                    margin: const EdgeInsets.only(top: 4),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    constraints: const BoxConstraints(maxHeight: 250),
                    child: ListView.builder(
                      padding: const EdgeInsets.all(8.0),
                      shrinkWrap: true,
                      itemCount: options.length,
                      itemBuilder: (BuildContext context, int index) {
                        final String option = options.elementAt(index);
                        return ListTile(
                          title: Text(option),
                          onTap: () => onSelected(option),
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
                labelText: 'Libro favorito', border: OutlineInputBorder()),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _favGenreController,
            decoration: const InputDecoration(
                labelText: 'Género favorito', border: OutlineInputBorder()),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _bioController,
            decoration: const InputDecoration(
                labelText: 'Biografía / Notas', border: OutlineInputBorder()),
            maxLines: 3,
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: _save,
            icon: const Icon(Icons.save),
            label: const Text('Guardar cambios'),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(
      BuildContext context, String title, IconData icon) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icon, size: 20, color: theme.colorScheme.primary),
        const SizedBox(width: 8),
        Text(title,
            style: theme.textTheme.titleMedium
                ?.copyWith(fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildCounter(
      BuildContext context, String label, String count, IconData icon) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withValues(alpha: 0.08),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: theme.colorScheme.primary, size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          count,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary,
          ),
        ),
        Text(
          label.toUpperCase(),
          style: theme.textTheme.labelSmall?.copyWith(
            fontWeight: FontWeight.w800,
            letterSpacing: 0.5,
            color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(
      BuildContext context, IconData icon, String label, String value) {
    final theme = Theme.of(context);
    final isValueEmpty = value.isEmpty;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest
                  .withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 20, color: theme.colorScheme.secondary),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant
                        .withValues(alpha: 0.6),
                    fontWeight: FontWeight.bold,
                    textBaseline: TextBaseline.alphabetic,
                  ),
                ),
                Text(
                  isValueEmpty ? 'No especificado' : value,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: isValueEmpty
                        ? theme.colorScheme.outline
                        : theme.colorScheme.onSurface,
                    fontWeight:
                        isValueEmpty ? FontWeight.normal : FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickLink(
      BuildContext context, String label, IconData icon, VoidCallback onTap) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Icon(icon, color: theme.colorScheme.secondary),
        title: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        trailing: Icon(Icons.arrow_forward_ios_rounded,
            size: 14, color: theme.colorScheme.outline),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }
}
