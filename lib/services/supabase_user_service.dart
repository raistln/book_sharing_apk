import 'dart:convert';

import 'package:http/http.dart' as http;

import 'supabase_config_service.dart';

class SupabaseUserService {
  SupabaseUserService({
    http.Client? client,
    SupabaseConfigService? configService,
    Future<SupabaseConfig> Function()? configLoader,
  })  : _client = client ?? http.Client(),
        _loadConfig =
            configLoader ?? ((configService ?? SupabaseConfigService()).loadConfig);

  final http.Client _client;
  final Future<SupabaseConfig> Function() _loadConfig;

  Future<bool> isUsernameAvailable(String username) async {
    final config = await _loadConfig();
    final uri = Uri.parse('${config.url}/rest/v1/local_users').replace(
      queryParameters: {
        'username': 'eq.$username',
        'select': 'id',
      },
    );

    final response = await _client.get(
      uri,
      headers: {
        'apikey': config.anonKey,
        'Authorization': 'Bearer ${config.anonKey}',
        'Accept': 'application/json',
        'Prefer': 'count=exact',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as List<dynamic>;
      return data.isEmpty;
    }

    throw SupabaseUserServiceException(
      'Error ${response.statusCode}: ${response.body}',
    );
  }

  void dispose() {
    _client.close();
  }
}

class SupabaseUserServiceException implements Exception {
  SupabaseUserServiceException(this.message);

  final String message;

  @override
  String toString() => 'SupabaseUserServiceException: $message';
}
