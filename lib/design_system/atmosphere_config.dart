import 'package:flutter/material.dart';

/// Sistema de atmósferas para la aplicación
/// Inspirado en bibliotecas y géneros literarios
enum AtmosphereType {
  /// Neutral/Biblioteca - Atmósfera por defecto
  library,

  /// Fantasía - Para futuras expansiones
  fantasy,

  /// Ciencia Ficción - Para futuras expansiones
  sciFi,

  /// Terror - Para futuras expansiones
  horror,
}

/// Configuración de atmósfera visual
class AtmosphereConfig {
  const AtmosphereConfig({
    required this.type,
    required this.primaryAccent,
    required this.secondaryAccent,
    required this.ambientColor,
    required this.shadowIntensity,
  });

  final AtmosphereType type;
  final Color primaryAccent;
  final Color secondaryAccent;
  final Color ambientColor;
  final double shadowIntensity;

  /// Atmósfera de biblioteca (por defecto)
  /// Colores cálidos, terrosos, reminiscentes de madera y papel viejo
  static const library = AtmosphereConfig(
    type: AtmosphereType.library,
    primaryAccent: Color(0xFF8B4513), // Marrón silla de montar (saddle brown)
    secondaryAccent: Color(0xFFD2691E), // Chocolate
    ambientColor: Color(0xFFFFF8DC), // Cornsilk - color papel antiguo
    shadowIntensity: 0.15,
  );

  /// Atmósfera de fantasía (opcional, para futuro)
  /// Colores místicos, púrpuras y azules profundos
  static const fantasy = AtmosphereConfig(
    type: AtmosphereType.fantasy,
    primaryAccent: Color(0xFF4B0082), // Índigo
    secondaryAccent: Color(0xFF9370DB), // Púrpura medio
    ambientColor: Color(0xFFE6E6FA), // Lavanda
    shadowIntensity: 0.20,
  );

  /// Atmósfera de ciencia ficción (opcional, para futuro)
  /// Colores fríos, cian y azules tecnológicos
  static const sciFi = AtmosphereConfig(
    type: AtmosphereType.sciFi,
    primaryAccent: Color(0xFF00CED1), // Turquesa oscuro
    secondaryAccent: Color(0xFF4682B4), // Azul acero
    ambientColor: Color(0xFFE0FFFF), // Cian claro
    shadowIntensity: 0.18,
  );

  /// Atmósfera de terror (opcional, para futuro)
  /// Colores oscuros, rojos sangre y grises
  static const horror = AtmosphereConfig(
    type: AtmosphereType.horror,
    primaryAccent: Color(0xFF8B0000), // Rojo oscuro
    secondaryAccent: Color(0xFF2F4F4F), // Gris pizarra oscuro
    ambientColor: Color(0xFFDCDCDC), // Gainsboro
    shadowIntensity: 0.25,
  );

  /// Obtener configuración por tipo
  static AtmosphereConfig fromType(AtmosphereType type) {
    switch (type) {
      case AtmosphereType.library:
        return library;
      case AtmosphereType.fantasy:
        return fantasy;
      case AtmosphereType.sciFi:
        return sciFi;
      case AtmosphereType.horror:
        return horror;
    }
  }
}
