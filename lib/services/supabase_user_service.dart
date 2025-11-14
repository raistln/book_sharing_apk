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
      'select':
          'id,username,display_name,avatar_url,google_books_api_key,is_deleted,pin_hash,pin_salt,pin_updated_at,created_at,updated_at',
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
    String? displayName,
    String? avatarUrl,
    String? googleBooksApiKey,
    String? pinHash,
    String? pinSalt,
    DateTime? pinUpdatedAt,
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
        'display_name': displayName,
        'avatar_url': avatarUrl,
        'google_books_api_key': googleBooksApiKey,
        'is_deleted': isDeleted,
        'pin_hash': pinHash,
        'pin_salt': pinSalt,
        'pin_updated_at': pinUpdatedAt?.toUtc().toIso8601String(),
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
    String? displayName,
    String? avatarUrl,
    String? googleBooksApiKey,
    required bool isDeleted,
    String? pinHash,
    String? pinSalt,
    DateTime? pinUpdatedAt,
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
        'display_name': displayName,
        'avatar_url': avatarUrl,
        'google_books_api_key': googleBooksApiKey,
        'is_deleted': isDeleted,
        'pin_hash': pinHash,
        'pin_salt': pinSalt,
        'pin_updated_at': pinUpdatedAt?.toUtc().toIso8601String(),
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

  Future<SupabaseUserRecord?> fetchUserByUsername(
    String username, {
    String? accessToken,
  }) async {
    final config = await _loadConfig();
    final uri = Uri.parse('${config.url}/rest/v1/local_users').replace(
      queryParameters: {
        'username': 'eq.$username',
        'select':
            'id,username,display_name,avatar_url,google_books_api_key,is_deleted,pin_hash,pin_salt,pin_updated_at,created_at,updated_at',
        'limit': '1',
      },
    );

    final response = await _client.get(
      uri,
      headers: _buildHeaders(
        config,
        accessToken: accessToken,
      ),
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final payload = jsonDecode(response.body);
      if (payload is List && payload.isNotEmpty) {
        final first = payload.first;
        if (first is Map<String, dynamic>) {
          return SupabaseUserRecord.fromJson(first);
        }
      }
      return null;
    }

    throw SupabaseUserServiceException(
      'Error ${response.statusCode}: ${response.body}',
      response.statusCode,
    );
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
    this.displayName,
    this.avatarUrl,
    this.googleBooksApiKey,
    required this.isDeleted,
    this.createdAt,
    this.updatedAt,
    this.pinHash,
    this.pinSalt,
    this.pinUpdatedAt,
  });

  final String id;
  final String username;
  final String? displayName;
  final String? avatarUrl;
  final String? googleBooksApiKey;
  final bool isDeleted;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? pinHash;
  final String? pinSalt;
  final DateTime? pinUpdatedAt;

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
      displayName: json['display_name'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      googleBooksApiKey: json['google_books_api_key'] as String?,
      isDeleted: (json['is_deleted'] as bool?) ?? false,
      createdAt: _parseDate(json['created_at']),
      updatedAt: _parseDate(json['updated_at']),
      pinHash: json['pin_hash'] as String?,
      pinSalt: json['pin_salt'] as String?,
      pinUpdatedAt: _parseDate(json['pin_updated_at']),
    );
  }
}
