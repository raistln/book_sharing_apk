import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../providers/auth_providers.dart';
import '../../../providers/book_providers.dart';
import '../../screens/home/home_shell.dart';

class ExistingAccountLoginScreen extends ConsumerStatefulWidget {
  const ExistingAccountLoginScreen({super.key});

  static const routeName = '/existing-account';

  @override
  ConsumerState<ExistingAccountLoginScreen> createState() =>
      _ExistingAccountLoginScreenState();
}

class _ExistingAccountLoginScreenState
    extends ConsumerState<ExistingAccountLoginScreen> {
  final _usernameController = TextEditingController();
  final _pinController = TextEditingController();

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
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final isLoading =
        _isSubmitting || authState.status == AuthStatus.loading;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(Icons.login,
                      size: 96, color: Theme.of(context).colorScheme.primary),
                  const SizedBox(height: 24),
                  Text(
                    'Inicio con usuario existente',
                    style: Theme.of(context).textTheme.headlineSmall,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _usernameController,
                    enabled: !isLoading,
                    textCapitalization: TextCapitalization.none,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      labelText: 'Nombre de usuario',
                      border: OutlineInputBorder(),
                      hintText: 'Ej. ana_lectora',
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _pinController,
                    enabled: !isLoading,
                    obscureText: true,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    maxLength: 6,
                    decoration: const InputDecoration(
                      labelText: 'PIN',
                      border: OutlineInputBorder(),
                      counterText: '',
                    ),
                    onSubmitted: (_) => _submit(),
                  ),
                  const SizedBox(height: 20),
                  FilledButton.icon(
                    onPressed: isLoading ? null : _submit,
                    icon: const Icon(Icons.check_circle_outline),
                    label: const Text('Acceder'),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: isLoading
                        ? null
                        : () {
                            Navigator.of(context).pop();
                          },
                    child: const Text('Volver'),
                  ),
                  if (_errorMessage != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      _errorMessage!,
                      style:
                          TextStyle(color: Theme.of(context).colorScheme.error),
                      textAlign: TextAlign.center,
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
          _errorMessage =
              result.message ?? 'PIN incorrecto. Intenta de nuevo.';
        });
        return;
      }

      if (!mounted || _navigated) return;
      _navigated = true;
      Navigator.of(context)
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
