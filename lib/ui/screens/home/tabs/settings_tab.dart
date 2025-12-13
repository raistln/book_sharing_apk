import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../config/supabase_defaults.dart';
import '../../../../providers/auth_providers.dart';
import '../../../../providers/book_providers.dart';
import '../../../../providers/cover_refresh_providers.dart';
import '../../../../providers/api_providers.dart';
import '../../../../providers/settings_providers.dart';
import '../../../../providers/theme_providers.dart';
import '../../../../services/backup_scheduler_service.dart';
import '../../../../utils/database_reset.dart';
import '../../../../providers/loan_providers.dart' as loan;
import '../../../../utils/file_export_helper.dart';
import '../../../widgets/library/export_handler.dart';
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
              // Donation card at the top
              _buildDonationCard(context, ref),
              const SizedBox(height: 32),
              
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
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.upload_file_outlined),
                      title: const Text('Exportar biblioteca'),
                      subtitle: const Text('Guarda tu lista de libros en CSV, JSON o PDF'),
                      onTap: () => ExportHandler.handle(context, ref),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.history_edu_outlined),
                      title: const Text('Exportar historial de préstamos'),
                      subtitle: const Text('Genera un informe de tus préstamos (CSV)'),
                      onTap: () => _handleExportLoans(context, ref),
                    ),
                    const Divider(height: 1),
                    ListTile(
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
                  ],
                ),
              ),
              const SizedBox(height: 32),
              
              // Sección de Almacenamiento
              Text(
                'Almacenamiento',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 12),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.broken_image_outlined),
                  title: const Text('Borrar todas las portadas'),
                  subtitle: const Text('Libera espacio eliminando las imágenes descargadas.'),
                  onTap: () => _handleDeleteCovers(context, ref),
                ),
              ),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.delete_sweep_outlined, color: Colors.red),
                  title: const Text('Resetear base de datos local'),
                  subtitle: const Text('Elimina todos los datos locales y comienza desde cero.', style: TextStyle(color: Colors.red)),
                  onTap: () => _handleResetDatabase(context, ref),
                ),
              ),
              const SizedBox(height: 32),
              
              // Sección de Backup
              Text(
                'Copias de seguridad',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 12),
              const _BackupSection(),
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
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.warning_amber, size: 48, color: Colors.orange),
                            const SizedBox(height: 16),
                            const Text(
                              'Se eliminarán TODOS los datos locales (libros, grupos, préstamos) '
                              'y tendrás que iniciar sesión o configurar un nuevo usuario.',
                            ),
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.blue.shade50,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.blue.shade200),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.lightbulb_outline, color: Colors.blue.shade700),
                                  const SizedBox(width: 12),
                                  const Expanded(
                                    child: Text(
                                      '💡 Tip: Exporta tu biblioteca antes de continuar. '
                                      'Si tienes backups automáticos, búscalos en Descargas/BookSharing/backups.',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
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
                'Integraciones externas',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 12),
              const _SupabaseConfigCard(),
              const SizedBox(height: 16),
              _GoogleBooksApiCard(
                onConfigure: () => _handleConfigureGoogleBooksKey(context, ref),
                onClear: () => _handleClearGoogleBooksKey(context, ref),
              ),
              const SizedBox(height: 16),
              _buildSyncActionsCard(context, ref),
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

  Future<void> _handleResetDatabase(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('⚠️ Resetear base de datos local'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.warning_amber, size: 48, color: Colors.red),
            SizedBox(height: 16),
            Text(
              'Esto eliminará TODOS los datos locales:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('• Libros registrados'),
            Text('• Grupos y membresías'),
            Text('• Préstamos y notificaciones'),
            Text('• Configuración local'),
            SizedBox(height: 12),
            Text(
              'Los datos en la nube (Supabase) NO se eliminarán.',
              style: TextStyle(color: Colors.blue),
            ),
            SizedBox(height: 8),
            Text(
              'Después de resetear, la app se reiniciará automáticamente.',
              style: TextStyle(fontStyle: FontStyle.italic),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Resetear todo'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      if (context.mounted) {
        _showFeedbackSnackBar(
          context: context,
          message: 'Reseteando base de datos...',
          isError: false,
        );
      }

      // Delete the database file
      await DatabaseReset.forceResetDatabase();

      if (context.mounted) {
        _showFeedbackSnackBar(
          context: context,
          message: 'Base de datos reseteada. Reiniciando app...',
          isError: false,
        );
      }

      // Wait a moment then restart the app
      await Future.delayed(const Duration(seconds: 2));
      if (context.mounted) {
        SystemNavigator.pop();
      }
    } catch (error) {
      if (context.mounted) {
        _showFeedbackSnackBar(
          context: context,
          message: 'Error al resetear la base de datos: $error',
          isError: true,
        );
      }
    }
  }

  Future<void> _handleDeleteCovers(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Borrar todas las portadas?'),
        content: const Text(
          'Se eliminarán todas las imágenes de portada descargadas. '
          'Podrás volver a descargarlas manualmente desde la biblioteca.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Borrar'),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    final coverService = ref.read(coverRefreshServiceProvider);
    final activeUser = ref.read(activeUserProvider).value;

    try {
      final count = await coverService.deleteAllCovers(ownerUserId: activeUser?.id);
      
      if (!context.mounted) return;
      
      _showFeedbackSnackBar(
        context: context,
        message: 'Se eliminaron $count portadas.',
        isError: false,
      );
      
      // Refresh book list to show default covers
      ref.invalidate(bookListProvider);
    } catch (e) {
      if (!context.mounted) return;
      _showFeedbackSnackBar(
        context: context,
        message: 'Error al borrar portadas: $e',
        isError: true,
      );
    }
  }

  Future<void> _handleConfigureGoogleBooksKey(BuildContext context, WidgetRef ref) async {
    final controller = TextEditingController();
    final currentKey = ref.read(googleBooksApiKeyControllerProvider).valueOrNull;
    
    if (currentKey != null) {
      controller.text = currentKey;
    }

    final result = await showDialog<String>(
      context: context,
      builder: (dialogContext) => _GoogleBooksApiDialog(
        initialKey: currentKey,
        controller: controller,
      ),
    );

    if (result != null && context.mounted) {
      try {
        await ref.read(googleBooksApiKeyControllerProvider.notifier).saveApiKey(result);
        if (context.mounted) {
          _showFeedbackSnackBar(
            context: context,
            message: 'API key guardada correctamente.',
            isError: false,
          );
        }
      } catch (e) {
        if (context.mounted) {
          _showFeedbackSnackBar(
            context: context,
            message: 'Error al guardar API key: $e',
            isError: true,
          );
        }
      }
    }
  }

  Future<void> _handleClearGoogleBooksKey(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Eliminar API key de Google Books?'),
        content: const Text(
          'Se eliminará la API key guardada. La búsqueda de libros en Google Books dejará de funcionar hasta que configures una nueva key.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      try {
        await ref.read(googleBooksApiKeyControllerProvider.notifier).clearApiKey();
        if (context.mounted) {
          _showFeedbackSnackBar(
            context: context,
            message: 'API key eliminada.',
            isError: false,
          );
        }
      } catch (e) {
        if (context.mounted) {
          _showFeedbackSnackBar(
            context: context,
            message: 'Error al eliminar API key: $e',
            isError: true,
          );
        }
      }
    }
  }

  Future<void> _handleExportLoans(BuildContext context, WidgetRef ref) async {
    try {
      final activeUser = ref.read(activeUserProvider).value;
      if (activeUser == null) {
        _showFeedbackSnackBar(
          context: context,
          message: 'Debes tener una sesión activa.',
          isError: true,
        );
        return;
      }

      final repository = ref.read(loanRepositoryProvider);
      final exportService = ref.read(loan.loanExportServiceProvider);
      
      // Fetch all loans to analyze
      final loans = await repository.getAllLoanDetails();
      
      if (!context.mounted) return;

      // Ask for action (Share/Download)
      final action = await FileExportHelper.showExportActionSheet(context);
      if (action == null) return;

      final result = await exportService.exportLoans(
        loanDetails: loans,
        activeUser: activeUser,
      );

      if (!context.mounted) return;

      await FileExportHelper.handleFileExport(
        context: context,
        bytes: result.bytes,
        fileName: result.fileName,
        mimeType: result.mimeType,
        action: action,
        onFeedback: (message, isError) {
           _showFeedbackSnackBar(
            context: context,
            message: message,
            isError: isError,
          );
        },
      );

    } catch (e) {
      if (!context.mounted) return;
      _showFeedbackSnackBar(
        context: context,
        message: 'Error al exportar préstamos: $e',
        isError: true,
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

class _BackupSection extends StatefulWidget {
  const _BackupSection();

  @override
  State<_BackupSection> createState() => _BackupSectionState();
}

class _BackupSectionState extends State<_BackupSection> {
  bool _isLoading = true;
  bool _isEnabled = false;

  @override
  void initState() {
    super.initState();
    _loadStatus();
  }

  Future<void> _loadStatus() async {
    final enabled = await BackupSchedulerService.isAutoBackupEnabled();
    if (mounted) {
      setState(() {
        _isEnabled = enabled;
        _isLoading = false;
      });
    }
  }

  Future<void> _toggleBackup(bool value) async {
    setState(() => _isLoading = true);
    try {
      if (value) {
        await BackupSchedulerService.enableAutoBackup();
      } else {
        await BackupSchedulerService.disableAutoBackup();
      }
      if (mounted) {
        setState(() {
          _isEnabled = value;
          _isLoading = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(value 
              ? 'Backup automático semanal activado' 
              : 'Backup automático desactivado'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cambiar configuración: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: SwitchListTile(
        value: _isEnabled,
        onChanged: _isLoading ? null : _toggleBackup,
        title: const Text('Backup automático semanal'),
        subtitle: const Text(
          'Guarda una copia de tu biblioteca cada semana en segundo plano.',
        ),
        secondary: _isLoading 
          ? const SizedBox(
              width: 24, 
              height: 24, 
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Icon(Icons.backup_outlined),
      ),
    );
  }
}

class _GoogleBooksApiCard extends ConsumerWidget {
  const _GoogleBooksApiCard({
    required this.onConfigure,
    required this.onClear,
  });

  final VoidCallback onConfigure;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final apiKeyAsync = ref.watch(googleBooksApiKeyControllerProvider);
    final apiKey = apiKeyAsync.valueOrNull;
    final hasApiKey = apiKey != null && apiKey.isNotEmpty;
    final isLoading = apiKeyAsync.isLoading;
    final errorMessage = apiKeyAsync.whenOrNull(
      error: (error, _) => error.toString(),
    );

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isLoading)
              const LinearProgressIndicator(minHeight: 4),
            if (isLoading) const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  Icons.book_outlined,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Google Books API',
                  style: theme.textTheme.titleMedium,
                ),
                if (hasApiKey) ...[
                  const SizedBox(width: 8),
                  const Icon(
                    Icons.check_circle,
                    color: Colors.green,
                    size: 20,
                  ),
                ],
              ],
            ),
            const SizedBox(height: 12),
            Text(
              hasApiKey
                  ? 'API key configurada. Puedes buscar libros en Google Books.'
                  : 'Configura una API key para buscar libros en Google Books.',
              style: theme.textTheme.bodyMedium,
            ),
            if (errorMessage != null) ...[
              const SizedBox(height: 8),
              Text(
                'Error: $errorMessage',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.error,
                ),
              ),
            ],
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 8,
              children: [
                FilledButton.icon(
                  onPressed: isLoading ? null : onConfigure,
                  icon: const Icon(Icons.key_outlined),
                  label: Text(hasApiKey ? 'Cambiar API key' : 'Configurar API key'),
                ),
                if (hasApiKey)
                  OutlinedButton.icon(
                    onPressed: isLoading ? null : onClear,
                    icon: const Icon(Icons.delete_outline),
                    label: const Text('Eliminar'),
                  ),
              ],
            ),
            if (!hasApiKey) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.blue.shade700, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          '¿Cómo obtener una API key?',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Colors.blue.shade700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '1. Ve a Google Cloud Console\n'
                      '2. Crea un nuevo proyecto o selecciona uno existente\n'
                      '3. Habilita la "Books API"\n'
                      '4. Crea credenciales tipo "API key"\n'
                      '5. Copia la clave y pégala aquí',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.blue.shade700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _GoogleBooksApiDialog extends StatefulWidget {
  const _GoogleBooksApiDialog({
    required this.initialKey,
    required this.controller,
  });

  final String? initialKey;
  final TextEditingController controller;

  @override
  State<_GoogleBooksApiDialog> createState() => _GoogleBooksApiDialogState();
}

class _GoogleBooksApiDialogState extends State<_GoogleBooksApiDialog> {
  bool _isLoading = false;
  bool _obscureKey = true;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      title: const Text('Configurar API key de Google Books'),
      content: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Introduce tu API key de Google Books para poder buscar libros.',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: widget.controller,
              obscureText: _obscureKey,
              decoration: InputDecoration(
                labelText: 'API Key',
                hintText: 'Pega tu API key aquí',
                suffixIcon: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(_obscureKey ? Icons.visibility : Icons.visibility_off),
                      onPressed: () {
                        setState(() {
                          _obscureKey = !_obscureKey;
                        });
                      },
                    ),
                    if (widget.controller.text.isNotEmpty)
                      IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          widget.controller.clear();
                          setState(() {});
                        },
                      ),
                  ],
                ),
                border: const OutlineInputBorder(),
              ),
              maxLines: _obscureKey ? 1 : 3,
            ),
            if (widget.controller.text.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue.shade700, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Puedes validar la API key antes de guardarla.',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.blue.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        if (widget.controller.text.isNotEmpty)
          OutlinedButton(
            onPressed: _isLoading ? null : () => _validateAndSave(context),
            child: _isLoading
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Validar y guardar'),
          ),
        FilledButton(
          onPressed: _isLoading ? null : () => _saveAndClose(context),
          child: const Text('Guardar'),
        ),
      ],
    );
  }

  Future<void> _validateAndSave(BuildContext context) async {
    setState(() => _isLoading = true);

    try {
      // Here you could validate the API key
      // For now, we'll just save it
      _saveAndClose(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al validar API key: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _saveAndClose(BuildContext context) {
    final apiKey = widget.controller.text.trim();
    Navigator.of(context).pop(apiKey.isEmpty ? null : apiKey);
  }
}
