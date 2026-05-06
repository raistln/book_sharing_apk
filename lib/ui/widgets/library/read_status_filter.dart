import 'package:flutter/material.dart';
import '../../../l10n/generated/app_localizations.dart';

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
          items: [
            DropdownMenuItem(
              value: null,
              child: Text(S.of(context).readStatusFilterAll),
            ),
            DropdownMenuItem(
              value: true,
              child: Text(S.of(context).readStatusFilterRead),
            ),
            DropdownMenuItem(
              value: false,
              child: Text(S.of(context).readStatusFilterUnread),
            ),
          ],
        ),
      ),
    );
  }
}
