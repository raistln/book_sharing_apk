import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../providers/book_providers.dart';
import '../../../providers/auth_providers.dart';
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
  static const _groupStepIndex = 0;
  static const _joinStepIndex = 1;
  static const _bookStepIndex = 2;
  static const _summaryStepIndex = 3;

  static const _totalSteps = 4;

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
  bool _isSynced = false;
  bool _groupCreated = false;

  @override
  void initState() {
    super.initState();
    _groupNameController = TextEditingController();
    _groupDescriptionController = TextEditingController();
    _joinCodeController = TextEditingController();
    _bookTitleController = TextEditingController();
    _bookAuthorController = TextEditingController();
    _groupNameController.addListener(_resetGroupCreatedFlag);
    _groupDescriptionController.addListener(_resetGroupCreatedFlag);
  }

  @override
  void dispose() {
    _groupNameController.removeListener(_resetGroupCreatedFlag);
    _groupDescriptionController.removeListener(_resetGroupCreatedFlag);
    _groupNameController.dispose();
    _groupDescriptionController.dispose();
    _joinCodeController.dispose();
    _bookTitleController.dispose();
    _bookAuthorController.dispose();
    super.dispose();
  }

  void _resetGroupCreatedFlag() {
    if (!_groupCreated) {
      return;
    }
    setState(() {
      _groupCreated = false;
    });
  }

  Future<void> _skipWizard(BuildContext context) async {
    if (_isProcessing) return;
    setState(() => _isProcessing = true);
    final onboardingService = ref.read(onboardingServiceProvider);
    final navigator = Navigator.of(context);
    await onboardingService.markCompleted();
    ref.invalidate(onboardingProgressProvider);
    if (!mounted) return;
    final syncController = ref.read(groupSyncControllerProvider.notifier);
    await syncController.syncGroups();
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
    final syncController = ref.read(groupSyncControllerProvider.notifier);
    await syncController.syncGroups();
    if (!mounted) return;
    messenger.clearSnackBars();
    final theme = Theme.of(context);
    messenger.showSnackBar(
      SnackBar(
        content: const Text('¡Listo! Bienvenido a Book Sharing.'),
        backgroundColor: theme.colorScheme.primary,
      ),
    );
    navigator.pushNamedAndRemoveUntil(HomeShell.routeName, (route) => false);
  }

  Future<void> _handleContinue(BuildContext context) async {
    if (_isProcessing) return;
    setState(() => _isProcessing = true);
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final index = _currentStep;
    try {
      final success = await _runStepAction(context, index, messenger: messenger);
      if (!mounted || !success) {
        return;
      }

      if (index == _summaryStepIndex) {
        await _completeWizard(navigator: navigator, messenger: messenger);
        return;
      }

      await _markStepCompleted(index, advance: true, messenger: messenger);
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  Future<void> _handleSkipStep(int index) async {
    if (_isProcessing) return;
    setState(() => _isProcessing = true);
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    try {
      if (index == _summaryStepIndex) {
        await _completeWizard(navigator: navigator, messenger: messenger);
        return;
      }
      await _markStepCompleted(index, advance: true, skipped: true, messenger: messenger);
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
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
      case _groupStepIndex:
        return _createGroup(context, messenger: messenger);
      case _joinStepIndex:
        return _joinGroupByCode(context, messenger: messenger);
      case _bookStepIndex:
        return _registerBook(context, messenger: messenger);
      case _summaryStepIndex:
        return true;
      default:
        return false;
    }
  }

  Future<bool> _createGroup(BuildContext context, {required ScaffoldMessengerState messenger}) async {
    if (_groupCreated) {
      return true;
    }

    final activeUser = ref.read(activeUserProvider).value;
    if (activeUser == null || !_isSynced) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Estamos terminando de sincronizar tu cuenta. Intenta en unos segundos.')),
      );
      return false;
    }

    if (!(_groupFormKey.currentState?.validate() ?? false)) {
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
      _groupCreated = true;
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
    final activeUser = ref.read(activeUserProvider).value;
    if (activeUser == null || !_isSynced) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Estamos terminando de sincronizar tu cuenta. Intenta en unos segundos.')),
      );
      return false;
    }

    if (!(_joinFormKey.currentState?.validate() ?? false)) {
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
    final activeUser = ref.read(activeUserProvider).value;
    if (activeUser == null || !_isSynced) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Estamos terminando de sincronizar tu cuenta. Intenta en unos segundos.')),
      );
      return false;
    }

    if (!(_bookFormKey.currentState?.validate() ?? false)) {
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
    _groupCreated = _completedSteps[_groupStepIndex];
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

        final authState = ref.watch(authControllerProvider);
        final activeUserAsync = ref.watch(activeUserProvider);
        final activeUser = activeUserAsync.asData?.value;
        _isSynced = activeUser != null && activeUser.remoteId != null;

        if (authState.status == AuthStatus.loading || activeUserAsync.isLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final steps = _buildSteps(context, displayName: activeUser?.username ?? '');

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

  List<Step> _buildSteps(BuildContext context, {required String displayName}) {
    final theme = Theme.of(context);

    Widget buildSyncNotice({required String title, required String subtitle}) {
      if (_isSynced) {
        return const SizedBox.shrink();
      }

      return Card(
        color: theme.colorScheme.surfaceContainerHighest,
        child: ListTile(
          leading: const SizedBox(
            height: 24,
            width: 24,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          title: Text(title),
          subtitle: Text(subtitle),
        ),
      );
    }

    return [
      Step(
        title: const Text('Crea tu primer grupo'),
        subtitle: const Text('Invita a tus amigos y comparte la biblioteca.'),
        isActive: _currentStep >= _groupStepIndex,
        state: _resolveStepState(_groupStepIndex),
        content: Form(
          key: _groupFormKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Un grupo te permite compartir libros con otros miembros. Puedes crear uno nuevo ahora o hacerlo más tarde.',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 12),
              buildSyncNotice(
                title: 'Sincronizando tu cuenta...',
                subtitle: 'En cuanto terminemos podrás crear grupos.',
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _groupNameController,
                decoration: const InputDecoration(
                  labelText: 'Nombre del grupo',
                  hintText: 'Ej. Club de lectura Aficionados',
                ),
                textInputAction: TextInputAction.next,
                enabled: _isSynced,
                validator: (value) {
                  if (!_isSynced) return null;
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
                ),
                enabled: _isSynced,
              ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: () => _showGroupInfoSheet(context),
                  icon: const Icon(Icons.info_outline),
                  label: const Text('Aprender sobre grupos'),
                ),
              ),
            ],
          ),
        ),
      ),
      Step(
        title: const Text('Únete con un código'),
        subtitle: const Text('Introduce el código que te compartieron.'),
        isActive: _currentStep >= _joinStepIndex,
        state: _resolveStepState(_joinStepIndex),
        content: Form(
          key: _joinFormKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Las invitaciones por código se generan desde otros grupos. Si aún no tienes uno, puedes omitir este paso.',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 12),
              buildSyncNotice(
                title: 'Sincronizando tu cuenta...',
                subtitle: 'Necesitamos tu usuario activo para validar el código.',
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _joinCodeController,
                decoration: const InputDecoration(
                  labelText: 'Código de invitación',
                  hintText: 'Ej. 123e4567-e89b-12d3-a456-426614174000',
                ),
                textInputAction: TextInputAction.done,
                enabled: _isSynced,
                validator: (value) {
                  if (!_isSynced) return null;
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
        subtitle: const Text('Compártelo con tu grupo y gestiona préstamos.'),
        isActive: _currentStep >= _bookStepIndex,
        state: _resolveStepState(_bookStepIndex),
        content: Form(
          key: _bookFormKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Puedes registrar libros manualmente o importar catálogos más adelante. Empieza con un ejemplar de referencia.',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 12),
              buildSyncNotice(
                title: 'Sincronizando tu cuenta...',
                subtitle: 'Necesitamos tu usuario activo para registrar libros.',
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _bookTitleController,
                decoration: const InputDecoration(
                  labelText: 'Título del libro',
                  hintText: 'Ej. El nombre del viento',
                ),
                enabled: _isSynced,
                validator: (value) {
                  if (!_isSynced) return null;
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
                enabled: _isSynced,
              ),
            ],
          ),
        ),
      ),
      Step(
        title: const Text('Todo listo'),
        subtitle: const Text('Revisa y empieza a usar la app.'),
        isActive: _currentStep >= _summaryStepIndex,
        state: _resolveStepState(_summaryStepIndex),
        content: _SummaryStep(
          displayName: displayName,
          groupCompleted: _completedSteps[_groupStepIndex],
          joinCompleted: _completedSteps[_joinStepIndex],
          bookCompleted: _completedSteps[_bookStepIndex],
        ),
      ),
    ];
  }

  StepState _resolveStepState(int index) {
    if (_currentStep == index) {
      return StepState.editing;
    }
    if (_completedSteps[index]) {
      return StepState.complete;
    }
    return StepState.indexed;
  }

  Future<void> _showGroupInfoSheet(BuildContext context) async {
    await showModalBottomSheet<void>(
      context: context,
      builder: (ctx) => const _GroupInfoBottomSheet(),
    );
  }
}

class _GroupInfoBottomSheet extends StatelessWidget {
  const _GroupInfoBottomSheet();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('¿Qué es un grupo?', style: theme.textTheme.titleMedium),
            const SizedBox(height: 12),
            Text(
              'Los grupos reúnen a tus amigos o familiares para compartir bibliotecas locales. '
              'Desde aquí podrás invitar miembros, gestionar préstamos y llevar un historial conjunto.',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            Text(
              'Puedes crear varios grupos: uno para tu familia, otro para tu club de lectura, etc. '
              'Cada grupo tiene sus propias invitaciones y catálogos.',
              style: theme.textTheme.bodySmall,
            ),
            const SizedBox(height: 24),
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Entendido'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryStep extends StatelessWidget {
  const _SummaryStep({
    required this.displayName,
    required this.groupCompleted,
    required this.joinCompleted,
    required this.bookCompleted,
  });

  final String displayName;
  final bool groupCompleted;
  final bool joinCompleted;
  final bool bookCompleted;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Widget buildTile({
      required String title,
      required String subtitle,
      required bool done,
    }) {
      return ListTile(
        leading: Icon(
          done ? Icons.check_circle_outline : Icons.radio_button_unchecked,
          color: done ? theme.colorScheme.primary : theme.colorScheme.onSurfaceVariant,
        ),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: Text(done ? 'Completado' : 'Pendiente'),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '¡Ya casi terminamos!',
          style: theme.textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        Text(
          'Estos son los pasos que configuraste. Puedes volver atrás si quieres ajustar algo antes de empezar.',
          style: theme.textTheme.bodyMedium,
        ),
        const SizedBox(height: 16),
        Card(
          child: Column(
            children: [
              ListTile(
                leading: Icon(
                  Icons.person_outline,
                  color: theme.colorScheme.primary,
                ),
                title: const Text('Perfil configurado'),
                subtitle: Text('Usuario: $displayName'),
                trailing: const Text('Completado'),
              ),
              const Divider(height: 1),
              buildTile(
                title: 'Primer grupo',
                subtitle: 'Creaste tu comunidad principal.',
                done: groupCompleted,
              ),
              const Divider(height: 1),
              buildTile(
                title: 'Unión por código',
                subtitle: 'Te uniste a un grupo existente.',
                done: joinCompleted,
              ),
              const Divider(height: 1),
              buildTile(
                title: 'Libro registrado',
                subtitle: 'Añadiste tu primer ejemplar compartido.',
                done: bookCompleted,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Al pulsar “Finalizar” sincronizaremos tu información y te llevaremos a tu biblioteca.',
          style: theme.textTheme.bodySmall,
        ),
      ],
    );
  }
}
