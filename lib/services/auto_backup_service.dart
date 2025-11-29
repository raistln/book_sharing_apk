import 'dart:developer' as developer;
import 'dart:io';

import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../data/repositories/book_repository.dart';
import 'book_export_service.dart';

class AutoBackupService {
  AutoBackupService({
    required BookRepository bookRepository,
    required BookExportService exportService,
  })  : _bookRepository = bookRepository,
        _exportService = exportService;

  final BookRepository _bookRepository;
  final BookExportService _exportService;

  static const String backupFolderName = 'BookSharing';
  static const String backupSubfolder = 'backups';
  static const int maxBackups = 4;

  /// Performs a backup and saves it to the Downloads folder
  Future<String?> performBackup({int? ownerUserId}) async {
    try {
      developer.log('[AutoBackupService] Starting automatic backup', name: 'AutoBackupService');

      final books = await _bookRepository.fetchActiveBooks(ownerUserId: ownerUserId);
      if (books.isEmpty) {
        developer.log('[AutoBackupService] No books to backup', name: 'AutoBackupService');
        return null;
      }

      final reviews = await _bookRepository.fetchActiveReviews();

      final result = await _exportService.export(
        books: books,
        reviews: reviews,
        format: BookExportFormat.csv,
      );

      final backupDir = await _getBackupDirectory();
      final timestamp = DateFormat('yyyy-MM-dd').format(DateTime.now());
      final filename = 'biblioteca_backup_$timestamp.csv';
      final targetFile = File(p.join(backupDir.path, filename));

      await targetFile.writeAsBytes(result.bytes, flush: true);

      developer.log(
        '[AutoBackupService] Backup saved: ${targetFile.path}',
        name: 'AutoBackupService',
      );

      // Clean old backups
      await _cleanOldBackups(backupDir);

      return targetFile.path;
    } catch (e) {
      developer.log(
        '[AutoBackupService] Backup failed: $e',
        name: 'AutoBackupService',
      );
      return null;
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

  /// Removes old backups, keeping only the most recent ones
  Future<void> _cleanOldBackups(Directory backupDir) async {
    try {
      final files = await backupDir
          .list()
          .where((entity) => entity is File && entity.path.endsWith('.csv'))
          .cast<File>()
          .toList();

      if (files.length <= maxBackups) {
        return;
      }

      // Sort by modification time (newest first)
      files.sort((a, b) {
        final aStat = a.statSync();
        final bStat = b.statSync();
        return bStat.modified.compareTo(aStat.modified);
      });

      // Delete old backups
      final toDelete = files.skip(maxBackups);
      for (final file in toDelete) {
        await file.delete();
        developer.log(
          '[AutoBackupService] Deleted old backup: ${file.path}',
          name: 'AutoBackupService',
        );
      }
    } catch (e) {
      developer.log(
        '[AutoBackupService] Failed to clean old backups: $e',
        name: 'AutoBackupService',
      );
    }
  }

  /// Lists all available backups
  Future<List<File>> listBackups() async {
    try {
      final backupDir = await _getBackupDirectory();
      final files = await backupDir
          .list()
          .where((entity) => entity is File && entity.path.endsWith('.csv'))
          .cast<File>()
          .toList();

      // Sort by modification time (newest first)
      files.sort((a, b) {
        final aStat = a.statSync();
        final bStat = b.statSync();
        return bStat.modified.compareTo(aStat.modified);
      });

      return files;
    } catch (e) {
      developer.log(
        '[AutoBackupService] Failed to list backups: $e',
        name: 'AutoBackupService',
      );
      return [];
    }
  }
}
