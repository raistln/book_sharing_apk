import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'providers/auth_providers.dart';
import 'providers/book_providers.dart';
import 'providers/notification_providers.dart';
import 'providers/sync_providers.dart';
import 'providers/theme_providers.dart';
import 'ui/screens/auth/lock_screen.dart';
import 'ui/screens/auth/pin_setup_screen.dart';
import 'ui/screens/home/home_shell.dart';
import 'ui/screens/auth/existing_account_login_screen.dart';
import 'ui/widgets/inactivity_listener.dart';
import 'ui/screens/splash_screen.dart';
import 'ui/screens/onboarding/onboarding_intro_screen.dart';
import 'ui/screens/onboarding/onboarding_wizard_screen.dart';
import 'ui/widgets/coach_mark_host.dart';

final navigatorKey = GlobalKey<NavigatorState>();

class BookSharingApp extends ConsumerStatefulWidget {
  const BookSharingApp({super.key});

  @override
  ConsumerState<BookSharingApp> createState() => _BookSharingAppState();
}

class _BookSharingAppState extends ConsumerState<BookSharingApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (kDebugMode) {
      debugPrint('[AppLifecycle] State changed to: $state');
    }
    
    if (state == AppLifecycleState.resumed) {
      // Sync when app comes back to foreground
      final authState = ref.read(authControllerProvider);
      if (authState.status == AuthStatus.unlocked) {
        if (kDebugMode) debugPrint('[AppLifecycle] App resumed & unlocked -> Syncing & Resuming AutoSync');
        final coordinator = ref.read(unifiedSyncCoordinatorProvider);
        coordinator.syncNow(); 
        
        // Check for upcoming or expired loans and notify
        ref.read(loanControllerProvider.notifier).checkUpcomingLoans();

        if (coordinator.isTimerSuspended) {
          coordinator.resumeAutoSync();
        }
      } else {
        if (kDebugMode) debugPrint('[AppLifecycle] App resumed but auth status is ${authState.status} -> No action');
      }
    } else if (state == AppLifecycleState.paused) {
      // No necesitamos detener el auto-sync, el coordinador lo maneja inteligentemente
      if (kDebugMode) debugPrint('[AppLifecycle] App paused -> Coordinator will adapt intervals');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Ensure notification intent notifier is instantiated.
    ref.watch(notificationIntentProvider);
    
    // Listen to auth changes to start/stop auto-sync (must be in build)
    ref.listen<AuthState>(authControllerProvider, (previous, next) {
      if (kDebugMode) {
        debugPrint('[AuthListener] Auth status changed: ${previous?.status} -> ${next.status}');
      }
      
      if (next.status == AuthStatus.unlocked && previous?.status != AuthStatus.unlocked) {
        if (kDebugMode) debugPrint('[AuthListener] Auth unlocked -> Starting AutoSync');
        ref.read(unifiedSyncCoordinatorProvider).startAutoSync();
      } else if (next.status != AuthStatus.unlocked && previous?.status == AuthStatus.unlocked) {
        if (kDebugMode) debugPrint('[AuthListener] Auth locked/other -> Stopping AutoSync');
        ref.read(unifiedSyncCoordinatorProvider).stopAutoSync();
      }
    });

    ref.listen<NotificationIntent?>(notificationIntentProvider, (previous, next) {
      if (next == null) {
        return;
      }

      WidgetsBinding.instance.addPostFrameCallback((_) {
        final authState = ref.read(authControllerProvider);
        if (authState.status != AuthStatus.unlocked) {
          return;
        }

        final navigator = navigatorKey.currentState;
        if (navigator == null) {
          return;
        }

        navigator.pushNamedAndRemoveUntil(HomeShell.routeName, (route) => false);
      });
    });

    final theme = ref.watch(lightThemeProvider);
    final darkTheme = ref.watch(darkThemeProvider);
    final mode = ref.watch(themeModeProvider);

    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'Book Sharing App',
      debugShowCheckedModeBanner: false,
      theme: theme,
      darkTheme: darkTheme,
      themeMode: mode,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'),
        Locale('es'),
      ],
      builder: (context, child) {
        return CoachMarkOverlayHost(child: child ?? const SizedBox.shrink());
      },
      home: const SplashScreen(),
      routes: {
        LockScreen.routeName: (context) => const LockScreen(),
        PinSetupScreen.routeName: (context) => const PinSetupScreen(),
        ExistingAccountLoginScreen.routeName: (context) =>
            const ExistingAccountLoginScreen(),
        OnboardingIntroScreen.routeName: (context) => const OnboardingIntroScreen(),
        OnboardingWizardScreen.routeName: (context) => const OnboardingWizardScreen(),
        HomeShell.routeName: (context) =>
            const InactivityListener(child: HomeShell()),
      },
    );
  }
}
