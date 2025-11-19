import 'dart:convert';

import 'package:flutter/foundation.dart';

import 'package:http/http.dart' as http;

import 'supabase_config_service.dart';

class SupabaseGroupRecord {
  SupabaseGroupRecord({
    required this.id,
    required this.name,
    required this.description,
    required this.ownerId,
    required this.createdAt,
    required this.members,
    required this.sharedBooks,
    required this.invitations,
  });

  final String id;
  final String name;
  final String? description;
  final String? ownerId;
  final DateTime createdAt;
  final List<SupabaseGroupMemberRecord> members;
  final List<SupabaseSharedBookRecord> sharedBooks;
  final List<SupabaseGroupInvitationRecord> invitations;

  factory SupabaseGroupRecord.fromJson(Map<String, dynamic> json) {
    final membersJson = json['group_members'] as List<dynamic>?;
    final sharedBooksJson = json['shared_books'] as List<dynamic>?;
    final invitationsJson = json['group_invitations'] as List<dynamic>?;
    return SupabaseGroupRecord(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      ownerId: json['owner_id'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      members: membersJson == null
          ? const []
          : membersJson
              .whereType<Map<String, dynamic>>()
              .map(SupabaseGroupMemberRecord.fromJson)
              .toList(growable: false),
      sharedBooks: sharedBooksJson == null
          ? const []
          : sharedBooksJson
              .whereType<Map<String, dynamic>>()
              .map(SupabaseSharedBookRecord.fromJson)
              .toList(growable: false),
      invitations: invitationsJson == null
          ? const []
          : invitationsJson
              .whereType<Map<String, dynamic>>()
              .map(SupabaseGroupInvitationRecord.fromJson)
              .toList(growable: false),
    );
  }
}

class SupabaseGroupMemberRecord {
  SupabaseGroupMemberRecord({
    required this.id,
    required this.userId,
    required this.role,
    required this.createdAt,
  });

  final String id;
  final String userId;
  final String role;
  final DateTime createdAt;

  factory SupabaseGroupMemberRecord.fromJson(Map<String, dynamic> json) {
    return SupabaseGroupMemberRecord(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      role: json['role'] as String? ?? 'member',
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}

class SupabaseSharedBookRecord {
  SupabaseSharedBookRecord({
    required this.id,
    required this.groupId,
    required this.bookUuid,
    required this.ownerId,
    required this.visibility,
    required this.isAvailable,
    required this.createdAt,
    required this.updatedAt,
    required this.loans,
  });

  final String id;
  final String groupId;
  final String? bookUuid;
  final String ownerId;
  final String visibility;
  final bool isAvailable;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final List<SupabaseLoanRecord> loans;

  factory SupabaseSharedBookRecord.fromJson(Map<String, dynamic> json) {
    DateTime? tryParse(String? value) =>
        value != null ? DateTime.tryParse(value) : null;
    final loansJson = json['loans'] as List<dynamic>?;

    return SupabaseSharedBookRecord(
      id: json['id'] as String,
      groupId: json['group_id'] as String,
      bookUuid: json['book_uuid'] as String?,
      ownerId: json['owner_id'] as String,
      visibility: (json['visibility'] as String?) ?? 'group',
      isAvailable: json['is_available'] is bool
          ? json['is_available'] as bool
          : (json['is_available'] as num?)?.toInt() == 1,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: tryParse(json['updated_at'] as String?),
      loans: loansJson == null
          ? const []
          : loansJson
              .whereType<Map<String, dynamic>>()
              .map(SupabaseLoanRecord.fromJson)
              .toList(growable: false),
    );
  }
}

class SupabaseLoanRecord {
  SupabaseLoanRecord({
    required this.id,
    required this.sharedBookId,
    required this.fromUser,
    required this.toUser,
    required this.status,
    required this.startDate,
    required this.dueDate,
    required this.returnedAt,
    required this.cancelledAt,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String sharedBookId;
  final String fromUser;
  final String toUser;
  final String status;
  final DateTime startDate;
  final DateTime? dueDate;
  final DateTime? returnedAt;
  final DateTime? cancelledAt;
  final DateTime createdAt;
  final DateTime? updatedAt;

  factory SupabaseLoanRecord.fromJson(Map<String, dynamic> json) {
    DateTime? tryParse(String? value) =>
        value != null ? DateTime.tryParse(value) : null;

    return SupabaseLoanRecord(
      id: json['id'] as String,
      sharedBookId: json['shared_book_id'] as String,
      fromUser: json['from_user'] as String,
      toUser: json['to_user'] as String,
      status: (json['status'] as String?) ?? 'pending',
      startDate: DateTime.parse(json['start_date'] as String),
      dueDate: tryParse(json['due_date'] as String?),
      returnedAt: tryParse(json['returned_at'] as String?),
      cancelledAt: tryParse(json['cancelled_at'] as String?),
      createdAt:
          DateTime.parse((json['created_at'] ?? json['start_date']) as String),
      updatedAt: tryParse(json['updated_at'] as String?),
    );
  }
}

class SupabaseGroupInvitationRecord {
  SupabaseGroupInvitationRecord({
    required this.id,
    required this.groupId,
    required this.inviterId,
    required this.acceptedUserId,
    required this.role,
    required this.code,
    required this.status,
    required this.expiresAt,
    required this.respondedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String groupId;
  final String inviterId;
  final String? acceptedUserId;
  final String role;
  final String code;
  final String status;
  final DateTime expiresAt;
  final DateTime? respondedAt;
  final DateTime createdAt;
  final DateTime? updatedAt;

  factory SupabaseGroupInvitationRecord.fromJson(Map<String, dynamic> json) {
    DateTime? tryParse(String? value) =>
        value != null ? DateTime.tryParse(value) : null;

    return SupabaseGroupInvitationRecord(
      id: json['id'] as String,
      groupId: json['group_id'] as String,
      inviterId: json['inviter_id'] as String,
      acceptedUserId: json['accepted_user_id'] as String?,
      role: (json['role'] as String?) ?? 'member',
      code: json['code'] as String,
      status: (json['status'] as String?) ?? 'pending',
      expiresAt: DateTime.parse(json['expires_at'] as String),
      respondedAt: tryParse(json['responded_at'] as String?),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: tryParse(json['updated_at'] as String?),
    );
  }
}

class SupabaseGroupService {
  SupabaseGroupService({
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
    final useServiceRole = accessToken == null;
    final baseToken = config.authToken(useServiceRole: useServiceRole);
    final token = accessToken ?? baseToken;
    final apiKey = useServiceRole ? baseToken : config.anonKey;

    return {
      'apikey': apiKey,
      'Authorization': 'Bearer $token',
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      'Prefer': preferRepresentation ? 'return=representation' : 'return=minimal',
    };
  }

  Future<List<SupabaseGroupRecord>> fetchGroups({String? accessToken}) async {
    final config = await _loadConfig();
    final uri = Uri.parse('${config.url}/rest/v1/groups').replace(
      queryParameters: {
        'select':
            'id,name,description,owner_id,created_at,'
            'group_members(id,user_id,role,created_at),'
            'shared_books(id,group_id,book_uuid,owner_id,visibility,is_available,created_at,updated_at,'
            'loans(id,shared_book_id,from_user,to_user,status,start_date,due_date,returned_at,cancelled_at,created_at,updated_at)),'
            'group_invitations(id,group_id,inviter_id,accepted_user_id,role,code,status,expires_at,responded_at,created_at,updated_at)',
      },
    );

    final response = await _client.get(
      uri,
      headers: _buildHeaders(
        config,
        accessToken: accessToken,
      ),
    );

    if (response.statusCode != 200) {
      throw SupabaseGroupServiceException(
        'Error ${response.statusCode}: ${response.body}',
      );
    }

    final payload = jsonDecode(utf8.decode(response.bodyBytes)) as List<dynamic>;
    if (kDebugMode) {
      debugPrint(
        '[SupabaseGroupService] GET /groups -> ${payload.length} groups (status=${response.statusCode})',
      );
    }
    return payload
        .whereType<Map<String, dynamic>>()
        .map(SupabaseGroupRecord.fromJson)
        .toList(growable: false);
  }

  Future<List<SupabaseSharedBookRecord>> fetchSharedBooksForGroup({
    required String groupId,
    String? accessToken,
  }) async {
    final config = await _loadConfig();
    final uri = Uri.parse('${config.url}/rest/v1/shared_books').replace(
      queryParameters: {
        'select':
            'id,group_id,book_uuid,owner_id,visibility,is_available,created_at,updated_at,'
            'loans(id,shared_book_id,from_user,to_user,status,start_date,due_date,returned_at,cancelled_at,created_at,updated_at)',
        'group_id': 'eq.$groupId',
        'order': 'created_at.desc',
      },
    );

    final response = await _client.get(
      uri,
      headers: _buildHeaders(
        config,
        accessToken: accessToken,
      ),
    );

    if (response.statusCode != 200) {
      throw SupabaseGroupServiceException(
        'Error ${response.statusCode}: ${response.body}',
      );
    }

    final payload = jsonDecode(utf8.decode(response.bodyBytes)) as List<dynamic>;
    if (kDebugMode) {
      debugPrint(
        '[SupabaseGroupService] GET /shared_books (group=$groupId) -> ${payload.length} items (status=${response.statusCode})',
      );
      if (payload.isEmpty && response.body.isNotEmpty) {
        debugPrint('[SupabaseGroupService] Raw body: ${_truncateForLog(response.body)}');
      }
    }
    return payload
        .whereType<Map<String, dynamic>>()
        .map(SupabaseSharedBookRecord.fromJson)
        .toList(growable: false);
  }

  Future<String> createSharedBook({
    required String id,
    required String groupId,
    required String bookUuid,
    required String ownerId,
    required String visibility,
    required bool isAvailable,
    required bool isDeleted,
    required DateTime createdAt,
    required DateTime updatedAt,
    String? accessToken,
  }) async {
    final config = await _loadConfig();
    final uri = Uri.parse('${config.url}/rest/v1/shared_books');

    final payload = <String, dynamic>{
      'id': id,
      'group_id': groupId,
      'book_uuid': bookUuid,
      'owner_id': ownerId,
      'visibility': visibility,
      'is_available': isAvailable,
      'is_deleted': isDeleted,
      'created_at': createdAt.toUtc().toIso8601String(),
      'updated_at': updatedAt.toUtc().toIso8601String(),
    };

    final response = await _client.post(
      uri,
      headers: _buildHeaders(
        config,
        accessToken: accessToken,
        preferRepresentation: true,
      ),
      body: jsonEncode(payload),
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) {
        return id;
      }

      final decoded = jsonDecode(response.body);
      if (decoded is List && decoded.isNotEmpty) {
        final first = decoded.first;
        if (first is Map<String, dynamic>) {
          return (first['id'] as String?) ?? id;
        }
      } else if (decoded is Map<String, dynamic>) {
        return (decoded['id'] as String?) ?? id;
      }

      return id;
    }

    throw SupabaseGroupServiceException(
      'Error ${response.statusCode}: ${response.body}',
    );
  }

  Future<bool> updateSharedBook({
    required String id,
    required String groupId,
    required String bookUuid,
    required String ownerId,
    required String visibility,
    required bool isAvailable,
    required bool isDeleted,
    required DateTime updatedAt,
    String? accessToken,
  }) async {
    final config = await _loadConfig();
    final uri = Uri.parse('${config.url}/rest/v1/shared_books').replace(
      queryParameters: {
        'id': 'eq.$id',
      },
    );

    final payload = <String, dynamic>{
      'group_id': groupId,
      'book_uuid': bookUuid,
      'owner_id': ownerId,
      'visibility': visibility,
      'is_available': isAvailable,
      'is_deleted': isDeleted,
      'updated_at': updatedAt.toUtc().toIso8601String(),
    };

    final response = await _client.patch(
      uri,
      headers: _buildHeaders(
        config,
        accessToken: accessToken,
      ),
      body: jsonEncode(payload),
    );

    if (response.statusCode == 404) {
      return false;
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return true;
    }

    throw SupabaseGroupServiceException(
      'Error ${response.statusCode}: ${response.body}',
    );
  }

  Future<bool> deleteSharedBook({
    required String id,
    required DateTime updatedAt,
    String? accessToken,
  }) async {
    final config = await _loadConfig();
    final uri = Uri.parse('${config.url}/rest/v1/shared_books').replace(
      queryParameters: {
        'id': 'eq.$id',
      },
    );

    final payload = <String, dynamic>{
      'is_deleted': true,
      'updated_at': updatedAt.toUtc().toIso8601String(),
    };

    final response = await _client.patch(
      uri,
      headers: _buildHeaders(
        config,
        accessToken: accessToken,
      ),
      body: jsonEncode(payload),
    );

    if (response.statusCode == 404) {
      return false;
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return true;
    }

    throw SupabaseGroupServiceException(
      'Error ${response.statusCode}: ${response.body}',
    );
  }

  void dispose() {
    _client.close();
  }
}

String _truncateForLog(String value, {int maxLength = 400}) {
  if (value.length <= maxLength) {
    return value;
  }
  return '${value.substring(0, maxLength)}…';
}

class SupabaseGroupServiceException implements Exception {
  SupabaseGroupServiceException(this.message);

  final String message;

  @override
  String toString() => 'SupabaseGroupServiceException: $message';
}
