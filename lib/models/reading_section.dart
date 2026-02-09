import 'dart:convert';

/// Representa un tramo (sección) de lectura del libro
class ReadingSection {
  const ReadingSection({
    required this.numero,
    required this.capituloInicio,
    required this.capituloFin,
    required this.fechaApertura,
    required this.fechaCierre,
  });

  final int numero;
  final int capituloInicio;
  final int capituloFin;
  final DateTime fechaApertura;
  final DateTime fechaCierre;

  bool get isAbierto {
    final now = DateTime.now();
    return now.isAfter(fechaApertura) && now.isBefore(fechaCierre);
  }

  bool get isCerrado => DateTime.now().isAfter(fechaCierre);

  Map<String, dynamic> toJson() => {
        'numero': numero,
        'capitulo_inicio': capituloInicio,
        'capitulo_fin': capituloFin,
        'fecha_apertura': fechaApertura.toIso8601String(),
        'fecha_cierre': fechaCierre.toIso8601String(),
        'abierto': isAbierto,
      };

  factory ReadingSection.fromJson(Map<String, dynamic> json) {
    return ReadingSection(
      numero: json['numero'] as int,
      capituloInicio: json['capitulo_inicio'] as int,
      capituloFin: json['capitulo_fin'] as int,
      fechaApertura: DateTime.parse(json['fecha_apertura'] as String),
      fechaCierre: DateTime.parse(json['fecha_cierre'] as String),
    );
  }

  @override
  String toString() =>
      'Tramo $numero: Caps $capituloInicio-$capituloFin (${fechaApertura.toLocal()} - ${fechaCierre.toLocal()})';
}

/// Utilidades para serializar/deserializar listas de tramos
class ReadingSectionListHelper {
  static String toJsonString(List<ReadingSection> sections) {
    final jsonList = sections.map((s) => s.toJson()).toList();
    return jsonEncode(jsonList);
  }

  static List<ReadingSection> fromJsonString(String jsonString) {
    if (jsonString.isEmpty) return [];
    final jsonList = jsonDecode(jsonString) as List;
    return jsonList
        .map((json) => ReadingSection.fromJson(json as Map<String, dynamic>))
        .toList();
  }
}
