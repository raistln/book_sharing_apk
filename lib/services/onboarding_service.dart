import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingProgress {
  const OnboardingProgress({
    required this.introSeen,
    required this.completed,
    this.currentStep,
    required this.discoverCoachPending,
    required this.discoverCoachSeen,
    required this.detailCoachPending,
    required this.detailCoachSeen,
  });

  final bool introSeen;
  final bool completed;
  final int? currentStep;
  final bool discoverCoachPending;
  final bool discoverCoachSeen;
  final bool detailCoachPending;
  final bool detailCoachSeen;

  bool get shouldShowWizard => introSeen && !completed;
  bool get shouldShowDiscoverCoach =>
      discoverCoachPending && !discoverCoachSeen;
  bool get shouldShowDetailCoach => detailCoachPending && !detailCoachSeen;
}

class OnboardingService {
  static const _introSeenKey = 'onboarding_intro_seen';
  static const _completedKey = 'onboarding_completed';
  static const _currentStepKey = 'onboarding_current_step';
  static const _discoverCoachPendingKey = 'onboarding_discover_coach_pending';
  static const _discoverCoachSeenKey = 'onboarding_discover_coach_seen';
  static const _detailCoachPendingKey = 'onboarding_detail_coach_pending';
  static const _detailCoachSeenKey = 'onboarding_detail_coach_seen';

  Future<OnboardingProgress> loadProgress() async {
    final prefs = await SharedPreferences.getInstance();
    final introSeen = prefs.getBool(_introSeenKey) ?? false;
    final completed = prefs.getBool(_completedKey) ?? false;
    final hasStep = prefs.containsKey(_currentStepKey);
    final currentStep = hasStep ? prefs.getInt(_currentStepKey) : null;
    final discoverPending = prefs.getBool(_discoverCoachPendingKey) ?? false;
    final discoverSeen = prefs.getBool(_discoverCoachSeenKey) ?? false;
    final detailPending = prefs.getBool(_detailCoachPendingKey) ?? false;
    final detailSeen = prefs.getBool(_detailCoachSeenKey) ?? false;

    if (kDebugMode) {
      debugPrint('[OnboardingService] loadProgress: '
          'introSeen=$introSeen, completed=$completed, currentStep=$currentStep, '
          'discoverPending=$discoverPending, discoverSeen=$discoverSeen, '
          'detailPending=$detailPending, detailSeen=$detailSeen');
    }

    return OnboardingProgress(
      introSeen: introSeen,
      completed: completed,
      currentStep: currentStep,
      discoverCoachPending: discoverPending,
      discoverCoachSeen: discoverSeen,
      detailCoachPending: detailPending,
      detailCoachSeen: detailSeen,
    );
  }

  Future<void> markIntroSeen() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_introSeenKey, true);
    if (kDebugMode) {
      debugPrint('[OnboardingService] markIntroSeen');
    }
  }

  Future<void> saveCurrentStep(int stepIndex) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_currentStepKey, stepIndex);
    await prefs.setBool(_completedKey, false);
    if (kDebugMode) {
      debugPrint('[OnboardingService] saveCurrentStep -> stepIndex=$stepIndex');
    }
  }

  Future<void> clearCurrentStep() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_currentStepKey);
    if (kDebugMode) {
      debugPrint('[OnboardingService] clearCurrentStep');
    }
  }

  Future<void> markCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_introSeenKey, true);
    await prefs.remove(_currentStepKey);
    await prefs.setBool(_completedKey, true);
    if (kDebugMode) {
      debugPrint('[OnboardingService] markCompleted');
    }
  }

  Future<void> reset() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_introSeenKey);
    await prefs.remove(_currentStepKey);
    await prefs.remove(_completedKey);
    await prefs.remove(_discoverCoachPendingKey);
    await prefs.remove(_discoverCoachSeenKey);
    await prefs.remove(_detailCoachPendingKey);
    await prefs.remove(_detailCoachSeenKey);
    if (kDebugMode) {
      debugPrint('[OnboardingService] reset all flags');
    }
  }

  Future<void> markDiscoverCoachPending({bool resetSeen = false}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_discoverCoachPendingKey, true);
    await prefs.setBool(_detailCoachPendingKey, true);
    if (resetSeen) {
      await prefs.setBool(_discoverCoachSeenKey, false);
      await prefs.setBool(_detailCoachSeenKey, false);
    }
  }

  Future<void> markDetailCoachPending({bool resetSeen = false}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_detailCoachPendingKey, true);
    if (resetSeen) {
      await prefs.setBool(_detailCoachSeenKey, false);
    }
  }

  Future<bool> isDiscoverCoachPending() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_discoverCoachPendingKey) ?? false;
  }

  Future<bool> hasShownDiscoverCoach() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_discoverCoachSeenKey) ?? false;
  }

  Future<void> markDiscoverCoachSeen() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_discoverCoachSeenKey, true);
    await prefs.setBool(_discoverCoachPendingKey, false);
  }

  Future<bool> isDetailCoachPending() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_detailCoachPendingKey) ?? false;
  }

  Future<bool> hasShownDetailCoach() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_detailCoachSeenKey) ?? false;
  }

  Future<void> markDetailCoachSeen() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_detailCoachSeenKey, true);
    await prefs.setBool(_detailCoachPendingKey, false);
  }
}
