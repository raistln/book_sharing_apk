import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../data/local/database.dart';
import '../../../utils/reading_rhythm_helper.dart';

class ReadingRhythmChart extends StatefulWidget {
  final ReadingRhythmData data;
  final Function(Book) onBookTap;

  const ReadingRhythmChart({
    super.key,
    required this.data,
    required this.onBookTap,
  });

  @override
  State<ReadingRhythmChart> createState() => _ReadingRhythmChartState();
}

class _ReadingRhythmChartState extends State<ReadingRhythmChart> {
  double _horizontalScale = 1.0;
  final ScrollController _scrollController = ScrollController();
  double _baseScale = 1.0;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.data.rows.isEmpty) return _buildEmptyState();

    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = constraints.maxWidth;
        final chartWidth = maxWidth * _horizontalScale;

        return Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header minimalista y tranquilo
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Tu viaje lector",
                        style: Theme.of(context)
                            .textTheme
                            .labelMedium
                            ?.copyWith(
                              color: Theme.of(context).colorScheme.secondary,
                              letterSpacing: 1.2,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.data.insight,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withValues(alpha: 0.8),
                              height: 1.3,
                              fontFamily: 'Serif',
                            ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onScaleStart: (d) => _baseScale = _horizontalScale,
                    onScaleUpdate: (d) => setState(() => _horizontalScale =
                        (_baseScale * d.scale).clamp(1.0, 10.0)),
                    child: SingleChildScrollView(
                      controller: _scrollController,
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      child: SizedBox(
                        width: chartWidth,
                        child: Stack(
                          children: [
                            // Capa 1: Fondo sutil (El tiempo)
                            Positioned.fill(
                                child: _buildZenGrid(context, chartWidth)),

                            // Capa 2: Los libros (El viaje)
                            Padding(
                              padding:
                                  const EdgeInsets.only(top: 40.0, bottom: 100),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: widget.data.rows
                                    .map((row) => _buildZenBookRow(
                                        context, row, chartWidth))
                                    .toList(),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            // Zoom Controls
            Positioned(
              left: 16,
              bottom: 16,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  FloatingActionButton.small(
                    heroTag: 'zoom_in_rhythm',
                    onPressed: () {
                      setState(() {
                        _horizontalScale =
                            (_horizontalScale * 1.5).clamp(1.0, 10.0);
                      });
                    },
                    child: const Icon(Icons.add),
                  ),
                  const SizedBox(height: 8),
                  FloatingActionButton.small(
                    heroTag: 'zoom_out_rhythm',
                    onPressed: () {
                      setState(() {
                        _horizontalScale =
                            (_horizontalScale / 1.5).clamp(1.0, 10.0);
                      });
                    },
                    child: const Icon(Icons.remove),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Text(
        'El silencio antes de la historia...',
        style: TextStyle(
            color:
                Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4),
            fontStyle: FontStyle.italic),
      ),
    );
  }

  Widget _buildZenGrid(BuildContext context, double width) {
    final months = <DateTime>[];
    DateTime current =
        DateTime(widget.data.startDate.year, widget.data.startDate.month, 1);
    while (current.isBefore(widget.data.endDate.add(const Duration(days: 1)))) {
      months.add(current);
      current = DateTime(current.year, current.month + 1, 1);
    }

    final totalDuration =
        widget.data.endDate.difference(widget.data.startDate).inMilliseconds;
    final safeDuration = totalDuration == 0 ? 1 : totalDuration;

    return Stack(
      children: months.map((m) {
        double startOffset =
            m.difference(widget.data.startDate).inMilliseconds / safeDuration;
        final left = (startOffset * width).clamp(0.0, width);

        // Solo mostramos etiqueta si cabe en el ancho
        if (left > width) return const SizedBox.shrink();

        return Positioned(
          left: left,
          top: 0,
          bottom: 0,
          child: Container(
            // Una línea vertical muy sutil, casi invisible
            decoration: BoxDecoration(
              border: Border(
                left: BorderSide(
                  color: Theme.of(context)
                      .colorScheme
                      .outlineVariant
                      .withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
            ),
            padding: const EdgeInsets.only(left: 8.0, top: 10.0),
            child: Text(
              DateFormat('MMM', 'es')
                  .format(m)
                  .toLowerCase(), // Minúsculas se ven más suaves
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurfaceVariant
                        .withValues(alpha: 0.5),
                  ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildZenBookRow(
      BuildContext context, RhythmRow row, double chartWidth) {
    final totalDuration =
        widget.data.endDate.difference(widget.data.startDate).inMilliseconds;
    final safeDuration = totalDuration == 0 ? 1 : totalDuration;
    const double rowHeight = 85.0; // Más aire entre libros

    // Color pastel suave
    final calmColor = _getZenColor(row.book.id);

    // Calcular puntos de inicio y fin totales para la línea conectora
    double? firstX;
    double? lastX;

    if (row.segments.isNotEmpty) {
      final startMs = row.segments.first.start
          .difference(widget.data.startDate)
          .inMilliseconds;
      final endMs = row.segments.last.end
          .difference(widget.data.startDate)
          .inMilliseconds;
      firstX = (startMs / safeDuration * chartWidth).clamp(0.0, chartWidth);
      lastX = (endMs / safeDuration * chartWidth).clamp(0.0, chartWidth);
    }

    return InkWell(
      onTap: () => widget.onBookTap(row.book),
      splashColor: calmColor.withValues(alpha: 0.1),
      highlightColor: Colors.transparent,
      child: Container(
        height: rowHeight,
        alignment: Alignment.centerLeft,
        child: Stack(
          alignment: Alignment.centerLeft,
          children: [
            // 1. EL HILO CONDUCTOR (Línea punteada de fondo)
            // Conecta el primer día de lectura con el último, dando continuidad
            if (firstX != null && lastX != null && (lastX - firstX) > 5)
              Positioned(
                left: firstX + 10, // Un pequeño offset
                width: lastX - firstX,
                top: 45, // Alineado al centro de las barras
                child: CustomPaint(
                  painter: _DottedLinePainter(
                      color: calmColor.withValues(alpha: 0.3)),
                  size: Size(lastX - firstX, 2),
                ),
              ),

            // 2. LAS SESIONES DE LECTURA (Píldoras suaves)
            ...row.segments.map((segment) {
              final startOffset = segment.start
                      .difference(widget.data.startDate)
                      .inMilliseconds /
                  safeDuration;
              final durationPercent =
                  segment.end.difference(segment.start).inMilliseconds /
                      safeDuration;

              final left = (startOffset * chartWidth).clamp(0.0, chartWidth);
              // Mínimo ancho visual para que una lectura de 5 min se vea como un puntito
              final width =
                  (durationPercent * chartWidth).clamp(6.0, chartWidth);

              return Positioned(
                left: left,
                top: 36, // Dejamos espacio arriba para el título
                height: 18,
                width: width,
                child: Container(
                  decoration: BoxDecoration(
                    color: segment.isPause
                        ? Colors
                            .transparent // Las pausas son invisibles, solo el hilo las cruza
                        : calmColor,
                    borderRadius:
                        BorderRadius.circular(10), // Completamente redondo
                    boxShadow: segment.isPause
                        ? null
                        : [
                            BoxShadow(
                                color: calmColor.withValues(alpha: 0.4),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                                spreadRadius: -2)
                          ],
                  ),
                ),
              );
            }),

            // 3. LA PORTADA Y TÍTULO (Flotando al inicio)
            if (firstX != null)
              Positioned(
                left: firstX,
                top: 0,
                child: Row(
                  children: [
                    Container(
                      width: 24, // Portada pequeñita
                      height: 36,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(6),
                          color: Colors.grey.shade200,
                          image: row.book.coverPath != null
                              ? DecorationImage(
                                  image: FileImage(File(row.book.coverPath!)),
                                  fit: BoxFit.cover,
                                )
                              : null,
                          boxShadow: [
                            BoxShadow(
                                color: Colors.black.withValues(alpha: 0.05),
                                blurRadius: 4,
                                offset: const Offset(0, 2))
                          ]),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      row.book.title,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withValues(alpha: 0.7),
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                  ],
                ),
              )
          ],
        ),
      ),
    );
  }

  // Paleta de colores "Nature / Zen"
  Color _getZenColor(int index) {
    const palette = [
      Color(0xFF8DA399), // Sage Green
      Color(0xFFD4A5A5), // Dusty Rose
      Color(0xFF9EA1D4), // Muted Lavender
      Color(0xFFA7C5EB), // Soft Blue
      Color(0xFFE6C9A8), // Sand
      Color(0xFFB5B5A6), // Warm Grey
    ];
    return palette[index % palette.length];
  }
}

// Pintor para la línea punteada suave
class _DottedLinePainter extends CustomPainter {
  final Color color;
  _DottedLinePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;

    const dashWidth = 4.0;
    const dashSpace = 6.0;
    double startX = 0;

    while (startX < size.width) {
      canvas.drawLine(
        Offset(startX, size.height / 2),
        Offset(startX + dashWidth, size.height / 2),
        paint,
      );
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
