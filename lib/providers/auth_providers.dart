import 'dart:async';
import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/auth_service.dart';
import '../models/global_sync_state.dart';
import '../services/inactivity_service.dart';
import '../services/unified_sync_coordinator.dart';
import 'book_providers.dart';
import 'sync_providers.dart';

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
  final userRepository = ref.watch(userRepositoryProvider);
  return AuthService(userRepository: userRepository);
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
  AuthController(
    this._authService,
    this._syncCoordinator,
  ) : super(AuthState.initial);

  final AuthService _authService;
  final UnifiedSyncCoordinator _syncCoordinator;
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
    state = state.copyWith(
        status: AuthStatus.loading,
        failedAttempts: 0,
        lockUntil: AuthState._lockUntilSentinel);
    final hasPin = await _authService.hasConfiguredPin();
    if (!hasPin) {
      state = state.copyWith(
        status: AuthStatus.needsPin,
        failedAttempts: 0,
        lockUntil: null,
      );
      return;
    }

    await _authService.lockSession();
    _cancelLockTimer();
    state = state.copyWith(
      status: AuthStatus.locked,
      failedAttempts: 0,
      lockUntil: null,
    );
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
      _syncCoordinator.recordUserActivity();
      unawaited(_triggerInitialSync());
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
      _syncCoordinator.recordUserActivity();
      unawaited(_triggerInitialSync());
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
    // Marcamos cambios para subir el nuevo PIN al servidor
    _syncCoordinator.markPendingChanges(SyncEntity.users);
    await _syncCoordinator.syncNow(entities: [SyncEntity.users]);

    await _authService.unlockSession();
    state = state.copyWith(
      status: AuthStatus.unlocked,
      failedAttempts: 0,
      lockUntil: null,
    );
    _cancelLockTimer();
    unawaited(_triggerInitialSync());
  }

  Future<void> clearPin() async {
    state = state.copyWith(status: AuthStatus.loading);
    await _authService.clearPin();
    _syncCoordinator.markPendingChanges(SyncEntity.users);
    state = state.copyWith(
      status: AuthStatus.needsPin,
      failedAttempts: 0,
      lockUntil: null,
    );
    _cancelLockTimer();
  }

  Future<void> markAuthenticated({bool runSync = true}) async {
    state = state.copyWith(status: AuthStatus.loading);
    await _authService.unlockSession();
    state = state.copyWith(
      status: AuthStatus.unlocked,
      failedAttempts: 0,
      lockUntil: null,
    );
    _cancelLockTimer();
    if (runSync) {
      unawaited(_triggerInitialSync());
    }
  }

  Future<void> _triggerInitialSync() async {
    _log('Iniciando sincronización unificada tras desbloqueo.');
    try {
      // syncNow() ya sigue el orden correcto: Usuarios -> Grupos -> Préstamos -> Libros
      await _syncCoordinator.syncNow();
      _log('Sincronización inicial completada exitosamente.');
    } catch (error, stackTrace) {
      _log(
        'Error en la sincronización inicial tras desbloqueo.',
        error: error,
        stackTrace: stackTrace,
        level: 1000,
      );
    }
  }

  void _log(
    String message, {
    Object? error,
    StackTrace? stackTrace,
    int level = 0,
  }) {
    developer.log(
      message,
      name: 'AuthController',
      error: error,
      stackTrace: stackTrace,
      level: level,
    );

    if (!kDebugMode) {
      return;
    }

    final buffer = StringBuffer('[AuthController] ')..write(message);

    if (error != null) {
      buffer.write(' Error: $error');
    }

    debugPrint(buffer.toString());

    if (error != null && stackTrace != null) {
      debugPrint(stackTrace.toString());
    }
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
  final syncCoordinator = ref.watch(unifiedSyncCoordinatorProvider);

  return AuthController(
    service,
    syncCoordinator,
  );
});

final inactivityManagerProvider = Provider<InactivityManager>((ref) {
  final manager = InactivityManager(
    onTimeout: () {
      // Desactivado por petición del usuario: Sesión Persistente (Cold Start Only)
      // No bloqueamos por inactividad.
    },
  );

  ref.onDispose(manager.dispose);
  return manager;
});
