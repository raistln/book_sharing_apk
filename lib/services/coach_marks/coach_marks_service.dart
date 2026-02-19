import 'package:shared_preferences/shared_preferences.dart';

import 'coach_mark_models.dart';

class CoachMarksService {
  static const _pendingPrefix = 'coach_mark_pending_';
  static const _seenPrefix = 'coach_mark_seen_';

  String _pendingKey(CoachMarkId id) => '$_pendingPrefix${id.storageKey}';
  String _seenKey(CoachMarkId id) => '$_seenPrefix${id.storageKey}';

  Future<bool> isPending(CoachMarkId id) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_pendingKey(id)) ?? false;
  }

  Future<void> setPending(CoachMarkId id, bool pending) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_pendingKey(id), pending);
  }

  Future<bool> hasSeen(CoachMarkId id) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_seenKey(id)) ?? false;
  }

  Future<void> markSeen(CoachMarkId id) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_seenKey(id), true);
    await prefs.setBool(_pendingKey(id), false);
  }

  Future<void> resetMark(CoachMarkId id) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_pendingKey(id), true);
    await prefs.setBool(_seenKey(id), false);
  }

  Future<void> resetSequence(CoachMarkSequence sequence) async {
    final marks = coachMarkSequences[sequence];
    if (marks == null) return;
    final prefs = await SharedPreferences.getInstance();
    for (final mark in marks) {
      await prefs.setBool(_pendingKey(mark), true);
      await prefs.setBool(_seenKey(mark), false);
    }
  }

  Future<List<CoachMarkId>> pendingMarksForSequence(
      CoachMarkSequence sequence) async {
    final marks = coachMarkSequences[sequence];
    if (marks == null) {
      return const [];
    }

    final prefs = await SharedPreferences.getInstance();
    final result = <CoachMarkId>[];
    for (final mark in marks) {
      final pending = prefs.getBool(_pendingKey(mark)) ?? false;
      final seen = prefs.getBool(_seenKey(mark)) ?? false;
      if (pending || !seen) {
        result.add(mark);
      }
    }
    return result;
  }

  Future<void> markSequenceCompleted(CoachMarkSequence sequence) async {
    final marks = coachMarkSequences[sequence];
    if (marks == null) return;
    final prefs = await SharedPreferences.getInstance();
    for (final mark in marks) {
      await prefs.setBool(_pendingKey(mark), false);
      await prefs.setBool(_seenKey(mark), true);
    }
  }

  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    for (final entry in coachMarkSequences.entries) {
      for (final mark in entry.value) {
        await prefs.remove(_pendingKey(mark));
        await prefs.remove(_seenKey(mark));
      }
    }
  }
}
