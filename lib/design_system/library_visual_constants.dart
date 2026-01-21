import 'package:flutter/material.dart';

class LibraryVisualConstants {
  // Tintes de fondo para las tarjetas de libros
  static Color getOwnedBookTint(ThemeData theme) =>
      theme.colorScheme.surfaceContainerHighest;

  static Color getLoanedByYouTint(ThemeData theme) =>
      theme.brightness == Brightness.light
          ? Colors.grey.shade200
          : Colors.grey.shade800;

  static Color getLoanedToYouTint(ThemeData theme) =>
      theme.brightness == Brightness.light
          ? Colors.blue.shade50
          : Colors.blue.shade900.withValues(alpha: 0.3);

  static Color getPrivateTint(ThemeData theme) =>
      theme.brightness == Brightness.light
          ? Colors.green.shade50
          : Colors.green.shade900.withValues(alpha: 0.3);

  // Colores para chips/etiquetas
  static Color getLoanedChipColor(ThemeData theme) =>
      theme.brightness == Brightness.light
          ? Colors.grey.shade300
          : Colors.grey.shade700;

  static Color getLoanedToYouChipColor(ThemeData theme) =>
      theme.brightness == Brightness.light
          ? Colors.blue.shade100
          : Colors.blue.shade800;

  static Color getPrivateChipColor(ThemeData theme) =>
      theme.brightness == Brightness.light
          ? Colors.green.shade100
          : Colors.green.shade800;
}
