import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/auto_backup_service.dart';

final autoBackupServiceProvider = Provider<AutoBackupService>((ref) {
  return AutoBackupService();
});
