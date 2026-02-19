import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/clubs_provider.dart';
import '../../../providers/book_providers.dart';
import '../../dialogs/create_club_dialog.dart';
import 'club_detail_page.dart';

class ClubsListPage extends ConsumerWidget {
  const ClubsListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final clubsAsync = ref.watch(userClubsProvider);

    return clubsAsync.when(
      data: (clubs) {
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => const CreateClubDialog(),
                        );
                      },
                      icon: const Icon(Icons.add),
                      label: const Text('Crear Grupo'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _handleJoinClubByCode(context, ref),
                      icon: const Icon(Icons.qr_code_2_outlined),
                      label: const Text('Unirse por código'),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: clubs.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.menu_book, size: 64, color: Colors.grey),
                          SizedBox(height: 16),
                          Text('Aún no tienes clubes de lectura'),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: clubs.length,
                      itemBuilder: (context, index) {
                        final club = clubs[index];
                        return Card(
                          child: ListTile(
                            title: Text(club.name),
                            subtitle: Text('${club.frequency} • ${club.city}'),
                            trailing: const Icon(Icons.chevron_right),
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) =>
                                      ClubDetailPage(club: club),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
            ),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, s) => Center(child: Text('Error: $e')),
    );
  }

  Future<void> _handleJoinClubByCode(
      BuildContext context, WidgetRef ref) async {
    final user = ref.read(activeUserProvider).value;
    if (user == null || user.remoteId == null) return;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => _JoinClubByCodeDialog(
        onJoin: (code) async {
          final clubService = ref.read(clubServiceProvider);
          await clubService.joinClubByUuid(
            clubUuid: code,
            userId: user.id,
            userRemoteId: user.remoteId!,
          );
        },
      ),
    );
  }
}

class _JoinClubByCodeDialog extends StatefulWidget {
  const _JoinClubByCodeDialog({required this.onJoin});

  final Future<void> Function(String code) onJoin;

  @override
  State<_JoinClubByCodeDialog> createState() => _JoinClubByCodeDialogState();
}

class _JoinClubByCodeDialogState extends State<_JoinClubByCodeDialog> {
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
      title: const Text('Unirse a Club'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _codeController,
              decoration: InputDecoration(
                labelText: 'ID del Club',
                border: const OutlineInputBorder(),
                errorText: _errorText,
                helperText: 'Ingresa el código UUID del club',
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Por favor ingresa un código';
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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('¡Te has unido al club!')),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
          _errorText = e.toString().contains('Exception:')
              ? e.toString().split('Exception:').last.trim()
              : 'Código no válido o ya eres miembro.';
        });
      }
    }
  }
}
