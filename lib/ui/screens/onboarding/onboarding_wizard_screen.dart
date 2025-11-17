import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../providers/book_providers.dart';
import '../../../services/onboarding_service.dart';
import '../../widgets/empty_state.dart';
import '../home/home_shell.dart';
import 'onboarding_intro_screen.dart';

class OnboardingWizardScreen extends ConsumerStatefulWidget {
  const OnboardingWizardScreen({super.key});

  static const routeName = '/onboarding-wizard';

  @override
  ConsumerState<OnboardingWizardScreen> createState() => _OnboardingWizardScreenState();
}

class _OnboardingWizardScreenState extends ConsumerState<OnboardingWizardScreen> {
  static const _totalSteps = 3;

  final _groupFormKey = GlobalKey<FormState>();
  final _joinFormKey = GlobalKey<FormState>();
  final _bookFormKey = GlobalKey<FormState>();

  late final TextEditingController _groupNameController;
  late final TextEditingController _groupDescriptionController;
  late final TextEditingController _joinCodeController;
  late final TextEditingController _bookTitleController;
  late final TextEditingController _bookAuthorController;

  int _currentStep = 0;
  final List<bool> _completedSteps = List<bool>.filled(_totalSteps, false);
  bool _initializedFromProgress = false;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _groupNameController = TextEditingController();
    _groupDescriptionController = TextEditingController();
    _joinCodeController = TextEditingController();
    _bookTitleController = TextEditingController();
    _bookAuthorController = TextEditingController();
  }

  @override
  void dispose() {
    _groupNameController.dispose();
    _groupDescriptionController.dispose();
    _joinCodeController.dispose();
    _bookTitleController.dispose();
    _bookAuthorController.dispose();
    super.dispose();
  }

  Future<void> _skipWizard(BuildContext context) async {
    if (_isProcessing) return;
    setState(() => _isProcessing = true);
    final onboardingService = ref.read(onboardingServiceProvider);
    final navigator = Navigator.of(context);
    await onboardingService.markCompleted();
    ref.invalidate(onboardingProgressProvider);
    if (!mounted) return;
    navigator.pushNamedAndRemoveUntil(HomeShell.routeName, (route) => false);
  }

  Future<void> _completeWizard({required NavigatorState navigator, required ScaffoldMessengerState messenger}) async {
    final onboardingService = ref.read(onboardingServiceProvider);
    await onboardingService.markCompleted();
    await onboardingService.markDiscoverCoachPending(resetSeen: true);
    await onboardingService.markDetailCoachPending(resetSeen: true);
    ref.invalidate(onboardingProgressProvider);
    if (!mounted) return;
    messenger.showSnackBar(
      const SnackBar(content: Text('¡Listo! Bienvenido a Book Sharing.')),
    );
    navigator.pushNamedAndRemoveUntil(HomeShell.routeName, (route) => false);
  }

  Future<void> _handleContinue(BuildContext context) async {
    if (_isProcessing) return;
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final index = _currentStep;
    final success = await _runStepAction(context, index, messenger: messenger);
    if (!mounted) return;
    if (!success) {
      return;
    }

    if (index == _totalSteps - 1) {
      await _completeWizard(navigator: navigator, messenger: messenger);
      return;
    }

    await _markStepCompleted(index, advance: true, messenger: messenger);
  }

  Future<void> _handleSkipStep(int index) async {
    if (_isProcessing) return;
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    if (index == _totalSteps - 1) {
      await _completeWizard(navigator: navigator, messenger: messenger);
      return;
    }
    await _markStepCompleted(index, advance: true, skipped: true, messenger: messenger);
  }

  Future<void> _markStepCompleted(int index, {required bool advance, bool skipped = false, required ScaffoldMessengerState messenger}) async {
    setState(() {
      _completedSteps[index] = true;
    });

    final onboardingService = ref.read(onboardingServiceProvider);
    await onboardingService.saveCurrentStep(index + 1);
    ref.invalidate(onboardingProgressProvider);

    if (!mounted) return;

    if (advance) {
      setState(() {
        _currentStep = (index + 1).clamp(0, _totalSteps - 1);
      });
    }

    if (skipped) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Paso omitido. Puedes configurarlo más tarde desde la ayuda.')),
      );
    }
  }

  Future<bool> _runStepAction(
    BuildContext context,
    int index, {
    required ScaffoldMessengerState messenger,
  }) async {
    switch (index) {
      case 0:
        return _createGroup(context, messenger: messenger);
      case 1:
        return _joinGroupByCode(context, messenger: messenger);
      case 2:
        return _registerBook(context, messenger: messenger);
      default:
        return false;
    }
  }

  Future<bool> _createGroup(BuildContext context, {required ScaffoldMessengerState messenger}) async {
    if (!(_groupFormKey.currentState?.validate() ?? false)) {
      return false;
    }

    final activeUser = ref.read(activeUserProvider).value;
    if (activeUser == null) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Necesitas una cuenta activa para crear un grupo.')),
      );
      return false;
    }

    final name = _groupNameController.text.trim();
    final description = _groupDescriptionController.text.trim();

    setState(() => _isProcessing = true);
    final controller = ref.read(groupPushControllerProvider.notifier);
    try {
      await controller.createGroup(
        name: name,
        description: description.isEmpty ? null : description,
        owner: activeUser,
      );
      if (!mounted) return false;
      messenger.showSnackBar(
        SnackBar(content: Text('Grupo "$name" creado correctamente.')),
      );
      return true;
    } catch (error) {
      if (!mounted) return false;
      messenger.showSnackBar(
        SnackBar(content: Text('No se pudo crear el grupo: $error')),
      );
      return false;
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  Future<bool> _joinGroupByCode(BuildContext context, {required ScaffoldMessengerState messenger}) async {
    if (!(_joinFormKey.currentState?.validate() ?? false)) {
      return false;
    }

    final activeUser = ref.read(activeUserProvider).value;
    if (activeUser == null) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Necesitas una cuenta activa para unirte a un grupo.')),
      );
      return false;
    }

    final code = _joinCodeController.text.trim();

    setState(() => _isProcessing = true);
    final controller = ref.read(groupPushControllerProvider.notifier);
    try {
      await controller.acceptInvitationByCode(
        code: code,
        user: activeUser,
      );
      if (!mounted) return false;
      messenger.showSnackBar(
        const SnackBar(content: Text('Te uniste al grupo correctamente.')),
      );
      return true;
    } catch (error) {
      if (!mounted) return false;
      messenger.showSnackBar(
        SnackBar(content: Text('No se pudo unir al grupo: $error')),
      );
      return false;
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  Future<bool> _registerBook(BuildContext context, {required ScaffoldMessengerState messenger}) async {
    if (!(_bookFormKey.currentState?.validate() ?? false)) {
      return false;
    }

    final activeUser = ref.read(activeUserProvider).value;
    if (activeUser == null) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Necesitas una cuenta activa para registrar un libro.')),
      );
      return false;
    }

    final title = _bookTitleController.text.trim();
    final author = _bookAuthorController.text.trim();

    setState(() => _isProcessing = true);
    final repository = ref.read(bookRepositoryProvider);
    try {
      await repository.addBook(
        title: title,
        author: author.isEmpty ? null : author,
        owner: activeUser,
      );
      if (!mounted) return false;
      messenger.showSnackBar(
        SnackBar(content: Text('Libro "$title" añadido a tu biblioteca.')),
      );
      return true;
    } catch (error) {
      if (!mounted) return false;
      messenger.showSnackBar(
        SnackBar(content: Text('No se pudo registrar el libro: $error')),
      );
      return false;
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  void _initializeFromProgress(OnboardingProgress progress) {
    if (_initializedFromProgress) {
      return;
    }
    _initializedFromProgress = true;

    final currentStep = progress.currentStep ?? 0;
    for (var i = 0; i < currentStep && i < _totalSteps; i++) {
      _completedSteps[i] = true;
    }
    _currentStep = currentStep.clamp(0, _totalSteps - 1);
  }

  @override
  Widget build(BuildContext context) {
    final progressAsync = ref.watch(onboardingProgressProvider);

    return progressAsync.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, _) => Scaffold(
        body: Center(
          child: EmptyState(
            icon: Icons.error_outline,
            title: 'No pudimos cargar el estado del onboarding.',
            message: '$error',
            action: EmptyStateAction(
              label: 'Reintentar',
              icon: Icons.refresh,
              onPressed: () => ref.invalidate(onboardingProgressProvider),
            ),
          ),
        ),
      ),
      data: (progress) {
        if (!progress.introSeen || progress.completed) {
          WidgetsBinding.instance.addPostFrameCallback((_) async {
            if (!mounted || _isProcessing) return;
            setState(() => _isProcessing = true);
            try {
              if (!progress.introSeen) {
                Navigator.of(context)
                    .pushReplacementNamed(OnboardingIntroScreen.routeName);
                return;
              }

              final navigator = Navigator.of(context);
              final messenger = ScaffoldMessenger.of(context);
              await _completeWizard(navigator: navigator, messenger: messenger);
            } finally {
              if (mounted) {
                setState(() => _isProcessing = false);
              }
            }
          });
          return const Scaffold();
        }

        _initializeFromProgress(progress);

        final steps = _buildSteps(context);

        return Scaffold(
          appBar: AppBar(
            title: const Text('Primeros pasos'),
            automaticallyImplyLeading: false,
            actions: [
              TextButton(
                onPressed: _isProcessing ? null : () => _skipWizard(context),
                child: const Text('Omitir wizard'),
              ),
            ],
          ),
          body: Stepper(
            type: StepperType.vertical,
            physics: const ClampingScrollPhysics(),
            currentStep: _currentStep,
            onStepTapped: (index) {
              if (_isProcessing) return;
              setState(() => _currentStep = index);
            },
            controlsBuilder: (context, details) {
              return Row(
                children: [
                  FilledButton.icon(
                    onPressed: _isProcessing ? null : () => _handleContinue(context),
                    icon: Icon(_currentStep == _totalSteps - 1
                        ? Icons.check_circle_outline
                        : Icons.arrow_forward),
                    label: Text(_currentStep == _totalSteps - 1 ? 'Finalizar' : 'Continuar'),
                  ),
                  const SizedBox(width: 12),
                  TextButton(
                    onPressed: _isProcessing ? null : () => _handleSkipStep(_currentStep),
                    child: const Text('Omitir paso'),
                  ),
                ],
              );
            },
            steps: steps,
          ),
        );
      },
    );
  }

  List<Step> _buildSteps(BuildContext context) {
    final theme = Theme.of(context);

    return [
      Step(
        title: const Text('Crea tu primer grupo'),
        subtitle: const Text('Invita a tus amigos y comparte la biblioteca.'),
        state: _completedSteps[0] ? StepState.complete : StepState.indexed,
        isActive: _currentStep >= 0,
        content: Form(
          key: _groupFormKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Un grupo te permite compartir libros con otros miembros. Puedes crear uno nuevo ahora o hacerlo más tarde.',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _groupNameController,
                decoration: const InputDecoration(
                  labelText: 'Nombre del grupo',
                  hintText: 'Ej. Club de lectura Aficionados',
                ),
                textInputAction: TextInputAction.next,
                validator: (value) {
                  final trimmed = value?.trim() ?? '';
                  if (trimmed.isEmpty) {
                    return 'Introduce un nombre para el grupo.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _groupDescriptionController,
                decoration: const InputDecoration(
                  labelText: 'Descripción (opcional)',
                  hintText: 'Comparte tu objetivo, reglas o notas internas.',
                ),
                maxLines: 2,
              ),
            ],
          ),
        ),
      ),
      Step(
        title: const Text('Únete a un grupo por código'),
        subtitle: const Text('Si recibiste un código de invitación, introdúcelo aquí.'),
        state: _completedSteps[1] ? StepState.complete : StepState.indexed,
        isActive: _currentStep >= 1,
        content: Form(
          key: _joinFormKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Las invitaciones por código se generan desde otros grupos. Si aún no tienes uno, puedes omitir este paso.',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _joinCodeController,
                decoration: const InputDecoration(
                  labelText: 'Código de invitación',
                  hintText: 'Ej. 123e4567-e89b-12d3-a456-426614174000',
                ),
                textInputAction: TextInputAction.done,
                validator: (value) {
                  final trimmed = value?.trim() ?? '';
                  if (trimmed.isEmpty) {
                    return 'Introduce un código válido o pulsa "Omitir paso".';
                  }
                  if (trimmed.length < 6) {
                    return 'El código es demasiado corto.';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
      Step(
        title: const Text('Registra tu primer libro'),
        subtitle: const Text('Añade un libro a tu biblioteca personal.'),
        state: _completedSteps[2] ? StepState.complete : StepState.indexed,
        isActive: _currentStep >= 2,
        content: Form(
          key: _bookFormKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Puedes registrar libros manualmente o importar catálogos más adelante. Empieza con un ejemplar de referencia.',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _bookTitleController,
                decoration: const InputDecoration(
                  labelText: 'Título del libro',
                  hintText: 'Ej. El nombre del viento',
                ),
                validator: (value) {
                  final trimmed = value?.trim() ?? '';
                  if (trimmed.isEmpty) {
                    return 'Introduce un título para el libro.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _bookAuthorController,
                decoration: const InputDecoration(
                  labelText: 'Autor (opcional)',
                  hintText: 'Ej. Patrick Rothfuss',
                ),
              ),
            ],
          ),
        ),
      ),
    ];
  }
}
