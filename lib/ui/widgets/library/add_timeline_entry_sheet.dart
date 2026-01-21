import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/local/database.dart';
import '../../../providers/book_providers.dart';

/// Bottom sheet for adding or editing timeline entries
class AddTimelineEntrySheet extends ConsumerStatefulWidget {
  const AddTimelineEntrySheet({
    super.key,
    required this.book,
    required this.userId,
    this.existingEntry,
  });

  final Book book;
  final int userId;
  final ReadingTimelineEntry? existingEntry;

  @override
  ConsumerState<AddTimelineEntrySheet> createState() =>
      _AddTimelineEntrySheetState();
}

class _AddTimelineEntrySheetState extends ConsumerState<AddTimelineEntrySheet> {
  late final TextEditingController _pageController;
  late final TextEditingController _noteController;
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _pageController = TextEditingController(
      text: widget.existingEntry?.currentPage?.toString() ?? '',
    );
    _noteController = TextEditingController(
      text: widget.existingEntry?.note ?? '',
    );
    _selectedDate = widget.existingEntry?.eventDate ?? DateTime.now();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEditing = widget.existingEntry != null;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Icon(
                  Icons.timeline_outlined,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 12),
                Text(
                  isEditing ? 'Editar progreso' : 'Añadir progreso',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Date picker
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.calendar_today_outlined),
              title: const Text('Fecha'),
              subtitle: Text(
                _formatDate(_selectedDate),
                style: theme.textTheme.bodyLarge,
              ),
              onTap: () => _selectDate(context),
            ),
            const SizedBox(height: 16),
            // Page number
            TextField(
              controller: _pageController,
              decoration: InputDecoration(
                labelText: 'Página actual (opcional)',
                hintText: widget.book.pageCount != null
                    ? 'De ${widget.book.pageCount} páginas'
                    : 'Número de página',
                prefixIcon: const Icon(Icons.bookmark_outline),
                border: const OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            // Note
            TextField(
              controller: _noteController,
              decoration: const InputDecoration(
                labelText: 'Nota personal (opcional)',
                hintText: 'Tus impresiones, pensamientos...',
                prefixIcon: Icon(Icons.edit_note_outlined),
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 24),
            // Save button
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _save,
                icon: const Icon(Icons.check),
                label: Text(isEditing ? 'Guardar cambios' : 'Añadir'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dateToCheck = DateTime(date.year, date.month, date.day);

    if (dateToCheck == today) {
      return 'Hoy, ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } else if (dateToCheck == today.subtract(const Duration(days: 1))) {
      return 'Ayer, ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } else {
      return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (date != null && context.mounted) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_selectedDate),
      );

      if (time != null) {
        setState(() {
          _selectedDate = DateTime(
            date.year,
            date.month,
            date.day,
            time.hour,
            time.minute,
          );
        });
      }
    }
  }

  Future<void> _save() async {
    final pageText = _pageController.text.trim();
    final note = _noteController.text.trim();

    int? currentPage;
    if (pageText.isNotEmpty) {
      currentPage = int.tryParse(pageText);
      if (currentPage == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Por favor, introduce un número de página válido'),
          ),
        );
        return;
      }
    }

    try {
      final timelineService = ref.read(readingTimelineServiceProvider);
      final dao = ref.read(timelineEntryDaoProvider);

      if (widget.existingEntry != null) {
        // Update existing entry
        await dao.updateEntry(
          entryId: widget.existingEntry!.id,
          currentPage: currentPage,
          note: note.isEmpty ? null : note,
          eventDate: _selectedDate,
        );
      } else {
        // Create new entry
        await timelineService.addProgressUpdate(
          book: widget.book,
          userId: widget.userId,
          currentPage: currentPage,
          note: note.isEmpty ? null : note,
          eventDate: _selectedDate,
        );
      }

      // Refresh data
      ref.invalidate(readingTimelineProvider(widget.book.id));
      ref.invalidate(readingInsightProvider(widget.book.id));

      if (!mounted) return;
      Navigator.of(context).pop();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.existingEntry != null
                ? 'Progreso actualizado'
                : 'Progreso añadido',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $error'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }
}
