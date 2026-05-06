import 'package:flutter/material.dart' as material;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../providers/book_providers.dart';
import '../../widgets/textured_background.dart';
import '../../../design_system/literary_animations.dart';
import '../home/home_shell.dart';
import 'onboarding_wizard_screen.dart';
import '../../../l10n/generated/app_localizations.dart';

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
    final s = S.of(context);

    final slides = [
      _IntroSlide(
        icon: material.Icons.auto_stories_outlined,
        title: s.onboardingSlide1Title,
        message: s.onboardingSlide1Message,
      ),
      _IntroSlide(
        icon: material.Icons.diversity_3_outlined,
        title: s.onboardingSlide2Title,
        message: s.onboardingSlide2Message,
      ),
      _IntroSlide(
        icon: material.Icons.import_contacts_outlined,
        title: s.onboardingSlide3Title,
        message: s.onboardingSlide3Message,
      ),
      _IntroSlide(
        icon: material.Icons.cloud_sync_outlined,
        title: s.onboardingSlide4Title,
        message: s.onboardingSlide4Message,
      ),
    ];

    final isLastPage = _currentPage == slides.length - 1;

    return material.Scaffold(
      appBar: material.AppBar(
        automaticallyImplyLeading: false,
        actions: [
          material.TextButton(
            onPressed: () => _completeIntro(context),
            child: material.Text(s.actionSkip),
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
                  itemCount: slides.length,
                  itemBuilder: (context, index) {
                    final slide = slides[index];
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
                        slides.length,
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
                      label: material.Text(isLastPage
                          ? s.actionStartChronicle
                          : s.actionNextPage),
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
                      label: material.Text(s.actionSkipPrologue),
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
