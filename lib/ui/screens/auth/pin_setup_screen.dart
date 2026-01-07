import 'package:flutter/material.dart' as material;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../providers/auth_providers.dart';
import '../../../providers/book_providers.dart';
import '../../widgets/textured_background.dart';
import '../../widgets/auth/literary_pin_input.dart';
import '../../../design_system/literary_animations.dart';
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
  
  final _usernameFocusNode = material.FocusNode();
  final _pinFocusNode = material.FocusNode();
  final _confirmFocusNode = material.FocusNode();

  String? _errorMessage;
  bool _navigated = false;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _pinController.dispose();
    _confirmController.dispose();
    _usernameFocusNode.dispose();
    _pinFocusNode.dispose();
    _confirmFocusNode.dispose();
    super.dispose();
  }

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
    final isLoading = authState.status == AuthStatus.loading || _isSubmitting;
    final isExistingUser = activeUser != null;
    final theme = material.Theme.of(context);

    // Si ya existe usuario, no pedimos nombre, solo PIN.
    final stepTitle = isExistingUser ? 'Nueva Llave' : 'Nombra al Guardián';
    final stepSubtitle = isExistingUser
        ? 'Actualiza el código de acceso a tu biblioteca.'
        : '¿Cómo deben conocerte en los círculos de lectura?';

    return material.Scaffold(
      // AppBar transparente para volver si es necesario (o logout en casos raros)
      appBar: material.AppBar(
        backgroundColor: material.Colors.transparent,
        elevation: 0,
        iconTheme: theme.iconTheme,
      ),
      extendBodyBehindAppBar: true,
      body: TexturedBackground(
        child: material.SafeArea(
          child: material.Center(
            child: material.SingleChildScrollView(
              padding: const material.EdgeInsets.all(24),
              child: material.ConstrainedBox(
                constraints: const material.BoxConstraints(maxWidth: 420),
                child: material.Column(
                  mainAxisSize: material.MainAxisSize.min,
                  children: [
                    FadeScaleIn(
                      child: material.Icon(
                          material.Icons.shield_outlined, // Icono de Guardián
                          size: 80,
                          color: theme.colorScheme.primary),
                    ),
                    const material.SizedBox(height: 24),

                    FadeScaleIn(
                      delay: const Duration(milliseconds: 100),
                      child: material.Text(
                        stepTitle,
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontFamily: 'Georgia',
                        ),
                        textAlign: material.TextAlign.center,
                      ),
                    ),
                    const material.SizedBox(height: 12),
                    FadeScaleIn(
                      delay: const Duration(milliseconds: 150),
                      child: material.Text(
                        stepSubtitle,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        textAlign: material.TextAlign.center,
                      ),
                    ),

                    const material.SizedBox(height: 32),

                    // SECTION 1: USERNAME (Solo si es nuevo)
                    if (!isExistingUser) ...[
                      FadeScaleIn(
                        delay: const Duration(milliseconds: 200),
                        child: material.TextField(
                          controller: _usernameController,
                          focusNode: _usernameFocusNode,
                          autofocus: true,
                          enabled: !isLoading,
                          textCapitalization: material.TextCapitalization.none,
                          textInputAction: material.TextInputAction.next,
                          onSubmitted: (_) {
                            _pinFocusNode.requestFocus();
                          },
                          style: theme.textTheme.titleMedium,
                          textAlign: material.TextAlign.center,
                          decoration: material.InputDecoration(
                            labelText: 'Nombre o Alias',
                            hintText: 'Ej. El Bibliotecario',
                            border: material.OutlineInputBorder(
                              borderRadius: material.BorderRadius.circular(12),
                            ),
                            filled: true,
                            fillColor: theme.colorScheme.surfaceContainerHighest
                                .withValues(alpha: 0.5),
                          ),
                        ),
                      ),
                      const material.SizedBox(height: 32),
                    ],

                    // SECTION 2: PIN CREATION
                    FadeScaleIn(
                      delay: const Duration(milliseconds: 300),
                      child: material.Column(
                        children: [
                          material.Text(
                            'Forja tu llave maestra (4 dígitos)',
                            style: theme.textTheme.titleSmall,
                          ),
                          const material.SizedBox(height: 16),
                          LiteraryPinInput(
                            controller: _pinController,
                            focusNode: _pinFocusNode,
                            autofocus: isExistingUser,
                            length: 4,
                            onCompleted: () {
                              _confirmFocusNode.requestFocus();
                            },
                            onChanged: (_) => setState(() {}),
                          ),
                        ],
                      ),
                    ),

                    const material.SizedBox(height: 24),

                    FadeScaleIn(
                      delay: const Duration(milliseconds: 400),
                      child: material.Column(
                        children: [
                          material.Text(
                            'Confirma la llave',
                            style: theme.textTheme.titleSmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant),
                          ),
                          const material.SizedBox(height: 16),
                          LiteraryPinInput(
                            controller: _confirmController,
                            focusNode: _confirmFocusNode,
                            autofocus: false,
                            length: 4,
                            onCompleted: _submit,
                          ),
                        ],
                      ),
                    ),

                    const material.SizedBox(height: 32),

                    // ACTION BUTTON
                    FadeScaleIn(
                      delay: const Duration(milliseconds: 500),
                      child: material.SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: material.FilledButton.icon(
                          onPressed: isLoading ? null : _submit,
                          style: material.FilledButton.styleFrom(
                              shape: material.RoundedRectangleBorder(
                                  borderRadius:
                                      material.BorderRadius.circular(16))),
                          icon: const material.Icon(
                              material.Icons.vpn_key_outlined),
                          label: material.Text(isExistingUser
                              ? 'Actualizar Llave'
                              : 'Establecer Guardián'),
                        ),
                      ),
                    ),

                    const material.SizedBox(height: 16),

                    if (!isExistingUser)
                      FadeScaleIn(
                        delay: const Duration(milliseconds: 600),
                        child: material.TextButton(
                          onPressed: isLoading
                              ? null
                              : () {
                                  material.Navigator.of(context).pushNamed(
                                      ExistingAccountLoginScreen.routeName);
                                },
                          child: const material.Text(
                              '¿Ya tienes una cuenta? Recupérala aquí'),
                        ),
                      ),

                    if (_errorMessage != null) ...[
                      const material.SizedBox(height: 24),
                      material.Text(
                        _errorMessage!,
                        style:
                            material.TextStyle(color: theme.colorScheme.error),
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
              'El nombre del guardián debe ser legible (min 3 letras).';
        });
        return;
      }
    }

    if (pin.length < 4) {
      // Changed to 4 per user request
      setState(() {
        _errorMessage = 'La llave debe tener 4 dígitos.';
      });
      return;
    }

    if (pin != confirm) {
      setState(() {
        _errorMessage = 'Las llaves no coinciden. Intenta forjarlas de nuevo.';
        _confirmController.clear();
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
                'Este nombre de guardián ya está ocupado. Elige otro alias.';
          });
          return;
        }

        final userRepository = ref.read(userRepositoryProvider);
        await userRepository.createUser(username: username);

        // Reset onboarding for new user
        final onboardingService = ref.read(onboardingServiceProvider);
        await onboardingService.reset();

        ref.read(userSyncControllerProvider.notifier).markPendingChanges();
      }

      if (!mounted) return;
      await ref.read(authControllerProvider.notifier).configurePin(pin);
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'No se pudo completar el ritual: $error';
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
