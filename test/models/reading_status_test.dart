import 'package:book_sharing_app/models/reading_status.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ReadingStatus', () {
    test('values have correct properties', () {
      expect(ReadingStatus.pending.value, 'pending');
      expect(ReadingStatus.pending.label, 'Pendiente');
      expect(ReadingStatus.pending.icon, Icons.schedule_outlined);

      expect(ReadingStatus.reading.value, 'reading');
      expect(ReadingStatus.reading.label, 'Leyendo');
      expect(ReadingStatus.reading.icon, Icons.auto_stories);

      expect(ReadingStatus.finished.value, 'finished');
      expect(ReadingStatus.finished.label, 'Terminado');
      expect(ReadingStatus.finished.icon, Icons.check_circle_outlined);
    });

    test('fromValue returns correct status', () {
      expect(ReadingStatus.fromValue('pending'), ReadingStatus.pending);
      expect(ReadingStatus.fromValue('reading'), ReadingStatus.reading);
      expect(ReadingStatus.fromValue('finished'), ReadingStatus.finished);
      expect(ReadingStatus.fromValue('invalid'), ReadingStatus.pending); // default
    });

    test('isCompleted returns true only for finished', () {
      expect(ReadingStatus.pending.isCompleted, false);
      expect(ReadingStatus.reading.isCompleted, false);
      expect(ReadingStatus.finished.isCompleted, true);
      expect(ReadingStatus.abandoned.isCompleted, false);
    });

    test('isActive returns true for reading and rereading', () {
      expect(ReadingStatus.pending.isActive, false);
      expect(ReadingStatus.reading.isActive, true);
      expect(ReadingStatus.rereading.isActive, true);
      expect(ReadingStatus.finished.isActive, false);
      expect(ReadingStatus.abandoned.isActive, false);
    });
  });
}
