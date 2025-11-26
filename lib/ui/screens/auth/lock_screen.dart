import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' as material;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../providers/auth_providers.dart';
import '../home/home_shell.dart';

class LockScreen extends ConsumerStatefulWidget {
  const LockScreen({super.key});

  static const routeName = '/lock';

  @override
  ConsumerState<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends ConsumerState<LockScreen> {
  final _pinController = material.TextEditingController();
  String? _errorMessage;
  bool _navigated = false;
  bool _resetPinOnAttempt = false;

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }

  Future<void> _tryUnlock() async {
    if (_pinController.text.isEmpty) return;

    setState(() {
      _errorMessage = null;
    });

    if (_resetPinOnAttempt) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('pin_code');
    }

    final result = await ref
        .read(authControllerProvider.notifier)
        .unlockWithPin(_pinController.text);

    if (mounted) {
      if (result.success) {
        if (!_navigated) {
          _navigateToHome();
        }
      } else {
        setState(() {
          _errorMessage = result.message ?? 'PIN incorrecto. Intenta de nuevo.';
        });
      }
    }
  }

  Future<void> _tryBiometric() async {
    setState(() {
      _errorMessage = null;
    });

    final success = await ref
        .read(authControllerProvider.notifier)
        .unlockWithBiometrics();

    if (mounted) {
      if (success) {
        if (!_navigated) {
          _navigateToHome();
        }
      } else {
        setState(() {
          _errorMessage = 'Autenticación fallida';
        });
      }
    }
  }

  void _navigateToHome() {
    if (_navigated) return;
    _navigated = true;
    material.Navigator.of(context).pushNamedAndRemoveUntil(
      HomeShell.routeName,
      (route) => false,
    );
  }

  @override
  material.Widget build(material.BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final status = authState.status;
    final isLoading = status == AuthStatus.loading;
    final isTemporarilyLocked = authState.isTemporarilyLocked;
    final biometricAvailability = ref.watch(biometricAvailabilityProvider);
    final isBiometricEnabled =
        biometricAvailability.maybeWhen(data: (value) => value, orElse: () => false);
    final isBiometricLoading = biometricAvailability.isLoading;

    return material.Scaffold(
      body: material.SafeArea(
        child: material.Padding(
          padding: const material.EdgeInsets.all(24),
          child: material.Center(
            child: material.ConstrainedBox(
              constraints: const material.BoxConstraints(maxWidth: 420),
              child: material.Column(
                mainAxisSize: material.MainAxisSize.min,
                children: [
                  material.Icon(material.Icons.lock_outline,
                      size: 96, color: material.Theme.of(context).colorScheme.primary),
                  const material.SizedBox(height: 24),
                  material.Text(
                    'Desbloquea tu biblioteca',
                    style: material.Theme.of(context).textTheme.headlineSmall,
                    textAlign: material.TextAlign.center,
                  ),
                  const material.SizedBox(height: 16),
                  material.TextField(
                    controller: _pinController,
                    obscureText: true,
                    enabled: !isLoading && !isTemporarilyLocked,
                    textAlign: material.TextAlign.center,
                    keyboardType: material.TextInputType.number,
                    decoration: const material.InputDecoration(
                      labelText: 'PIN',
                      border: material.OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => _tryUnlock(),
                  ),
                  const material.SizedBox(height: 16),
                  material.FilledButton.icon(
                    onPressed:
                        (isLoading || isTemporarilyLocked) ? null : _tryUnlock,
                    icon: const material.Icon(material.Icons.lock_open),
                    label: const material.Text('Desbloquear'),
                  ),
                  const material.SizedBox(height: 12),
                  material.OutlinedButton.icon(
                    onPressed:
                        (isLoading || isTemporarilyLocked || !isBiometricEnabled ||
                                isBiometricLoading)
                            ? null
                            : _tryBiometric,
                    icon: const material.Icon(material.Icons.fingerprint),
                    label: const material.Text('Usar biometría'),
                  ),
                  if (isBiometricLoading) ...[
                    const material.SizedBox(height: 8),
                    const material.CircularProgressIndicator(),
                  ] else if (!isBiometricEnabled) ...[
                    const material.SizedBox(height: 8),
                    material.Text(
                      'Biometría no disponible en este dispositivo.',
                      style: material.Theme.of(context).textTheme.bodySmall,
                      textAlign: material.TextAlign.center,
                    ),
                  ],
                  const material.SizedBox(height: 12),
                  if (isTemporarilyLocked)
                    material.Text(
                      'Bloqueado temporalmente. Intenta más tarde.',
                      style: material.TextStyle(color: material.Theme.of(context).colorScheme.error),
                      textAlign: material.TextAlign.center,
                    )
                  else if (_errorMessage != null)
                    material.Text(
                      _errorMessage!,
                      style: material.TextStyle(color: material.Theme.of(context).colorScheme.error),
                      textAlign: material.TextAlign.center,
                    ),
                  if (kDebugMode) ...[
                    const material.SizedBox(height: 16),
                    material.SwitchListTile.adaptive(
                      title: const material.Text('Debug: borrar PIN antes de intentar'),
                      subtitle: const material.Text(
                          'Usa para forzar el flujo de configuración en cada intento.'),
                      value: _resetPinOnAttempt,
                      onChanged: isLoading
                          ? null
                          : (value) {
                              setState(() {
                                _resetPinOnAttempt = value;
                              });
                            },
                    ),
                  ],
                  if (isLoading) ...[
                    const material.SizedBox(height: 8),
                    const material.CircularProgressIndicator(),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
