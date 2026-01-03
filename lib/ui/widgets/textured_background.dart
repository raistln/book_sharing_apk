import 'dart:math';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';

/// Widget que aplica una textura de fondo sutil (ruido/grano)
/// Generada programáticamente para no depender de assets
class TexturedBackground extends StatelessWidget {
  const TexturedBackground({
    super.key,
    required this.child,
    this.opacity = 0.03,
    this.grainSize = 1.0,
  });

  final Widget child;
  final double opacity;
  final double grainSize;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Contenido principal
        child,

        // Capa de textura (ignora toques)
        IgnorePointer(
          child: Opacity(
            opacity: opacity,
            child: CustomPaint(
              painter: _NoisePainter(
                grainSize: grainSize,
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white
                    : Colors.black,
              ),
              size: Size.infinite,
            ),
          ),
        ),
      ],
    );
  }
}

/// Painter que dibuja ruido aleatorio
class _NoisePainter extends CustomPainter {
  _NoisePainter({
    required this.grainSize,
    required this.color,
  });

  final double grainSize;
  final Color color;
  final Random _random = Random(42); // Semilla fija para consistencia visual

  @override
  void paint(Canvas canvas, Size size) {
    // Dibujar ruido solo si el tamaño es razonable para evitar cuelgues
    // Usamos drawPoints para mayor eficiencia que dibujar rectángulos individuales

    final paint = Paint()
      ..color = color
      ..strokeWidth = grainSize
      ..strokeCap = StrokeCap.square;

    final List<Offset> points = [];

    // Densidad del ruido (ajustable)
    // Reducción de densidad para eficiencia: 1 punto cada ~4 pixeles cuadrados
    final density = size.width * size.height * 0.15;

    for (int i = 0; i < density; i++) {
      final x = _random.nextDouble() * size.width;
      final y = _random.nextDouble() * size.height;
      points.add(Offset(x, y));
    }

    canvas.drawPoints(ui.PointMode.points, points, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false; // El ruido es estático
  }
}
