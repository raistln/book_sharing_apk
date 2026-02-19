import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../config/supabase_defaults.dart';

class SupabaseConfig {
  const SupabaseConfig({
    required this.url,
    required this.anonKey,
    this.serviceRoleKey,
  });

  final String url;
  final String anonKey;
  final String? serviceRoleKey;

  SupabaseConfig copyWith(
          {String? url, String? anonKey, String? serviceRoleKey}) =>
      SupabaseConfig(
        url: url ?? this.url,
        anonKey: anonKey ?? this.anonKey,
        serviceRoleKey: serviceRoleKey ?? this.serviceRoleKey,
      );

  String authToken({bool useServiceRole = false}) {
    if (useServiceRole &&
        serviceRoleKey != null &&
        serviceRoleKey!.isNotEmpty) {
      return serviceRoleKey!;
    }
    return anonKey;
  }
}

class SupabaseConfigService {
  const SupabaseConfigService();

  Future<SupabaseConfig> loadConfig() async {
    final envUrl = dotenv.maybeGet('SUPABASE_URL');
    final envAnon = dotenv.maybeGet('SUPABASE_ANON_KEY');
    final envService = dotenv.maybeGet('SUPABASE_SERVICE_ROLE_KEY');

    return SupabaseConfig(
      url: (envUrl != null && envUrl.isNotEmpty) ? envUrl : kSupabaseDefaultUrl,
      anonKey: (envAnon != null && envAnon.isNotEmpty)
          ? envAnon
          : kSupabaseDefaultAnonKey,
      serviceRoleKey: envService,
    );
  }

  Future<void> saveConfig(SupabaseConfig config) async {}

  Future<void> clear() async {}
}
