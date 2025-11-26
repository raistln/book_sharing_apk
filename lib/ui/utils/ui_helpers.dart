import 'package:flutter/material.dart';

/// Helper functions for UI improvements
class UIHelpers {
  /// Shows a friendly error message based on the error type
  static String getFriendlyErrorMessage(dynamic error) {
    final errorStr = error.toString().toLowerCase();

    // Errores de red
    if (errorStr.contains('socketexception') ||
        errorStr.contains('networkexception') ||
        errorStr.contains('failed host lookup')) {
      return 'No hay conexión a internet. Verifica tu conexión y vuelve a intentarlo.';
    }

    // Timeout
    if (errorStr.contains('timeout')) {
      return 'La operación tardó demasiado. Verifica tu conexión e intenta de nuevo.';
    }

    // Permisos
    if (errorStr.contains('permission') || errorStr.contains('unauthorized')) {
      return 'No tienes permisos para realizar esta acción.';
    }

    // Validación
    if (errorStr.contains('validation') || errorStr.contains('invalid')) {
      return 'Algunos datos no son válidos. Revisa la información e intenta de nuevo.';
    }

    // Libro ya prestado (mensaje ya amigable)
    if (errorStr.contains('ya tiene un préstamo activo')) {
      return error.toString();
    }

    // Préstamo no encontrado
    if (errorStr.contains('no se pudo') || errorStr.contains('not found')) {
      return 'No se pudo completar la operación. Por favor, intenta de nuevo.';
    }

    // Error genérico
    return 'Ocurrió un error inesperado. Por favor, intenta de nuevo más tarde.';
  }

  /// Shows a confirmation dialog for critical actions
  static Future<bool> showConfirmDialog({
    required BuildContext context,
    required String title,
    required String message,
    String confirmText = 'Confirmar',
    String cancelText = 'Cancelar',
    bool isDangerous = true,
  }) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(title),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(cancelText),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context, true),
                style: isDangerous
                    ? FilledButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.error,
                      )
                    : null,
                child: Text(confirmText),
              ),
            ],
          ),
        ) ??
        false;
  }

  /// Shows an error snackbar with friendly message
  static void showErrorSnackBar(
    BuildContext context,
    dynamic error, {
    Duration duration = const Duration(seconds: 4),
  }) {
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(getFriendlyErrorMessage(error)),
        backgroundColor: Theme.of(context).colorScheme.error,
        duration: duration,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// Shows a success snackbar
  static void showSuccessSnackBar(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 3),
  }) {
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: duration,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
