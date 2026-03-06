import 'package:book_sharing_app/models/reading_section.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ReadingSection', () {
    test('constructor sets values', () {
      final section = ReadingSection(
        numero: 1,
        capituloInicio: 1,
        capituloFin: 5,
        fechaApertura: DateTime(2023, 1, 1),
        fechaCierre: DateTime(2023, 1, 7),
      );
      expect(section.numero, 1);
      expect(section.capituloInicio, 1);
      expect(section.capituloFin, 5);
      expect(section.fechaApertura, DateTime(2023, 1, 1));
      expect(section.fechaCierre, DateTime(2023, 1, 7));
    });

    test('isAbierto returns true when current date is between dates', () {
      final section = ReadingSection(
        numero: 1,
        capituloInicio: 1,
        capituloFin: 5,
        fechaApertura: DateTime.now().subtract(const Duration(days: 1)),
        fechaCierre: DateTime.now().add(const Duration(days: 1)),
      );
      expect(section.isAbierto, true);
    });

    test('isAbierto returns false when current date is before opening', () {
      final section = ReadingSection(
        numero: 1,
        capituloInicio: 1,
        capituloFin: 5,
        fechaApertura: DateTime.now().add(const Duration(days: 1)),
        fechaCierre: DateTime.now().add(const Duration(days: 7)),
      );
      expect(section.isAbierto, false);
    });

    test('isAbierto returns false when current date is after closing', () {
      final section = ReadingSection(
        numero: 1,
        capituloInicio: 1,
        capituloFin: 5,
        fechaApertura: DateTime.now().subtract(const Duration(days: 7)),
        fechaCierre: DateTime.now().subtract(const Duration(days: 1)),
      );
      expect(section.isAbierto, false);
    });

    test('isCerrado returns true when current date is after closing', () {
      final section = ReadingSection(
        numero: 1,
        capituloInicio: 1,
        capituloFin: 5,
        fechaApertura: DateTime.now().subtract(const Duration(days: 7)),
        fechaCierre: DateTime.now().subtract(const Duration(days: 1)),
      );
      expect(section.isCerrado, true);
    });

    test('isCerrado returns false when current date is before closing', () {
      final section = ReadingSection(
        numero: 1,
        capituloInicio: 1,
        capituloFin: 5,
        fechaApertura: DateTime.now().subtract(const Duration(days: 1)),
        fechaCierre: DateTime.now().add(const Duration(days: 1)),
      );
      expect(section.isCerrado, false);
    });

    test('toJson returns correct map', () {
      final section = ReadingSection(
        numero: 1,
        capituloInicio: 1,
        capituloFin: 5,
        fechaApertura: DateTime(2023, 1, 1),
        fechaCierre: DateTime(2023, 1, 7),
      );
      final json = section.toJson();
      expect(json['numero'], 1);
      expect(json['capitulo_inicio'], 1);
      expect(json['capitulo_fin'], 5);
      expect(json['fecha_apertura'], '2023-01-01T00:00:00.000');
      expect(json['fecha_cierre'], '2023-01-07T00:00:00.000');
      expect(json['abierto'], isA<bool>());
    });

    test('fromJson creates correct ReadingSection', () {
      final json = {
        'numero': 1,
        'capitulo_inicio': 1,
        'capitulo_fin': 5,
        'fecha_apertura': '2023-01-01T00:00:00.000',
        'fecha_cierre': '2023-01-07T00:00:00.000',
      };
      final section = ReadingSection.fromJson(json);
      expect(section.numero, 1);
      expect(section.capituloInicio, 1);
      expect(section.capituloFin, 5);
      expect(section.fechaApertura, DateTime(2023, 1, 1));
      expect(section.fechaCierre, DateTime(2023, 1, 7));
    });

    test('toString returns formatted string', () {
      final section = ReadingSection(
        numero: 1,
        capituloInicio: 1,
        capituloFin: 5,
        fechaApertura: DateTime(2023, 1, 1),
        fechaCierre: DateTime(2023, 1, 7),
      );
      final str = section.toString();
      expect(str, contains('Tramo 1'));
      expect(str, contains('Caps 1-5'));
    });
  });

  group('ReadingSectionListHelper', () {
    test('toJsonString converts list to JSON string', () {
      final sections = [
        ReadingSection(
          numero: 1,
          capituloInicio: 1,
          capituloFin: 5,
          fechaApertura: DateTime(2023, 1, 1),
          fechaCierre: DateTime(2023, 1, 7),
        ),
      ];
      final jsonString = ReadingSectionListHelper.toJsonString(sections);
      expect(jsonString, isA<String>());
      expect(jsonString, contains('numero'));
    });

    test('fromJsonString converts JSON string to list', () {
      const jsonString = '[{"numero":1,"capitulo_inicio":1,"capitulo_fin":5,"fecha_apertura":"2023-01-01T00:00:00.000","fecha_cierre":"2023-01-07T00:00:00.000","abierto":false}]';
      final sections = ReadingSectionListHelper.fromJsonString(jsonString);
      expect(sections.length, 1);
      expect(sections.first.numero, 1);
    });

    test('fromJsonString returns empty list for empty string', () {
      final sections = ReadingSectionListHelper.fromJsonString('');
      expect(sections, []);
    });
  });
}
