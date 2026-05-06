import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/local/database.dart';
import '../../../models/club_enums.dart';
import '../../../providers/clubs_provider.dart';
import '../../../l10n/generated/app_localizations.dart';

class ClubSettingsPage extends ConsumerStatefulWidget {
  const ClubSettingsPage({super.key, required this.club});

  final ReadingClub club;

  @override
  ConsumerState<ClubSettingsPage> createState() => _ClubSettingsPageState();
}

class _ClubSettingsPageState extends ConsumerState<ClubSettingsPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _meetingPlaceController;
  late TextEditingController _frequencyDaysController;
  late ClubFrequency _frequency;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.club.name);
    _descriptionController =
        TextEditingController(text: widget.club.description);
    _meetingPlaceController =
        TextEditingController(text: widget.club.meetingPlace);
    _frequency = ClubFrequency.fromString(widget.club.frequency);
    _frequencyDaysController = TextEditingController(
        text: widget.club.frequencyDays?.toString() ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _meetingPlaceController.dispose();
    _frequencyDaysController.dispose();
    super.dispose();
  }

  Future<void> _saveSettings() async {
    final l10n = S.of(context);
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final clubService = ref.read(clubServiceProvider);
      await clubService.updateClubSettings(
        clubUuid: widget.club.uuid,
        name: _nameController.text,
        description: _descriptionController.text,
        meetingPlace: _meetingPlaceController.text,
        frequency: _frequency,
        frequencyDays: _frequency == ClubFrequency.personalizada
            ? int.tryParse(_frequencyDaysController.text)
            : null,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.clubSettingsSaved)),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al guardar: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = S.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.clubSettingsTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _isLoading ? null : _saveSettings,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: l10n.clubSettingsName,
                        border: const OutlineInputBorder(),
                      ),
                      validator: (value) =>
                          value?.isEmpty == true ? 'Requerido' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _descriptionController,
                      decoration: InputDecoration(
                        labelText: l10n.clubSettingsDescription,
                        border: const OutlineInputBorder(),
                      ),
                      maxLines: 3,
                      validator: (value) =>
                          value?.isEmpty == true ? 'Requerido' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _meetingPlaceController,
                      decoration: InputDecoration(
                        labelText: l10n.clubSettingsCity,
                        border: const OutlineInputBorder(),
                        helperText: 'Opcional', // TODO: Consider adding l10n for Opcional
                      ),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<ClubFrequency>(
                      initialValue: _frequency,
                      decoration: InputDecoration(
                        labelText: l10n.clubSettingsFrequency,
                        border: const OutlineInputBorder(),
                      ),
                      items: ClubFrequency.values.map((freq) {
                        return DropdownMenuItem(
                          value: freq,
                          child: Text(freq.label),
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
                        decoration: InputDecoration(
                          labelText: l10n.clubSettingsCustomFrequency,
                          border: const OutlineInputBorder(),
                          prefixIcon: const Icon(Icons.timer),
                          helperText: l10n.clubSettingsCustomFrequencyDays,
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (_frequency == ClubFrequency.personalizada) {
                            if (value == null || value.isEmpty) {
                              return 'Requerido';
                            }
                            final days = int.tryParse(value);
                            if (days == null || days <= 0) return 'Inválido';
                          }
                          return null;
                        },
                      ),
                    ],
                    const SizedBox(height: 32),
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.red),
                        foregroundColor: Colors.red,
                      ),
                      icon: const Icon(Icons.delete_forever),
                      label: Text(l10n.clubSettingsDeleteButton),
                      onPressed: _confirmDelete,
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Future<void> _confirmDelete() async {
    final l10n = S.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.clubSettingsDeleteTitle),
        content: Text(l10n.clubSettingsDeleteMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(l10n.actionDelete),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      _deleteClub();
    }
  }

  Future<void> _deleteClub() async {
    final l10n = S.of(context);
    setState(() => _isLoading = true);
    try {
      await ref.read(clubServiceProvider).deleteClub(widget.club.uuid);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.clubSettingsDeleteSuccess)),
        );
        // Pop settings and detail page, returning to list
        Navigator.of(context).pop(); // Settings
        Navigator.of(context).pop(); // Detail
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al eliminar: $e')),
        );
        setState(() => _isLoading = false);
      }
    }
  }
}
