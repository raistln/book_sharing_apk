import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';

class AuthService {
  AuthService({
    LocalAuthentication? localAuth,
    FlutterSecureStorage? storage,
  })  : _localAuth = localAuth ?? LocalAuthentication(),
        _storage = _SecurePluginStorageAdapter(
            storage ?? const FlutterSecureStorage());

  final LocalAuthentication _localAuth;
  final _StorageAdapter _storage;

  static const _pinKey = 'auth.pin';
  static const _pinConfiguredKey = 'auth.pin_configured';
  static const _lockedKey = 'auth.session_locked';
  static const _defaultPin = '1234';

  Future<bool> hasConfiguredPin() async {
    final configured = await _storage.read(_pinConfiguredKey);
    if (configured == 'true') return true;

    final storedPin = await _storage.read(_pinKey);
    if (storedPin != null && storedPin.isNotEmpty) {
      await _storage.write(_pinConfiguredKey, 'true');
      return true;
    }

    if (configured == null) {
      // Seed a default PIN for first run in development until replaced by user setup.
      await _storage.write(_pinKey, _defaultPin);
      await _storage.write(_pinConfiguredKey, 'true');
      await _storage.write(_lockedKey, 'true');
      return true;
    }

    return false;
  }

  Future<bool> verifyPin(String pin) async {
    final storedPin = await _storage.read(_pinKey);
    if (storedPin == null) return false;
    return storedPin == pin;
  }

  Future<bool> isBiometricAvailable() async {
    if (kIsWeb) return false;
    try {
      final isSupported = await _localAuth.isDeviceSupported();
      if (!isSupported) return false;

      final canCheck = await _localAuth.canCheckBiometrics;
      if (!canCheck) return false;

      final available = await _localAuth.getAvailableBiometrics();
      return available.isNotEmpty;
    } on PlatformException {
      return false;
    }
  }

  Future<bool> authenticateWithBiometrics() async {
    if (kIsWeb) return false;
    try {
      return await _localAuth.authenticate(
        localizedReason: 'Autentícate para desbloquear tu biblioteca',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );
    } on PlatformException {
      return false;
    }
  }

  Future<void> lockSession() async {
    await _storage.write(_lockedKey, 'true');
  }

  Future<void> unlockSession() async {
    await _storage.write(_lockedKey, 'false');
  }

  Future<void> setPin(String pin) async {
    await _storage.write(_pinKey, pin);
    await _storage.write(_pinConfiguredKey, 'true');
  }

  Future<void> clearPin() async {
    await _storage.delete(_pinKey);
    await _storage.write(_pinConfiguredKey, 'false');
    await lockSession();
  }

  Future<bool> isSessionLocked() async {
    final locked = await _storage.read(_lockedKey);
    if (locked == null) {
      await lockSession();
      return true;
    }
    return locked != 'false';
  }
}

abstract class _StorageAdapter {
  Future<String?> read(String key);
  Future<void> write(String key, String value);
  Future<void> delete(String key);
}

class _SecurePluginStorageAdapter implements _StorageAdapter {
  _SecurePluginStorageAdapter(this._storage);

  final FlutterSecureStorage _storage;

  @override
  Future<String?> read(String key) async {
    try {
      return await _storage.read(key: key);
    } on PlatformException {
      return null;
    }
  }

  @override
  Future<void> write(String key, String value) async {
    try {
      await _storage.write(key: key, value: value);
    } on PlatformException {
      // Ignore write failures for now; caller will operate with defaults.
    }
  }

  @override
  Future<void> delete(String key) async {
    try {
      await _storage.delete(key: key);
    } on PlatformException {
      // Ignore delete failures quietly.
    }
  }
}
