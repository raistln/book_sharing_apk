import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/club_enums.dart';
import '../../providers/clubs_provider.dart';
import '../../providers/book_providers.dart';

class CreateClubDialog extends ConsumerStatefulWidget {
  const CreateClubDialog({super.key});

  @override
  ConsumerState<CreateClubDialog> createState() => _CreateClubDialogState();
}

class _CreateClubDialogState extends ConsumerState<CreateClubDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _cityController = TextEditingController();
  final _meetingPlaceController = TextEditingController();
  final _frequencyDaysController = TextEditingController();

  ClubFrequency _frequency = ClubFrequency.mensual;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _cityController.dispose();
    _meetingPlaceController.dispose();
    _frequencyDaysController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final user = ref.read(activeUserProvider).value;
    if (user == null || user.remoteId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: No se encontró usuario activo')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final clubService = ref.read(clubServiceProvider);

      int? frequencyDays;
      if (_frequency == ClubFrequency.personalizada) {
        frequencyDays = int.tryParse(_frequencyDaysController.text);
      }

      await clubService.createClub(
        ownerUserId: user.id,
        ownerRemoteId: user.remoteId!,
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        city: _cityController.text.trim(),
        meetingPlace: _meetingPlaceController.text.trim().isEmpty
            ? null
            : _meetingPlaceController.text.trim(),
        frequency: _frequency,
        frequencyDays: frequencyDays,
      );

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Club creado exitosamente')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al crear club: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // If we have a user location in profile, we could pre-fill city
    // final user = ref.watch(activeUserProvider).value;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(24),
        constraints: const BoxConstraints(maxWidth: 400),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Crear Club de Lectura',
                  style: Theme.of(context).textTheme.headlineSmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Nombre del Club',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.group),
                  ),
                  validator: (value) => value == null || value.isEmpty
                      ? 'Ingresa un nombre'
                      : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Descripción',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.description),
                  ),
                  maxLines: 2,
                  validator: (value) => value == null || value.isEmpty
                      ? 'Ingresa una descripción'
                      : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _cityController,
                  decoration: const InputDecoration(
                    labelText: 'Ciudad',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.location_city),
                  ),
                  validator: (value) => value == null || value.isEmpty
                      ? 'Ingresa una ciudad'
                      : null,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<ClubFrequency>(
                  initialValue: _frequency,
                  decoration: const InputDecoration(
                    labelText: 'Frecuencia de Lectura',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.calendar_today),
                  ),
                  items: ClubFrequency.values.map((f) {
                    return DropdownMenuItem(
                      value: f,
                      child: Text(f.label),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) setState(() => _frequency = value);
                  },
                ),
                if (_frequency == ClubFrequency.personalizada) ...[
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _frequencyDaysController,
                    decoration: const InputDecoration(
                      labelText: 'Periodicidad Personalizada',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.timer),
                      helperText: 'Días asignados para leer cada sección',
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (_frequency == ClubFrequency.personalizada) {
                        if (value == null || value.isEmpty) return 'Requerido';
                        final days = int.tryParse(value);
                        if (days == null || days <= 0) return 'Inválido';
                      }
                      return null;
                    },
                  ),
                ],
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed:
                          _isLoading ? null : () => Navigator.of(context).pop(),
                      child: const Text('Cancelar'),
                    ),
                    const SizedBox(width: 16),
                    FilledButton(
                      onPressed: _isLoading ? null : _submit,
                      child: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white))
                          : const Text('Crear Club'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
