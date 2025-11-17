import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../providers/auth_providers.dart';
import '../../../providers/book_providers.dart';
import 'auth/lock_screen.dart';
import 'auth/pin_setup_screen.dart';
import 'home/home_shell.dart';
import 'onboarding/onboarding_intro_screen.dart';
import 'onboarding/onboarding_wizard_screen.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  bool _navigated = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(authControllerProvider.notifier).checkAuth();
    });
  }

  Future<void> _navigate(String routeName) async {
    if (_navigated) return;
    _navigated = true;
    await Navigator.of(context).pushReplacementNamed(routeName);
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AuthState>(authControllerProvider, (previous, next) {
      if (!mounted || _navigated) return;

      final status = next.status;

      if (status == AuthStatus.unlocked) {
        _handleUnlocked();
      } else if (status == AuthStatus.needsPin) {
        _navigate(PinSetupScreen.routeName);
      } else if (status == AuthStatus.locked) {
        _navigate(LockScreen.routeName);
      }
    });

    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FlutterLogo(size: 96),
            SizedBox(height: 24),
            CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }

  Future<void> _handleUnlocked() async {
    final progress = await ref.read(onboardingProgressProvider.future);
    if (!mounted) return;

    if (!progress.introSeen) {
      await _navigate(OnboardingIntroScreen.routeName);
      return;
    }

    if (!progress.completed) {
      await _navigate(OnboardingWizardScreen.routeName);
      return;
    }

    await _navigate(HomeShell.routeName);
  }
}
