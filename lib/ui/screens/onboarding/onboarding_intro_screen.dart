import 'package:flutter/material.dart' as material;
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
  late final material.PageController _pageController;
  int _currentPage = 0;
  bool _isCompleting = false;

  final _slides = const [
    _IntroSlide(
      icon: material.Icons.menu_book_outlined,
      title: 'Tu biblioteca personal',
      message:
          'Registra tus libros, añade notas y mantén el control de tus ejemplares disponibles para préstamo.',
    ),
    _IntroSlide(
      icon: material.Icons.groups_outlined,
      title: 'Comparte con tu grupo',
      message:
          'Únete a comunidades, descubre colecciones compartidas y coordina préstamos sin perder el contexto.',
    ),
    _IntroSlide(
      icon: material.Icons.handshake_outlined,
      title: 'Préstamos con seguimiento',
      message:
          'Solicita, acepta y gestiona préstamos con recordatorios automáticos y estados claros para todos.',
    ),
    _IntroSlide(
      icon: material.Icons.sync_outlined,
      title: 'Sincronización en la nube',
      message:
          'La app se sincroniza con Supabase para mantener tus cambios disponibles en todos tus dispositivos.',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = material.PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _completeIntro(material.BuildContext context) async {
    if (_isCompleting) {
      return;
    }
    setState(() {
      _isCompleting = true;
    });

    final onboardingService = ref.read(onboardingServiceProvider);
    final navigator = material.Navigator.of(context);
    await onboardingService.markIntroSeen();
    await onboardingService.saveCurrentStep(0);

    if (!mounted) return;
    navigator.pushReplacementNamed(OnboardingWizardScreen.routeName);
  }

  @override
  @override
  material.Widget build(material.BuildContext context) {
    final theme = material.Theme.of(context);
    final isLastPage = _currentPage == _slides.length - 1;

    return material.Scaffold(
      appBar: material.AppBar(
        automaticallyImplyLeading: false,
        actions: [
          material.TextButton(
            onPressed: () => _completeIntro(context),
            child: const material.Text('Saltar'),
          ),
        ],
      ),
      body: material.SafeArea(
        child: material.Column(
          children: [
            material.Expanded(
              child: material.PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemCount: _slides.length,
                itemBuilder: (context, index) {
                  final slide = _slides[index];
                  return material.Padding(
                    padding: const material.EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                    child: material.Column(
                      mainAxisAlignment: material.MainAxisAlignment.center,
                      children: [
                        material.Icon(slide.icon, size: 120, color: theme.colorScheme.primary),
                        const material.SizedBox(height: 32),
                        material.Text(
                          slide.title,
                          style: theme.textTheme.headlineMedium,
                          textAlign: material.TextAlign.center,
                        ),
                        const material.SizedBox(height: 16),
                        material.Text(
                          slide.message,
                          style: theme.textTheme.bodyLarge,
                          textAlign: material.TextAlign.center,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            material.Padding(
              padding: const material.EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: material.Column(
                children: [
                  material.Row(
                    mainAxisAlignment: material.MainAxisAlignment.center,
                    children: List.generate(
                      _slides.length,
                      (index) => material.AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const material.EdgeInsets.symmetric(horizontal: 4),
                        height: 8,
                        width: _currentPage == index ? 24 : 8,
                        decoration: material.BoxDecoration(
                          color: _currentPage == index
                              ? theme.colorScheme.primary
                              : theme.colorScheme.primary.withValues(alpha: 0.3),
                          borderRadius: material.BorderRadius.circular(999),
                        ),
                      ),
                    ),
                  ),
                  const material.SizedBox(height: 24),
                  material.FilledButton.icon(
                    onPressed: () {
                      if (isLastPage) {
                        _completeIntro(context);
                      } else {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 250),
                          curve: material.Curves.easeOut,
                        );
                      }
                    },
                    icon: material.Icon(
                        isLastPage ? material.Icons.check_circle_outline : material.Icons.arrow_forward),
                    label: material.Text(isLastPage ? 'Empezar' : 'Siguiente'),
                  ),
                  const material.SizedBox(height: 12),
                  material.TextButton.icon(
                    onPressed: () async {
                      if (_isCompleting) return;
                      setState(() {
                        _isCompleting = true;
                      });
                      final onboardingService = ref.read(onboardingServiceProvider);
                      final navigator = material.Navigator.of(context);
                      await onboardingService.markIntroSeen();
                      if (!mounted) return;
                      navigator.pushReplacementNamed(HomeShell.routeName);
                    },
                    icon: const material.Icon(material.Icons.home_outlined),
                    label: const material.Text('Ir a la app (volveré luego)'),
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

  final material.IconData icon;
  final String title;
  final String message;
}
