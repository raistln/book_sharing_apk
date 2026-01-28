import 'dart:convert';

class Bulletin {
  final int id;
  final String narrativa;
  final List<BulletinEvent> contenido;
  final int totalEventos;
  final String periodo;
  final String provincia;

  Bulletin({
    required this.id,
    required this.narrativa,
    required this.contenido,
    required this.totalEventos,
    required this.periodo,
    required this.provincia,
  });

  factory Bulletin.fromJson(Map<String, dynamic> json) {
    var contenidoJson = json['contenido'];
    List<BulletinEvent> eventsList = [];

    if (contenidoJson != null) {
      if (contenidoJson is String) {
        // In case it's stored as a string in Supabase
        contenidoJson = jsonDecode(contenidoJson);
      }
      if (contenidoJson is List) {
        eventsList = contenidoJson
            .map((e) => BulletinEvent.fromJson(e as Map<String, dynamic>))
            .toList();
      }
    }

    return Bulletin(
      id: json['id'] as int? ?? 0,
      narrativa: json['narrativa'] as String? ?? '',
      contenido: eventsList,
      totalEventos: json['total_eventos'] as int? ?? 0,
      periodo: json['periodo'] as String? ?? '',
      provincia: json['provincia'] as String? ?? '',
    );
  }
}

class BulletinEvent {
  final String titulo;
  final String autor;
  final String hora;
  final String lugar;
  final String descripcion;
  final String fecha;

  BulletinEvent({
    required this.titulo,
    required this.autor,
    required this.hora,
    required this.lugar,
    required this.descripcion,
    required this.fecha,
  });

  factory BulletinEvent.fromJson(Map<String, dynamic> json) {
    return BulletinEvent(
      titulo: json['titulo'] as String? ?? json['title'] as String? ?? '',
      autor: json['autor'] as String? ?? json['author'] as String? ?? '',
      hora: json['hora'] as String? ?? json['time'] as String? ?? '',
      lugar: json['lugar'] as String? ?? json['location'] as String? ?? '',
      descripcion: json['descripcion'] as String? ??
          json['description'] as String? ??
          '',
      fecha: json['fecha'] as String? ?? json['date'] as String? ?? '',
    );
  }
}
