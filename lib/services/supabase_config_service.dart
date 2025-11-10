import 'package:flutter_dotenv/flutter_dotenv.dart';

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
  const SupabaseConfigService();

  Future<SupabaseConfig> loadConfig() async {
    final envUrl = dotenv.maybeGet('SUPABASE_URL');
    final envAnon = dotenv.maybeGet('SUPABASE_ANON_KEY');

    return SupabaseConfig(
      url: (envUrl != null && envUrl.isNotEmpty) ? envUrl : kSupabaseDefaultUrl,
      anonKey:
          (envAnon != null && envAnon.isNotEmpty) ? envAnon : kSupabaseDefaultAnonKey,
    );
  }

  Future<void> saveConfig(SupabaseConfig config) async {}

  Future<void> clear() async {}
}
