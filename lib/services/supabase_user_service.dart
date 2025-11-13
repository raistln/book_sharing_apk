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
    bool forceServiceRole = false,
  }) {
    final useServiceRole = forceServiceRole || accessToken == null;
    final baseToken = config.authToken(useServiceRole: useServiceRole);
    final token = accessToken ?? baseToken;
    final apiKey = useServiceRole ? baseToken : config.anonKey;

    final headers = <String, String>{
      'apikey': apiKey,
      'Authorization': 'Bearer $token',
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

    final headers = _buildHeaders(
      config,
      forceServiceRole: true,
    );
    headers['Prefer'] = 'count=exact';

    final response = await _client.get(
      uri,
      headers: headers,
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

  Future<List<SupabaseUserRecord>> fetchUsers({
    String? accessToken,
    DateTime? updatedAfter,
  }) async {
    final config = await _loadConfig();
    final query = <String, String>{
      'select': 'id,username,is_deleted,created_at,updated_at',
      'order': 'updated_at.asc',
    };

    if (updatedAfter != null) {
      query['updated_at'] = 'gte.${updatedAfter.toUtc().toIso8601String()}';
    }

    final uri = Uri.parse('${config.url}/rest/v1/local_users').replace(
      queryParameters: query,
    );

    final response = await _client.get(
      uri,
      headers: _buildHeaders(
        config,
        accessToken: accessToken,
      ),
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final payload = jsonDecode(response.body) as List<dynamic>;
      return payload
          .whereType<Map<String, dynamic>>()
          .map(SupabaseUserRecord.fromJson)
          .toList();
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

class SupabaseUserRecord {
  const SupabaseUserRecord({
    required this.id,
    required this.username,
    required this.isDeleted,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String username;
  final bool isDeleted;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  static DateTime? _parseDate(dynamic value) {
    if (value is String) {
      return DateTime.tryParse(value);
    }
    return null;
  }

  factory SupabaseUserRecord.fromJson(Map<String, dynamic> json) {
    return SupabaseUserRecord(
      id: json['id'] as String,
      username: (json['username'] as String?) ?? '',
      isDeleted: (json['is_deleted'] as bool?) ?? false,
      createdAt: _parseDate(json['created_at']),
      updatedAt: _parseDate(json['updated_at']),
    );
  }
}
