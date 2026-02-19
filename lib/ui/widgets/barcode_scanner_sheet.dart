import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

/// Widget for scanning barcodes (ISBN codes)
///
/// Displays a camera view with barcode detection and overlay frame.
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

        // Haptic feedback
        HapticFeedback.lightImpact();

        // Call callback first
        widget.onScanned(value.trim());

        // Then close dialog with the scanned value
        if (mounted) {
          Navigator.of(context).pop(value.trim());
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
              child: Stack(
                children: [
                  DecoratedBox(
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
                  // Barcode overlay frame
                  Positioned.fill(
                    child: CustomPaint(
                      painter: _BarcodeFramePainter(),
                    ),
                  ),
                  // Corner indicators
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.3),
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                ],
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
                        const SnackBar(
                            content:
                                Text('Este dispositivo no tiene linterna.')),
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

/// Custom painter for barcode scanning frame overlay
class _BarcodeFramePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black.withValues(alpha: 0.5)
      ..style = PaintingStyle.fill;

    // Create transparent center area for barcode
    final centerRect = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2),
      width: size.width * 0.7,
      height: size.height * 0.3,
    );

    // Paint dark overlay outside center area
    final path = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
      ..addRect(centerRect)
      ..fillType = PathFillType.evenOdd;

    canvas.drawPath(path, paint);

    // Draw corner brackets
    final cornerPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    const cornerLength = 30.0;
    const cornerWidth = 4.0;

    // Top-left corner
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          centerRect.left - cornerWidth,
          centerRect.top - cornerWidth,
          cornerLength,
          cornerLength,
        ),
        const Radius.circular(8),
      ),
      cornerPaint,
    );

    // Top-right corner
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          centerRect.right - cornerLength + cornerWidth,
          centerRect.top - cornerWidth,
          cornerLength,
          cornerLength,
        ),
        const Radius.circular(8),
      ),
      cornerPaint,
    );

    // Bottom-left corner
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          centerRect.left - cornerWidth,
          centerRect.bottom - cornerLength + cornerWidth,
          cornerLength,
          cornerLength,
        ),
        const Radius.circular(8),
      ),
      cornerPaint,
    );

    // Bottom-right corner
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          centerRect.right - cornerLength + cornerWidth,
          centerRect.bottom - cornerLength + cornerWidth,
          cornerLength,
          cornerLength,
        ),
        const Radius.circular(8),
      ),
      cornerPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
