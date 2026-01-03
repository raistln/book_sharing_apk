import 'package:flutter/material.dart';
import '../empty_state.dart';
import '../../../design_system/evocative_texts.dart';

class EmptyLibraryState extends StatelessWidget {
  const EmptyLibraryState({super.key, required this.onAddBook});

  final VoidCallback onAddBook;

  @override
  Widget build(BuildContext context) {
    return EmptyState(
      icon: Icons.menu_book_outlined,
      title: EvocativeTexts.emptyLibraryTitle,
      message: EvocativeTexts.emptyLibraryMessage,
      action: EmptyStateAction(
        label: EvocativeTexts.emptyLibraryAction,
        icon: Icons.add_circle_outline,
        onPressed: onAddBook,
      ),
    );
  }
}
