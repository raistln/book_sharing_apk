import 'package:flutter/material.dart';

/// Animaciones literarias - lentas, suaves, contemplativas
/// Inspiradas en el ritmo de la lectura
class LiteraryAnimations {
  LiteraryAnimations._();

  // Duraciones
  /// Duración muy corta para micro-interacciones
  static const Duration veryShort = Duration(milliseconds: 200);

  /// Duración corta para transiciones rápidas
  static const Duration short = Duration(milliseconds: 300);

  /// Duración media para la mayoría de animaciones
  static const Duration medium = Duration(milliseconds: 400);

  /// Duración larga para transiciones importantes
  static const Duration long = Duration(milliseconds: 500);

  /// Duración muy larga para momentos especiales
  static const Duration veryLong = Duration(milliseconds: 700);

  // Curvas de animación - todas suaves, nada elástico
  /// Curva suave de entrada y salida (por defecto)
  static const Curve smooth = Curves.easeInOutCubic;

  /// Curva suave de entrada
  static const Curve smoothIn = Curves.easeInCubic;

  /// Curva suave de salida
  static const Curve smoothOut = Curves.easeOutCubic;

  /// Curva muy suave para transiciones delicadas
  static const Curve gentle = Curves.easeInOutQuad;

  /// Curva para desvanecimientos
  static const Curve fade = Curves.easeInOutSine;

  /// Animación de escala para tap en cards
  /// Escala ligeramente hacia abajo (0.98) para feedback táctil
  static const double tapScaleDown = 0.98;
  static const Duration tapDuration = short;
  static const Curve tapCurve = gentle;

  /// Animación de entrada para cards
  static const Duration cardEntryDuration = medium;
  static const Curve cardEntryCurve = smoothOut;
  static const Offset cardEntryOffset = Offset(0, 20);

  /// Animación de página (para navegación)
  static const Duration pageTransitionDuration = long;
  static const Curve pageTransitionCurve = smooth;

  /// Animación especial para "El Gran Archivo"
  static const Duration archiveTransitionDuration = veryLong;
  static const Curve archiveTransitionCurve = smooth;
  static const double archiveTransitionSlide = 30.0;

  /// Animación de fade para estados vacíos
  static const Duration emptyStateFadeDuration = medium;
  static const Curve emptyStateFadeCurve = fade;

  /// Animación de icono en estados vacíos
  static const Duration emptyStateIconDuration = long;
  static const Curve emptyStateIconCurve = smoothOut;
  static const double emptyStateIconScale = 1.0;
}

/// Widget helper para animación de tap
class TapAnimation extends StatefulWidget {
  const TapAnimation({
    super.key,
    required this.child,
    this.onTap,
    this.enabled = true,
  });

  final Widget child;
  final VoidCallback? onTap;
  final bool enabled;

  @override
  State<TapAnimation> createState() => _TapAnimationState();
}

class _TapAnimationState extends State<TapAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: LiteraryAnimations.tapDuration,
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: LiteraryAnimations.tapScaleDown,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: LiteraryAnimations.tapCurve,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    if (widget.enabled) {
      _controller.forward();
    }
  }

  void _handleTapUp(TapUpDetails details) {
    if (widget.enabled) {
      _controller.reverse();
    }
  }

  void _handleTapCancel() {
    if (widget.enabled) {
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      onTap: widget.onTap,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: widget.child,
      ),
    );
  }
}

/// Widget helper para animación de entrada (Fade + Scale)
class FadeScaleIn extends StatefulWidget {
  const FadeScaleIn({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.duration = LiteraryAnimations.medium,
    this.curve = LiteraryAnimations.smoothOut,
  });

  final Widget child;
  final Duration delay;
  final Duration duration;
  final Curve curve;

  @override
  State<FadeScaleIn> createState() => _FadeScaleInState();
}

class _FadeScaleInState extends State<FadeScaleIn>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    final curvedAnimation = CurvedAnimation(
      parent: _controller,
      curve: widget.curve,
    );

    _fadeAnimation =
        Tween<double>(begin: 0.0, end: 1.0).animate(curvedAnimation);
    _scaleAnimation =
        Tween<double>(begin: 0.95, end: 1.0).animate(curvedAnimation);

    if (widget.delay == Duration.zero) {
      _controller.forward();
    } else {
      Future.delayed(widget.delay, () {
        if (mounted) _controller.forward();
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: widget.child,
      ),
    );
  }
}
