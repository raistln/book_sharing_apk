import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../ui/widgets/barcode_scanner_sheet.dart';

class BookScannerButton extends ConsumerWidget {
  const BookScannerButton({
    super.key,
    required this.onBarcodeScanned,
  });

  final Function(String) onBarcodeScanned;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FilledButton.icon(
      onPressed: () => _showBarcodeScanner(context),
      icon: const Icon(Icons.camera_alt_outlined),
      label: const Text('Escanear código'),
    );
  }

  void _showBarcodeScanner(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => BarcodeScannerSheet(
        onScanned: (barcode) {
          Navigator.of(context).pop();
          onBarcodeScanned(barcode);
        },
      ),
    );
  }
}
