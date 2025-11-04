import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class GoogleBooksApiService {
  GoogleBooksApiService({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _storage;

  static const _apiKeyStorageKey = 'google_books_api_key';

  Future<String?> readApiKey() async {
    try {
      return await _storage.read(key: _apiKeyStorageKey);
    } on PlatformException {
      return null;
    }
  }

  Future<void> saveApiKey(String apiKey) async {
    try {
      await _storage.write(key: _apiKeyStorageKey, value: apiKey.trim());
    } on PlatformException {
      // Ignore write failures for now; UI will continue solicit input.
    }
  }

  Future<void> clearApiKey() async {
    try {
      await _storage.delete(key: _apiKeyStorageKey);
    } on PlatformException {
      // Ignore delete failures quietly.
    }
  }
}
