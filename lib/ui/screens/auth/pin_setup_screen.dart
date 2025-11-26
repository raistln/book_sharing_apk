import 'package:flutter/material.dart' as material;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../providers/auth_providers.dart';
import '../../../providers/book_providers.dart';
import '../home/home_shell.dart';
import '../onboarding/onboarding_intro_screen.dart';
import 'existing_account_login_screen.dart';

class PinSetupScreen extends ConsumerStatefulWidget {
  const PinSetupScreen({super.key});

  static const routeName = '/setup-pin';

  @override
  ConsumerState<PinSetupScreen> createState() => _PinSetupScreenState();
}

class _PinSetupScreenState extends ConsumerState<PinSetupScreen> {
  final _usernameController = material.TextEditingController();
  final _pinController = material.TextEditingController();
  final _confirmController = material.TextEditingController();
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
  @override
  material.Widget build(material.BuildContext context) {
    ref.listen<AuthState>(authControllerProvider, (previous, next) {
      if (!mounted || _navigated) return;
      if (next.status == AuthStatus.unlocked) {
        _navigated = true;
        final navigator = material.Navigator.of(context);
        final onboardingService = ref.read(onboardingServiceProvider);
        Future<void>.microtask(() async {
          final progress = await onboardingService.loadProgress();
          if (!mounted) return;
          final routeName = (!progress.introSeen || !progress.completed)
              ? OnboardingIntroScreen.routeName
              : HomeShell.routeName;
          navigator.pushNamedAndRemoveUntil(routeName, (route) => false);
        });
      }
    });

    final authState = ref.watch(authControllerProvider);
    final activeUserAsync = ref.watch(activeUserProvider);
    final activeUser = activeUserAsync.asData?.value;
    final isLoading =
        authState.status == AuthStatus.loading || _isSubmitting;
    final isExistingUser = activeUser != null;

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
                  material.Icon(material.Icons.pin,
                      size: 96, color: material.Theme.of(context).colorScheme.primary),
                  const material.SizedBox(height: 24),
                  material.Text(
                    'Configura un PIN de acceso',
                    style: material.Theme.of(context).textTheme.headlineSmall,
                    textAlign: material.TextAlign.center,
                  ),
                  const material.SizedBox(height: 16),
                  if (!isExistingUser) ...[
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
                  ],
                  material.TextField(
                    controller: _pinController,
                    enabled: !isLoading,
                    obscureText: true,
                    maxLength: 6,
                    keyboardType: material.TextInputType.number,
                    textAlign: material.TextAlign.center,
                    decoration: const material.InputDecoration(
                      labelText: 'PIN nuevo',
                      border: material.OutlineInputBorder(),
                      counterText: '',
                    ),
                  ),
                  const material.SizedBox(height: 12),
                  material.TextField(
                    controller: _confirmController,
                    enabled: !isLoading,
                    obscureText: true,
                    maxLength: 6,
                    keyboardType: material.TextInputType.number,
                    textAlign: material.TextAlign.center,
                    decoration: const material.InputDecoration(
                      labelText: 'Confirmar PIN',
                      border: material.OutlineInputBorder(),
                      counterText: '',
                    ),
                    onSubmitted: (_) => _submit(),
                  ),
                  const material.SizedBox(height: 20),
                  material.FilledButton.icon(
                    onPressed: isLoading ? null : _submit,
                    icon: const material.Icon(material.Icons.check_circle_outline),
                    label: const material.Text('Guardar PIN'),
                  ),
                  const material.SizedBox(height: 12),
                  if (!isExistingUser)
                    material.TextButton.icon(
                      onPressed: isLoading
                          ? null
                          : () {
                              material.Navigator.of(context)
                                  .pushNamed(ExistingAccountLoginScreen.routeName);
                            },
                      icon: const material.Icon(material.Icons.person_search),
                      label: const material.Text('Ya tengo cuenta'),
                    ),
                  const material.SizedBox(height: 12),
                  if (_errorMessage != null)
                    material.Text(
                      _errorMessage!,
                      style: material.TextStyle(color: material.Theme.of(context).colorScheme.error),
                      textAlign: material.TextAlign.center,
                    ),
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

    final activeUser = ref.read(activeUserProvider).value;
    final hasExistingUser = activeUser != null;
    final username = _usernameController.text.trim();
    final pin = _pinController.text.trim();
    final confirm = _confirmController.text.trim();

    if (!hasExistingUser) {
      if (username.length < 3) {
        setState(() {
          _errorMessage =
              'El nombre de usuario debe tener al menos 3 caracteres.';
        });
        return;
      }
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
      if (!hasExistingUser) {
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
        ref.read(userSyncControllerProvider.notifier).markPendingChanges();
      }

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
