import 'dart:convert';
import 'dart:developer' as developer;

import 'package:http/http.dart' as http;

import 'supabase_config_service.dart';

class SupabaseNotificationRecord {
  const SupabaseNotificationRecord({
    required this.id,
    required this.type,
    required this.targetUserId,
    this.actorUserId,
    this.loanId,
    this.sharedBookId,
    this.title,
    this.message,
    required this.status,
    required this.isDeleted,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String type;
  final String targetUserId;
  final String? actorUserId;
  final String? loanId;
  final String? sharedBookId;
  final String? title;
  final String? message;
  final String status;
  final bool isDeleted;
  final DateTime createdAt;
  final DateTime updatedAt;

  static DateTime? _tryParseDate(dynamic value) {
    if (value is String && value.isNotEmpty) {
      return DateTime.tryParse(value);
    }
    return null;
  }

  factory SupabaseNotificationRecord.fromJson(Map<String, dynamic> json) {
    final created = _tryParseDate(json['created_at']);
    final updated = _tryParseDate(json['updated_at']);
    return SupabaseNotificationRecord(
      id: json['id'] as String,
      type: json['type'] as String,
      targetUserId: json['target_user_id'] as String,
      actorUserId: json['actor_user_id'] as String?,
      loanId: json['loan_id'] as String?,
      sharedBookId: json['shared_book_id'] as String?,
      title: json['title'] as String?,
      message: json['message'] as String?,
      status: json['status'] as String? ?? 'unread',
      isDeleted: (json['is_deleted'] as bool?) ?? false,
      createdAt: created ?? DateTime.now(),
      updatedAt: updated ?? created ?? DateTime.now(),
    );
  }
}

class SupabaseNotificationUpsert {
  const SupabaseNotificationUpsert({
    required this.id,
    required this.type,
    required this.targetUserId,
    this.actorUserId,
    this.loanId,
    this.sharedBookId,
    this.title,
    this.message,
    required this.status,
    required this.isDeleted,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String type;
  final String targetUserId;
  final String? actorUserId;
  final String? loanId;
  final String? sharedBookId;
  final String? title;
  final String? message;
  final String status;
  final bool isDeleted;
  final DateTime createdAt;
  final DateTime updatedAt;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'target_user_id': targetUserId,
      'actor_user_id': actorUserId,
      'loan_id': loanId,
      'shared_book_id': sharedBookId,
      'title': title,
      'message': message,
      'status': status,
      'is_deleted': isDeleted,
      'created_at': createdAt.toUtc().toIso8601String(),
      'updated_at': updatedAt.toUtc().toIso8601String(),
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
          'id,type,target_user_id,actor_user_id,loan_id,shared_book_id,title,message,status,is_deleted,created_at,updated_at',
      'target_user_id': 'eq.$targetUserId',
      'order': 'updated_at.asc',
    };

    if (!includeDeleted) {
      query['is_deleted'] = 'eq.false';
    }

    if (updatedAfter != null) {
      query['updated_at'] = 'gte.${updatedAfter.toUtc().toIso8601String()}';
    }

    final uri = Uri.parse('${config.url}/rest/v1/in_app_notifications').replace(
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
    final uri = Uri.parse('${config.url}/rest/v1/in_app_notifications').replace(
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
        type: input.type,
        targetUserId: input.targetUserId,
        actorUserId: input.actorUserId,
        loanId: input.loanId,
        sharedBookId: input.sharedBookId,
        title: input.title,
        message: input.message,
        status: input.status,
        isDeleted: input.isDeleted,
        createdAt: input.createdAt,
        updatedAt: input.updatedAt,
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
