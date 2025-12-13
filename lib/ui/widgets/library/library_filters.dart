import 'package:flutter/material.dart';

class LibraryFilters extends StatelessWidget {
  const LibraryFilters({
    super.key,
    required this.onRefreshCovers,
    required this.onExport,
  });

  final VoidCallback onRefreshCovers;
  final VoidCallback onExport;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        RefreshCoversButton(onRefresh: onRefreshCovers),
      ],
    );
  }
}

class ExportButton extends StatelessWidget {
  const ExportButton({super.key, required this.onExport});

  final VoidCallback onExport;

  @override
  Widget build(BuildContext context) {
    return FilledButton.icon(
      onPressed: onExport,
      icon: const Icon(Icons.share_outlined),
      label: const Text('Exportar'),
    );
  }
}

class RefreshCoversButton extends StatelessWidget {
  const RefreshCoversButton({super.key, required this.onRefresh});

  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onRefresh,
      icon: const Icon(Icons.refresh),
      label: const Text('Actualizar portadas'),
    );
  }
}
