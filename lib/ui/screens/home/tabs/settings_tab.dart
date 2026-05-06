import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../../providers/auto_backup_providers.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../widgets/info_pop.dart';

import '../../../../l10n/generated/app_localizations.dart';
import '../../../../providers/auth_providers.dart';
import '../../../../providers/book_providers.dart';
import '../../../../providers/cover_refresh_providers.dart';
import '../../../../providers/api_providers.dart';
import '../../../../providers/settings_providers.dart';
import '../../../../providers/theme_providers.dart';
import '../../../../providers/locale_providers.dart';
import '../../../../services/backup_scheduler_service.dart';
import '../../../../utils/database_reset.dart';
import '../../../../providers/loan_providers.dart' as loan;
import '../../../../providers/sync_providers.dart';
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
  if (isError) {
    InfoPop.error(context, message);
  } else {
    InfoPop.success(context, message);
  }
}

/// Settings tab - manages app configuration, security, and integrations
class SettingsTab extends ConsumerWidget {
  const SettingsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Donation card at the top
                _buildDonationCard(context, ref),
                const SizedBox(height: 32),

                // Sección de importación de libros
                Text(
                  S.of(context).settingsLibrary,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 12),
                Text(
                  S.of(context).settingsLibraryDesc,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 16),
                Card(
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.upload_file_outlined),
                        title: Text(S.of(context).exportLibrary),
                        subtitle: Text(
                            S.of(context).exportLibraryDesc),
                        onTap: () => ExportHandler.handle(context, ref),
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.history_edu_outlined),
                        title: Text(S.of(context).exportLoanHistory),
                        subtitle: Text(
                            S.of(context).exportLoanHistoryDesc),
                        onTap: () => _handleExportLoans(context, ref),
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.import_export),
                        title: Text(S.of(context).importBooks),
                        subtitle: Text(
                            S.of(context).importBooksDesc),
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
                  S.of(context).settingsStorage,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 12),
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.broken_image_outlined),
                    title: Text(S.of(context).deleteAllCovers),
                    subtitle: Text(
                        S.of(context).deleteAllCoversDesc),
                    onTap: () => _handleDeleteCovers(context, ref),
                  ),
                ),
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.delete_sweep_outlined,
                        color: Colors.red),
                    title: Text(S.of(context).resetLocalDatabase),
                    subtitle: Text(
                        S.of(context).resetLocalDatabaseDesc,
                        style: const TextStyle(color: Colors.red)),
                    onTap: () => _handleResetDatabase(context, ref),
                  ),
                ),
                const SizedBox(height: 32),

                // Sección de Backup
                Text(
                  S.of(context).settingsBackup,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 12),
                const _BackupSection(),
                const SizedBox(height: 32),

                // Sección de seguridad
                Text(
                  S.of(context).settingsSecurity,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 12),
                Text(
                  S.of(context).settingsSecurityDesc,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 24),
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.password_outlined),
                    title: Text(S.of(context).changePin),
                    subtitle:
                        Text(S.of(context).changePinDesc),
                    onTap: () {
                      Navigator.of(context).pushNamed(PinSetupScreen.routeName);
                    },
                  ),
                ),
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.cancel_outlined),
                    title: Text(S.of(context).deletePinAndSwitchUser),
                    subtitle: Text(
                        S.of(context).deletePinAndSwitchUserDesc),
                    onTap: () async {
                      final confirmed = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title:
                              Text(S.of(context).securityResetConfirmTitle),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.warning_amber,
                                  size: 48, color: Colors.orange),
                              const SizedBox(height: 16),
                              Text(
                                S.of(context).securityResetConfirmMessage,
                              ),
                              const SizedBox(height: 16),
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.blue.shade50,
                                  borderRadius: BorderRadius.circular(8),
                                  border:
                                      Border.all(color: Colors.blue.shade200),
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.lightbulb_outline,
                                        color: Colors.blue.shade700),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        S.of(context).securityResetConfirmTip,
                                        style: const TextStyle(
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
                              child: Text(S.of(context).cancel),
                            ),
                            FilledButton(
                              onPressed: () => Navigator.of(context).pop(true),
                              style: FilledButton.styleFrom(
                                backgroundColor:
                                    Theme.of(context).colorScheme.error,
                              ),
                              child: Text(S.of(context).securityResetAction),
                            ),
                          ],
                        ),
                      );

                      if (confirmed != true) return;

                      // Clear PIN first
                      await ref
                          .read(authControllerProvider.notifier)
                          .clearPin();

                      // Clear all local data
                      final database = ref.read(appDatabaseProvider);
                      await database.clearAllData();

                      if (!context.mounted) return;

                      // Show message and close app so user can restart fresh
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                              S.of(context).securityResetSuccess),
                          duration: const Duration(seconds: 3),
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
                  S.of(context).settingsAppearance,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 12),
                const _ThemeSection(),

                const SizedBox(height: 16),
                Text(
                  S.of(context).settingsLanguage,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text(
                  S.of(context).settingsLanguageDesc,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 12),
                const _LanguageSection(),

                const SizedBox(height: 16),
                Text(
                  S.of(context).settingsExternalIntegrations,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 12),
                _GoogleBooksApiCard(
                  onConfigure: () =>
                      _handleConfigureGoogleBooksKey(context, ref),
                  onClear: () => _handleClearGoogleBooksKey(context, ref),
                ),
                const SizedBox(height: 16),
                _buildSyncActionsCard(context, ref),

                const SizedBox(height: 24),
                _PlaceholderTab(
                  title: S.of(context).settingsMoreComingSoon,
                  description:
                      S.of(context).settingsMoreComingSoonDesc,
                ),
                const SizedBox(height: 24),
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      S.of(context).settingsOpenLibraryCredit,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
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
                  S.of(context).donationTitle,
                  style: theme.textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              S.of(context).donationMessage,
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: () => _openDonationLink(context, donationUrl),
              icon: const Icon(Icons.open_in_new),
              label: Text(S.of(context).donationButton),
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
      _showFeedbackSnackBar(
        context: context,
        message: S.of(context).donationLinkInvalid,
        isError: true,
      );
      return;
    }

    try {
      final launched =
          await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!launched && context.mounted) {
        _showFeedbackSnackBar(
          context: context,
          message: S.of(context).donationLinkError,
          isError: true,
        );
      }
    } catch (e) {
      if (!context.mounted) return;
      _showFeedbackSnackBar(
        context: context,
        message: S.of(context).donationLinkOpenError(e.toString()),
        isError: true,
      );
    }
  }

  Widget _buildSyncStatusBanner(BuildContext context, WidgetRef ref) {
    final state = ref.watch(globalSyncStateProvider);
    final theme = Theme.of(context);

    final statusText = state.when(
      data: (data) => data.isSyncing
          ? S.of(context).syncingWithSupabase
          : data.lastFullSync != null
              ? S.of(context).lastSync(DateFormat.yMd().add_Hm().format(data.lastFullSync!))
              : S.of(context).notSyncedYet,
      loading: () => S.of(context).syncingWithSupabase,
      error: (error, _) => S.of(context).syncLastError,
    );

    final String? errorText = state.whenOrNull(
      data: (data) =>
          data.hasErrors ? S.of(context).syncErrorRecent : null,
      error: (error, _) => error.toString(),
    );

    final isSyncing = state.maybeWhen(
      data: (data) => data.isSyncing,
      loading: () => true,
      orElse: () => false,
    );

    final hasPendingChanges = state.maybeWhen(
      data: (data) => data.pendingChangesCount > 0,
      orElse: () => false,
    );

    final color = isSyncing
        ? theme.colorScheme.primaryContainer
        : errorText != null
            ? theme.colorScheme.errorContainer
            : theme.colorScheme.surfaceContainerHighest;

    final icon = isSyncing
        ? const Icon(Icons.sync, color: Colors.white)
        : errorText != null
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
                  S.of(context).syncStatus,
                  style: theme.textTheme.titleMedium
                      ?.copyWith(color: Colors.white),
                ),
                const SizedBox(height: 4),
                Text(
                  statusText,
                  style:
                      theme.textTheme.bodyMedium?.copyWith(color: Colors.white),
                ),
                if (errorText != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    errorText,
                    style: theme.textTheme.bodySmall
                        ?.copyWith(color: theme.colorScheme.error),
                  ),
                ],
                if (hasPendingChanges && !isSyncing) ...[
                  const SizedBox(height: 8),
                  Text(
                    S.of(context).pendingChanges,
                    style: theme.textTheme.bodySmall
                        ?.copyWith(color: Colors.white70),
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
    final isSyncing = ref.watch(isSyncingProvider);
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
                  S.of(context).manualSync,
                  style: theme.textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              S.of(context).manualSyncDesc,
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 8,
              children: [
                FilledButton.icon(
                  onPressed:
                      isSyncing ? null : () => _handleSyncGroups(context, ref),
                  icon: isSyncing
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.sync_outlined),
                  label: Text(
                      isSyncing ? S.of(context).syncing : S.of(context).syncNow),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleSyncGroups(BuildContext context, WidgetRef ref) async {
    final coordinator = ref.read(unifiedSyncCoordinatorProvider);
    try {
      await coordinator.syncNow();
      if (!context.mounted) return;

      _showFeedbackSnackBar(
        context: context,
        message: S.of(context).syncComplete,
        isError: false,
      );
    } catch (error) {
      if (!context.mounted) return;
      _showFeedbackSnackBar(
        context: context,
        message: S.of(context).syncError(error.toString()),
        isError: true,
      );
    }
  }

  Future<void> _handleResetDatabase(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(S.of(context).resetDatabaseTitle),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.warning_amber, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              S.of(context).resetDatabaseWarning,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(S.of(context).resetDatabaseItem1),
            Text(S.of(context).resetDatabaseItem2),
            Text(S.of(context).resetDatabaseItem3),
            Text(S.of(context).resetDatabaseItem4),
            const SizedBox(height: 12),
            Text(
              S.of(context).resetDatabaseCloudNote,
              style: const TextStyle(color: Colors.blue),
            ),
            const SizedBox(height: 8),
            Text(
              S.of(context).resetDatabaseRestartNote,
              style: const TextStyle(fontStyle: FontStyle.italic),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(S.of(context).cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text(S.of(context).securityResetAction),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      if (context.mounted) {
        _showFeedbackSnackBar(
          context: context,
          message: S.of(context).resettingDatabase,
          isError: false,
        );
      }

      // Delete the database file
      await DatabaseReset.forceResetDatabase();

      if (context.mounted) {
        _showFeedbackSnackBar(
          context: context,
          message: S.of(context).databaseResetSuccess,
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
          message: S.of(context).errorResettingDatabase(error.toString()),
          isError: true,
        );
      }
    }
  }

  Future<void> _handleDeleteCovers(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(S.of(context).deleteCoversTitle),
        content: Text(
          S.of(context).deleteCoversDesc,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(S.of(context).cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: Text(S.of(context).deleteAction),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    final coverService = ref.read(coverRefreshServiceProvider);
    final activeUser = ref.read(activeUserProvider).value;

    try {
      final count =
          await coverService.deleteAllCovers(ownerUserId: activeUser?.id);

      if (!context.mounted) return;

      _showFeedbackSnackBar(
        context: context,
        message: S.of(context).coversDeletedCount(count.toString()),
        isError: false,
      );

      // Refresh book list to show default covers
      ref.invalidate(bookListProvider);
    } catch (e) {
      if (!context.mounted) return;
      _showFeedbackSnackBar(
        context: context,
        message: S.of(context).errorDeletingCovers(e.toString()),
        isError: true,
      );
    }
  }

  Future<void> _handleConfigureGoogleBooksKey(
      BuildContext context, WidgetRef ref) async {
    final controller = TextEditingController();
    final currentKey =
        ref.read(googleBooksApiKeyControllerProvider).valueOrNull;

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
        await ref
            .read(googleBooksApiKeyControllerProvider.notifier)
            .saveApiKey(result);
        if (context.mounted) {
          _showFeedbackSnackBar(
            context: context,
            message: S.of(context).apiKeySavedSuccess,
            isError: false,
          );
        }
      } catch (e) {
        if (context.mounted) {
          _showFeedbackSnackBar(
            context: context,
            message: S.of(context).errorSavingApiKey(e.toString()),
            isError: true,
          );
        }
      }
    }
  }

  Future<void> _handleClearGoogleBooksKey(
      BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(S.of(context).googleBooksKeyDeleteTitle),
        content: Text(
          S.of(context).googleBooksKeyDeleteDesc,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(S.of(context).cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: Text(S.of(context).delete),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      try {
        await ref
            .read(googleBooksApiKeyControllerProvider.notifier)
            .clearApiKey();
        if (context.mounted) {
          _showFeedbackSnackBar(
            context: context,
            message: S.of(context).apiKeyDeletedSuccess,
            isError: false,
          );
        }
      } catch (e) {
        if (context.mounted) {
          _showFeedbackSnackBar(
            context: context,
            message: S.of(context).errorDeletingApiKey(e.toString()),
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
          message: S.of(context).errorActiveSessionRequired,
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
        message: S.of(context).errorExportingLoans(e.toString()),
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
                S.of(context).errorLoadingTheme,
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
                label: Text(S.of(context).retry),
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
                ThemePreference.system => S.of(context).themeSystem,
                ThemePreference.light => S.of(context).themeLight,
                ThemePreference.dark => S.of(context).themeDark,
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
            if (isLoading) const LinearProgressIndicator(minHeight: 4),
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
                  ? S.of(context).googleBooksKeyConfigured
                  : S.of(context).googleBooksKeyNotConfigured,
              style: theme.textTheme.bodyMedium,
            ),
            if (errorMessage != null) ...[
              const SizedBox(height: 8),
              Text(
                S.of(context).errorGeneric(errorMessage),
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
                  label: Text(
                      hasApiKey ? S.of(context).changeApiKey : S.of(context).configApiKey),
                ),
                if (hasApiKey)
                  OutlinedButton.icon(
                    onPressed: isLoading ? null : onClear,
                    icon: const Icon(Icons.delete_outline),
                    label: Text(S.of(context).delete),
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
                        Icon(Icons.info_outline,
                            color: Colors.blue.shade700, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          S.of(context).googleBooksKeyHelpTitle,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Colors.blue.shade700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      S.of(context).googleBooksKeyHelpSteps,
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
      title: Text(S.of(context).googleBooksKeyDialogTitle),
      content: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              S.of(context).googleBooksKeyDialogDesc,
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: widget.controller,
              obscureText: _obscureKey,
              decoration: InputDecoration(
                labelText: 'API Key',
                hintText: S.of(context).googleBooksKeyHint,
                suffixIcon: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(_obscureKey
                          ? Icons.visibility
                          : Icons.visibility_off),
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
                    Icon(Icons.info_outline,
                        color: Colors.blue.shade700, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        S.of(context).googleBooksKeyValidationTip,
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
          child: Text(S.of(context).cancel),
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
                : Text(S.of(context).validateAndSave),
          ),
        FilledButton(
          onPressed: _isLoading ? null : () => _saveAndClose(context),
          child: Text(S.of(context).save),
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
            content: Text(S.of(context).errorValidatingApiKey(e.toString())),
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
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
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

  Future<bool> _requestStoragePermission() async {
    if (!Platform.isAndroid) return true;

    // Check for Android 11+ (API 30+)
    final androidInfo = await DeviceInfoPlugin().androidInfo;
    if (androidInfo.version.sdkInt >= 30) {
      if (await Permission.manageExternalStorage.isGranted) {
        return true;
      }

      if (mounted) {
        await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(S.of(context).permissionRequired),
            content: Text(
                S.of(context).backupPermissionDesc),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(S.of(context).cancel),
              ),
              FilledButton(
                onPressed: () {
                  Navigator.pop(context);
                  Permission.manageExternalStorage.request();
                },
                child: Text(S.of(context).continueLabel),
              ),
            ],
          ),
        );
      }

      return await Permission.manageExternalStorage.status.isGranted;
    }

    // Older Android versions
    var status = await Permission.storage.status;
    if (status.isGranted) {
      return true;
    }

    status = await Permission.storage.request();
    return status.isGranted;
  }

  Future<void> _toggleBackup(bool value) async {
    if (value) {
      final hasPermission = await _requestStoragePermission();
      if (!hasPermission) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(S.of(context).errorStoragePermissionRequired),
            ),
          );
        }
        return;
      }
    }

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
                ? S.of(context).autoBackupEnabled
                : S.of(context).autoBackupDisabled),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(S.of(context).errorChangingBackupConfig(e.toString())),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  Future<void> _manualBackup(WidgetRef ref) async {
    final hasPermission = await _requestStoragePermission();
    if (!hasPermission) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'Se requiere permiso de almacenamiento para guardar el backup.'),
          ),
        );
      }
      return;
    }

    try {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Creando copia de seguridad...')),
        );
      }

      // Use provider to get service instance
      final backupService = ref.read(autoBackupServiceProvider);
      final activeUser = ref.read(activeUserProvider).value;

      final path =
          await backupService.performBackup(ownerUserId: activeUser?.id);

      if (!mounted) return;

      if (path != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(S.of(context).backupSavedAt(path)),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 4),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text(S.of(context).errorCreatingBackup),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(S.of(context).errorCreatingBackupDetail(e.toString())),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  Future<void> _restoreLatestAutoBackup(WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(S.of(context).restoreLatestBackupTitle),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('⚠️ ${S.of(context).warningLabel}:', style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(
                S.of(context).restoreBackupWarning),
            const SizedBox(height: 8),
            Text(S.of(context).appRestartNote),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(S.of(context).cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: Text(S.of(context).restore),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(S.of(context).searchingBackups)),
        );
      }

      final backupService = ref.read(autoBackupServiceProvider);
      final backups = await backupService.getAvailableBackups();

      if (backups.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(S.of(context).noBackupsFound)),
          );
        }
        return;
      }

      final latestBackup = backups.first;

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text(S.of(context).restoringBackup(latestBackup.path.split('/').last))),
        );
      }

      await backupService.restoreFromZip(latestBackup);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(S.of(context).restoreComplete)),
        );
        // Wait a bit and restart
        await Future.delayed(const Duration(seconds: 2));
        SystemNavigator.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(S.of(context).errorRestoringBackup(e.toString())),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  Future<void> _restoreManualBackup(WidgetRef ref) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['zip'],
        initialDirectory:
            '/storage/emulated/0/Download', // Try to open in Downloads
      );

      if (result != null && result.files.single.path != null) {
        if (!mounted) return;

        final file = File(result.files.single.path!);

        final confirmed = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(S.of(context).restoreSpecificBackupTitle),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(S.of(context).backupFileLabel(file.path.split('/').last)),
                const SizedBox(height: 16),
                Text(
                    S.of(context).restoreBackupWarning),
                const SizedBox(height: 8),
                Text(S.of(context).appRestartNote),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(S.of(context).cancel),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context, true),
                style: FilledButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.error,
                ),
                child: Text(S.of(context).restore),
              ),
            ],
          ),
        );

        if (confirmed != true) return;

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(S.of(context).restoringBackup(''))),
          );
        }

        final backupService = ref.read(autoBackupServiceProvider);
        await backupService.restoreFromZip(file);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Restauración completada. Reiniciando...')),
          );
          await Future.delayed(const Duration(seconds: 2));
          SystemNavigator.pop();
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al seleccionar backup: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Need Consumer to access providers inside this widget
    return Consumer(builder: (context, ref, child) {
      return Card(
        child: Column(
          children: [
            SwitchListTile(
              value: _isEnabled,
              onChanged: _isLoading ? null : _toggleBackup,
              title: const Text('Backup automático semanal'),
              subtitle: const Text(
                'Guarda una copia completa (base de datos y portadas) cada semana.',
              ),
              secondary: _isLoading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.backup_outlined),
            ),
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.save_alt),
              title: const Text('Hacer backup ahora'),
              subtitle:
                  const Text('Crea manualmnete una copia ZIP en Descargas'),
              onTap: _isLoading ? null : () => _manualBackup(ref),
            ),
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.restore),
              title: const Text('Importar backup automático'),
              subtitle: const Text(
                  'Restaurar desde la copia automática más reciente'),
              onTap: _isLoading ? null : () => _restoreLatestAutoBackup(ref),
            ),
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.folder_open),
              title: const Text('Cargar backup manual'),
              subtitle: const Text('Buscar archivo ZIP en el dispositivo'),
              onTap: _isLoading ? null : () => _restoreManualBackup(ref),
            ),
          ],
        ),
      );
    });
  }
}

class _LanguageSection extends ConsumerWidget {
  const _LanguageSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localePrefAsync = ref.watch(localeSettingsProvider);

    return localePrefAsync.when(
      data: (preference) {
        return SegmentedButton<LocalePreference>(
          segments: [
            ButtonSegment<LocalePreference>(
              value: LocalePreference.system,
              label: Text(S.of(context).languageSystem),
            ),
            ButtonSegment<LocalePreference>(
              value: LocalePreference.spanish,
              label: Text(S.of(context).languageSpanish),
            ),
            ButtonSegment<LocalePreference>(
              value: LocalePreference.english,
              label: Text(S.of(context).languageEnglish),
            ),
          ],
          selected: {preference},
          onSelectionChanged: (Set<LocalePreference> newSelection) {
            ref
                .read(localeSettingsProvider.notifier)
                .update(newSelection.first);
          },
        );
      },
      loading: () => const CircularProgressIndicator(),
      error: (error, _) => Text(S.of(context).errorGeneric(error.toString())),
    );
  }
}
