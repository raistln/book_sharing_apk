import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'ui/screens/splash_screen.dart';

final themeProvider = Provider<ThemeData>((ref) {
  return ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF4A148C)),
    visualDensity: VisualDensity.adaptivePlatformDensity,
  );
});

final routerConfigProvider = Provider<RouterConfig<Object>>((ref) {
  return RouterConfig(
    routerDelegate: _PlaceholderRouterDelegate(
      initialRoute: const SplashScreen(),
    ),
  );
});

class BookSharingApp extends ConsumerWidget {
  const BookSharingApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeProvider);

    return MaterialApp(
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
    );
  }
}

/// Placeholder router delegate until navigation is implemented.
class _PlaceholderRouterDelegate extends RouterDelegate<Object>
    with ChangeNotifier, PopNavigatorRouterDelegateMixin<Object> {
  _PlaceholderRouterDelegate({required this.initialRoute});

  final Widget initialRoute;

  @override
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: navigatorKey,
      pages: [
        MaterialPage<void>(child: initialRoute),
      ],
      onPopPage: (route, result) => route.didPop(result),
    );
  }

  @override
  Future<bool> popRoute() {
    final navigator = navigatorKey.currentState;
    if (navigator?.canPop() ?? false) {
      navigator!.pop();
      return Future.value(true);
    }
    return Future.value(false);
  }

  @override
  Future<void> setNewRoutePath(Object configuration) async {
    // No-op for now; will be expanded when navigation is implemented.
  }
}
