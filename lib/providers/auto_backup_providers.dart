import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/auto_backup_service.dart';
import 'book_providers.dart';

final autoBackupServiceProvider = Provider<AutoBackupService>((ref) {
  return AutoBackupService(
    bookRepository: ref.watch(bookRepositoryProvider),
    exportService: ref.watch(bookExportServiceProvider),
  );
});
