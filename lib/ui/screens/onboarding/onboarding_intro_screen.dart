import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../providers/book_providers.dart';
import '../home/home_shell.dart';
import 'onboarding_wizard_screen.dart';

class OnboardingIntroScreen extends ConsumerStatefulWidget {
  const OnboardingIntroScreen({super.key});

  static const routeName = '/onboarding-intro';

  @override
  ConsumerState<OnboardingIntroScreen> createState() => _OnboardingIntroScreenState();
}

class _OnboardingIntroScreenState extends ConsumerState<OnboardingIntroScreen> {
  late final PageController _pageController;
  int _currentPage = 0;
  bool _isCompleting = false;

  final _slides = const [
    _IntroSlide(
      icon: Icons.menu_book_outlined,
      title: 'Tu biblioteca personal',
      message:
          'Registra tus libros, añade notas y mantén el control de tus ejemplares disponibles para préstamo.',
    ),
    _IntroSlide(
      icon: Icons.groups_outlined,
      title: 'Comparte con tu grupo',
      message:
          'Únete a comunidades, descubre colecciones compartidas y coordina préstamos sin perder el contexto.',
    ),
    _IntroSlide(
      icon: Icons.handshake_outlined,
      title: 'Préstamos con seguimiento',
      message:
          'Solicita, acepta y gestiona préstamos con recordatorios automáticos y estados claros para todos.',
    ),
    _IntroSlide(
      icon: Icons.sync_outlined,
      title: 'Sincronización en la nube',
      message:
          'La app se sincroniza con Supabase para mantener tus cambios disponibles en todos tus dispositivos.',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _completeIntro(BuildContext context) async {
    if (_isCompleting) {
      return;
    }
    setState(() {
      _isCompleting = true;
    });

    final onboardingService = ref.read(onboardingServiceProvider);
    final navigator = Navigator.of(context);
    await onboardingService.markIntroSeen();
    await onboardingService.saveCurrentStep(0);

    if (!mounted) return;
    navigator.pushReplacementNamed(OnboardingWizardScreen.routeName);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLastPage = _currentPage == _slides.length - 1;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        actions: [
          TextButton(
            onPressed: () => _completeIntro(context),
            child: const Text('Saltar'),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemCount: _slides.length,
                itemBuilder: (context, index) {
                  final slide = _slides[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(slide.icon, size: 120, color: theme.colorScheme.primary),
                        const SizedBox(height: 32),
                        Text(
                          slide.title,
                          style: theme.textTheme.headlineMedium,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          slide.message,
                          style: theme.textTheme.bodyLarge,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _slides.length,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        height: 8,
                        width: _currentPage == index ? 24 : 8,
                        decoration: BoxDecoration(
                          color: _currentPage == index
                              ? theme.colorScheme.primary
                              : theme.colorScheme.primary.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  FilledButton.icon(
                    onPressed: () {
                      if (isLastPage) {
                        _completeIntro(context);
                      } else {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 250),
                          curve: Curves.easeOut,
                        );
                      }
                    },
                    icon: Icon(isLastPage ? Icons.check_circle_outline : Icons.arrow_forward),
                    label: Text(isLastPage ? 'Empezar' : 'Siguiente'),
                  ),
                  const SizedBox(height: 12),
                  TextButton.icon(
                    onPressed: () async {
                      if (_isCompleting) return;
                      setState(() {
                        _isCompleting = true;
                      });
                      final onboardingService = ref.read(onboardingServiceProvider);
                      final navigator = Navigator.of(context);
                      await onboardingService.markIntroSeen();
                      if (!mounted) return;
                      navigator.pushReplacementNamed(HomeShell.routeName);
                    },
                    icon: const Icon(Icons.home_outlined),
                    label: const Text('Ir a la app (volveré luego)'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _IntroSlide {
  const _IntroSlide({
    required this.icon,
    required this.title,
    required this.message,
  });

  final IconData icon;
  final String title;
  final String message;
}
