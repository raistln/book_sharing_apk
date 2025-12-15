import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../data/local/database.dart';
import '../../../providers/book_providers.dart';
import 'library_utils.dart';

/// Shows dialog to create a manual loan for a book
Future<void> showManualLoanDialog(
  BuildContext context,
  WidgetRef ref,
  Book book,
) async {
  final loanController = ref.read(loanControllerProvider.notifier);
  final theme = Theme.of(context);

  
  final nameController = TextEditingController();
  final contactController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  DateTime? selectedDueDate;
  bool noDeadline = false;

  try {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text('Préstamo manual de "${book.title}"'),
            content: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Prestar a alguien sin la app',
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Nombre del prestatario *',
                      hintText: 'Ej: Juan Pérez',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'El nombre es requerido';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: contactController,
                    decoration: const InputDecoration(
                      labelText: 'Contacto (opcional)',
                      hintText: 'Teléfono o email',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  CheckboxListTile(
                    value: noDeadline,
                    onChanged: (value) {
                      setState(() {
                        noDeadline = value ?? false;
                        if (noDeadline) {
                          selectedDueDate = null;
                        }
                      });
                    },
                    title: const Text('Sin fecha límite'),
                    subtitle: const Text('El préstamo no tendrá fecha de vencimiento'),
                    controlAffinity: ListTileControlAffinity.leading,
                  ),
                  if (!noDeadline)
                    const SizedBox(height: 12),
                  if (!noDeadline)
                    OutlinedButton.icon(
                      onPressed: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now().add(const Duration(days: 14)),
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(const Duration(days: 365)),
                        );
                        if (picked != null) {
                          setState(() => selectedDueDate = picked);
                        }
                      },
                      icon: const Icon(Icons.calendar_today),
                      label: Text(
                        selectedDueDate == null
                            ? 'Seleccionar fecha de devolución *'
                            : 'Vence: ${DateFormat.yMMMd().format(selectedDueDate!)}',
                      ),
                    ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancelar'),
              ),
              FilledButton(
                onPressed: () {
                  if (formKey.currentState?.validate() ?? false) {
                    if (!noDeadline && selectedDueDate == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Selecciona una fecha de devolución o marca "Sin fecha límite"'),
                        ),
                      );
                      return;
                    }
                    Navigator.pop(context, {
                      'name': nameController.text.trim(),
                      'contact': contactController.text.trim(),
                      'dueDate': noDeadline ? null : selectedDueDate,
                    });
                  }
                },
                child: const Text('Crear préstamo'),
              ),
            ],
          );
        },
      ),
    );

    if (result == null) return;

    // Get active user and first shared book for this book
    final activeUser = await ref.read(userRepositoryProvider).getActiveUser();
    if (activeUser == null) {
      if (!context.mounted) return;
      showFeedbackSnackBar(
        context: context,
        message: 'Necesitas un usuario activo.',
        isError: true,
      );
      return;
    }


    // Always ensure the book is shared in the "Préstamos Personales" group
    // This guarantees manual loans appear in the correct group
    final bookRepository = ref.read(bookRepositoryProvider);
    SharedBook sharedBook;
    try {
      sharedBook = await bookRepository.ensureBookIsShared(book, activeUser);
    } catch (e) {
      if (!context.mounted) return;
      showFeedbackSnackBar(
        context: context,
        message: 'Error preparando el libro: $e',
        isError: true,
      );
      return;
    }

    // Create the manual loan
    if (kDebugMode) {
      debugPrint('[MANUAL LOAN DIALOG] About to create manual loan');
    }
    
    await loanController.createManualLoan(
      sharedBook: sharedBook,
      owner: activeUser,
      borrowerName: result['name'] as String,
      borrowerContact: (result['contact'] as String).isNotEmpty
          ? result['contact'] as String
          : null,
      dueDate: result['dueDate'] as DateTime? ?? DateTime.now().add(const Duration(days: 14)),
    );

    // Invalidate book list to refresh UI chip state
    ref.invalidate(bookListProvider);

    // Changes saved locally - background sync will handle upload when ready

    if (!context.mounted) return;
    showFeedbackSnackBar(
      context: context,
      message: 'Préstamo manual creado correctamente.',
      isError: false,
    );
  } catch (err) {
    if (context.mounted) {
      showFeedbackSnackBar(
        context: context,
        message: 'Error al crear préstamo: ${err.toString()}',
        isError: true,
      );
    }
  }
}
