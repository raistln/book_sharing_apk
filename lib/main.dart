import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'providers/notification_providers.dart';
import 'providers/permission_providers.dart';
import 'services/notification_service.dart';
import 'services/permission_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final notificationService = NotificationService.instance;
  await notificationService.init();

  final permissionService = PermissionService();
  await permissionService.ensureNotificationPermission();
  await notificationService.requestPermissions();

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
