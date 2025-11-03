import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
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
  final _pinController = TextEditingController();
  String? _errorMessage;
  bool _navigated = false;
  bool _resetPinOnAttempt = false;

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }

  Future<void> _tryUnlock() async {
    setState(() {
      _errorMessage = null;
    });

    if (_resetPinOnAttempt) {
      await ref.read(authControllerProvider.notifier).clearPin();
      if (!mounted) return;
      setState(() {
        _errorMessage = 'PIN limpiado (debug). Configura uno nuevo.';
        _pinController.clear();
      });
      return;
    }

    final pinValue = _pinController.text.trim();
    final result =
        await ref.read(authControllerProvider.notifier).unlockWithPin(pinValue);

    if (!mounted) return;

    if (!result.success) {
      setState(() {
        _errorMessage = result.message ?? 'PIN incorrecto. Intenta de nuevo.';
        _pinController.clear();
      });
      return;
    }

    _navigateToHome();
  }

  Future<void> _tryBiometric() async {
    setState(() {
      _errorMessage = null;
    });

    final success =
        await ref.read(authControllerProvider.notifier).unlockWithBiometrics();

    if (!mounted) return;

    if (!success) {
      setState(() {
        _errorMessage = 'No fue posible autenticar con biometría.';
      });
      return;
    }

    _navigateToHome();
  }

  void _navigateToHome() {
    if (_navigated) return;
    _navigated = true;
    Navigator.of(context)
        .pushNamedAndRemoveUntil(HomeShell.routeName, (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final status = authState.status;
    final isLoading = status == AuthStatus.loading;
    final isTemporarilyLocked = authState.isTemporarilyLocked;
    final biometricAvailability = ref.watch(biometricAvailabilityProvider);
    final isBiometricEnabled =
        biometricAvailability.maybeWhen(data: (value) => value, orElse: () => false);
    final isBiometricLoading = biometricAvailability.isLoading;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.lock_outline,
                      size: 96, color: Theme.of(context).colorScheme.primary),
                  const SizedBox(height: 24),
                  Text(
                    'Desbloquea tu biblioteca',
                    style: Theme.of(context).textTheme.headlineSmall,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _pinController,
                    obscureText: true,
                    enabled: !isLoading && !isTemporarilyLocked,
                    textAlign: TextAlign.center,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'PIN',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => _tryUnlock(),
                  ),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed:
                        (isLoading || isTemporarilyLocked) ? null : _tryUnlock,
                    icon: const Icon(Icons.lock_open),
                    label: const Text('Desbloquear'),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed:
                        (isLoading || isTemporarilyLocked || !isBiometricEnabled ||
                                isBiometricLoading)
                            ? null
                            : _tryBiometric,
                    icon: const Icon(Icons.fingerprint),
                    label: const Text('Usar biometría'),
                  ),
                  if (isBiometricLoading) ...[
                    const SizedBox(height: 8),
                    const LinearProgressIndicator(minHeight: 2),
                  ] else if (!isBiometricEnabled) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Biometría no disponible en este dispositivo.',
                      style: Theme.of(context).textTheme.bodySmall,
                      textAlign: TextAlign.center,
                    ),
                  ],
                  const SizedBox(height: 12),
                  if (isTemporarilyLocked)
                    Text(
                      'Bloqueado temporalmente. Intenta más tarde.',
                      style: TextStyle(color: Theme.of(context).colorScheme.error),
                      textAlign: TextAlign.center,
                    )
                  else if (_errorMessage != null)
                    Text(
                      _errorMessage!,
                      style: TextStyle(color: Theme.of(context).colorScheme.error),
                      textAlign: TextAlign.center,
                    ),
                  if (kDebugMode) ...[
                    const SizedBox(height: 16),
                    SwitchListTile.adaptive(
                      title: const Text('Debug: borrar PIN antes de intentar'),
                      subtitle: const Text(
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
                    const SizedBox(height: 24),
                    const CircularProgressIndicator(),
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
