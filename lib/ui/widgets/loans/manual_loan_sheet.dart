import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../data/local/database.dart';
import '../../../providers/book_providers.dart';
import '../../../providers/user_providers.dart';
import '../../../services/loan_controller.dart';

class ManualLoanSheet extends ConsumerStatefulWidget {
  const ManualLoanSheet({super.key, this.initialBook});

  final Book? initialBook;

  @override
  ConsumerState<ManualLoanSheet> createState() => _ManualLoanSheetState();
}

class _ManualLoanSheetState extends ConsumerState<ManualLoanSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _contactController = TextEditingController();
  
  Book? _selectedBook;
  DateTime _dueDate = DateTime.now().add(const Duration(days: 14)); // Default 2 weeks

  @override
  void initState() {
    super.initState();
    _selectedBook = widget.initialBook;
  }


  @override
  void dispose() {
    _nameController.dispose();
    _contactController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loanState = ref.watch(loanControllerProvider);
    final availableBooksAsync = ref.watch(userBooksProvider); // Should filter by available later
    final currentUser = ref.watch(activeUserProvider).value;

    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 16,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Nuevo Préstamo Manual',
                style: theme.textTheme.titleLarge,
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const Divider(),
          Flexible(
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    Text('Libro a prestar', style: theme.textTheme.labelLarge),
                    const SizedBox(height: 8),
                    availableBooksAsync.when(
                      data: (books) {
                        // Filter only available books
                        final available = books.where((b) => b.status == 'available').toList();
                        
                        if (available.isEmpty) {
                          return Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.errorContainer,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.error_outline, color: theme.colorScheme.error),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    'No tienes libros disponibles para prestar.',
                                    style: TextStyle(color: theme.colorScheme.onErrorContainer),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }

                        return DropdownButtonFormField<Book>(
                          value: _selectedBook,
                          decoration: InputDecoration(
                            border: const OutlineInputBorder(),
                            hintText: 'Selecciona un libro',
                            filled: true,
                            fillColor: theme.colorScheme.surfaceVariant.withOpacity(0.3),
                          ),
                          items: available.map((book) {
                            return DropdownMenuItem(
                              value: book,
                              child: Text(
                                book.title, 
                                overflow: TextOverflow.ellipsis,
                              ),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() => _selectedBook = value);
                          },
                          validator: (value) => value == null ? 'Selecciona un libro' : null,
                          isExpanded: true,
                        );
                      },
                      loading: () => const LinearProgressIndicator(),
                      error: (err, stack) => Text('Error cargando libros: $err'),
                    ),

                    const SizedBox(height: 24),
                    Text('Datos del prestatario', style: theme.textTheme.labelLarge),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Nombre Completo',
                        hintText: 'Ej. Juan Pérez',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.person_outline),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'El nombre es requerido';
                        }
                        return null;
                      },
                      textCapitalization: TextCapitalization.words,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _contactController,
                      decoration: const InputDecoration(
                        labelText: 'Contacto (Opcional)',
                        hintText: 'Teléfono, email o nota',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.contact_phone_outlined),
                      ),
                    ),

                    const SizedBox(height: 24),
                    Text('Fecha de devolución', style: theme.textTheme.labelLarge),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: _dueDate,
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(const Duration(days: 365)),
                        );
                        if (picked != null) {
                          setState(() => _dueDate = picked);
                        }
                      },
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.calendar_today),
                        ),
                        child: Text(
                          DateFormat.yMMMd().format(_dueDate),
                          style: theme.textTheme.bodyLarge,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    if (loanState.lastError != null)
                      Container(
                        padding: const EdgeInsets.all(8),
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.errorContainer,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          loanState.lastError!,
                          style: TextStyle(color: theme.colorScheme.onErrorContainer),
                        ),
                      ),

                    FilledButton.icon(
                      onPressed: (loanState.isLoading || currentUser == null) 
                        ? null 
                        : _submit,
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.all(16),
                      ),
                      icon: loanState.isLoading 
                        ? const SizedBox(
                            width: 20, 
                            height: 20, 
                            child: CircularProgressIndicator(strokeWidth: 2)
                          )
                        : const Icon(Icons.save),
                      label: Text(
                        loanState.isLoading ? 'Guardando...' : 'Registrar Préstamo'
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedBook == null) return; // Should be caught by validator but double check

    final currentUser = ref.read(activeUserProvider).value;
    if (currentUser == null) return;

    try {
      await ref.read(loanControllerProvider.notifier).createManualLoanDirect(
        book: _selectedBook!,
        owner: currentUser,
        borrowerName: _nameController.text,
        dueDate: _dueDate,
        borrowerContact: _contactController.text.isNotEmpty 
            ? _contactController.text 
            : null,
      );

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Préstamo registrado correctamente')),
        );
      }
    } catch (e) {
      // Error is handled in controller state, shown in UI
    }
  }
}
