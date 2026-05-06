import 'package:flutter/material.dart';
import '../empty_state.dart';
import '../../../../l10n/generated/app_localizations.dart';

class EmptyLibraryState extends StatelessWidget {
  const EmptyLibraryState({super.key, required this.onAddBook});

  final VoidCallback onAddBook;

  @override
  Widget build(BuildContext context) {
    return EmptyState(
      icon: Icons.menu_book_outlined,
      title: S.of(context).evocEmptyLibraryTitle,
      message: S.of(context).evocEmptyLibraryMessage,
      action: EmptyStateAction(
        label: S.of(context).evocEmptyLibraryAction,
        icon: Icons.add_circle_outline,
        onPressed: onAddBook,
      ),
    );
  }
}
