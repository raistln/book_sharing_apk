import 'dart:developer' as developer;
import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AutoBackupService {
  AutoBackupService();

  static const String backupFolderName = 'BookSharing';
  static const String backupSubfolder = 'backups';
  static const String _lastBackupIndexKey = 'last_backup_index';

  /// Performs a backup of the database and covers to a ZIP file.
  /// Rotates between backup_1.zip and backup_2.zip.
  Future<String?> performBackup({int? ownerUserId}) async {
    try {
      developer.log('[AutoBackupService] Starting automatic ZIP backup',
          name: 'AutoBackupService');

      // 1. Prepare files to backup
      final dbFolder = await getApplicationDocumentsDirectory();
      final dbPath = p.join(dbFolder.path, 'book_sharing_v2.sqlite');
      final coversPath = p.join(dbFolder.path, 'covers');

      final dbFile = File(dbPath);
      if (!dbFile.existsSync()) {
        developer.log('[AutoBackupService] Database file not found at $dbPath',
            name: 'AutoBackupService');
        return null;
      }

      // 2. Create archive
      final archive = Archive();

      // Add Database
      final dbBytes = await dbFile.readAsBytes();
      archive.addFile(
          ArchiveFile('book_sharing_v2.sqlite', dbBytes.length, dbBytes));

      // Add Covers
      final coversDir = Directory(coversPath);
      if (await coversDir.exists()) {
        await for (final entity in coversDir.list(recursive: false)) {
          if (entity is File) {
            final fileName = p.basename(entity.path);
            final bytes = await entity.readAsBytes();
            archive
                .addFile(ArchiveFile('covers/$fileName', bytes.length, bytes));
          }
        }
      }

      // 3. Encoder
      final encoder = ZipEncoder();
      final zipData = encoder.encode(archive);

      // 4. Determine target file (rotation)
      final backupDir = await _getBackupDirectory();
      final prefs = await SharedPreferences.getInstance();
      int lastIndex =
          prefs.getInt(_lastBackupIndexKey) ?? 2; // Default to 2 so next is 1
      int nextIndex = lastIndex == 1 ? 2 : 1;

      final filename = 'backup_$nextIndex.zip';
      final targetFile = File(p.join(backupDir.path, filename));

      // 5. Write file
      await targetFile.writeAsBytes(zipData, flush: true);

      // Update rotation index
      await prefs.setInt(_lastBackupIndexKey, nextIndex);

      developer.log(
        '[AutoBackupService] ZIP Backup saved: ${targetFile.path}',
        name: 'AutoBackupService',
      );

      // Legacy cleanup (remove old CSVs if any)
      await _cleanOldCsvBackups(backupDir);

      return targetFile.path;
    } catch (e) {
      developer.log(
        '[AutoBackupService] Backup failed: $e',
        name: 'AutoBackupService',
      );
      return null;
    }
  }

  /// Restores the database and covers from a ZIP file.
  /// WARNING: Overwrites existing data.
  Future<void> restoreFromZip(File zipFile) async {
    try {
      developer.log('[AutoBackupService] Restoring from ${zipFile.path}',
          name: 'AutoBackupService');

      final bytes = await zipFile.readAsBytes();
      final archive = ZipDecoder().decodeBytes(bytes);

      final appDocDir = await getApplicationDocumentsDirectory();

      for (final file in archive) {
        if (file.isFile) {
          final filename = file.name;
          if (filename == 'book_sharing_v2.sqlite') {
            final outFile =
                File(p.join(appDocDir.path, 'book_sharing_v2.sqlite'));
            await outFile.writeAsBytes(file.content as List<int>, flush: true);
            developer.log('[AutoBackupService] Restored database',
                name: 'AutoBackupService');
          } else if (filename.startsWith('covers/')) {
            // Ensure covers/ subdirectory exists
            final coversDir = Directory(p.join(appDocDir.path, 'covers'));
            if (!await coversDir.exists()) {
              await coversDir.create(recursive: true);
            }
            final extractFilename =
                p.basename(filename); // Just the filename, strip 'covers/'
            if (extractFilename.isNotEmpty) {
              final outFile = File(p.join(coversDir.path, extractFilename));
              await outFile.writeAsBytes(file.content as List<int>,
                  flush: true);
            }
          }
        }
      }
      developer.log('[AutoBackupService] Restore completed successfully',
          name: 'AutoBackupService');
    } catch (e) {
      developer.log('[AutoBackupService] Restore failed: $e',
          name: 'AutoBackupService');
      rethrow;
    }
  }

  /// Searches for available backups in the standard location.
  Future<List<File>> getAvailableBackups() async {
    try {
      final backupDir = await _getBackupDirectory();
      if (!await backupDir.exists()) return [];

      final file1 = File(p.join(backupDir.path, 'backup_1.zip'));
      final file2 = File(p.join(backupDir.path, 'backup_2.zip'));

      final backups = <File>[];
      if (await file1.exists()) backups.add(file1);
      if (await file2.exists()) backups.add(file2);

      // Sort by modified date descending (newest first)
      backups
          .sort((a, b) => b.lastModifiedSync().compareTo(a.lastModifiedSync()));

      return backups;
    } catch (e) {
      developer.log('[AutoBackupService] Error listing backups: $e',
          name: 'AutoBackupService');
      return [];
    }
  }

  /// Gets or creates the backup directory in Downloads
  Future<Directory> _getBackupDirectory() async {
    final downloadsDir = await getDownloadsDirectory();
    if (downloadsDir == null) {
      throw Exception('Downloads directory not available');
    }

    final backupDir = Directory(
      p.join(downloadsDir.path, backupFolderName, backupSubfolder),
    );

    if (!await backupDir.exists()) {
      await backupDir.create(recursive: true);
    }

    return backupDir;
  }

  Future<void> _cleanOldCsvBackups(Directory backupDir) async {
    try {
      final files = await backupDir
          .list()
          .where((entity) => entity is File && entity.path.endsWith('.csv'))
          .cast<File>()
          .toList();

      for (final file in files) {
        await file.delete();
      }
    } catch (_) {}
  }
}
