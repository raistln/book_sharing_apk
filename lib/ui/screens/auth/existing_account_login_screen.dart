import 'package:flutter/material.dart' as material;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../providers/auth_providers.dart';
import '../../../providers/book_providers.dart';
import '../../screens/home/home_shell.dart';
import '../../widgets/auth/literary_pin_input.dart';

class ExistingAccountLoginScreen extends ConsumerStatefulWidget {
  const ExistingAccountLoginScreen({super.key});

  static const routeName = '/existing-account';

  @override
  ConsumerState<ExistingAccountLoginScreen> createState() =>
      _ExistingAccountLoginScreenState();
}

class _ExistingAccountLoginScreenState
    extends ConsumerState<ExistingAccountLoginScreen> {
  final _usernameController = material.TextEditingController();
  final _pinController = material.TextEditingController();

  String? _errorMessage;
  bool _isSubmitting = false;
  bool _navigated = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _pinController.dispose();
    super.dispose();
  }

  @override
  material.Widget build(material.BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final isLoading = _isSubmitting || authState.status == AuthStatus.loading;

    return material.Scaffold(
      body: material.SafeArea(
        child: material.Padding(
          padding: const material.EdgeInsets.all(24),
          child: material.Center(
            child: material.ConstrainedBox(
              constraints: const material.BoxConstraints(maxWidth: 420),
              child: material.Column(
                mainAxisSize: material.MainAxisSize.min,
                crossAxisAlignment: material.CrossAxisAlignment.center,
                children: [
                  material.Icon(material.Icons.login,
                      size: 96,
                      color: material.Theme.of(context).colorScheme.primary),
                  const material.SizedBox(height: 24),
                  material.Text(
                    'Inicio con usuario existente',
                    style: material.Theme.of(context).textTheme.headlineSmall,
                    textAlign: material.TextAlign.center,
                  ),
                  const material.SizedBox(height: 16),
                  material.TextField(
                    controller: _usernameController,
                    enabled: !isLoading,
                    textCapitalization: material.TextCapitalization.none,
                    textInputAction: material.TextInputAction.next,
                    decoration: const material.InputDecoration(
                      labelText: 'Nombre de usuario',
                      border: material.OutlineInputBorder(),
                      hintText: 'Ej. ana_lectora',
                    ),
                  ),
                  const material.SizedBox(height: 12),
                  const material.SizedBox(height: 12),
                  // Usamos el nuevo input literario
                  material.Padding(
                    padding: const material.EdgeInsets.symmetric(vertical: 8.0),
                    child: LiteraryPinInput(
                      controller: _pinController,
                      length: 4, // Match the maxLength used previously
                      onCompleted: _submit,
                      onChanged: (_) {
                        if (_errorMessage != null) {
                          setState(() {
                            _errorMessage = null;
                          });
                        }
                      },
                    ),
                  ),
                  const material.SizedBox(height: 20),
                  material.FilledButton.icon(
                    onPressed: isLoading ? null : _submit,
                    icon: const material.Icon(
                        material.Icons.check_circle_outline),
                    label: const material.Text('Acceder'),
                  ),
                  const material.SizedBox(height: 12),
                  material.TextButton(
                    onPressed: isLoading
                        ? null
                        : () {
                            material.Navigator.of(context).pop();
                          },
                    child: const material.Text('Volver'),
                  ),
                  if (_errorMessage != null) ...[
                    const material.SizedBox(height: 12),
                    material.Text(
                      _errorMessage!,
                      style: material.TextStyle(
                          color: material.Theme.of(context).colorScheme.error),
                      textAlign: material.TextAlign.center,
                    ),
                  ],
                  if (isLoading) ...[
                    const material.SizedBox(height: 24),
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

  Future<void> _submit() async {
    if (_isSubmitting) return;

    final username = _usernameController.text.trim();
    final pin = _pinController.text.trim();

    if (username.length < 3) {
      setState(() {
        _errorMessage =
            'El nombre de usuario debe tener al menos 3 caracteres.';
      });
      return;
    }

    if (pin.length < 4) {
      setState(() {
        _errorMessage = 'El PIN debe tener al menos 4 dígitos.';
      });
      return;
    }

    setState(() {
      _errorMessage = null;
      _isSubmitting = true;
    });

    try {
      final supabaseService = ref.read(supabaseUserServiceProvider);
      final record = await supabaseService.fetchUserByUsername(username);

      if (record == null || record.isDeleted) {
        if (!mounted) return;
        setState(() {
          _errorMessage = 'No encontramos un usuario activo con ese nombre.';
        });
        return;
      }

      if (record.pinHash == null || record.pinSalt == null) {
        if (!mounted) return;
        setState(() {
          _errorMessage =
              'Ese usuario no tiene un PIN configurado todavía. Configúralo primero.';
        });
        return;
      }

      final userRepository = ref.read(userRepositoryProvider);
      final localUser = await userRepository.importRemoteUser(record);

      if (localUser.isDeleted) {
        if (!mounted) return;
        setState(() {
          _errorMessage = 'El usuario remoto está marcado como eliminado.';
        });
        return;
      }

      final authController = ref.read(authControllerProvider.notifier);
      final result = await authController.unlockWithPin(pin);

      if (!result.success) {
        if (!mounted) return;
        setState(() {
          _errorMessage = result.message ?? 'PIN incorrecto. Intenta de nuevo.';
        });
        return;
      }

      if (!mounted || _navigated) return;
      _navigated = true;

      // Importante: Saltamos el onboarding y el wizard para cuentas existentes
      final onboardingService = ref.read(onboardingServiceProvider);
      await onboardingService.markCompleted();

      if (!mounted) return;
      material.Navigator.of(context)
          .pushNamedAndRemoveUntil(HomeShell.routeName, (route) => false);
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'No fue posible iniciar sesión: $error';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }
}
