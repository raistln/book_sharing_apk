import 'package:flutter/material.dart';

class ReadStatusFilter extends StatelessWidget {
  const ReadStatusFilter({
    super.key,
    required this.selectedFilter,
    required this.onChanged,
  });

  final bool? selectedFilter;
  final ValueChanged<bool?> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<bool?>(
          value: selectedFilter,
          onChanged: onChanged,
          style: theme.textTheme.bodyMedium,
          items: const [
            DropdownMenuItem(
              value: null,
              child: Text('Todos los libros'),
            ),
            DropdownMenuItem(
              value: true,
              child: Text('Leídos'),
            ),
            DropdownMenuItem(
              value: false,
              child: Text('No leídos'),
            ),
          ],
        ),
      ),
    );
  }
}
