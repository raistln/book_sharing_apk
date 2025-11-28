import 'dart:convert';
import 'dart:developer' as developer;

import 'package:http/http.dart' as http;

import 'supabase_config_service.dart';

class SupabaseNotificationRecord {
  const SupabaseNotificationRecord({
    required this.id,
    required this.loanId,
    required this.userId,
    required this.type,
    required this.title,
    required this.message,
    required this.status,
    this.readAt,
    required this.createdAt,
  });

  final String id;
  final String loanId;
  final String userId;
  final String type;
  final String title;
  final String message;
  final String status;
  final DateTime? readAt;
  final DateTime createdAt;

  static DateTime? _tryParseDate(dynamic value) {
    if (value is String && value.isNotEmpty) {
      return DateTime.tryParse(value);
    }
    return null;
  }

  factory SupabaseNotificationRecord.fromJson(Map<String, dynamic> json) {
    final created = _tryParseDate(json['created_at']);
    final readAt = _tryParseDate(json['read_at']);
    return SupabaseNotificationRecord(
      id: json['id'] as String,
      loanId: json['loan_id'] as String,
      userId: json['user_id'] as String,
      type: json['type'] as String,
      title: json['title'] as String,
      message: json['message'] as String,
      status: json['status'] as String? ?? 'unread',
      readAt: readAt,
      createdAt: created ?? DateTime.now(),
    );
  }
}

class SupabaseNotificationUpsert {
  const SupabaseNotificationUpsert({
    required this.id,
    required this.loanId,
    required this.userId,
    required this.type,
    required this.title,
    required this.message,
    required this.status,
    this.readAt,
    required this.createdAt,
  });

  final String id;
  final String loanId;
  final String userId;
  final String type;
  final String title;
  final String message;
  final String status;
  final DateTime? readAt;
  final DateTime createdAt;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'loan_id': loanId,
      'user_id': userId,
      'type': type,
      'title': title,
      'message': message,
      'status': status,
      'read_at': readAt?.toUtc().toIso8601String(),
      'created_at': createdAt.toUtc().toIso8601String(),
    };
  }
}

class SupabaseNotificationServiceException implements Exception {
  SupabaseNotificationServiceException(this.message, [this.statusCode]);

  final String message;
  final int? statusCode;

  @override
  String toString() =>
      'SupabaseNotificationServiceException(${statusCode ?? 'unknown'}): $message';
}

class SupabaseNotificationService {
  SupabaseNotificationService({
    http.Client? client,
    SupabaseConfigService? configService,
    Future<SupabaseConfig> Function()? configLoader,
  })  : _client = client ?? http.Client(),
        _loadConfig =
            configLoader ?? ((configService ?? const SupabaseConfigService()).loadConfig);

  final http.Client _client;
  final Future<SupabaseConfig> Function() _loadConfig;

  Map<String, String> _buildHeaders(
    SupabaseConfig config, {
    String? accessToken,
    bool preferRepresentation = false,
    bool mergeDuplicates = false,
  }) {
    final useServiceRole = accessToken == null;
    final baseToken = config.authToken(useServiceRole: useServiceRole);
    final token = accessToken ?? baseToken;
    final apiKey = useServiceRole ? baseToken : config.anonKey;

    final headers = <String, String>{
      'apikey': apiKey,
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    final preferValues = <String>[];
    preferValues.add(preferRepresentation ? 'return=representation' : 'return=minimal');
    if (mergeDuplicates) {
      preferValues.add('resolution=merge-duplicates');
    }

    headers['Prefer'] = preferValues.join(',');
    return headers;
  }

  Future<List<SupabaseNotificationRecord>> fetchNotifications({
    required String targetUserId,
    String? accessToken,
    DateTime? updatedAfter,
    bool includeDeleted = false,
  }) async {
    final config = await _loadConfig();
    final query = <String, String>{
      'select':
          'id,loan_id,user_id,type,title,message,status,read_at,created_at',
      'user_id': 'eq.$targetUserId',
      'order': 'created_at.desc',
    };

    final uri = Uri.parse('${config.url}/rest/v1/loan_notifications').replace(
      queryParameters: query,
    );

    final response = await _client.get(
      uri,
      headers: _buildHeaders(config, accessToken: accessToken),
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final payload = jsonDecode(response.body);
      if (payload is List) {
        return payload
            .whereType<Map<String, dynamic>>()
            .map(SupabaseNotificationRecord.fromJson)
            .toList(growable: false);
      }
      return const [];
    }

    throw SupabaseNotificationServiceException(
      'Error ${response.statusCode}: ${response.body}',
      response.statusCode,
    );
  }

  Future<SupabaseNotificationRecord> upsertNotification({
    required SupabaseNotificationUpsert input,
    String? accessToken,
  }) async {
    final config = await _loadConfig();
    final uri = Uri.parse('${config.url}/rest/v1/loan_notifications').replace(
      queryParameters: {'on_conflict': 'id'},
    );

    final response = await _client.post(
      uri,
      headers: _buildHeaders(
        config,
        accessToken: accessToken,
        preferRepresentation: true,
        mergeDuplicates: true,
      ),
      body: jsonEncode(input.toJson()),
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      try {
        final decoded = jsonDecode(response.body);
        if (decoded is List && decoded.isNotEmpty) {
          final first = decoded.first;
          if (first is Map<String, dynamic>) {
            return SupabaseNotificationRecord.fromJson(first);
          }
        } else if (decoded is Map<String, dynamic>) {
          return SupabaseNotificationRecord.fromJson(decoded);
        }
      } catch (error, stackTrace) {
        developer.log(
          'Failed to decode Supabase upsert notification response, falling back to input values.',
          name: 'SupabaseNotificationService',
          error: error,
          stackTrace: stackTrace,
        );
      }

      return SupabaseNotificationRecord(
        id: input.id,
        loanId: input.loanId,
        userId: input.userId,
        type: input.type,
        title: input.title,
        message: input.message,
        status: input.status,
        readAt: input.readAt,
        createdAt: input.createdAt,
      );
    }

    throw SupabaseNotificationServiceException(
      'Error ${response.statusCode}: ${response.body}',
      response.statusCode,
    );
  }

  void dispose() {
    _client.close();
  }
}
