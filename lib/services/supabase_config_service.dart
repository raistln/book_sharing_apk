import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../config/supabase_defaults.dart';

class SupabaseConfig {
  const SupabaseConfig({required this.url, required this.anonKey});

  final String url;
  final String anonKey;

  SupabaseConfig copyWith({String? url, String? anonKey}) => SupabaseConfig(
        url: url ?? this.url,
        anonKey: anonKey ?? this.anonKey,
      );
}

class SupabaseConfigService {
  SupabaseConfigService({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _storage;

  static const _urlKey = 'supabase_url';
  static const _anonKey = 'supabase_anon_key';

  Future<SupabaseConfig> loadConfig() async {
    try {
      final storedUrl = await _storage.read(key: _urlKey);
      final storedAnon = await _storage.read(key: _anonKey);
      final url = (storedUrl?.isNotEmpty ?? false)
          ? storedUrl!
          : kSupabaseDefaultUrl;
      final anonKey = (storedAnon?.isNotEmpty ?? false)
          ? storedAnon!
          : kSupabaseDefaultAnonKey;
      return SupabaseConfig(url: url, anonKey: anonKey);
    } on PlatformException {
      return const SupabaseConfig(
        url: kSupabaseDefaultUrl,
        anonKey: kSupabaseDefaultAnonKey,
      );
    }
  }

  Future<void> saveConfig(SupabaseConfig config) async {
    try {
      await _storage.write(key: _urlKey, value: config.url);
      await _storage.write(key: _anonKey, value: config.anonKey);
    } on PlatformException {
      // ignore write failures for now
    }
  }

  Future<void> clear() async {
    try {
      await _storage.delete(key: _urlKey);
      await _storage.delete(key: _anonKey);
    } on PlatformException {
      // ignore delete failures quietly
    }
  }
}
