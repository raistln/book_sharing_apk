import 'package:book_sharing_app/models/bulletin.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('BulletinEvent', () {
    test('constructor sets values', () {
      final event = BulletinEvent(
        titulo: 'Title',
        autor: 'Author',
        hora: '10:00',
        lugar: 'Location',
        descripcion: 'Description',
        fecha: '2023-01-01',
      );
      expect(event.titulo, 'Title');
      expect(event.autor, 'Author');
      expect(event.hora, '10:00');
      expect(event.lugar, 'Location');
      expect(event.descripcion, 'Description');
      expect(event.fecha, '2023-01-01');
    });

    test('toJson returns correct map', () {
      final event = BulletinEvent(
        titulo: 'Title',
        autor: 'Author',
        hora: '10:00',
        lugar: 'Location',
        descripcion: 'Description',
        fecha: '2023-01-01',
      );
      final json = event.toJson();
      expect(json['titulo'], 'Title');
      expect(json['autor'], 'Author');
      expect(json['hora'], '10:00');
      expect(json['lugar'], 'Location');
      expect(json['descripcion'], 'Description');
      expect(json['fecha'], '2023-01-01');
    });

    test('fromJson creates correct BulletinEvent', () {
      final json = {
        'titulo': 'Title',
        'autor': 'Author',
        'hora': '10:00',
        'lugar': 'Location',
        'descripcion': 'Description',
        'fecha': '2023-01-01',
      };
      final event = BulletinEvent.fromJson(json);
      expect(event.titulo, 'Title');
      expect(event.autor, 'Author');
      expect(event.hora, '10:00');
      expect(event.lugar, 'Location');
      expect(event.descripcion, 'Description');
      expect(event.fecha, '2023-01-01');
    });

    test('fromJson handles alternative keys', () {
      final json = {
        'title': 'Title',
        'author': 'Author',
        'time': '10:00',
        'location': 'Location',
        'description': 'Description',
        'date': '2023-01-01',
      };
      final event = BulletinEvent.fromJson(json);
      expect(event.titulo, 'Title');
      expect(event.autor, 'Author');
      expect(event.hora, '10:00');
      expect(event.lugar, 'Location');
      expect(event.descripcion, 'Description');
      expect(event.fecha, '2023-01-01');
    });
  });

  group('Bulletin', () {
    test('constructor sets values', () {
      final events = [BulletinEvent(titulo: 'Event', autor: 'Author', hora: '10:00', lugar: 'Location', descripcion: 'Desc', fecha: '2023-01-01')];
      final bulletin = Bulletin(
        id: 1,
        province: 'Province',
        period: 'Period',
        month: 1,
        year: 2023,
        monthName: 'January',
        narrative: 'Narrative',
        events: events,
        totalEvents: 1,
        generatedAt: DateTime(2023, 1, 1),
      );
      expect(bulletin.id, 1);
      expect(bulletin.province, 'Province');
      expect(bulletin.period, 'Period');
      expect(bulletin.month, 1);
      expect(bulletin.year, 2023);
      expect(bulletin.monthName, 'January');
      expect(bulletin.narrative, 'Narrative');
      expect(bulletin.events, events);
      expect(bulletin.totalEvents, 1);
      expect(bulletin.generatedAt, DateTime(2023, 1, 1));
    });

    test('toJson returns correct map', () {
      final events = [BulletinEvent(titulo: 'Event', autor: 'Author', hora: '10:00', lugar: 'Location', descripcion: 'Desc', fecha: '2023-01-01')];
      final bulletin = Bulletin(
        id: 1,
        province: 'Province',
        period: 'Period',
        month: 1,
        year: 2023,
        monthName: 'January',
        narrative: 'Narrative',
        events: events,
        totalEvents: 1,
        generatedAt: DateTime(2023, 1, 1),
      );
      final json = bulletin.toJson();
      expect(json['id'], 1);
      expect(json['province'], 'Province');
      expect(json['period'], 'Period');
      expect(json['month'], 1);
      expect(json['year'], 2023);
      expect(json['month_name'], 'January');
      expect(json['narrative'], 'Narrative');
      expect(json['events'], isA<List>());
      expect(json['total_events'], 1);
      expect(json['generated_at'], '2023-01-01T00:00:00.000');
    });

    test('fromJson creates correct Bulletin', () {
      final json = {
        'id': 1,
        'province': 'Province',
        'period': 'Period',
        'month': 1,
        'year': 2023,
        'month_name': 'January',
        'narrative': 'Narrative',
        'events': [{'titulo': 'Event', 'autor': 'Author', 'hora': '10:00', 'lugar': 'Location', 'descripcion': 'Desc', 'fecha': '2023-01-01'}],
        'total_events': 1,
        'generated_at': '2023-01-01T00:00:00.000',
      };
      final bulletin = Bulletin.fromJson(json);
      expect(bulletin.id, 1);
      expect(bulletin.province, 'Province');
      expect(bulletin.period, 'Period');
      expect(bulletin.month, 1);
      expect(bulletin.year, 2023);
      expect(bulletin.monthName, 'January');
      expect(bulletin.narrative, 'Narrative');
      expect(bulletin.events.length, 1);
      expect(bulletin.totalEvents, 1);
      expect(bulletin.generatedAt, DateTime(2023, 1, 1));
    });
  });
}
