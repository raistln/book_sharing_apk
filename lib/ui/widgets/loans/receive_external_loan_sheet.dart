import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../providers/book_providers.dart';

class ReceiveExternalLoanSheet extends ConsumerStatefulWidget {
  const ReceiveExternalLoanSheet({super.key});

  @override
  ConsumerState<ReceiveExternalLoanSheet> createState() =>
      _ReceiveExternalLoanSheetState();
}

class _ReceiveExternalLoanSheetState
    extends ConsumerState<ReceiveExternalLoanSheet> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _authorController = TextEditingController();
  final _lenderNameController = TextEditingController();
  final _lenderContactController = TextEditingController();

  DateTime _dueDate = DateTime.now().add(const Duration(days: 15));

  @override
  void dispose() {
    _titleController.dispose();
    _authorController.dispose();
    _lenderNameController.dispose();
    _lenderContactController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final currentUser = ref.read(activeUserProvider).asData?.value;
    if (currentUser == null) return;

    final loanController = ref.read(loanControllerProvider.notifier);

    // Close sheet first
    Navigator.pop(context);

    try {
      await loanController.receiveExternalLoan(
        user: currentUser,
        title: _titleController.text.trim(),
        author: _authorController.text.trim(),
        lenderName: _lenderNameController.text.trim(),
        dueDate: _dueDate,
        lenderContact: _lenderContactController.text.trim(),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Libro prestado registrado')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al registrar: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 24,
        right: 24,
        top: 24,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Registrar libro prestado',
                style: theme.textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                'Registra un libro que alguien (fuera de la app) te ha prestado.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 24),

              // Book Details
              Text('Detalles del libro', style: theme.textTheme.titleMedium),
              const SizedBox(height: 12),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Título del libro *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.book_outlined),
                ),
                textCapitalization: TextCapitalization.sentences,
                validator: (value) =>
                    value == null || value.trim().isEmpty ? 'Requerido' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _authorController,
                decoration: const InputDecoration(
                  labelText: 'Autor',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person_outline),
                ),
                textCapitalization: TextCapitalization.words,
              ),

              const SizedBox(height: 24),

              // Lender Details
              Text('¿Quién te lo prestó?', style: theme.textTheme.titleMedium),
              const SizedBox(height: 12),
              TextFormField(
                controller: _lenderNameController,
                decoration: const InputDecoration(
                  labelText: 'Nombre del propietario *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.account_circle_outlined),
                ),
                textCapitalization: TextCapitalization.words,
                validator: (value) =>
                    value == null || value.trim().isEmpty ? 'Requerido' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _lenderContactController,
                decoration: const InputDecoration(
                  labelText: 'Contacto (Opcional)',
                  hintText: 'Teléfono, email, etc.',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.contact_phone_outlined),
                ),
              ),

              const SizedBox(height: 24),

              // Due Date
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
                    labelText: 'Fecha de devolución',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.calendar_today),
                  ),
                  child: Text(
                    DateFormat.yMMMd().format(_dueDate),
                    style: theme.textTheme.bodyLarge,
                  ),
                ),
              ),

              const SizedBox(height: 32),

              FilledButton.icon(
                onPressed: _submit,
                icon: const Icon(Icons.save_alt),
                label: const Text('Registrar préstamo'),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
