import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../../../data/local/database.dart';
import '../../../providers/book_providers.dart';
import 'library_utils.dart';

/// Shows dialog to create a manual loan for a book
Future<void> showManualLoanDialog(
  BuildContext context,
  WidgetRef ref,
  Book book,
) async {
  final loanRepository = ref.read(loanRepositoryProvider);
  final groupDao = ref.read(groupDaoProvider);
  final theme = Theme.of(context);
  // ignore: prefer_const_constructors
  final uuid = Uuid();
  
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

    // Find a shared book for this book (or create one if needed)
    final sharedBooks = await groupDao.findSharedBooksByBookId(book.id);
    SharedBook? sharedBook;
    
    if (sharedBooks.isNotEmpty) {
      sharedBook = sharedBooks.first;
    } else {
      // Need to create a shared book first - get user's groups
      final groups = await groupDao.getGroupsForUser(activeUser.id);
      if (groups.isEmpty) {
        if (!context.mounted) return;
        showFeedbackSnackBar(
          context: context,
          message: 'Necesitas estar en un grupo para crear préstamos.',
          isError: true,
        );
        return;
      }
      
      // Create shared book in first group
      final group = groups.first;
      final now = DateTime.now();
      final sharedBookId = await groupDao.insertSharedBook(
        SharedBooksCompanion.insert(
          uuid: uuid.v4(),
          groupId: group.id,
          groupUuid: group.uuid,
          bookId: book.id,
          bookUuid: book.uuid,
          ownerUserId: activeUser.id,
          ownerRemoteId: activeUser.remoteId != null
              ? Value(activeUser.remoteId!)
              : const Value.absent(),
          isAvailable: const Value(true),
          visibility: const Value('group'),
          isDirty: const Value(true),
          isDeleted: const Value(false),
          syncedAt: const Value(null),
          createdAt: Value(now),
          updatedAt: Value(now),
        ),
      );
      sharedBook = await groupDao.findSharedBookById(sharedBookId);
    }

    if (sharedBook == null) {
      if (!context.mounted) return;
      showFeedbackSnackBar(
        context: context,
        message: 'No se pudo preparar el libro para préstamo.',
        isError: true,
      );
      return;
    }

    // Create the manual loan
    await loanRepository.createManualLoan(
      sharedBook: sharedBook,
      owner: activeUser,
      borrowerName: result['name'] as String,
      borrowerContact: (result['contact'] as String).isNotEmpty
          ? result['contact'] as String
          : null,
      dueDate: result['dueDate'] as DateTime? ?? DateTime.now().add(const Duration(days: 14)),
    );

    // Sync to update book status in groups
    await ref.read(groupSyncControllerProvider.notifier).syncGroups();

    if (!context.mounted) return;
    showFeedbackSnackBar(
      context: context,
      message: 'Préstamo manual creado correctamente.',
      isError: false,
    );
  } finally {
    nameController.dispose();
    contactController.dispose();
  }
}
