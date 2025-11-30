import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class GroupStatsChips extends StatelessWidget {
  const GroupStatsChips({
    super.key,
    required this.membersAsync,
    required this.sharedBooksAsync,
    required this.loansAsync,
    required this.invitationsAsync,
  });

  final AsyncValue<List<dynamic>> membersAsync;
  final AsyncValue<List<dynamic>> sharedBooksAsync;
  final AsyncValue<List<dynamic>> loansAsync;
  final AsyncValue<List<dynamic>> invitationsAsync;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 16,
      runSpacing: 8,
      children: [
        AsyncCountChip(
          icon: Icons.people_outline,
          label: 'Miembros',
          value: membersAsync,
        ),
        AsyncCountChip(
          icon: Icons.menu_book_outlined,
          label: 'Libros compartidos',
          value: sharedBooksAsync,
        ),
        AsyncCountChip(
          icon: Icons.swap_horiz_outlined,
          label: 'Préstamos',
          value: loansAsync,
        ),
        AsyncCountChip(
          icon: Icons.qr_code_2_outlined,
          label: 'Invitaciones',
          value: invitationsAsync,
        ),
      ],
    );
  }
}

class AsyncCountChip<T> extends StatelessWidget {
  const AsyncCountChip({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final AsyncValue<List<T>> value;

  @override
  Widget build(BuildContext context) {
    return value.when(
      data: (items) => Chip(
        avatar: Icon(icon, size: 18),
        label: Text('$label: ${items.length}'),
      ),
      loading: () => const Chip(
        avatar: SizedBox(
          width: 16,
          height: 16,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
        label: Text('Cargando...'),
      ),
      error: (error, _) => Chip(
        avatar: const Icon(Icons.error_outline, size: 18),
        label: Text('Error $label'),
      ),
    );
  }
}
