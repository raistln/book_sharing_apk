import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

/// Widget for scanning barcodes (ISBN codes)
/// 
/// Displays a camera view with barcode detection.
/// Returns the scanned barcode value when detected.
class BarcodeScannerSheet extends StatefulWidget {
  const BarcodeScannerSheet({
    super.key,
    required this.onScanned,
  });

  final Function(String) onScanned;

  @override
  State<BarcodeScannerSheet> createState() => _BarcodeScannerSheetState();
}

class _BarcodeScannerSheetState extends State<BarcodeScannerSheet> {
  late final MobileScannerController _controller;
  bool _handled = false;

  @override
  void initState() {
    super.initState();
    _controller = MobileScannerController(
      detectionSpeed: DetectionSpeed.noDuplicates,
      facing: CameraFacing.back,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleDetection(BarcodeCapture capture) {
    if (_handled) {
      return;
    }

    for (final barcode in capture.barcodes) {
      final value = barcode.rawValue;
      if (value != null && value.trim().isNotEmpty) {
        _handled = true;
        _controller.stop();
        if (mounted) {
          Navigator.of(context).pop();
          widget.onScanned(value.trim());
        }
        return;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Escanea el código de barras',
                    style: theme.textTheme.titleMedium,
                  ),
                ),
                IconButton(
                  tooltip: 'Cerrar',
                  onPressed: () => Navigator.of(context).maybePop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 12),
            AspectRatio(
              aspectRatio: 3 / 4,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: Colors.black,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: MobileScanner(
                    controller: _controller,
                    onDetect: _handleDetection,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Alinea el código de barras dentro del recuadro. La lectura se completará automáticamente.',
              style: theme.textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton.icon(
                  onPressed: () async {
                    final hasTorch = _controller.hasTorch;
                    if (!hasTorch) {
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Este dispositivo no tiene linterna.')),
                      );
                      return;
                    }
                    await _controller.toggleTorch();
                  },
                  icon: const Icon(Icons.flashlight_on_outlined),
                  label: const Text('Linterna'),
                ),
                TextButton.icon(
                  onPressed: () async {
                    await _controller.switchCamera();
                  },
                  icon: const Icon(Icons.cameraswitch_outlined),
                  label: const Text('Cambiar cámara'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
