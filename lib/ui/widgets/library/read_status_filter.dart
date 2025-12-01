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
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        FilterChip(
          label: const Text('Leídos'),
          selected: selectedFilter == true,
          onSelected: (selected) {
            onChanged(selected ? true : null);
          },
        ),
        const SizedBox(width: 8),
        FilterChip(
          label: const Text('No leídos'),
          selected: selectedFilter == false,
          onSelected: (selected) {
            onChanged(selected ? false : null);
          },
        ),
      ],
    );
  }
}
