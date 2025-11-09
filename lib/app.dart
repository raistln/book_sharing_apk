import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'providers/auth_providers.dart';
import 'providers/notification_providers.dart';
import 'ui/screens/auth/lock_screen.dart';
import 'ui/screens/auth/pin_setup_screen.dart';
import 'ui/screens/home/home_shell.dart';
import 'ui/widgets/inactivity_listener.dart';
import 'ui/screens/splash_screen.dart';

final themeProvider = Provider<ThemeData>((ref) {
  return ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF4A148C)),
    visualDensity: VisualDensity.adaptivePlatformDensity,
  );
});

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

    final theme = ref.watch(themeProvider);

    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'Book Sharing App',
      debugShowCheckedModeBanner: false,
      theme: theme,
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
        HomeShell.routeName: (context) => const InactivityListener(child: HomeShell()),
      },
    );
  }
}
