import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../providers/book_providers.dart';
import '../../../../utils/group_utils.dart';
import '../../../widgets/empty_state.dart';
import 'discover_group_page.dart';

/// Helper to perform sync
Future<void> _performSync(BuildContext context, WidgetRef ref) async {
  final controller = ref.read(groupSyncControllerProvider.notifier);
  await controller.syncGroups();
  if (!context.mounted) return;

  final state = ref.read(groupSyncControllerProvider);
  if (state.lastError != null) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error: ${state.lastError}')),
    );
  } else {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Sincronización completada')),
    );
  }
}

/// Discovery tab - shows groups and allows browsing shared books
///
/// Displays a list of groups the user belongs to. Tapping a group
/// navigates to DiscoverGroupPage to browse shared books.
class DiscoverTab extends ConsumerWidget {
  const DiscoverTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groupsAsync = ref.watch(groupListProvider);
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Descubrir', style: theme.textTheme.headlineMedium),
          const SizedBox(height: 8),
          Text(
            'Explora los grupos a los que perteneces y descubre libros disponibles para solicitar préstamo.',
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),
          Expanded(
            child: groupsAsync.when(
              data: (groups) {
                // Filter out personal loans group from discovery
                final discoverableGroups = groups
                    .where((group) => !isPersonalLoansGroup(group.name))
                    .toList();

                if (discoverableGroups.isEmpty) {
                  return EmptyState(
                    icon: Icons.groups_outlined,
                    title: 'Aún no perteneces a ningún grupo',
                    message:
                        'Crea un grupo o únete con un código para empezar a compartir libros y gestionar préstamos.',
                    action: EmptyStateAction(
                      label: 'Unirme o sincronizar',
                      icon: Icons.sync_outlined,
                      variant: EmptyStateActionVariant.text,
                      onPressed: () => unawaited(_syncNow(context, ref)),
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async => _syncNow(context, ref),
                  child: ListView.separated(
                    itemCount: discoverableGroups.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final group = discoverableGroups[index];
                      final subtitle = group.description?.trim();
                      return Card(
                        child: ListTile(
                          leading: const Icon(Icons.groups_2_outlined),
                          title: Text(group.name),
                          subtitle: subtitle != null && subtitle.isNotEmpty
                              ? Text(subtitle)
                              : null,
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => DiscoverGroupPage(group: group),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline, size: 48),
                    const SizedBox(height: 12),
                    Text(
                      'No pudimos cargar tus grupos.',
                      style: theme.textTheme.titleMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '$error',
                      style: theme.textTheme.bodySmall,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    FilledButton.icon(
                      onPressed: () => _syncNow(context, ref),
                      icon: const Icon(Icons.refresh),
                      label: const Text('Reintentar'),
                    ),
                  ],
                ),
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
