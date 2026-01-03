import 'package:flutter/material.dart';

/// Sombras narrativas para diferentes estados de libros
/// Cada sombra cuenta una historia visual sobre el estado del libro
class LiteraryShadows {
  LiteraryShadows._();

  /// Sombra para libro normal/disponible
  /// Sombra suave y neutral, como un libro descansando en una estantería
  static List<BoxShadow> normalBookShadow(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return [
      BoxShadow(
        color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.15),
        blurRadius: 8,
        offset: const Offset(0, 2),
      ),
      BoxShadow(
        color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.08),
        blurRadius: 4,
        offset: const Offset(0, 1),
      ),
    ];
  }

  /// Sombra para libro prestado
  /// Sombra cálida y suave, como si el libro estuviera en un viaje
  static List<BoxShadow> loanedBookShadow(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return [
      BoxShadow(
        color: Colors.orange.withValues(alpha: isDark ? 0.25 : 0.12),
        blurRadius: 10,
        offset: const Offset(0, 3),
      ),
      BoxShadow(
        color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.1),
        blurRadius: 6,
        offset: const Offset(0, 2),
      ),
    ];
  }

  /// Sombra para libro solicitado
  /// Sombra con brillo azulado, como anticipación
  static List<BoxShadow> requestedBookShadow(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return [
      BoxShadow(
        color: Colors.blue.withValues(alpha: isDark ? 0.3 : 0.15),
        blurRadius: 12,
        offset: const Offset(0, 3),
      ),
      BoxShadow(
        color: Colors.blue.withValues(alpha: isDark ? 0.15 : 0.08),
        blurRadius: 6,
        offset: const Offset(0, 1),
        spreadRadius: 1,
      ),
    ];
  }

  /// Sombra para libro retrasado
  /// Sombra rojiza y más intensa, urgencia visual
  static List<BoxShadow> overdueBookShadow(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return [
      BoxShadow(
        color: Colors.red.withValues(alpha: isDark ? 0.35 : 0.18),
        blurRadius: 14,
        offset: const Offset(0, 4),
      ),
      BoxShadow(
        color: Colors.red.withValues(alpha: isDark ? 0.2 : 0.1),
        blurRadius: 8,
        offset: const Offset(0, 2),
        spreadRadius: 1,
      ),
    ];
  }

  /// Sombra para libro archivado
  /// Sombra apagada, como un libro guardado en el olvido
  static List<BoxShadow> archivedBookShadow(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return [
      BoxShadow(
        color: Colors.grey.withValues(alpha: isDark ? 0.25 : 0.12),
        blurRadius: 6,
        offset: const Offset(0, 2),
      ),
      BoxShadow(
        color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.06),
        blurRadius: 3,
        offset: const Offset(0, 1),
      ),
    ];
  }

  /// Sombra para libro privado
  /// Sombra púrpura misteriosa
  static List<BoxShadow> privateBookShadow(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return [
      BoxShadow(
        color: Colors.purple.withValues(alpha: isDark ? 0.3 : 0.15),
        blurRadius: 10,
        offset: const Offset(0, 3),
      ),
      BoxShadow(
        color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.1),
        blurRadius: 5,
        offset: const Offset(0, 1),
      ),
    ];
  }

  /// Sombra profunda para cards de grupo
  /// Sensación de "lugar", como entrar en una sala
  static List<BoxShadow> groupCardShadow(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return [
      BoxShadow(
        color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.2),
        blurRadius: 16,
        offset: const Offset(0, 4),
        spreadRadius: 2,
      ),
      BoxShadow(
        color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.12),
        blurRadius: 8,
        offset: const Offset(0, 2),
      ),
    ];
  }

  /// Sombra para portadas de libro
  /// Sombra que da profundidad a la imagen de portada
  static List<BoxShadow> bookCoverShadow(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return [
      BoxShadow(
        color: Colors.black.withValues(alpha: isDark ? 0.5 : 0.25),
        blurRadius: 8,
        offset: const Offset(2, 3),
      ),
      BoxShadow(
        color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.15),
        blurRadius: 4,
        offset: const Offset(1, 1),
      ),
    ];
  }

  /// Obtener sombra según el estado del libro
  static List<BoxShadow> forBookStatus(String status, BuildContext context) {
    switch (status.toLowerCase()) {
      case 'available':
        return normalBookShadow(context);
      case 'loaned':
        return loanedBookShadow(context);
      case 'requested':
        return requestedBookShadow(context);
      case 'overdue':
        return overdueBookShadow(context);
      case 'archived':
        return archivedBookShadow(context);
      case 'private':
        return privateBookShadow(context);
      default:
        return normalBookShadow(context);
    }
  }
}
