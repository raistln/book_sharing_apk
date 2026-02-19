import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

/// Utility to completely reset the local database
class DatabaseReset {
  /// Completely delete the local database file and all related data
  static Future<void> deleteDatabaseFile() async {
    try {
      if (kDebugMode) {
        debugPrint('[DatabaseReset] Starting complete database deletion...');
      }

      // Get all possible database locations
      final directories = await _getAllDatabaseDirectories();

      for (final dir in directories) {
        await _deleteDatabaseInDirectory(dir);
      }

      // Also try to delete from common database paths
      await _deleteFromCommonPaths();

      if (kDebugMode) {
        debugPrint('[DatabaseReset] Complete database deletion finished');
      }
    } catch (error) {
      if (kDebugMode) {
        debugPrint('[DatabaseReset] Error deleting database: $error');
      }
      rethrow;
    }
  }

  /// Get all possible database directories
  static Future<List<Directory>> _getAllDatabaseDirectories() async {
    final directories = <Directory>[];

    try {
      // Application documents directory (primary location)
      final appDocumentsDir = await getApplicationDocumentsDirectory();
      directories.add(appDocumentsDir);

      // Application support directory
      final appSupportDir = await getApplicationSupportDirectory();
      directories.add(appSupportDir);

      // Temporary directory
      final tempDir = await getTemporaryDirectory();
      directories.add(tempDir);

      // External storage (if available)
      if (Platform.isAndroid) {
        final externalDir = await getExternalStorageDirectory();
        if (externalDir != null) {
          directories.add(externalDir);
        }
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[DatabaseReset] Error getting directories: $e');
      }
    }

    return directories;
  }

  /// Delete database files in a specific directory
  static Future<void> _deleteDatabaseInDirectory(Directory dir) async {
    try {
      if (kDebugMode) {
        debugPrint('[DatabaseReset] Checking directory: ${dir.path}');
      }

      // Common database file names
      final dbNames = [
        'book_sharing.db',
        'book_sharing.sqlite',
        'book_sharing.sqlite3',
        'drift_db.sqlite',
        'app_database.db',
        'database.db'
      ];

      for (final dbName in dbNames) {
        final dbFile = File('${dir.path}/$dbName');
        if (await dbFile.exists()) {
          await dbFile.delete();
          if (kDebugMode) {
            debugPrint('[DatabaseReset] Deleted: ${dbFile.path}');
          }
        }

        // Delete WAL and SHM files
        final walFile = File('${dir.path}/$dbName-wal');
        final shmFile = File('${dir.path}/$dbName-shm');
        final journalFile = File('${dir.path}/$dbName-journal');

        for (final file in [walFile, shmFile, journalFile]) {
          if (await file.exists()) {
            await file.delete();
            if (kDebugMode) {
              debugPrint('[DatabaseReset] Deleted: ${file.path}');
            }
          }
        }
      }

      // Also check for any .db files in the directory
      await _deleteAllDbFiles(dir);
    } catch (e) {
      if (kDebugMode) {
        debugPrint(
            '[DatabaseReset] Error deleting in directory ${dir.path}: $e');
      }
    }
  }

  /// Delete all .db files in directory
  static Future<void> _deleteAllDbFiles(Directory dir) async {
    try {
      final files = await dir.list().toList();
      for (final file in files) {
        if (file is File) {
          final fileName = file.path.split('/').last;
          if (fileName.endsWith('.db') ||
              fileName.endsWith('.sqlite') ||
              fileName.endsWith('.sqlite3')) {
            await file.delete();
            if (kDebugMode) {
              debugPrint('[DatabaseReset] Deleted database file: ${file.path}');
            }
          }
        }
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[DatabaseReset] Error deleting .db files: $e');
      }
    }
  }

  /// Delete from common database paths
  static Future<void> _deleteFromCommonPaths() async {
    try {
      // Android specific paths
      if (Platform.isAndroid) {
        final paths = [
          '/data/data/databases',
          '/data/data/app_databases',
          '/data/data/app_flutter/databases',
        ];

        for (final path in paths) {
          final dir = Directory(path);
          if (await dir.exists()) {
            await _deleteAllDbFiles(dir);
          }
        }
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[DatabaseReset] Error deleting from common paths: $e');
      }
    }
  }

  /// Force close database connections and delete
  static Future<void> forceResetDatabase() async {
    try {
      if (kDebugMode) {
        debugPrint('[DatabaseReset] Force reset starting...');
      }

      // First try to delete normally
      await deleteDatabaseFile();

      // Wait a moment to ensure file handles are released
      await Future.delayed(const Duration(milliseconds: 500));

      // Try again to be sure
      await deleteDatabaseFile();

      if (kDebugMode) {
        debugPrint('[DatabaseReset] Force reset completed');
      }
    } catch (error) {
      if (kDebugMode) {
        debugPrint('[DatabaseReset] Force reset error: $error');
      }
      rethrow;
    }
  }

  /// Check if database exists and has old data
  static Future<bool> hasOldDatabase() async {
    try {
      final directories = await _getAllDatabaseDirectories();

      for (final dir in directories) {
        final dbFile = File('${dir.path}/book_sharing.db');
        if (await dbFile.exists()) {
          final fileSize = await dbFile.length();
          if (fileSize > 1024) {
            // Larger than 1KB
            if (kDebugMode) {
              debugPrint('[DatabaseReset] Found database at: ${dbFile.path}');
            }
            return true;
          }
        }
      }

      return false;
    } catch (error) {
      if (kDebugMode) {
        debugPrint('[DatabaseReset] Error checking database: $error');
      }
      return false;
    }
  }

  /// Reset database if it has old data
  static Future<void> resetIfOldDatabase() async {
    if (await hasOldDatabase()) {
      if (kDebugMode) {
        debugPrint('[DatabaseReset] Old database detected, force deleting...');
      }
      await forceResetDatabase();

      if (kDebugMode) {
        debugPrint('[DatabaseReset] Please restart the app to continue');
      }
    } else {
      if (kDebugMode) {
        debugPrint('[DatabaseReset] No old database found');
      }
    }
  }
}
