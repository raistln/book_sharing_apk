import 'dart:developer' as developer;

import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';

import '../data/local/book_dao.dart';
import '../data/local/database.dart';
import '../data/local/group_dao.dart';
import '../data/repositories/book_repository.dart';
import 'auto_backup_service.dart';
import 'book_export_service.dart';

/// Background task callback for workmanager
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    try {
      developer.log('[BackupScheduler] Starting scheduled backup task', name: 'BackupScheduler');

      // Initialize database and services
      final database = AppDatabase();
      final bookDao = BookDao(database);
      final groupDao = GroupDao(database);
      
      final bookRepository = BookRepository(
        bookDao,
        groupDao: groupDao,
      );
      const exportService = BookExportService();
      final backupService = AutoBackupService(
        bookRepository: bookRepository,
        exportService: exportService,
      );

      // Perform backup
      final result = await backupService.performBackup();

      await database.close();

      if (result != null) {
        developer.log(
          '[BackupScheduler] Backup completed successfully: $result',
          name: 'BackupScheduler',
        );
        return true;
      } else {
        developer.log('[BackupScheduler] Backup failed', name: 'BackupScheduler');
        return false;
      }
    } catch (e) {
      developer.log('[BackupScheduler] Error during backup: $e', name: 'BackupScheduler');
      return false;
    }
  });
}

class BackupSchedulerService {
  static const String _taskName = 'weekly_backup';
  static const String _prefKey = 'auto_backup_enabled';

  /// Initializes workmanager
  static Future<void> initialize() async {
    await Workmanager().initialize(
      callbackDispatcher,
    );
    developer.log('[BackupScheduler] Workmanager initialized', name: 'BackupScheduler');
  }

  /// Enables automatic weekly backups
  static Future<void> enableAutoBackup() async {
    try {
      await Workmanager().registerPeriodicTask(
        _taskName,
        _taskName,
        frequency: const Duration(days: 7),
        constraints: Constraints(
          networkType: NetworkType.notRequired,
        ),
      );

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_prefKey, true);

      developer.log('[BackupScheduler] Auto backup enabled', name: 'BackupScheduler');
    } catch (e) {
      developer.log('[BackupScheduler] Failed to enable auto backup: $e', name: 'BackupScheduler');
      rethrow;
    }
  }

  /// Disables automatic weekly backups
  static Future<void> disableAutoBackup() async {
    try {
      await Workmanager().cancelByUniqueName(_taskName);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_prefKey, false);

      developer.log('[BackupScheduler] Auto backup disabled', name: 'BackupScheduler');
    } catch (e) {
      developer.log('[BackupScheduler] Failed to disable auto backup: $e', name: 'BackupScheduler');
      rethrow;
    }
  }

  /// Checks if auto backup is currently enabled
  static Future<bool> isAutoBackupEnabled() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_prefKey) ?? false;
    } catch (e) {
      developer.log('[BackupScheduler] Failed to check auto backup status: $e', name: 'BackupScheduler');
      return false;
    }
  }
}
