import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../../providers/user_profile_provider.dart';
import '../../../providers/book_providers.dart';
import 'package:intl/intl.dart';

class UserProfileSheet extends ConsumerStatefulWidget {
  const UserProfileSheet({super.key});

  @override
  ConsumerState<UserProfileSheet> createState() => _UserProfileSheetState();
}

class _UserProfileSheetState extends ConsumerState<UserProfileSheet> {
  bool _isEditing = false;
  final _formKey = GlobalKey<FormState>();

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

  void _initControllers(userProfile) {
    if (_nameController.text.isEmpty && !_isEditing) {
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
              _initControllers(profile);
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
                                      (profile.name.isNotEmpty)
                                          ? profile.name[0].toUpperCase()
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
                              profile.name.isNotEmpty
                                  ? profile.name
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
                            decoration: const InputDecoration(
                                labelText: 'Nombre',
                                border: OutlineInputBorder()),
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _emailController,
                            decoration: const InputDecoration(
                                labelText: 'Correo',
                                border: OutlineInputBorder()),
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _residenceController,
                            decoration: const InputDecoration(
                                labelText: 'Lugar de residencia',
                                border: OutlineInputBorder()),
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
                      final totalBooks = books.length;
                      final readBooks = books.where((b) => b.isRead).toList();
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
                                value: readBooks.length.toString(),
                                icon: Icons.check_circle_outline,
                                color: Colors.green.shade100,
                                textColor: Colors.green.shade900,
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
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
                          const SizedBox(height: 32),
                          Text('Libros leídos el último año',
                              style: theme.textTheme.titleMedium),
                          const SizedBox(height: 16),
                          _ReadingCalendar(readBooks: readBooks),
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

class _ReadingCalendar extends StatelessWidget {
  const _ReadingCalendar({required this.readBooks});

  final List<dynamic> readBooks; // List<Book>

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final months = <DateTime>[];
    for (int i = 11; i >= 0; i--) {
      months.add(DateTime(now.year, now.month - i, 1));
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        childAspectRatio: 1.0,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
      ),
      itemCount: 12,
      itemBuilder: (context, index) {
        final monthDate = months[index];
        final count = readBooks.where((b) {
          // Check if readAt matches month and year
          // Note: Dynamic cast because Book type might not be fully visible here without import
          // but we know it has readAt from our migration.
          // Actually, we need to handle the case where readAt is null (though we filtered by isRead, old books have readAt=null)
          final date = (b.readAt as DateTime?);
          if (date == null) return false;
          return date.year == monthDate.year && date.month == monthDate.month;
        }).length;

        final isCurrentMonth =
            monthDate.month == now.month && monthDate.year == now.year;

        return Tooltip(
          message:
              '${DateFormat('MMMM yyyy', 'es').format(monthDate)}: $count libros',
          child: Container(
            decoration: BoxDecoration(
              color: count > 0
                  ? Colors.green
                      .withValues(alpha: (0.2 + (count * 0.1)).clamp(0.2, 1.0))
                  : Colors.grey.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: isCurrentMonth
                  ? Border.all(
                      color: Theme.of(context).colorScheme.primary, width: 2)
                  : null,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  DateFormat('MMM', 'es').format(monthDate).toUpperCase(),
                  style: Theme.of(context)
                      .textTheme
                      .labelSmall
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  count.toString(),
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
