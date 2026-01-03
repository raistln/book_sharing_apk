import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../design_system/literary_animations.dart';

/// Transición especial para entrar a "El Gran Archivo" (Biblioteca Compartida)
/// Simula la apertura solemne de una puerta hacia el conocimiento
class LibraryPageRoute<T> extends PageRouteBuilder<T> {
  final Widget page;
  final bool enableHapticFeedback;

  LibraryPageRoute({
    required this.page,
    this.enableHapticFeedback = true,
  }) : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionDuration: LiteraryAnimations.archiveTransitionDuration,
          reverseTransitionDuration: LiteraryAnimations.medium,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            // Curva de entrada suave y solemne
            final curvedAnimation = CurvedAnimation(
              parent: animation,
              curve: LiteraryAnimations.archiveTransitionCurve,
            );

            // Efecto de deslizamiento vertical sutil (como levantando la vista/telón)
            final slideAnimation = Tween<Offset>(
              begin: const Offset(0.0, 0.05), // Empieza un poco abajo
              end: Offset.zero,
            ).animate(curvedAnimation);

            // Fade suave
            final fadeAnimation = Tween<double>(
              begin: 0.0,
              end: 1.0,
            ).animate(curvedAnimation);

            // Escala sutil (creciendo hacia el lector)
            final scaleAnimation = Tween<double>(
              begin: 0.98,
              end: 1.0,
            ).animate(curvedAnimation);

            return SlideTransition(
              position: slideAnimation,
              child: FadeTransition(
                opacity: fadeAnimation,
                child: ScaleTransition(
                  scale: scaleAnimation,
                  child: child,
                ),
              ),
            );
          },
        );

  @override
  TickerFuture didPush() {
    if (enableHapticFeedback) {
      // Feedback táctil suave al iniciar la transición
      HapticFeedback.lightImpact();
    }
    return super.didPush();
  }
}
