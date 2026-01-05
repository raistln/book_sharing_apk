import 'package:flutter/material.dart' as material;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../providers/book_providers.dart';
import '../../widgets/textured_background.dart';
import '../../../design_system/literary_animations.dart';
import '../home/home_shell.dart';
import 'onboarding_wizard_screen.dart';

class OnboardingIntroScreen extends ConsumerStatefulWidget {
  const OnboardingIntroScreen({super.key});

  static const routeName = '/onboarding-intro';

  @override
  ConsumerState<OnboardingIntroScreen> createState() =>
      _OnboardingIntroScreenState();
}

class _OnboardingIntroScreenState extends ConsumerState<OnboardingIntroScreen> {
  late final material.PageController _pageController;
  int _currentPage = 0;
  bool _isCompleting = false;

  final _slides = const [
    _IntroSlide(
      icon: material.Icons.auto_stories_outlined, // Icono más literario
      title: 'Tu propia colección',
      message:
          'Cada libro cuenta una historia. Preserva las tuyas, añade notas y mantén viva la memoria de tus lecturas.',
    ),
    _IntroSlide(
      icon: material.Icons.diversity_3_outlined,
      title: 'Círculos de Lectura',
      message:
          'Donde las historias se encuentran. Únete a comunidades y descubre bibliotecas compartidas con otros lectores.',
    ),
    _IntroSlide(
      icon: material.Icons.import_contacts_outlined,
      title: 'El viaje del libro',
      message:
          'Sigue el rastro de cada ejemplar prestado. Gestiona devoluciones y comparte el conocimiento con confianza.',
    ),
    _IntroSlide(
      icon: material.Icons.cloud_sync_outlined,
      title: 'Crónica en la nube',
      message:
          'Tu catálogo se preserva en Supabase, disponible siempre para continuar la historia desde cualquier lugar.',
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
      body: TexturedBackground(
        child: material.SafeArea(
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
                      padding: const material.EdgeInsets.symmetric(
                          horizontal: 24, vertical: 32),
                      child: FadeScaleIn(
                        key: material.ValueKey(
                            index), // Para reiniciar animacion al cambiar
                        child: material.Column(
                          mainAxisAlignment: material.MainAxisAlignment.center,
                          children: [
                            material.Icon(slide.icon,
                                size: 120, color: theme.colorScheme.primary),
                            const material.SizedBox(height: 32),
                            material.Text(
                              slide.title,
                              style: theme.textTheme.headlineMedium?.copyWith(
                                fontFamily: 'Georgia', // Refuerzo literario
                              ),
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
                      ),
                    );
                  },
                ),
              ),
              material.Padding(
                padding: const material.EdgeInsets.symmetric(
                    horizontal: 24, vertical: 32),
                child: material.Column(
                  children: [
                    material.Row(
                      mainAxisAlignment: material.MainAxisAlignment.center,
                      children: List.generate(
                        _slides.length,
                        (index) => material.AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const material.EdgeInsets.symmetric(
                              horizontal: 4),
                          height: 8,
                          width: _currentPage == index ? 24 : 8,
                          decoration: material.BoxDecoration(
                            color: _currentPage == index
                                ? theme.colorScheme.primary
                                : theme.colorScheme.primary
                                    .withValues(alpha: 0.3),
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
                            duration: const Duration(milliseconds: 500),
                            curve: material
                                .Curves.easeInOutCubic, // Curva literaria
                          );
                        }
                      },
                      icon: material.Icon(isLastPage
                          ? material.Icons.check_circle_outline
                          : material.Icons.arrow_forward),
                      label: material.Text(
                          isLastPage ? 'Comenzar Crónica' : 'Siguiente Página'),
                    ),
                    const material.SizedBox(height: 12),
                    material.TextButton.icon(
                      onPressed: () async {
                        if (_isCompleting) return;
                        setState(() {
                          _isCompleting = true;
                        });
                        final onboardingService =
                            ref.read(onboardingServiceProvider);
                        final navigator = material.Navigator.of(context);
                        await onboardingService.markIntroSeen();
                        if (!mounted) return;
                        navigator.pushReplacementNamed(HomeShell.routeName);
                      },
                      icon: const material.Icon(material.Icons.home_outlined),
                      label: const material.Text('Saltar Prólogo'),
                    ),
                  ],
                ),
              ),
            ],
          ),
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
