import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/sync_providers.dart';
import '../../l10n/generated/app_localizations.dart';

/// Banner that shows the sync status of groups
///
/// Displays different states:
/// - Syncing: Shows progress indicator
/// - Error: Shows error message with retry button
/// - Pending: Shows pending changes with sync button
class SyncBanner extends ConsumerWidget {
  const SyncBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final syncStateAsync = ref.watch(globalSyncStateProvider);
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    final syncState = syncStateAsync.value;
    if (syncState == null) {
      return const SizedBox.shrink();
    }

    final isSyncing = syncState.isSyncing;
    final hasError = syncState.hasErrors;
    final hasPending = syncState.pendingChangesCount > 0;

    if (!isSyncing && !hasError && !hasPending) {
      return const SizedBox.shrink();
    }

    Color background;
    Color foreground;
    IconData icon;
    String message;

    if (isSyncing) {
      background = colors.primaryContainer;
      foreground = colors.onPrimaryContainer;
      icon = Icons.sync_outlined;
      message = S.of(context).syncingLabel;
    } else if (hasError) {
      background = colors.errorContainer;
      foreground = colors.onErrorContainer;
      icon = Icons.error_outline;
      final error = syncState.lastError ?? S.of(context).defaultSyncError;
      message = error.length > 140 ? '${error.substring(0, 137)}…' : error;
    } else {
      background = colors.surfaceContainerHigh;
      foreground = colors.onSurface;
      icon = Icons.cloud_upload_outlined;
      message = S.of(context).localChangesReadySync;
    }

    late final Widget trailing;
    if (isSyncing) {
      trailing = const SizedBox(
        height: 20,
        width: 20,
        child: CircularProgressIndicator(strokeWidth: 2),
      );
    } else if (hasError) {
      trailing = Wrap(
        spacing: 8,
        runSpacing: 8,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          TextButton.icon(
            onPressed: () => unawaited(_performSync(context, ref)),
            icon: const Icon(Icons.refresh),
            label: Text(S.of(context).actionRetry),
            style: TextButton.styleFrom(foregroundColor: foreground),
          ),
          IconButton(
            onPressed: () =>
                // Dejamos que el proximo sync limpie el error,
                // no podemos limpiar el error global porque no hay un metodo claro en estado global de lectura.
                // Como alternativa, podemos ocultarlo o reintentar.
                unawaited(_performSync(context, ref)),
            icon: Icon(Icons.close, color: foreground),
            tooltip: S.of(context).actionRetry,
          ),
        ],
      );
    } else {
      trailing = Align(
        alignment: Alignment.centerRight,
        child: TextButton.icon(
          onPressed: () => unawaited(_performSync(context, ref)),
          icon: const Icon(Icons.sync_outlined),
          label: Text(S.of(context).actionSyncNow),
          style: TextButton.styleFrom(foregroundColor: foreground),
        ),
      );
    }

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 250),
      child: Material(
        key: ValueKey<String>(
          isSyncing
              ? 'sync-banner-syncing'
              : hasError
                  ? 'sync-banner-error'
                  : 'sync-banner-pending',
        ),
        color: background,
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(icon, color: foreground),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        message,
                        style: theme.textTheme.bodyMedium
                            ?.copyWith(color: foreground),
                      ),
                    ),
                    if (isSyncing) ...[
                      const SizedBox(width: 12),
                      trailing,
                    ],
                  ],
                ),
                if (!isSyncing) ...[
                  const SizedBox(height: 8),
                  trailing,
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Helper function to perform sync
Future<void> _performSync(BuildContext context, WidgetRef ref) async {
  final coordinator = ref.read(unifiedSyncCoordinatorProvider);
  await coordinator.syncNow();
}
