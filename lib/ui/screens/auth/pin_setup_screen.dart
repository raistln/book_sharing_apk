import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../providers/auth_providers.dart';
import '../../../providers/book_providers.dart';
import '../home/home_shell.dart';

class PinSetupScreen extends ConsumerStatefulWidget {
  const PinSetupScreen({super.key});

  static const routeName = '/setup-pin';

  @override
  ConsumerState<PinSetupScreen> createState() => _PinSetupScreenState();
}

class _PinSetupScreenState extends ConsumerState<PinSetupScreen> {
  final _usernameController = TextEditingController();
  final _pinController = TextEditingController();
  final _confirmController = TextEditingController();
  String? _errorMessage;
  bool _navigated = false;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _pinController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AuthState>(authControllerProvider, (previous, next) {
      if (!mounted || _navigated) return;
      if (next.status == AuthStatus.unlocked) {
        _navigated = true;
        Navigator.of(context)
            .pushNamedAndRemoveUntil(HomeShell.routeName, (route) => false);
      }
    });

    final authState = ref.watch(authControllerProvider);
    final isLoading =
        authState.status == AuthStatus.loading || _isSubmitting;

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
                  Icon(Icons.pin, size: 96, color: Theme.of(context).colorScheme.primary),
                  const SizedBox(height: 24),
                  Text(
                    'Configura un PIN de acceso',
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
                    maxLength: 6,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    decoration: const InputDecoration(
                      labelText: 'PIN nuevo',
                      border: OutlineInputBorder(),
                      counterText: '',
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _confirmController,
                    enabled: !isLoading,
                    obscureText: true,
                    maxLength: 6,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    decoration: const InputDecoration(
                      labelText: 'Confirmar PIN',
                      border: OutlineInputBorder(),
                      counterText: '',
                    ),
                    onSubmitted: (_) => _submit(),
                  ),
                  const SizedBox(height: 20),
                  FilledButton.icon(
                    onPressed: isLoading ? null : _submit,
                    icon: const Icon(Icons.check_circle_outline),
                    label: const Text('Guardar PIN'),
                  ),
                  const SizedBox(height: 12),
                  if (_errorMessage != null)
                    Text(
                      _errorMessage!,
                      style: TextStyle(color: Theme.of(context).colorScheme.error),
                      textAlign: TextAlign.center,
                    ),
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
    final confirm = _confirmController.text.trim();

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

    if (pin != confirm) {
      setState(() {
        _errorMessage = 'Los PIN introducidos no coinciden.';
      });
      return;
    }

    setState(() {
      _errorMessage = null;
      _isSubmitting = true;
    });

    try {
      final supabaseService = ref.read(supabaseUserServiceProvider);
      final isAvailable = await supabaseService.isUsernameAvailable(username);

      if (!isAvailable) {
        if (!mounted) return;
        setState(() {
          _errorMessage =
              'Ese nombre de usuario ya existe en Supabase. Prueba con otro.';
        });
        return;
      }

      final userRepository = ref.read(userRepositoryProvider);
      await userRepository.createUser(username: username);

      if (!mounted) return;
      await ref.read(authControllerProvider.notifier).configurePin(pin);
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'No se pudo crear el usuario: $error';
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
