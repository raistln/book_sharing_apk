import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../config/supabase_defaults.dart';
import '../../../../providers/api_providers.dart';
import '../../../../providers/auth_providers.dart';
import '../../../../providers/book_providers.dart';
import '../../../../providers/settings_providers.dart';
import '../../../../providers/theme_providers.dart';
import '../../../widgets/import_books_dialog.dart';
import '../../auth/pin_setup_screen.dart';

/// Helper to show feedback snackbar
void _showFeedbackSnackBar({
  required BuildContext context,
  required String message,
  required bool isError,
}) {
  if (!context.mounted) return;
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: isError ? Theme.of(context).colorScheme.error : null,
    ),
  );
}

/// Settings tab - manages app configuration, security, and integrations
class SettingsTab extends ConsumerWidget {
  const SettingsTab({super.key});

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
                  title: const Text('Eliminar PIN y cambiar de usuario'),
                  subtitle: const Text('Vuelve al inicio para configurar otra cuenta.'),
                  onTap: () async {
                    final confirmed = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('¿Eliminar PIN y salir de la cuenta?'),
                        content: const Text(
                          'Se eliminarán TODOS los datos locales (libros, grupos, préstamos) '
                          'y tendrás que iniciar sesión o configurar un nuevo usuario.',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(false),
                            child: const Text('Cancelar'),
                          ),
                          FilledButton(
                            onPressed: () => Navigator.of(context).pop(true),
                            style: FilledButton.styleFrom(
                              backgroundColor: Theme.of(context).colorScheme.error,
                            ),
                            child: const Text('Eliminar todo'),
                          ),
                        ],
                      ),
                    );

                    if (confirmed != true) return;

                    // Clear PIN first
                    await ref.read(authControllerProvider.notifier).clearPin();

                    // Clear all local data
                    final database = ref.read(appDatabaseProvider);
                    await database.clearAllData();

                    if (!context.mounted) return;

                    // Show message and close app so user can restart fresh
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                            'Datos eliminados. Reinicia la app para configurar un nuevo usuario.'),
                        duration: Duration(seconds: 3),
                      ),
                    );

                    // Wait a moment for the snackbar to show, then close app
                    await Future.delayed(const Duration(milliseconds: 1500));
                    SystemNavigator.pop();
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
              _GoogleBooksApiCard(
                  onConfigure: () => _handleConfigureGoogleBooksKey(context, ref),
                  onClear: () => _handleClearGoogleBooksKey(context, ref)),
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

  Future<void> _openDonationLink(BuildContext context, String donationUrl) async {
    final uri = Uri.tryParse(donationUrl);
    if (uri == null) {
      _showFeedbackSnackBar(
        context: context,
        message: 'El enlace de donación no es válido.',
        isError: true,
      );
      return;
    }

    try {
      final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!launched && context.mounted) {
        _showFeedbackSnackBar(
          context: context,
          message: 'No se pudo abrir el enlace de donación.',
          isError: true,
        );
      }
    } catch (e) {
      if (!context.mounted) return;
      _showFeedbackSnackBar(
        context: context,
        message: 'Error al abrir el enlace: $e',
        isError: true,
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
                        : () => ref.read(groupSyncControllerProvider.notifier).clearError(),
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
      _showFeedbackSnackBar(
        context: context,
        message: 'API key de Google Books guardada.',
        isError: false,
      );
    }
  }

  Future<void> _handleClearGoogleBooksKey(BuildContext context, WidgetRef ref) async {
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

    final controller = ref.read(googleBooksApiKeyControllerProvider.notifier);
    await controller.clearApiKey();

    if (context.mounted) {
      _showFeedbackSnackBar(
        context: context,
        message: 'API key eliminada.',
        isError: false,
      );
    }
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
                  showSelectedIcon: false,
                ),
              ],
            ),
          ),
        );
      },
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
                onPressed: () => ref.invalidate(googleBooksApiKeyControllerProvider),
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
          text: 'Crea un proyecto nuevo o usa uno existente para la aplicación.',
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
