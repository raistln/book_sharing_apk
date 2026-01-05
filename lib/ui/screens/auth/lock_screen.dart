import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' as material;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../providers/auth_providers.dart';
import '../../utils/library_transition.dart';
import '../../widgets/textured_background.dart';
import '../../widgets/auth/literary_pin_input.dart';
import '../../../design_system/literary_animations.dart';
import '../home/home_shell.dart';

class LockScreen extends ConsumerStatefulWidget {
  const LockScreen({super.key});

  static const routeName = '/lock';

  @override
  ConsumerState<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends ConsumerState<LockScreen>
    with material.SingleTickerProviderStateMixin {
  final _pinController = material.TextEditingController();
  String? _errorMessage;
  bool _navigated = false;
  bool _resetPinOnAttempt = false;
  late material.AnimationController _shakeController;

  @override
  void initState() {
    super.initState();
    _shakeController = material.AnimationController(
        duration: const Duration(milliseconds: 500), vsync: this);
    _shakeController.addStatusListener((status) {
      if (status == material.AnimationStatus.completed) {
        _shakeController.reset();
      }
    });
  }

  @override
  void dispose() {
    _pinController.dispose();
    _shakeController.dispose();
    super.dispose();
  }

  void _triggerShake() {
    _shakeController.forward(from: 0.0);
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
        _triggerShake();
        setState(() {
          _errorMessage =
              result.message ?? 'La llave no encaja. Intenta de nuevo.';
          _pinController.clear();
        });
      }
    }
  }

  Future<void> _tryBiometric() async {
    setState(() {
      _errorMessage = null;
    });

    final success =
        await ref.read(authControllerProvider.notifier).unlockWithBiometrics();

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
    material.Navigator.of(context).pushAndRemoveUntil(
      LibraryPageRoute(page: const HomeShell()),
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
    final isBiometricEnabled = biometricAvailability.maybeWhen(
        data: (value) => value, orElse: () => false);
    final isBiometricLoading = biometricAvailability.isLoading;
    final theme = material.Theme.of(context);

    // Shake animation wrapper
    return material.Scaffold(
      body: TexturedBackground(
        child: material.SafeArea(
          child: material.Center(
            child: material.ConstrainedBox(
              constraints: const material.BoxConstraints(maxWidth: 420),
              child: material.AnimatedBuilder(
                animation: _shakeController,
                builder: (context, child) {
                  return material.Transform.translate(
                    offset: material.Offset(
                        math.sin(_shakeController.value * math.pi * 4) * 8, 0),
                    child: child,
                  );
                },
                child: material.Column(
                  mainAxisSize: material.MainAxisSize.min,
                  children: [
                    // Icono central (Libro/Candado)
                    FadeScaleIn(
                      child: material.Icon(
                        material.Icons
                            .lock_open_rounded, // Usamos un icono más suave
                        size: 80,
                        color:
                            theme.colorScheme.onSurface.withValues(alpha: 0.8),
                      ),
                    ),
                    const material.SizedBox(height: 32),

                    // Títulos literarios
                    FadeScaleIn(
                      delay: const Duration(milliseconds: 100),
                      child: material.Text(
                        'Desbloquea tu biblioteca',
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontFamily: 'Georgia',
                        ),
                        textAlign: material.TextAlign.center,
                      ),
                    ),
                    const material.SizedBox(height: 8),
                    FadeScaleIn(
                      delay: const Duration(milliseconds: 200),
                      child: material.Text(
                        'Introduce tu llave para acceder',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        textAlign: material.TextAlign.center,
                      ),
                    ),

                    const material.SizedBox(height: 48),

                    // Input PIN Literario
                    FadeScaleIn(
                      delay: const Duration(milliseconds: 300),
                      child: material.SizedBox(
                        height: 60,
                        child: LiteraryPinInput(
                          controller: _pinController,
                          // Cuando termine de escribir 4 digitos, intentamos desbloquear
                          length: 4,
                          onCompleted: _tryUnlock,
                        ),
                      ),
                    ),

                    const material.SizedBox(height: 32),

                    // Botón Biometría (opcional, sutil)
                    if (!isBiometricLoading && isBiometricEnabled)
                      FadeScaleIn(
                        delay: const Duration(milliseconds: 400),
                        child: material.IconButton(
                          onPressed: (isLoading || isTemporarilyLocked)
                              ? null
                              : _tryBiometric,
                          icon: const material.Icon(material.Icons.fingerprint,
                              size: 32),
                          tooltip: 'Usar huella',
                          style: material.IconButton.styleFrom(
                            foregroundColor: theme.colorScheme.primary,
                            padding: const material.EdgeInsets.all(16),
                            backgroundColor: theme.colorScheme.primaryContainer
                                .withValues(alpha: 0.3),
                          ),
                        ),
                      ),

                    const material.SizedBox(height: 24),

                    // Mensajes de error y estado
                    if (isTemporarilyLocked)
                      material.Text(
                        'La cerradura está atascada temporalmente. Espera un momento.',
                        style:
                            material.TextStyle(color: theme.colorScheme.error),
                        textAlign: material.TextAlign.center,
                      )
                    else if (_errorMessage != null)
                      material.Text(
                        _errorMessage!,
                        style:
                            material.TextStyle(color: theme.colorScheme.error),
                        textAlign: material.TextAlign.center,
                      ),

                    if (isLoading)
                      const material.SizedBox(
                          height: 24,
                          width: 24,
                          child: material.CircularProgressIndicator(
                              strokeWidth: 2)),

                    // Debug switch (solo debug)
                    if (kDebugMode) ...[
                      const material.SizedBox(height: 24),
                      material.Transform.scale(
                        scale: 0.8,
                        child: material.SwitchListTile.adaptive(
                          title: const material.Text(
                              'Debug: Reset PIN on attempt'),
                          value: _resetPinOnAttempt,
                          onChanged: (v) =>
                              setState(() => _resetPinOnAttempt = v),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
