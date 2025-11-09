import 'package:permission_handler/permission_handler.dart';

/// Centraliza la solicitud de permisos en tiempo de ejecución.
class PermissionService {
  /// Solicita el permiso de notificaciones (Android 13+/iOS) si es necesario.
  Future<bool> ensureNotificationPermission() async {
    try {
      final status = await Permission.notification.status;
      if (status.isGranted || status.isLimited) {
        return true;
      }

      final result = await Permission.notification.request();
      if (result.isPermanentlyDenied) {
        await openAppSettings();
      }
      return result.isGranted || result.isLimited;
    } on UnimplementedError {
      // Plataformas que no soportan este permiso.
      return true;
    }
  }

  /// Solicita el permiso de cámara cuando se quiera capturar una portada.
  Future<bool> ensureCameraPermission() async {
    try {
      final status = await Permission.camera.status;
      if (status.isGranted) {
        return true;
      }

      final result = await Permission.camera.request();
      if (result.isPermanentlyDenied) {
        await openAppSettings();
      }
      return result.isGranted;
    } on UnimplementedError {
      // En plataformas sin cámara simplemente continuamos.
      return true;
    }
  }
}
