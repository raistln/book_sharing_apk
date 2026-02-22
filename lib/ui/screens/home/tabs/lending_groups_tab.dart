import 'dart:async';

import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../data/local/database.dart';
import '../../../../models/book_genre.dart';
import '../../../../providers/book_providers.dart';
import '../../../../services/group_push_controller.dart';
import '../../../../services/loan_controller.dart';
import '../../../widgets/empty_state.dart';
import '../../../widgets/community/group_card.dart';
import '../../../dialogs/group_form_dialog.dart';
import '../../../widgets/info_pop.dart';

class LendingGroupsTab extends ConsumerWidget {
  const LendingGroupsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groupsAsync = ref.watch(groupListProvider);
    // final loanActionState = ref.watch(loanControllerProvider); // No utilizado actualmente
    final groupActionState = ref.watch(groupPushControllerProvider);
    final activeUser = ref.watch(activeUserProvider).value;
    final isGroupBusy = groupActionState.isLoading;

    return Column(
      children: [
        // Listen for group action feedback
        Consumer(builder: (context, ref, child) {
          ref.listen<GroupActionState>(groupPushControllerProvider,
              (previous, next) {
            if (next.lastError != null &&
                next.lastError != previous?.lastError) {
              InfoPop.error(context, next.lastError!);
            } else if (next.lastSuccess != null &&
                next.lastSuccess != previous?.lastSuccess) {
              InfoPop.success(context, next.lastSuccess!);
            }
          });
          ref.listen<LoanActionState>(loanControllerProvider, (previous, next) {
            if (next.lastError != null &&
                next.lastError != previous?.lastError) {
              InfoPop.error(context, next.lastError!);
            } else if (next.lastSuccess != null &&
                next.lastSuccess != previous?.lastSuccess) {
              InfoPop.success(context, next.lastSuccess!);
            }
          });
          return const SizedBox.shrink();
        }),
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
        if (isGroupBusy) const LinearProgressIndicator(),
        Expanded(
          child: groupsAsync.when(
            data: (groups) {
              if (groups.isEmpty) {
                return _EmptyCommunityState(
                    onSync: () => _syncNow(context, ref));
              }

              return RefreshIndicator(
                onRefresh: () async => _syncNow(context, ref),
                child: ListView.separated(
                  padding: const EdgeInsets.all(24),
                  itemCount: groups.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final group = groups[index];
                    return GroupCard(
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
    return EmptyState(
      icon: Icons.groups_outlined,
      title: 'Sincroniza tus grupos',
      message:
          'Conecta con Supabase para traer tus comunidades, miembros y libros compartidos.',
      action: EmptyStateAction(
        label: 'Sincronizar ahora',
        icon: Icons.sync_outlined,
        onPressed: () => unawaited(onSync()),
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
              style: theme.textTheme.titleLarge
                  ?.copyWith(color: theme.colorScheme.error),
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
      allowedGenres: result.allowedGenres != null
          ? _decodeGenreList(result.allowedGenres!)
          : null,
      primaryColor: result.primaryColor,
    );
  } catch (error) {
    if (!context.mounted) {
      return;
    }
    _showFeedbackSnackBar(
      context: context,
      message: 'No se pudo crear el grupo: $error',
      isError: true,
    );
  }
}

/// Decode JSON genre list from a string like '["fantasy","horror"]'.
List<String> _decodeGenreList(String json) {
  try {
    final trimmed = json.trim();
    if (!trimmed.startsWith('[')) return [];
    final inner = trimmed.substring(1, trimmed.length - 1);
    return inner
        .split(',')
        .map((s) => s.trim().replaceAll('"', '').replaceAll("'", ''))
        .where((s) => s.isNotEmpty)
        .toList();
  } catch (_) {
    return [];
  }
}

Future<void> _handleJoinGroupByCode(
  BuildContext context,
  WidgetRef ref,
  LocalUser user,
) async {
  await _showJoinGroupByCodeDialog(
    context,
    (code) async {
      final controller = ref.read(groupPushControllerProvider.notifier);
      await controller.acceptInvitationByCode(
        code: code,
        user: user,
      );

      // After joining, look up the newly joined group from the local list
      // to show a thematic filter warning if applicable.
      if (!context.mounted) return;
      final groups = ref.read(groupListProvider).value ?? [];
      // The most recently updated group is likely the one we just joined
      final joinedGroup = groups.isNotEmpty ? groups.last : null;
      final genres = BookGenre.allowedFromJson(joinedGroup?.allowedGenres);
      if (genres.isNotEmpty && context.mounted) {
        final genreNames = genres.map((g) => g.label).join(', ');
        await showDialog<void>(
          context: context,
          builder: (_) => AlertDialog(
            icon: const Icon(Icons.local_library_outlined),
            title: const Text('Grupo temático'),
            content: Text(
              'Este grupo tiene un filtro activo de géneros: $genreNames.\n\n'
              'Solo los libros físicos de esos géneros serán visibles en este grupo.',
            ),
            actions: [
              FilledButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Entendido'),
              ),
            ],
          ),
        );
      }
    },
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
  if (isError) {
    InfoPop.error(context, message);
  } else {
    InfoPop.success(context, message);
  }
}

Future<GroupFormResult?> _showGroupFormDialog(BuildContext context) {
  return showDialog<GroupFormResult>(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) => const GroupFormDialog(),
  );
}

Future<void> _showJoinGroupByCodeDialog(
  BuildContext context,
  Future<void> Function(String code) onJoin,
) {
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (_) => _JoinGroupByCodeDialog(onJoin: onJoin),
  );
}

class _JoinGroupByCodeDialog extends StatefulWidget {
  const _JoinGroupByCodeDialog({required this.onJoin});

  final Future<void> Function(String code) onJoin;

  @override
  State<_JoinGroupByCodeDialog> createState() => _JoinGroupByCodeDialogState();
}

class _JoinGroupByCodeDialogState extends State<_JoinGroupByCodeDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _codeController;
  bool _isSubmitting = false;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _codeController = TextEditingController();
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Unirse a grupo'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _codeController,
              decoration: InputDecoration(
                labelText: 'Código de grupo',
                border: const OutlineInputBorder(),
                errorText: _errorText,
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Por favor ingresa un código de grupo';
                }
                return null;
              },
              autofocus: true,
              textInputAction: TextInputAction.done,
              onFieldSubmitted: _isSubmitting ? null : (_) => _handleSubmit(),
              onChanged: (_) {
                if (_errorText != null) {
                  setState(() => _errorText = null);
                }
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: _isSubmitting ? null : _handleSubmit,
          child: _isSubmitting
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Unirse'),
        ),
      ],
    );
  }

  Future<void> _handleSubmit() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorText = null;
    });

    try {
      final code = _codeController.text.trim();
      await widget.onJoin(code);
      if (mounted) {
        Navigator.of(context).pop();
        InfoPop.success(context, '¡Te has unido al grupo exitosamente!');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
          _errorText =
              'El código no es válido o ya expiró. Verifícalo e intenta de nuevo.';
        });
      }
    }
  }
}
