import 'package:flutter/material.dart';
import '../empty_state.dart';

class EmptyLibraryState extends StatelessWidget {
  const EmptyLibraryState({super.key, required this.onAddBook});

  final VoidCallback onAddBook;

  @override
  Widget build(BuildContext context) {
    return EmptyState(
      icon: Icons.menu_book_outlined,
      title: 'Tu biblioteca está vacía',
      message:
          'Registra tu primer libro para organizar préstamos y compartir lecturas con tu grupo.',
      action: EmptyStateAction(
        label: 'Registrar libro',
        icon: Icons.add_circle_outline,
        onPressed: onAddBook,
      ),
    );
  }
}
