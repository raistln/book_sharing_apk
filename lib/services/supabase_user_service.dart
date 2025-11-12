import 'dart:convert';

import 'package:http/http.dart' as http;

import 'supabase_config_service.dart';

class SupabaseUserService {
  SupabaseUserService({
    http.Client? client,
    SupabaseConfigService? configService,
    Future<SupabaseConfig> Function()? configLoader,
  })  : _client = client ?? http.Client(),
        _loadConfig = configLoader ??
            ((configService ?? const SupabaseConfigService()).loadConfig);

  final http.Client _client;
  final Future<SupabaseConfig> Function() _loadConfig;

  Map<String, String> _buildHeaders(
    SupabaseConfig config, {
    String? accessToken,
    bool preferRepresentation = false,
  }) {
    final headers = <String, String>{
      'apikey': config.anonKey,
      'Authorization': 'Bearer ${accessToken ?? config.anonKey}',
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    headers['Prefer'] = preferRepresentation
        ? 'return=representation'
        : 'return=minimal';

    return headers;
  }

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
      response.statusCode,
    );
  }

  Future<String> createUser({
    required String id,
    required String username,
    required bool isDeleted,
    required DateTime createdAt,
    required DateTime updatedAt,
    String? accessToken,
  }) async {
    final config = await _loadConfig();
    final uri = Uri.parse('${config.url}/rest/v1/local_users');
    final response = await _client.post(
      uri,
      headers: _buildHeaders(
        config,
        accessToken: accessToken,
        preferRepresentation: true,
      ),
      body: jsonEncode({
        'id': id,
        'username': username,
        'is_deleted': isDeleted,
        'created_at': createdAt.toUtc().toIso8601String(),
        'updated_at': updatedAt.toUtc().toIso8601String(),
      }),
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) {
        return id;
      }

      final decoded = jsonDecode(response.body);
      if (decoded is List && decoded.isNotEmpty) {
        final record = decoded.first;
        if (record is Map<String, dynamic>) {
          return (record['id'] as String?) ?? id;
        }
      } else if (decoded is Map<String, dynamic>) {
        return (decoded['id'] as String?) ?? id;
      }

      return id;
    }

    throw SupabaseUserServiceException(
      'Error ${response.statusCode}: ${response.body}',
      response.statusCode,
    );
  }

  Future<bool> updateUser({
    required String id,
    required String username,
    required bool isDeleted,
    required DateTime updatedAt,
    String? accessToken,
  }) async {
    final config = await _loadConfig();
    final uri = Uri.parse('${config.url}/rest/v1/local_users').replace(
      queryParameters: {
        'id': 'eq.$id',
      },
    );

    final response = await _client.patch(
      uri,
      headers: _buildHeaders(
        config,
        accessToken: accessToken,
        preferRepresentation: false,
      ),
      body: jsonEncode({
        'username': username,
        'is_deleted': isDeleted,
        'updated_at': updatedAt.toUtc().toIso8601String(),
      }),
    );

    if (response.statusCode == 404) {
      return false;
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return true;
    }

    throw SupabaseUserServiceException(
      'Error ${response.statusCode}: ${response.body}',
      response.statusCode,
    );
  }

  void dispose() {
    _client.close();
  }
}

class SupabaseUserServiceException implements Exception {
  SupabaseUserServiceException(this.message, [this.statusCode]);

  final String message;
  final int? statusCode;

  @override
  String toString() =>
      'SupabaseUserServiceException(${statusCode ?? 'unknown'}): $message';
}
