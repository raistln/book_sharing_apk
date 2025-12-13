import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'providers/notification_providers.dart';
import 'providers/permission_providers.dart';
import 'services/notification_service.dart';
import 'services/permission_service.dart';
import 'services/backup_scheduler_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await dotenv.load();
  } catch (e) {
    debugPrint('Failed to load .env: $e');
  }

  final notificationService = NotificationService.instance;
  try {
    await notificationService.init();
  } catch (e) {
    debugPrint('Failed to init notification service: $e');
  }

  // Initialize background backup scheduler
  try {
    await BackupSchedulerService.initialize();
  } catch (e) {
    debugPrint('Failed to initialize backup scheduler: $e');
  }

  final permissionService = PermissionService();
  try {
    await permissionService.ensureNotificationPermission();
  } catch (e) {
    debugPrint('Failed to ensure notification permissions: $e');
  }
  
  try {
    await notificationService.requestPermissions();
  } catch (e) {
    debugPrint('Failed to request notification permissions: $e');
  }

  runApp(
    ProviderScope(
      overrides: [
        notificationServiceProvider.overrideWithValue(notificationService),
        permissionServiceProvider.overrideWithValue(permissionService),
      ],
      child: const BookSharingApp(),
    ),
  );
}
