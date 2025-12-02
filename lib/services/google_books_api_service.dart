import 'dart:developer' as developer;

import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class GoogleBooksApiService {
  GoogleBooksApiService({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _storage;

  static const _apiKeyStorageKey = 'google_books_api_key';

  Future<String?> readApiKey() async {
    try {
      final key = await _storage.read(key: _apiKeyStorageKey);
      final normalized = key?.trim();
      if (normalized == null || normalized.isEmpty) {
        return null;
      }

      developer.log(
        '[GoogleBooksApiService] Read API key from SecureStorage',
        name: 'GoogleBooksApiService',
      );
      return normalized;
    } on PlatformException catch (err) {
      developer.log(
        '[GoogleBooksApiService] SecureStorage read failed: $err',
        name: 'GoogleBooksApiService',
      );
      return null;
    }
  }

  Future<void> saveApiKey(String apiKey) async {
    final cleanKey = apiKey.trim();
    if (cleanKey.isEmpty) {
      throw ArgumentError('API key cannot be empty');
    }

    try {
      await _storage.write(key: _apiKeyStorageKey, value: cleanKey);
      developer.log(
        '[GoogleBooksApiService] Saved API key to SecureStorage',
        name: 'GoogleBooksApiService',
      );
    } on PlatformException catch (err) {
      developer.log(
        '[GoogleBooksApiService] SecureStorage write failed: $err',
        name: 'GoogleBooksApiService',
      );
      rethrow;
    }
  }

  Future<void> clearApiKey() async {
    try {
      await _storage.delete(key: _apiKeyStorageKey);
      developer.log(
        '[GoogleBooksApiService] Cleared API key from SecureStorage',
        name: 'GoogleBooksApiService',
      );
    } on PlatformException catch (err) {
      developer.log(
        '[GoogleBooksApiService] SecureStorage delete failed: $err',
        name: 'GoogleBooksApiService',
      );
      rethrow;
    }
  }
}
