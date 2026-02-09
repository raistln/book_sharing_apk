import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/club_enums.dart';
import '../../../providers/clubs_provider.dart';
import '../../../providers/book_providers.dart';

class UpdateReadingProgressDialog extends ConsumerStatefulWidget {
  const UpdateReadingProgressDialog({
    super.key,
    required this.clubUuid,
    required this.bookUuid,
    required this.totalSections,
    this.initialSection = 1,
    this.initialStatus = ReadingProgressStatus.noEmpezado,
  });

  final String clubUuid;
  final String bookUuid;
  final int totalSections;
  final int initialSection;
  final ReadingProgressStatus initialStatus;

  @override
  ConsumerState<UpdateReadingProgressDialog> createState() =>
      _UpdateReadingProgressDialogState();
}

class _UpdateReadingProgressDialogState
    extends ConsumerState<UpdateReadingProgressDialog> {
  late int _currentSection;
  late ReadingProgressStatus _status;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _currentSection = widget.initialSection;
    _status = widget.initialStatus;
  }

  Future<void> _save() async {
    final activeUser = ref.read(activeUserProvider).value;
    if (activeUser?.remoteId == null) return;

    setState(() => _isLoading = true);

    try {
      await ref.read(clubServiceProvider).updateProgress(
            clubUuid: widget.clubUuid,
            bookUuid: widget.bookUuid,
            userUuid: activeUser!.remoteId!,
            status: _status,
            currentSection: _currentSection,
          );

      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Actualizar Progreso'),
      content: _isLoading
          ? const SizedBox(
              height: 100,
              child: Center(child: CircularProgressIndicator()),
            )
          : Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text('¿Por qué sección vas?'),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: Slider(
                        value: _currentSection.toDouble(),
                        min: 1,
                        max: widget.totalSections.toDouble(),
                        divisions: widget.totalSections > 1
                            ? widget.totalSections - 1
                            : 1,
                        label: _currentSection.toString(),
                        onChanged: (value) {
                          setState(() => _currentSection = value.round());
                        },
                      ),
                    ),
                    Text(
                      '$_currentSection / ${widget.totalSections}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Text('Estado de lectura'),
                const SizedBox(height: 8),
                DropdownButtonFormField<ReadingProgressStatus>(
                  initialValue: _status,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  items: ReadingProgressStatus.values.map((s) {
                    return DropdownMenuItem(
                      value: s,
                      child: Text(s.label),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) setState(() => _status = value);
                  },
                ),
              ],
            ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: _isLoading ? null : _save,
          child: const Text('Guardar'),
        ),
      ],
    );
  }
}
