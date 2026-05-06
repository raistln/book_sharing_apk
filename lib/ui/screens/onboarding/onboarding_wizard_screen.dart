import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' as material;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../providers/auth_providers.dart';
import '../../../providers/book_providers.dart';
import '../../../services/onboarding_service.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/textured_background.dart';
import '../home/home_shell.dart';
import 'onboarding_intro_screen.dart';
import '../../../l10n/generated/app_localizations.dart';

class OnboardingWizardScreen extends ConsumerStatefulWidget {
  const OnboardingWizardScreen({super.key});

  static const routeName = '/onboarding-wizard';

  @override
  ConsumerState<OnboardingWizardScreen> createState() =>
      _OnboardingWizardScreenState();
}

class _OnboardingWizardScreenState
    extends ConsumerState<OnboardingWizardScreen> {
  static const _groupStepIndex = 0;
  static const _joinStepIndex = 1;
  static const _summaryStepIndex = 2;

  static const _totalSteps = 3;

  final _groupFormKey = material.GlobalKey<material.FormState>();
  final _joinFormKey = material.GlobalKey<material.FormState>();
  late final material.TextEditingController _groupNameController;
  late final material.TextEditingController _groupDescriptionController;
  late final material.TextEditingController _joinCodeController;
  int _currentStep = 0;
  final List<bool> _completedSteps = List<bool>.filled(_totalSteps, false);
  bool _initializedFromProgress = false;
  bool _isProcessing = false;
  bool _isSynced = false;
  bool _groupCreated = false;
  bool _navigationHandled = false;

  @override
  void initState() {
    super.initState();
    _groupNameController = material.TextEditingController();
    _groupDescriptionController = material.TextEditingController();
    _joinCodeController = material.TextEditingController();
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

  Future<void> _skipWizard(material.BuildContext context) async {
    if (_isProcessing) return;
    setState(() => _isProcessing = true);
    final onboardingService = ref.read(onboardingServiceProvider);
    final navigator = material.Navigator.of(context);
    await onboardingService.markCompleted();
    ref.invalidate(onboardingProgressProvider);
    if (!mounted) return;

    if (!mounted) return;
    final syncController = ref.read(groupSyncControllerProvider.notifier);
    try {
      await syncController.syncGroups();
    } catch (e) {
      // Ignoramos error de sync para no bloquear la navegación
      if (kDebugMode) {
        material.debugPrint('Error syncing on skip wizard: $e');
      }
    }
    if (!mounted) return;
    navigator.pushNamedAndRemoveUntil(HomeShell.routeName, (route) => false);
  }

  Future<void> _completeWizard(
      {required material.NavigatorState navigator,
      required material.ScaffoldMessengerState messenger}) async {
    final onboardingService = ref.read(onboardingServiceProvider);
    await onboardingService.markCompleted();
    await onboardingService.markDiscoverCoachPending(resetSeen: true);
    await onboardingService.markDetailCoachPending(resetSeen: true);
    ref.invalidate(onboardingProgressProvider);
    if (!mounted) return;

    if (!mounted) return;
    final syncController = ref.read(groupSyncControllerProvider.notifier);
    try {
      await syncController.syncGroups();
    } catch (e) {
      // Ignoramos error de sync para no bloquear la finalización
      if (kDebugMode) {
        print('Error syncing on complete wizard: $e');
      }
    }
    if (!mounted) return;
    messenger.clearSnackBars();
    final theme = material.Theme.of(context);
    messenger.showSnackBar(
      material.SnackBar(
        content: material.Text(S.of(context).welcomeToApp),
        backgroundColor: theme.colorScheme.primary,
      ),
    );
    navigator.pushNamedAndRemoveUntil(HomeShell.routeName, (route) => false);
  }

  Future<void> _handleContinue(material.BuildContext context) async {
    if (_isProcessing) return;
    setState(() => _isProcessing = true);
    final navigator = material.Navigator.of(context);
    final messenger = material.ScaffoldMessenger.of(context);
    final index = _currentStep;
    try {
      final success =
          await _runStepAction(context, index, messenger: messenger);
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
    final navigator = material.Navigator.of(context);
    final messenger = material.ScaffoldMessenger.of(context);
    try {
      if (index == _summaryStepIndex) {
        await _completeWizard(navigator: navigator, messenger: messenger);
        return;
      }
      await _markStepCompleted(index,
          advance: true, skipped: true, messenger: messenger);
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  Future<void> _markStepCompleted(int index,
      {required bool advance,
      bool skipped = false,
      required material.ScaffoldMessengerState messenger}) async {
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
        material.SnackBar(
            content: material.Text(
                S.of(context).stepSkippedHint)),
      );
    }
  }

  Future<bool> _runStepAction(
    material.BuildContext context,
    int index, {
    required material.ScaffoldMessengerState messenger,
  }) async {
    switch (index) {
      case _groupStepIndex:
        return _createGroup(context, messenger: messenger);
      case _joinStepIndex:
        return _joinGroupByCode(context, messenger: messenger);
      case _summaryStepIndex:
        return true;
      default:
        return false;
    }
  }

  Future<bool> _createGroup(material.BuildContext context,
      {required material.ScaffoldMessengerState messenger}) async {
    final s = S.of(context);
    final activeUser = ref.read(activeUserProvider).value;
    if (activeUser == null || !_isSynced) {
      messenger.showSnackBar(
        material.SnackBar(
            content: material.Text(
                s.errorSyncingAccount)),
      );
      return false;
    }

    if (!(_groupFormKey.currentState?.validate() ?? false)) {
      return false;
    }

    final name = _groupNameController.text.trim();
    final description = _groupDescriptionController.text.trim();

    // Verificar si ya existe un grupo con este nombre para evitar duplicados
    if (_groupCreated) {
      final groupDao = ref.read(groupDaoProvider);
      final existingGroups = await groupDao.getGroupsForUser(activeUser.id);
      final alreadyExists = existingGroups
          .any((g) => g.name.trim().toLowerCase() == name.toLowerCase());

      if (alreadyExists) {
        messenger.showSnackBar(
          material.SnackBar(
              content: material.Text(s.groupAlreadyExists(name))),
        );
        return true; // Consideramos que ya está "creado"
      }
    }

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
        material.SnackBar(
            content: material.Text(s.successGroupCreatedWizard(name))),
      );
      return true;
    } catch (error) {
      if (!mounted) return false;
      messenger.showSnackBar(
        material.SnackBar(
            content: material.Text(s.errorCreatingGroupWizard(error.toString()))),
      );
      return false;
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  Future<bool> _joinGroupByCode(material.BuildContext context,
      {required material.ScaffoldMessengerState messenger}) async {
    final s = S.of(context);
    final activeUser = ref.read(activeUserProvider).value;
    if (activeUser == null || !_isSynced) {
      messenger.showSnackBar(
        material.SnackBar(
            content: material.Text(
                s.errorSyncingAccount)),
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
        material.SnackBar(
            content: material.Text(s.successJoinedGroup)),
      );
      return true;
    } catch (error) {
      if (!mounted) return false;
      messenger.showSnackBar(
        material.SnackBar(
            content: material.Text(s.errorJoiningGroupWizard(error.toString()))),
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
  material.Widget build(material.BuildContext context) {
    final progressAsync = ref.watch(onboardingProgressProvider);

    return progressAsync.when(
      loading: () => const material.Scaffold(
        body: material.Center(child: material.CircularProgressIndicator()),
      ),
      error: (error, _) => material.Scaffold(
        body: material.Center(
          child: EmptyState(
            icon: material.Icons.error_outline,
            title: S.of(context).errorLoadingOnboarding,
            message: '$error',
            action: EmptyStateAction(
              label: S.of(context).actionRetry,
              icon: material.Icons.refresh,
              onPressed: () => ref.invalidate(onboardingProgressProvider),
            ),
          ),
        ),
      ),
      data: (progress) {
        if (!progress.introSeen || progress.completed) {
          material.WidgetsBinding.instance.addPostFrameCallback((_) async {
            // Evitar ejecuciones múltiples del callback
            if (!mounted || _isProcessing || _navigationHandled) return;
            _navigationHandled = true;
            setState(() => _isProcessing = true);
            try {
              if (!progress.introSeen) {
                material.Navigator.of(context)
                    .pushReplacementNamed(OnboardingIntroScreen.routeName);
                return;
              }

              // Si el wizard ya estaba completado (progress.completed == true),
              // simplemente navegamos al HomeShell sin volver a hacer sync.
              // La sincronización inicial se hará una sola vez en AuthController.
              final navigator = material.Navigator.of(context);
              if (progress.completed) {
                // Ya completado anteriormente, navegar directamente
                navigator.pushNamedAndRemoveUntil(
                    HomeShell.routeName, (route) => false);
                return;
              }

              // Si llegamos aquí, el wizard no está completado, llamar a _completeWizard
              final messenger = material.ScaffoldMessenger.of(context);
              await _completeWizard(navigator: navigator, messenger: messenger);
            } finally {
              if (mounted) {
                setState(() => _isProcessing = false);
              }
            }
          });
          return const material.Scaffold();
        }

        _initializeFromProgress(progress);

        final authState = ref.watch(authControllerProvider);
        final activeUserAsync = ref.watch(activeUserProvider);
        final activeUser = activeUserAsync.asData?.value;
        _isSynced = activeUser != null && activeUser.remoteId != null;

        if (authState.status == AuthStatus.loading ||
            activeUserAsync.isLoading) {
          return const material.Scaffold(
            body: material.Center(child: material.CircularProgressIndicator()),
          );
        }

        final steps =
            _buildSteps(context, displayName: activeUser?.username ?? '');

        return material.Scaffold(
          appBar: material.AppBar(
            title: material.Text(S.of(context).onboardingWizardTitle),
            automaticallyImplyLeading: false,
            actions: [
              material.TextButton(
                onPressed: _isProcessing ? null : () => _skipWizard(context),
                child: material.Text(S.of(context).actionSkipIntro),
              ),
            ],
          ),
          body: TexturedBackground(
            child: material.Stepper(
              type: material.StepperType.vertical,
              physics: const material.ClampingScrollPhysics(),
              currentStep: _currentStep,
              onStepTapped: (index) {
                if (_isProcessing) return;
                setState(() => _currentStep = index);
              },
              controlsBuilder: (context, details) {
                return material.Row(
                  children: [
                    material.FilledButton.icon(
                      onPressed:
                          _isProcessing ? null : () => _handleContinue(context),
                      icon: material.Icon(_currentStep == _totalSteps - 1
                          ? material.Icons.check_circle_outline
                          : material.Icons.arrow_forward),
                      label: material.Text(_currentStep == _totalSteps - 1
                          ? S.of(context).actionSealPact
                          : S.of(context).actionContinueWizard),
                    ),
                    const material.SizedBox(width: 12),
                    material.TextButton(
                      onPressed: _isProcessing
                          ? null
                          : () => _handleSkipStep(_currentStep),
                      child: material.Text(S.of(context).actionSkipChapter),
                    ),
                  ],
                );
              },
              steps: steps,
            ),
          ),
        );
      },
    );
  }

  List<material.Step> _buildSteps(material.BuildContext context,
      {required String displayName}) {
    final theme = material.Theme.of(context);

    material.Widget buildSyncNotice(
        {required String title, required String subtitle}) {
      if (_isSynced) {
        return const material.SizedBox.shrink();
      }

      return material.Card(
        color: theme.colorScheme.surfaceContainerHighest,
        child: material.ListTile(
          leading: const material.SizedBox(
            height: 24,
            width: 24,
            child: material.CircularProgressIndicator(strokeWidth: 2),
          ),
          title: material.Text(title),
          subtitle: material.Text(subtitle),
        ),
      );
    }

    return [
      material.Step(
        title: material.Text(S.of(context).wizardStep1Title),
        subtitle: material.Text(
            S.of(context).wizardStep1Subtitle),
        isActive: _currentStep >= _groupStepIndex,
        state: _resolveStepState(_groupStepIndex),
        content: material.Form(
          key: _groupFormKey,
          child: material.Column(
            crossAxisAlignment: material.CrossAxisAlignment.start,
            children: [
              material.Text(
                S.of(context).wizardStep1Content,
                style: theme.textTheme.bodyMedium,
              ),
              const material.SizedBox(height: 12),
              buildSyncNotice(
                title: S.of(context).syncingAccountTitle,
                subtitle: S.of(context).syncingAccountSubtitle,
              ),
              const material.SizedBox(height: 16),
              material.TextFormField(
                controller: _groupNameController,
                decoration: material.InputDecoration(
                  labelText: S.of(context).groupNameLabel,
                  hintText: S.of(context).groupNameHint,
                ),
                textInputAction: material.TextInputAction.next,
                enabled: _isSynced,
                validator: (value) {
                  if (!_isSynced) return null;
                  final trimmed = value?.trim() ?? '';
                  if (trimmed.isEmpty) {
                    return S.of(context).errorGroupNameRequired;
                  }
                  return null;
                },
              ),
              const material.SizedBox(height: 12),
              material.TextFormField(
                controller: _groupDescriptionController,
                decoration: material.InputDecoration(
                  labelText: S.of(context).groupDescriptionLabel,
                ),
                enabled: _isSynced,
              ),
              const material.SizedBox(height: 12),
              material.Align(
                alignment: material.Alignment.centerLeft,
                child: material.TextButton.icon(
                  onPressed: () => _showGroupInfoSheet(context),
                  icon: const material.Icon(material.Icons.info_outline),
                  label: material.Text(S.of(context).learnAboutGroupsAction),
                ),
              ),
            ],
          ),
        ),
      ),
      material.Step(
        title: material.Text(S.of(context).wizardStep2Title),
        subtitle: material.Text(
            S.of(context).wizardStep2Subtitle),
        isActive: _currentStep >= _joinStepIndex,
        state: _resolveStepState(_joinStepIndex),
        content: material.Form(
          key: _joinFormKey,
          child: material.Column(
            crossAxisAlignment: material.CrossAxisAlignment.start,
            children: [
              material.Text(
                S.of(context).wizardStep2Content,
                style: theme.textTheme.bodyMedium,
              ),
              const material.SizedBox(height: 12),
              buildSyncNotice(
                title: S.of(context).syncingAccountTitle,
                subtitle:
                    S.of(context).syncingAccountSubtitleJoin,
              ),
              const material.SizedBox(height: 16),
              material.TextFormField(
                controller: _joinCodeController,
                decoration: material.InputDecoration(
                  labelText: S.of(context).labelInvitationCode,
                  hintText: S.of(context).invitationCodeHint,
                ),
                textInputAction: material.TextInputAction.done,
                enabled: _isSynced,
                validator: (value) {
                  if (!_isSynced) return null;
                  final trimmed = value?.trim() ?? '';
                  if (trimmed.isEmpty) {
                    return S.of(context).errorInvalidCodeWizard;
                  }
                  if (trimmed.length < 6) {
                    return S.of(context).errorCodeTooShort;
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
      material.Step(
        title: material.Text(S.of(context).wizardStep3Title),
        subtitle:
            material.Text(S.of(context).wizardStep3Subtitle),
        isActive: _currentStep >= _summaryStepIndex,
        state: _resolveStepState(_summaryStepIndex),
        content: _SummaryStep(
          displayName: displayName,
          groupCompleted: _completedSteps[_groupStepIndex],
          joinCompleted: _completedSteps[_joinStepIndex],
        ),
      ),
    ];
  }

  material.StepState _resolveStepState(int index) {
    if (_currentStep == index) {
      return material.StepState.editing;
    }
    if (_completedSteps[index]) {
      return material.StepState.complete;
    }
    return material.StepState.indexed;
  }

  Future<void> _showGroupInfoSheet(material.BuildContext context) async {
    await material.showModalBottomSheet<void>(
      context: context,
      builder: (ctx) => const _GroupInfoBottomSheet(),
    );
  }
}

class _GroupInfoBottomSheet extends material.StatelessWidget {
  const _GroupInfoBottomSheet();

  @override
  material.Widget build(material.BuildContext context) {
    final theme = material.Theme.of(context);
    return material.SafeArea(
      child: material.Padding(
        padding: const material.EdgeInsets.all(24),
        child: material.Column(
          mainAxisSize: material.MainAxisSize.min,
          crossAxisAlignment: material.CrossAxisAlignment.start,
          children: [
            material.Text(S.of(context).whatIsGroupTitle,
                style: theme.textTheme.titleMedium),
            const material.SizedBox(height: 12),
            material.Text(
              S.of(context).whatIsGroupContent,
              style: theme.textTheme.bodyMedium,
            ),
            const material.SizedBox(height: 16),
            material.Text(
              S.of(context).whatIsGroupContent2,
              style: theme.textTheme.bodySmall,
            ),
            const material.SizedBox(height: 24),
            material.Align(
              alignment: material.Alignment.centerRight,
              child: material.FilledButton(
                onPressed: () => material.Navigator.of(context).pop(),
                child: material.Text(S.of(context).actionGotIt),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryStep extends material.StatelessWidget {
  const _SummaryStep({
    required this.displayName,
    required this.groupCompleted,
    required this.joinCompleted,
  });

  final String displayName;
  final bool groupCompleted;
  final bool joinCompleted;

  @override
  material.Widget build(material.BuildContext context) {
    final theme = material.Theme.of(context);

    material.Widget buildTile({
      required String title,
      required String subtitle,
      required bool done,
    }) {
      return material.ListTile(
        leading: material.Icon(
          done
              ? material.Icons.check_circle_outline
              : material.Icons.radio_button_unchecked,
          color: done
              ? theme.colorScheme.primary
              : theme.colorScheme.onSurfaceVariant,
        ),
        title: material.Text(title),
        subtitle: material.Text(subtitle),
        trailing: material.Text(done ? S.of(context).statusCompleted : S.of(context).statusPending),
      );
    }

    return material.Column(
      crossAxisAlignment: material.CrossAxisAlignment.start,
      children: [
        material.Text(
          S.of(context).almostDoneTitle,
          style: theme.textTheme.titleMedium,
        ),
        const material.SizedBox(height: 12),
        material.Text(
          S.of(context).onboardingSummaryMessage,
          style: theme.textTheme.bodyMedium,
        ),
        const material.SizedBox(height: 16),
        material.Card(
          child: material.Column(
            children: [
              material.ListTile(
                leading: material.Icon(
                  material.Icons.person_outline,
                  color: theme.colorScheme.primary,
                ),
                title: material.Text(S.of(context).profileConfiguredTitle),
                subtitle: material.Text(S.of(context).userLabel(displayName)),
                trailing: material.Text(S.of(context).statusCompleted),
              ),
              const material.Divider(height: 1),
              buildTile(
                title: S.of(context).firstGroupTitle,
                subtitle: S.of(context).firstGroupSubtitle,
                done: groupCompleted,
              ),
              const material.Divider(height: 1),
              buildTile(
                title: S.of(context).joinByCodeTitle,
                subtitle: S.of(context).joinByCodeSubtitle,
                done: joinCompleted,
              ),
            ],
          ),
        ),
        const material.SizedBox(height: 16),
        material.Text(
          S.of(context).finishOnboardingMessage,
          style: theme.textTheme.bodySmall,
        ),
      ],
    );
  }
}
