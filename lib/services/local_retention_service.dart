import 'dart:developer' as developer;

import 'package:drift/drift.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/local/database.dart';

class LocalRetentionService {
  LocalRetentionService(this._db);

  final AppDatabase _db;

  static const String _lastRunKey = 'local_retention_last_run_iso';
  static const String enabledPrefKey = 'local_retention_enabled';
  static const Duration _minRunInterval = Duration(hours: 24);

  Future<void> runIfNeeded() async {
    final prefs = await SharedPreferences.getInstance();
    final enabled = prefs.getBool(enabledPrefKey) ?? true;
    if (!enabled) {
      return;
    }

    final now = DateTime.now().toUtc();
    final raw = prefs.getString(_lastRunKey);
    final lastRun = raw != null ? DateTime.tryParse(raw) : null;

    if (lastRun != null && now.difference(lastRun) < _minRunInterval) {
      return;
    }

    await runNow();
    await prefs.setString(_lastRunKey, now.toIso8601String());
  }

  Future<bool> isEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(enabledPrefKey) ?? true;
  }

  Future<void> setEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(enabledPrefKey, enabled);
  }

  Future<void> runNow() async {
    final now = DateTime.now().toUtc();

    // Keep local data slightly longer than cloud cleanup windows.
    final ninetyDaysAgo = now.subtract(const Duration(days: 90));
    final oneEightyDaysAgo = now.subtract(const Duration(days: 180));
    final threeSixtyFiveDaysAgo = now.subtract(const Duration(days: 365));

    await _db.transaction(() async {
      // Soft-deleted records cleanup
      await (_db.delete(_db.sectionComments)
            ..where((t) =>
                t.isDeleted.equals(true) &
                t.updatedAt.isSmallerThanValue(ninetyDaysAgo)))
          .go();
      await (_db.delete(_db.bookProposals)
            ..where((t) =>
                t.isDeleted.equals(true) &
                t.updatedAt.isSmallerThanValue(ninetyDaysAgo)))
          .go();
      await (_db.delete(_db.clubBooks)
            ..where((t) =>
                t.isDeleted.equals(true) &
                t.updatedAt.isSmallerThanValue(ninetyDaysAgo)))
          .go();
      await (_db.delete(_db.clubMembers)
            ..where((t) =>
                t.isDeleted.equals(true) &
                t.updatedAt.isSmallerThanValue(ninetyDaysAgo)))
          .go();
      await (_db.delete(_db.readingClubs)
            ..where((t) =>
                t.isDeleted.equals(true) &
                t.updatedAt.isSmallerThanValue(ninetyDaysAgo)))
          .go();

      // Ephemeral discussion data cleanup
      await (_db.delete(_db.commentReports)
            ..where((t) => t.createdAt.isSmallerThanValue(oneEightyDaysAgo)))
          .go();
      await (_db.delete(_db.moderationLogs)
            ..where((t) => t.createdAt.isSmallerThanValue(threeSixtyFiveDaysAgo)))
          .go();

      // Closed proposal cleanup (kept for 180 days locally)
      await (_db.delete(_db.bookProposals)
            ..where((t) =>
                t.isDeleted.equals(false) &
                t.status.isIn(['cerrada', 'descartada', 'ganadora']) &
                t.updatedAt.isSmallerThanValue(oneEightyDaysAgo)))
          .go();
    });

    developer.log(
      '[LocalRetention] Local retention cleanup executed',
      name: 'LocalRetentionService',
    );
  }
}
