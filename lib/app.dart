import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'providers/auth_providers.dart';
import 'providers/notification_providers.dart';
import 'providers/theme_providers.dart';
import 'ui/screens/auth/lock_screen.dart';
import 'ui/screens/auth/pin_setup_screen.dart';
import 'ui/screens/home/home_shell.dart';
import 'ui/screens/auth/existing_account_login_screen.dart';
import 'ui/widgets/inactivity_listener.dart';
import 'ui/screens/splash_screen.dart';

final navigatorKey = GlobalKey<NavigatorState>();

class BookSharingApp extends ConsumerWidget {
  const BookSharingApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Ensure notification intent notifier is instantiated.
    ref.watch(notificationIntentProvider);

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
      home: const SplashScreen(),
      routes: {
        LockScreen.routeName: (context) => const LockScreen(),
        PinSetupScreen.routeName: (context) => const PinSetupScreen(),
        ExistingAccountLoginScreen.routeName: (context) =>
            const ExistingAccountLoginScreen(),
        HomeShell.routeName: (context) => const InactivityListener(child: HomeShell()),
      },
    );
  }
}
