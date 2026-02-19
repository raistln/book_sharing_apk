import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';

import '../data/repositories/user_repository.dart';

class AuthService {
  AuthService({
    required UserRepository userRepository,
    LocalAuthentication? localAuth,
    FlutterSecureStorage? storage,
    Random? random,
    AuthStorageAdapter? storageAdapter,
  })  : _userRepository = userRepository,
        _localAuth = localAuth ?? LocalAuthentication(),
        _storage = storageAdapter ??
            _SecurePluginStorageAdapter(
                storage ?? const FlutterSecureStorage()),
        _random = random ?? Random.secure();

  final UserRepository _userRepository;
  final LocalAuthentication _localAuth;
  final AuthStorageAdapter _storage;
  final Random _random;

  static const _lockedKey = 'auth.session_locked';

  static String hashPinWithSalt(String pin, String salt) {
    final payload = utf8.encode('$salt:$pin');
    final digest = sha256.convert(payload);
    return base64UrlEncode(digest.bytes);
  }

  Future<bool> hasConfiguredPin() async {
    final user = await _userRepository.getActiveUser();
    if (user == null) {
      return false;
    }
    return user.pinHash != null && user.pinSalt != null;
  }

  Future<bool> verifyPin(String pin) async {
    final user = await _userRepository.getActiveUser();
    if (user == null) {
      return false;
    }

    final salt = user.pinSalt;
    final hash = user.pinHash;
    if (salt == null || hash == null) {
      return false;
    }

    final attempt = hashPinWithSalt(pin, salt);
    return timingSafeEquals(hash, attempt);
  }

  Future<void> setPin(String pin) async {
    final user = await _userRepository.getActiveUser();
    if (user == null) {
      throw StateError('No existe un usuario activo para configurar el PIN.');
    }

    final salt = _generateSalt();
    final hash = hashPinWithSalt(pin, salt);
    final now = DateTime.now();

    await _userRepository.updatePinData(
      userId: user.id,
      pinHash: hash,
      pinSalt: salt,
      pinUpdatedAt: now,
      markDirty: true,
    );
  }

  Future<void> clearPin() async {
    final user = await _userRepository.getActiveUser();
    if (user == null) {
      return;
    }

    await _userRepository.clearPinData(userId: user.id);
    await lockSession();
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

  Future<bool> isSessionLocked() async {
    final locked = await _storage.read(_lockedKey);
    if (locked == null) {
      await lockSession();
      return true;
    }
    return locked != 'false';
  }

  String _generateSalt({int length = 16}) {
    final buffer = List<int>.generate(length, (_) => _random.nextInt(256));
    return base64UrlEncode(buffer);
  }

  bool timingSafeEquals(String a, String b) {
    if (a.length != b.length) {
      return false;
    }

    var diff = 0;
    for (var i = 0; i < a.length; i++) {
      diff |= a.codeUnitAt(i) ^ b.codeUnitAt(i);
    }
    return diff == 0;
  }
}

abstract class AuthStorageAdapter {
  Future<String?> read(String key);
  Future<void> write(String key, String value);
  Future<void> delete(String key);
}

class _SecurePluginStorageAdapter implements AuthStorageAdapter {
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
