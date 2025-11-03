import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/auth_service.dart';
import '../services/inactivity_service.dart';

enum AuthStatus { loading, needsPin, locked, unlocked }

class AuthState {
  const AuthState({
    required this.status,
    this.failedAttempts = 0,
    this.lockUntil,
  });

  final AuthStatus status;
  final int failedAttempts;
  final DateTime? lockUntil;

  bool get isTemporarilyLocked {
    if (lockUntil == null) return false;
    return DateTime.now().isBefore(lockUntil!);
  }

  AuthState copyWith({
    AuthStatus? status,
    int? failedAttempts,
    Object? lockUntil = _lockUntilSentinel,
  }) {
    return AuthState(
      status: status ?? this.status,
      failedAttempts: failedAttempts ?? this.failedAttempts,
      lockUntil: identical(lockUntil, _lockUntilSentinel)
          ? this.lockUntil
          : lockUntil as DateTime?,
    );
  }

  static const _lockUntilSentinel = Object();

  static const AuthState initial = AuthState(status: AuthStatus.loading);
}

class AuthAttemptResult {
  const AuthAttemptResult.success()
      : success = true,
        message = null;

  const AuthAttemptResult.failure({this.message}) : success = false;

  final bool success;
  final String? message;
}

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

final biometricAvailabilityProvider = FutureProvider<bool>((ref) async {
  final service = ref.watch(authServiceProvider);
  return service.isBiometricAvailable();
});

final isBiometricButtonEnabledProvider = Provider<bool>((ref) {
  final asyncValue = ref.watch(biometricAvailabilityProvider);
  return asyncValue.maybeWhen(data: (value) => value, orElse: () => false);
});

class AuthController extends StateNotifier<AuthState> {
  AuthController(this._authService) : super(AuthState.initial);

  final AuthService _authService;
  Timer? _lockTimer;

  void _cancelLockTimer() {
    _lockTimer?.cancel();
    _lockTimer = null;
  }

  void _startLockTimer(DateTime lockUntil) {
    _cancelLockTimer();
    final duration = lockUntil.difference(DateTime.now());
    if (duration.isNegative) {
      state = state.copyWith(lockUntil: null, failedAttempts: 0);
      return;
    }

    _lockTimer = Timer(duration, () {
      state = state.copyWith(lockUntil: null, failedAttempts: 0);
      _lockTimer = null;
    });
  }

  Future<void> checkAuth() async {
    state = state.copyWith(status: AuthStatus.loading, failedAttempts: 0, lockUntil: AuthState._lockUntilSentinel);
    final hasPin = await _authService.hasConfiguredPin();
    if (!hasPin) {
      state = state.copyWith(
        status: AuthStatus.needsPin,
        failedAttempts: 0,
        lockUntil: null,
      );
      return;
    }

    final isLocked = await _authService.isSessionLocked();
    state = state.copyWith(
      status: isLocked ? AuthStatus.locked : AuthStatus.unlocked,
      failedAttempts: 0,
      lockUntil: null,
    );
    if (!isLocked) {
      _cancelLockTimer();
    }
  }

  Future<AuthAttemptResult> unlockWithPin(String pin) async {
    if (state.isTemporarilyLocked) {
      final remaining = state.lockUntil!.difference(DateTime.now()).inSeconds;
      return AuthAttemptResult.failure(
        message:
            'Demasiados intentos. Espera ${remaining.clamp(1, 600)} segundos.',
      );
    }

    state = state.copyWith(status: AuthStatus.loading);
    final isValid = await _authService.verifyPin(pin);
    if (isValid) {
      await _authService.unlockSession();
      state = state.copyWith(
        status: AuthStatus.unlocked,
        failedAttempts: 0,
        lockUntil: null,
      );
      _cancelLockTimer();
      return const AuthAttemptResult.success();
    }

    final attempts = state.failedAttempts + 1;
    DateTime? lockUntil;
    String? message;

    if (attempts >= 5) {
      lockUntil = DateTime.now().add(const Duration(seconds: 30));
      message = 'Demasiados intentos fallidos. Espera 30 segundos.';
    } else {
      message = 'PIN incorrecto. Intenta de nuevo.';
    }

    state = state.copyWith(
      status: AuthStatus.locked,
      failedAttempts: lockUntil == null ? attempts : 0,
      lockUntil: lockUntil,
    );

    if (lockUntil != null) {
      _startLockTimer(lockUntil);
    }

    return AuthAttemptResult.failure(message: message);
  }

  Future<bool> unlockWithBiometrics() async {
    if (state.isTemporarilyLocked) {
      return false;
    }

    state = state.copyWith(status: AuthStatus.loading);
    final available = await _authService.isBiometricAvailable();
    if (!available) {
      state = state.copyWith(status: AuthStatus.locked);
      return false;
    }

    final success = await _authService.authenticateWithBiometrics();
    if (success) {
      await _authService.unlockSession();
      state = state.copyWith(
        status: AuthStatus.unlocked,
        failedAttempts: 0,
        lockUntil: null,
      );
      _cancelLockTimer();
      return true;
    }

    state = state.copyWith(status: AuthStatus.locked);
    return false;
  }

  Future<void> lock() async {
    state = state.copyWith(status: AuthStatus.loading);
    await _authService.lockSession();
    state = state.copyWith(status: AuthStatus.locked);
    _cancelLockTimer();
  }

  Future<void> configurePin(String pin) async {
    state = state.copyWith(status: AuthStatus.loading);
    await _authService.setPin(pin);
    await _authService.unlockSession();
    state = state.copyWith(
      status: AuthStatus.unlocked,
      failedAttempts: 0,
      lockUntil: null,
    );
    _cancelLockTimer();
  }

  Future<void> clearPin() async {
    state = state.copyWith(status: AuthStatus.loading);
    await _authService.clearPin();
    state = state.copyWith(
      status: AuthStatus.needsPin,
      failedAttempts: 0,
      lockUntil: null,
    );
    _cancelLockTimer();
  }

  @override
  void dispose() {
    _cancelLockTimer();
    super.dispose();
  }
}

final authControllerProvider =
    StateNotifierProvider<AuthController, AuthState>((ref) {
  final service = ref.watch(authServiceProvider);
  return AuthController(service);
});

final inactivityManagerProvider = Provider<InactivityManager>((ref) {
  final controller = ref.read(authControllerProvider.notifier);
  final manager = InactivityManager(
    onTimeout: () => controller.lock(),
  );

  ref.listen<AuthState>(authControllerProvider, (previous, next) {
    if (next.status == AuthStatus.unlocked) {
      manager.registerActivity();
    } else if (next.status == AuthStatus.locked ||
        next.status == AuthStatus.needsPin ||
        next.status == AuthStatus.loading) {
      manager.cancel();
    }
  });

  ref.onDispose(manager.dispose);
  return manager;
});
