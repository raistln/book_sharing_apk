import 'dart:async';

import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../data/local/database.dart';
import '../../../../providers/book_providers.dart';
import '../../../widgets/empty_state.dart';
import '../../../widgets/loan_feedback_banner.dart';
import '../../../widgets/community/group_card.dart';
import '../../../dialogs/group_form_dialog.dart';

class CommunityTab extends ConsumerWidget {
  const CommunityTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groupsAsync = ref.watch(groupListProvider);
    final loanActionState = ref.watch(loanControllerProvider);
    final groupActionState = ref.watch(groupPushControllerProvider);
    final activeUser = ref.watch(activeUserProvider).value;
    final isGroupBusy = groupActionState.isLoading;

    return SafeArea(
      child: Column(
        children: [
          if (groupActionState.lastError != null)
            LoanFeedbackBanner(
              message: groupActionState.lastError!,
              isError: true,
              onDismiss: () => ref.read(groupPushControllerProvider.notifier).dismissError(),
            )
          else if (groupActionState.lastSuccess != null)
            LoanFeedbackBanner(
              message: groupActionState.lastSuccess!,
              isError: false,
              onDismiss: () => ref.read(groupPushControllerProvider.notifier).dismissSuccess(),
            ),
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
          if (loanActionState.lastError != null)
            LoanFeedbackBanner(
              message: loanActionState.lastError!,
              isError: true,
              onDismiss: () => ref.read(loanControllerProvider.notifier).dismissError(),
            )
          else if (loanActionState.lastSuccess != null)
            LoanFeedbackBanner(
              message: loanActionState.lastSuccess!,
              isError: false,
              onDismiss: () =>
                  ref.read(loanControllerProvider.notifier).dismissSuccess(),
            ),
          Expanded(
            child: groupsAsync.when(
              data: (groups) {
                if (groups.isEmpty) {
                  return _EmptyCommunityState(onSync: () => _syncNow(context, ref));
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
      ),
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
              style: theme.textTheme.titleLarge?.copyWith(color: theme.colorScheme.error),
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

Future<void> _handleJoinGroupByCode(
  BuildContext context,
  WidgetRef ref,
  LocalUser user,
) async {
  final code = await _showJoinGroupByCodeDialog(context);
  if (code == null) {
    return;
  }

  final controller = ref.read(groupPushControllerProvider.notifier);
  try {
    await controller.acceptInvitationByCode(
      code: code,
      user: user,
    );
  } catch (error) {
    if (!context.mounted) {
      return;
    }
    _showFeedbackSnackBar(
      context: context,
      message: error.toString(),
      isError: true,
    );
  }
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
  final theme = Theme.of(context);
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: isError ? theme.colorScheme.error : theme.colorScheme.primary,
    ),
  );
}

Future<GroupFormResult?> _showGroupFormDialog(BuildContext context) {
  return showDialog<GroupFormResult>(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) => const GroupFormDialog(),
  );
}

Future<String?> _showJoinGroupByCodeDialog(BuildContext context) {
  return showDialog<String>(
    context: context,
    barrierDismissible: false,
    builder: (_) => const _JoinGroupByCodeDialog(),
  );
}

class _JoinGroupByCodeDialog extends StatefulWidget {
  const _JoinGroupByCodeDialog();

  @override
  State<_JoinGroupByCodeDialog> createState() => _JoinGroupByCodeDialogState();
}

class _JoinGroupByCodeDialogState extends State<_JoinGroupByCodeDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _codeController;
  bool _isSubmitting = false;

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
              decoration: const InputDecoration(
                labelText: 'Código de grupo',
                border: OutlineInputBorder(),
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

  void _handleSubmit() {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    setState(() => _isSubmitting = true);
    final code = _codeController.text.trim();
    
    Navigator.of(context).pop(code);
  }
}
