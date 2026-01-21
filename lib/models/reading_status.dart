import 'package:flutter/material.dart';

enum ReadingStatus {
  pending('pending', 'Pendiente', Icons.schedule_outlined),
  reading('reading', 'Leyendo', Icons.auto_stories),
  paused('paused', 'En pausa', Icons.pause_circle_outlined),
  finished('finished', 'Terminado', Icons.check_circle_outlined),
  abandoned('abandoned', 'Abandonado', Icons.block_outlined),
  rereading('rereading', 'Releyendo', Icons.replay_outlined);

  const ReadingStatus(this.value, this.label, this.icon);

  final String value;
  final String label;
  final IconData icon;

  static ReadingStatus fromValue(String value) {
    return ReadingStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => ReadingStatus.pending,
    );
  }

  /// Returns true if this status means the book has been read
  bool get isCompleted => this == ReadingStatus.finished;

  /// Returns true if the book is currently being read
  bool get isActive =>
      this == ReadingStatus.reading || this == ReadingStatus.rereading;
}
