import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../../providers/auth_providers.dart';
import '../../../providers/book_providers.dart';
import '../../../providers/auto_backup_providers.dart';
import '../widgets/inactivity_listener.dart';
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
  bool _showText = false;
  late final Quote _quote;
  final _startTime = DateTime.now();

  static final List<Quote> _quotes = [
    Quote(
      text:
          "El paso más importante que un hombre puede dar no es el primero, es el siguiente.",
      author: "Brandon Sanderson",
    ),
    // ... (rest of quotes kept same for brevity, but re-included in final file if I were rewriting whole file. Here I replace whole file content to be safe and cleaner)
    Quote(
      text:
          "Un lector vive mil vidas antes de morir. Aquel que nunca lee sólo vive una.",
      author: "George R.R. Martin",
    ),
    Quote(
      text:
          "Que otros se jacten de las páginas que han escrito; a mí me gustaría jactarme de las que he leído.",
      author: "Jorge Luis Borges",
    ),
    Quote(
      text:
          "Si solo lees los libros que todo el mundo lee, solo puedes pensar lo que todo el mundo piensa.",
      author: "Haruki Murakami",
    ),
    Quote(
      text: "El que lee mucho y anda mucho, ve mucho y sabe mucho.",
      author: "Miguel de Cervantes",
    ),
    Quote(
      text: "No todos los que vagan están perdidos.",
      author: "J.R.R. Tolkien",
    ),
    Quote(
      text: "Para viajar lejos, no hay mejor nave que un libro.",
      author: "Emily Dickinson",
    ),
    Quote(
        text: 'La lectura es una conversación. Todos los libros hablan.',
        author: 'Rebecca Solnit'),
    Quote(
        text: 'Los libros son una forma de libertad. Son una forma de ser.',
        author: 'Isabel Allende'),
    Quote(
        text: 'Una palabra tras otra, tras otra, es poder.',
        author: 'Margaret Atwood'),
    Quote(
        text: 'Un libro es un jardín que se lleva en el bolsillo.',
        author: 'Proverbio árabe'),
    Quote(
        text: 'La literatura es el lugar más hospitalario del mundo.',
        author: 'Irene Vallejo'),
    Quote(
        text: 'Escribo para descubrir lo que sé.', author: 'Flannery O’Connor'),
    Quote(
        text: 'Leer es elegir lo que uno quiere vivir.',
        author: 'Elena Ferrante'),
    Quote(text: 'La lectura es un acto de resistencia.', author: 'Zadie Smith'),
    Quote(
        text:
            'No hay barrera, cerradura ni cerrojo que puedas imponer a la libertad de mi mente.',
        author: 'Virginia Woolf'),
    Quote(
        text: 'La cultura no se hereda, se conquista.',
        author: 'André Malraux'),
    Quote(
      text:
          "Un libro debe ser el hacha que rompa el mar helado dentro de nosotros.",
      author: "Franz Kafka",
    ),
    Quote(
        text: 'La gente no lee para aprender, sino para olvidar.',
        author: 'Clarice Lispector'),
    Quote(
        text: 'Las historias importan. Muchas historias importan.',
        author: 'Chimamanda Ngozi Adichie'),
  ];

  @override
  void initState() {
    super.initState();
    _quote = (_quotes..shuffle()).first;

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (mounted) {
        setState(() => _showText = true);
      }

      // Check for backups before checking auth
      await _checkAndRestoreBackup();

      if (mounted) {
        ref.read(authControllerProvider.notifier).checkAuth();
      }
    });
  }

  Future<void> _checkAndRestoreBackup() async {
    try {
      final dbFolder = await getApplicationDocumentsDirectory();
      final dbPath = p.join(dbFolder.path, 'book_sharing_v2.sqlite');
      final dbFile = File(dbPath);

      // Only check if DB does NOT exist
      if (!await dbFile.exists()) {
        final backupService = ref.read(autoBackupServiceProvider);
        final backups = await backupService.getAvailableBackups();

        if (backups.isNotEmpty && mounted) {
          final latestBackup = backups.first;

          final shouldRestore = await showDialog<bool>(
            context: context,
            barrierDismissible: false,
            builder: (context) => AlertDialog(
              title: const Text('Copia de seguridad encontrada'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                      'No se encontró base de datos local, pero hay una copia de seguridad disponible.'),
                  const SizedBox(height: 12),
                  Text('Archivo: ${latestBackup.path.split('/').last}'),
                  const SizedBox(height: 12),
                  const Text('¿Quieres restaurar tus datos ahora?'),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Empezar de cero'),
                ),
                FilledButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('Restaurar Backup'),
                ),
              ],
            ),
          );

          if (shouldRestore == true && mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content:
                    Text('Restaurando copia de seguridad... Por favor espera.'),
                duration: Duration(
                    seconds: 10), // Long duration as it might take time
              ),
            );

            await backupService.restoreFromZip(latestBackup);

            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Restauración completada con éxito.')),
              );
            }
          }
        }
      }
    } catch (e) {
      debugPrint('Error verifying backups: $e');
    }
  }

  Future<void> _navigate(String routeName) async {
    if (_navigated || !mounted) return;
    _navigated = true;

    // Minimum display time of 3 seconds as requested
    final elapsed = DateTime.now().difference(_startTime);
    final remaining = const Duration(seconds: 3) - elapsed;
    if (remaining > Duration.zero) {
      await Future.delayed(remaining);
    }

    if (!mounted) return;

    setState(() => _showText = false); // Fade out text before transition
    await Future.delayed(const Duration(milliseconds: 400));

    if (!mounted) return;

    // Custom fade transition for a smooth experience
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            _getRouteWidget(routeName),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 800),
      ),
    );
  }

  Widget _getRouteWidget(String routeName) {
    switch (routeName) {
      case PinSetupScreen.routeName:
        return const PinSetupScreen();
      case LockScreen.routeName:
        return const LockScreen();
      case OnboardingIntroScreen.routeName:
        return const OnboardingIntroScreen();
      case OnboardingWizardScreen.routeName:
        return const OnboardingWizardScreen();
      case HomeShell.routeName:
        return const InactivityListener(child: HomeShell());
      default:
        return const SizedBox.shrink();
    }
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

    return Scaffold(
      backgroundColor: const Color(0xFF225A93),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: AnimatedOpacity(
            opacity: _showText ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 1000),
            curve: Curves.easeIn,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '“${_quote.text}”',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: Colors.white,
                        fontStyle: FontStyle.italic,
                        fontWeight: FontWeight.w300,
                        height: 1.5,
                      ),
                ),
                const SizedBox(height: 24),
                Text(
                  '— ${_quote.author}',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.white.withValues(alpha: 0.8),
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                ),
                const SizedBox(height: 64),
                const CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              ],
            ),
          ),
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

class Quote {
  final String text;
  final String author;

  Quote({required this.text, required this.author});
}
