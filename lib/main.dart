import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
    if (kDebugMode) {
      debugPrint('Failed to load .env: $e');
    }
  }

  try {
    final url = dotenv.get('SUPABASE_URL', fallback: '');
    final key = dotenv.get('SUPABASE_ANON_KEY', fallback: '');
    if (url.isNotEmpty && key.isNotEmpty) {
      await Supabase.initialize(url: url, anonKey: key);
    } else {
      if (kDebugMode) {
        debugPrint('[Main] Supabase URL or Key missing in .env');
      }
      // Fallback or skip? Supabase.initialize is required for Supabase.instance usage.
       // We might use defaults if available, but for now just log warning.
    }
  } catch (e) {
    if (kDebugMode) {
      debugPrint('Failed to initialize Supabase: $e');
    }
  }

  final notificationService = NotificationService.instance;
  try {
    await notificationService.init();
  } catch (e) {
    if (kDebugMode) {
      debugPrint('Failed to init notification service: $e');
    }
  }

  // Initialize background backup scheduler
  try {
    await BackupSchedulerService.initialize();
  } catch (e) {
    if (kDebugMode) {
      debugPrint('Failed to initialize backup scheduler: $e');
    }
  }

  final permissionService = PermissionService();
  try {
    await permissionService.ensureNotificationPermission();
  } catch (e) {
    if (kDebugMode) {
      debugPrint('Failed to ensure notification permissions: $e');
    }
  }
  
  try {
    await notificationService.requestPermissions();
  } catch (e) {
    if (kDebugMode) {
      debugPrint('Failed to request notification permissions: $e');
    }
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
