import 'dart:convert';

class Bulletin {
  final int id;
  final String province;
  final String period;
  final int month;
  final int year;
  final String? monthName;
  final String narrative;
  final List<BulletinEvent> events;
  final int totalEvents;
  final DateTime generatedAt;

  Bulletin({
    required this.id,
    required this.province,
    required this.period,
    required this.month,
    required this.year,
    this.monthName,
    required this.narrative,
    required this.events,
    required this.totalEvents,
    required this.generatedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'province': province,
      'period': period,
      'month': month,
      'year': year,
      'month_name': monthName,
      'narrative': narrative,
      'events': events.map((e) => e.toJson()).toList(),
      'total_events': totalEvents,
      'generated_at': generatedAt.toIso8601String(),
    };
  }

  factory Bulletin.fromJson(Map<String, dynamic> json) {
    var eventsJson = json['events'];
    List<BulletinEvent> eventsList = [];

    if (eventsJson != null) {
      if (eventsJson is String) {
        eventsJson = jsonDecode(eventsJson);
      }
      if (eventsJson is List) {
        eventsList = eventsJson
            .map((e) => BulletinEvent.fromJson(e as Map<String, dynamic>))
            .toList();
      }
    }

    return Bulletin(
      id: json['id'] as int? ?? 0,
      province: json['province'] as String? ?? '',
      period: json['period'] as String? ?? '',
      month: json['month'] as int? ?? 0,
      year: json['year'] as int? ?? 0,
      monthName: json['month_name'] as String?,
      narrative: json['narrative'] as String? ?? '',
      events: eventsList,
      totalEvents: json['total_events'] as int? ?? 0,
      generatedAt: DateTime.tryParse(json['generated_at'] as String? ?? '') ??
          DateTime.now(),
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

  Map<String, dynamic> toJson() {
    return {
      'titulo': titulo,
      'autor': autor,
      'hora': hora,
      'lugar': lugar,
      'descripcion': descripcion,
      'fecha': fecha,
    };
  }

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
