import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import 'supabase_config_service.dart';

// =====================================================================
// RECORD MODELS (from Supabase responses)
// =====================================================================

class SupabaseClubRecord {
  SupabaseClubRecord({
    required this.id,
    required this.name,
    required this.description,
    required this.city,
    this.meetingPlace,
    required this.frequency,
    required this.frequencyDays,
    required this.visibility,
    required this.nextBooksVisible,
    required this.ownerId,
    this.currentBookId,
    required this.createdAt,
    required this.updatedAt,
    required this.members,
    required this.books,
  });

  final String id;
  final String name;
  final String description;
  final String city;
  final String? meetingPlace;
  final String frequency;
  final int frequencyDays;
  final String visibility;
  final int nextBooksVisible;
  final String ownerId;
  final String? currentBookId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<SupabaseClubMemberRecord> members;
  final List<SupabaseClubBookRecord> books;

  factory SupabaseClubRecord.fromJson(Map<String, dynamic> json) {
    final membersJson = json['club_members'] as List<dynamic>?;
    final booksJson = json['club_books'] as List<dynamic>?;

    return SupabaseClubRecord(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String? ?? '',
      city: json['city'] as String,
      meetingPlace: json['meeting_place'] as String?,
      frequency: json['frequency'] as String,
      frequencyDays: json['frequency_days'] as int? ?? 30,
      visibility: json['visibility'] as String? ?? 'privado',
      nextBooksVisible: json['next_books_visible'] as int? ?? 1,
      ownerId: json['owner_id'] as String,
      currentBookId: json['current_book_id'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      members: membersJson == null
          ? const []
          : membersJson
              .whereType<Map<String, dynamic>>()
              .map(SupabaseClubMemberRecord.fromJson)
              .toList(growable: false),
      books: booksJson == null
          ? const []
          : booksJson
              .whereType<Map<String, dynamic>>()
              .map(SupabaseClubBookRecord.fromJson)
              .toList(growable: false),
    );
  }
}

class SupabaseClubMemberRecord {
  SupabaseClubMemberRecord({
    required this.id,
    required this.clubId,
    required this.memberId,
    required this.role,
    required this.status,
    required this.lastActivity,
    required this.createdAt,
    required this.updatedAt,
    this.username,
  });

  final String id;
  final String clubId;
  final String memberId;
  final String role;
  final String status;
  final DateTime lastActivity;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? username;

  factory SupabaseClubMemberRecord.fromJson(Map<String, dynamic> json) {
    final profile = json['profiles'] as Map<String, dynamic>?;
    return SupabaseClubMemberRecord(
      id: json['id'] as String,
      clubId: json['club_id'] as String,
      memberId: json['member_id'] as String,
      role: json['role'] as String? ?? 'miembro',
      status: json['status'] as String? ?? 'activo',
      lastActivity: DateTime.parse(json['last_activity'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      username: profile?['username'] as String?,
    );
  }
}

class SupabaseClubBookRecord {
  SupabaseClubBookRecord({
    required this.id,
    required this.clubId,
    required this.bookUuid,
    required this.orderPosition,
    required this.status,
    required this.sectionMode,
    required this.totalChapters,
    required this.sections,
    this.startDate,
    this.endDate,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String clubId;
  final String bookUuid;
  final int orderPosition;
  final String status;
  final String sectionMode;
  final int totalChapters;
  final String sections; // JSON string
  final DateTime? startDate;
  final DateTime? endDate;
  final DateTime createdAt;
  final DateTime updatedAt;

  factory SupabaseClubBookRecord.fromJson(Map<String, dynamic> json) {
    DateTime? tryParse(String? value) =>
        value != null ? DateTime.tryParse(value) : null;

    return SupabaseClubBookRecord(
      id: json['id'] as String,
      clubId: json['club_id'] as String,
      bookUuid: json['book_uuid'] as String,
      orderPosition: json['order_position'] as int,
      status: json['status'] as String,
      sectionMode: json['section_mode'] as String? ?? 'automatico',
      totalChapters: json['total_chapters'] as int,
      sections: json['sections'] as String? ?? '[]',
      startDate: tryParse(json['start_date'] as String?),
      endDate: tryParse(json['end_date'] as String?),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }
}

class SupabaseBookProposalRecord {
  SupabaseBookProposalRecord({
    required this.id,
    required this.clubId,
    required this.bookUuid,
    required this.proposedByUserId,
    required this.title,
    this.author,
    this.isbn,
    this.coverUrl,
    required this.votes,
    required this.status,
    required this.closingDate,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String clubId;
  final String bookUuid;
  final String proposedByUserId;
  final String title;
  final String? author;
  final String? isbn;
  final String? coverUrl;
  final String votes; // CSV of user IDs
  final String status;
  final DateTime closingDate;
  final DateTime createdAt;
  final DateTime updatedAt;

  factory SupabaseBookProposalRecord.fromJson(Map<String, dynamic> json) {
    return SupabaseBookProposalRecord(
      id: json['id'] as String,
      clubId: json['club_id'] as String,
      bookUuid: json['book_uuid'] as String,
      proposedByUserId: json['proposed_by_user_id'] as String,
      title: json['title'] as String,
      author: json['author'] as String?,
      isbn: json['isbn'] as String?,
      coverUrl: json['cover_url'] as String?,
      votes: json['votes'] as String? ?? '',
      status: json['status'] as String,
      closingDate: DateTime.parse(json['closing_date'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }
}

class SupabaseReadingProgressRecord {
  SupabaseReadingProgressRecord({
    required this.id,
    required this.bookId,
    required this.userId,
    required this.currentSection,
    required this.currentChapter,
    required this.progressStatus,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String bookId;
  final String userId;
  final int currentSection;
  final int currentChapter;
  final String progressStatus;
  final DateTime createdAt;
  final DateTime updatedAt;

  factory SupabaseReadingProgressRecord.fromJson(Map<String, dynamic> json) {
    return SupabaseReadingProgressRecord(
      id: json['id'] as String,
      bookId: json['book_id'] as String,
      userId: json['user_id'] as String,
      currentSection: json['current_section'] as int,
      currentChapter: json['current_chapter'] as int,
      progressStatus: json['progress_status'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }
}

class SupabaseSectionCommentRecord {
  SupabaseSectionCommentRecord({
    required this.id,
    required this.bookId,
    required this.sectionNumber,
    required this.authorUserId,
    required this.content,
    required this.reportCount,
    required this.isHidden,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String bookId;
  final int sectionNumber;
  final String authorUserId;
  final String content;
  final int reportCount;
  final bool isHidden;
  final DateTime createdAt;
  final DateTime updatedAt;

  factory SupabaseSectionCommentRecord.fromJson(Map<String, dynamic> json) {
    return SupabaseSectionCommentRecord(
      id: json['id'] as String,
      bookId: json['book_id'] as String,
      sectionNumber: json['section_number'] as int,
      authorUserId: json['author_user_id'] as String,
      content: json['content'] as String,
      reportCount: json['report_count'] as int? ?? 0,
      isHidden: json['is_hidden'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }
}

class SupabaseCommentReportRecord {
  SupabaseCommentReportRecord({
    required this.id,
    required this.commentId,
    required this.reportedByUserId,
    this.reason,
    required this.createdAt,
  });

  final String id;
  final String commentId;
  final String reportedByUserId;
  final String? reason;
  final DateTime createdAt;

  factory SupabaseCommentReportRecord.fromJson(Map<String, dynamic> json) {
    return SupabaseCommentReportRecord(
      id: json['id'] as String,
      commentId: json['comment_id'] as String,
      reportedByUserId: json['reported_by_user_id'] as String,
      reason: json['reason'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}

class SupabaseModerationLogRecord {
  SupabaseModerationLogRecord({
    required this.id,
    required this.clubId,
    required this.action,
    required this.performedByUserId,
    required this.targetId,
    this.reason,
    required this.createdAt,
  });

  final String id;
  final String clubId;
  final String action;
  final String performedByUserId;
  final String targetId;
  final String? reason;
  final DateTime createdAt;

  factory SupabaseModerationLogRecord.fromJson(Map<String, dynamic> json) {
    return SupabaseModerationLogRecord(
      id: json['id'] as String,
      clubId: json['club_id'] as String,
      action: json['action'] as String,
      performedByUserId: json['performed_by_user_id'] as String,
      targetId: json['target_id'] as String,
      reason: json['reason'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}

// =====================================================================
// SUPABASE CLUB SERVICE
// =====================================================================

class SupabaseClubService {
  SupabaseClubService({
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
      'Prefer':
          preferRepresentation ? 'return=representation' : 'return=minimal',
    };
  }

  // =====================================================================
  // FETCH (READ)
  // =====================================================================

  /// Fetch all clubs where user is a member
  Future<List<SupabaseClubRecord>> fetchClubs({String? accessToken}) async {
    final config = await _loadConfig();
    final uri = Uri.parse('${config.url}/rest/v1/reading_clubs').replace(
      queryParameters: {
        'select': 'id,name,description,city,meeting_place,frequency,'
            'frequency_days,visibility,next_books_visible,owner_id,'
            'current_book_id,created_at,updated_at,'
            'club_members(id,club_id,member_id,role,status,last_activity,created_at,updated_at,profiles(username)),'
            'club_books(id,club_id,book_uuid,order_position,status,section_mode,total_chapters,sections,start_date,end_date,created_at,updated_at)',
      },
    );

    final response = await _client.get(
      uri,
      headers: _buildHeaders(config, accessToken: accessToken),
    );

    if (response.statusCode != 200) {
      throw SupabaseClubServiceException(
        'Error ${response.statusCode}: ${response.body}',
      );
    }

    final payload =
        jsonDecode(utf8.decode(response.bodyBytes)) as List<dynamic>;

    if (kDebugMode) {
      debugPrint(
        '[SupabaseClubService] GET /reading_clubs -> ${payload.length} clubs (status=${response.statusCode})',
      );
    }

    return payload
        .whereType<Map<String, dynamic>>()
        .map(SupabaseClubRecord.fromJson)
        .toList(growable: false);
  }

  Future<List<SupabaseSectionCommentRecord>> fetchSectionComments({
    required List<String> bookIds,
    String? accessToken,
  }) async {
    if (bookIds.isEmpty) return [];

    final config = await _loadConfig();
    final uri = Uri.parse('${config.url}/rest/v1/section_comments').replace(
      queryParameters: {
        'select':
            'id,book_id,section_number,author_user_id,content,report_count,is_hidden,created_at,updated_at',
        'book_id': 'in.(${bookIds.join(',')})',
        'order': 'updated_at.asc',
      },
    );

    final response = await _client.get(
      uri,
      headers: _buildHeaders(config, accessToken: accessToken),
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final payload =
          jsonDecode(utf8.decode(response.bodyBytes)) as List<dynamic>;
      return payload
          .whereType<Map<String, dynamic>>()
          .map(SupabaseSectionCommentRecord.fromJson)
          .toList(growable: false);
    }

    throw SupabaseClubServiceException(
      'Error ${response.statusCode}: ${response.body}',
    );
  }

  Future<List<SupabaseCommentReportRecord>> fetchCommentReports({
    required List<String> commentIds,
    String? accessToken,
  }) async {
    if (commentIds.isEmpty) return [];

    final config = await _loadConfig();
    final uri = Uri.parse('${config.url}/rest/v1/comment_reports').replace(
      queryParameters: {
        'select':
            'id,comment_id,reported_by_user_id,reason,created_at',
        'comment_id': 'in.(${commentIds.join(',')})',
        'order': 'created_at.asc',
      },
    );

    final response = await _client.get(
      uri,
      headers: _buildHeaders(config, accessToken: accessToken),
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final payload =
          jsonDecode(utf8.decode(response.bodyBytes)) as List<dynamic>;
      return payload
          .whereType<Map<String, dynamic>>()
          .map(SupabaseCommentReportRecord.fromJson)
          .toList(growable: false);
    }

    throw SupabaseClubServiceException(
      'Error ${response.statusCode}: ${response.body}',
    );
  }

  Future<List<SupabaseModerationLogRecord>> fetchModerationLogs({
    required String clubId,
    String? accessToken,
  }) async {
    final config = await _loadConfig();
    final uri = Uri.parse('${config.url}/rest/v1/moderation_logs').replace(
      queryParameters: {
        'select':
            'id,club_id,action,performed_by_user_id,target_id,reason,created_at',
        'club_id': 'eq.$clubId',
        'order': 'created_at.desc',
      },
    );

    final response = await _client.get(
      uri,
      headers: _buildHeaders(config, accessToken: accessToken),
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final payload =
          jsonDecode(utf8.decode(response.bodyBytes)) as List<dynamic>;
      return payload
          .whereType<Map<String, dynamic>>()
          .map(SupabaseModerationLogRecord.fromJson)
          .toList(growable: false);
    }

    throw SupabaseClubServiceException(
      'Error ${response.statusCode}: ${response.body}',
    );
  }

  // =====================================================================
  // CREATE/UPDATE/DELETE CLUBS
  // =====================================================================

  Future<String> createClub({
    required String id,
    required String name,
    required String description,
    required String city,
    String? meetingPlace,
    required String frequency,
    required int frequencyDays,
    required String visibility,
    required int nextBooksVisible,
    required String ownerId,
    required DateTime createdAt,
    required DateTime updatedAt,
    String? accessToken,
  }) async {
    final config = await _loadConfig();
    final uri = Uri.parse('${config.url}/rest/v1/reading_clubs');

    final payload = <String, dynamic>{
      'id': id,
      'name': name,
      'description': description,
      'city': city,
      'meeting_place': meetingPlace,
      'frequency': frequency,
      'frequency_days': frequencyDays,
      'visibility': visibility,
      'next_books_visible': nextBooksVisible,
      'owner_id': ownerId,
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
      if (response.body.isEmpty) return id;

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

    throw SupabaseClubServiceException(
      'Error ${response.statusCode}: ${response.body}',
    );
  }

  Future<bool> updateClub({
    required String id,
    required String name,
    required String description,
    String? meetingPlace,
    required String frequency,
    required int frequencyDays,
    required int nextBooksVisible,
    required DateTime updatedAt,
    String? accessToken,
  }) async {
    final config = await _loadConfig();
    final uri = Uri.parse('${config.url}/rest/v1/reading_clubs').replace(
      queryParameters: {'id': 'eq.$id'},
    );

    final payload = <String, dynamic>{
      'name': name,
      'description': description,
      'meeting_place': meetingPlace,
      'frequency': frequency,
      'frequency_days': frequencyDays,
      'next_books_visible': nextBooksVisible,
      'updated_at': updatedAt.toUtc().toIso8601String(),
    };

    final response = await _client.patch(
      uri,
      headers: _buildHeaders(config, accessToken: accessToken),
      body: jsonEncode(payload),
    );

    if (response.statusCode == 404) return false;
    if (response.statusCode >= 200 && response.statusCode < 300) return true;

    throw SupabaseClubServiceException(
      'Error ${response.statusCode}: ${response.body}',
    );
  }

  Future<bool> deleteClub({
    required String id,
    String? accessToken,
  }) async {
    final config = await _loadConfig();
    final uri = Uri.parse('${config.url}/rest/v1/reading_clubs').replace(
      queryParameters: {'id': 'eq.$id'},
    );

    final response = await _client.delete(
      uri,
      headers: _buildHeaders(config, accessToken: accessToken),
    );

    if (response.statusCode == 404) return false;
    if (response.statusCode >= 200 && response.statusCode < 300) return true;

    throw SupabaseClubServiceException(
      'Error ${response.statusCode}: ${response.body}',
    );
  }

  // =====================================================================
  // CLUB MEMBERS
  // =====================================================================

  Future<String> createClubMember({
    required String id,
    required String clubId,
    required String memberId,
    required String role,
    required String status,
    required DateTime lastActivity,
    required DateTime createdAt,
    required DateTime updatedAt,
    String? accessToken,
  }) async {
    final config = await _loadConfig();
    final uri = Uri.parse('${config.url}/rest/v1/club_members');

    final payload = <String, dynamic>{
      'id': id,
      'club_id': clubId,
      'member_id': memberId,
      'role': role,
      'status': status,
      'last_activity': lastActivity.toUtc().toIso8601String(),
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
      if (response.body.isEmpty) return id;

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

    throw SupabaseClubServiceException(
      'Error ${response.statusCode}: ${response.body}',
    );
  }

  Future<bool> updateClubMember({
    required String id,
    required String role,
    required String status,
    required DateTime lastActivity,
    required DateTime updatedAt,
    String? accessToken,
  }) async {
    final config = await _loadConfig();
    final uri = Uri.parse('${config.url}/rest/v1/club_members').replace(
      queryParameters: {'id': 'eq.$id'},
    );

    final payload = <String, dynamic>{
      'role': role,
      'status': status,
      'last_activity': lastActivity.toUtc().toIso8601String(),
      'updated_at': updatedAt.toUtc().toIso8601String(),
    };

    final response = await _client.patch(
      uri,
      headers: _buildHeaders(config, accessToken: accessToken),
      body: jsonEncode(payload),
    );

    if (response.statusCode == 404) return false;
    if (response.statusCode >= 200 && response.statusCode < 300) return true;

    throw SupabaseClubServiceException(
      'Error ${response.statusCode}: ${response.body}',
    );
  }

  Future<bool> deleteClubMember({
    required String id,
    String? accessToken,
  }) async {
    final config = await _loadConfig();
    final uri = Uri.parse('${config.url}/rest/v1/club_members').replace(
      queryParameters: {'id': 'eq.$id'},
    );

    final response = await _client.delete(
      uri,
      headers: _buildHeaders(config, accessToken: accessToken),
    );

    if (response.statusCode == 404) return false;
    if (response.statusCode >= 200 && response.statusCode < 300) return true;

    throw SupabaseClubServiceException(
      'Error ${response.statusCode}: ${response.body}',
    );
  }

  // =====================================================================
  // CLUB BOOKS
  // =====================================================================

  Future<String> createClubBook({
    required String id,
    required String clubId,
    required String bookUuid,
    required int orderPosition,
    required String status,
    required String sectionMode,
    required int totalChapters,
    required String sections,
    DateTime? startDate,
    DateTime? endDate,
    required DateTime createdAt,
    required DateTime updatedAt,
    String? accessToken,
  }) async {
    final config = await _loadConfig();
    final uri = Uri.parse('${config.url}/rest/v1/club_books');

    final payload = <String, dynamic>{
      'id': id,
      'club_id': clubId,
      'book_uuid': bookUuid,
      'order_position': orderPosition,
      'status': status,
      'section_mode': sectionMode,
      'total_chapters': totalChapters,
      'sections': sections,
      'start_date': startDate?.toUtc().toIso8601String(),
      'end_date': endDate?.toUtc().toIso8601String(),
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
      return _extractId(response, id);
    }

    throw SupabaseClubServiceException(
      'Error ${response.statusCode}: ${response.body}',
    );
  }

  Future<bool> updateClubBook({
    required String id,
    required String status,
    DateTime? startDate,
    DateTime? endDate,
    required DateTime updatedAt,
    String? accessToken,
  }) async {
    final config = await _loadConfig();
    final uri = Uri.parse('${config.url}/rest/v1/club_books').replace(
      queryParameters: {'id': 'eq.$id'},
    );

    final payload = <String, dynamic>{
      'status': status,
      'start_date': startDate?.toUtc().toIso8601String(),
      'end_date': endDate?.toUtc().toIso8601String(),
      'updated_at': updatedAt.toUtc().toIso8601String(),
    };

    final response = await _client.patch(
      uri,
      headers: _buildHeaders(config, accessToken: accessToken),
      body: jsonEncode(payload),
    );

    if (response.statusCode == 404) return false;
    if (response.statusCode >= 200 && response.statusCode < 300) return true;

    throw SupabaseClubServiceException(
      'Error ${response.statusCode}: ${response.body}',
    );
  }

  // =====================================================================
  // BOOK PROPOSALS
  // =====================================================================

  Future<String> createBookProposal({
    required String id,
    required String clubId,
    required String bookUuid,
    required String proposedByUserId,
    required String title,
    String? author,
    String? isbn,
    String? coverUrl,
    required String status,
    required DateTime closingDate,
    required DateTime createdAt,
    required DateTime updatedAt,
    String? accessToken,
  }) async {
    final config = await _loadConfig();
    final uri = Uri.parse('${config.url}/rest/v1/book_proposals');

    final payload = <String, dynamic>{
      'id': id,
      'club_id': clubId,
      'book_uuid': bookUuid,
      'proposed_by_user_id': proposedByUserId,
      'title': title,
      'author': author,
      'isbn': isbn,
      'cover_url': coverUrl,
      'votes': '',
      'status': status,
      'closing_date': closingDate.toUtc().toIso8601String(),
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
      return _extractId(response, id);
    }

    throw SupabaseClubServiceException(
      'Error ${response.statusCode}: ${response.body}',
    );
  }

  Future<bool> updateBookProposal({
    required String id,
    required String votes,
    required String status,
    required DateTime updatedAt,
    String? accessToken,
  }) async {
    final config = await _loadConfig();
    final uri = Uri.parse('${config.url}/rest/v1/book_proposals').replace(
      queryParameters: {'id': 'eq.$id'},
    );

    final payload = <String, dynamic>{
      'votes': votes,
      'status': status,
      'updated_at': updatedAt.toUtc().toIso8601String(),
    };

    final response = await _client.patch(
      uri,
      headers: _buildHeaders(config, accessToken: accessToken),
      body: jsonEncode(payload),
    );

    if (response.statusCode == 404) return false;
    if (response.statusCode >= 200 && response.statusCode < 300) return true;

    throw SupabaseClubServiceException(
      'Error ${response.statusCode}: ${response.body}',
    );
  }

  // =====================================================================
  // READING PROGRESS
  // =====================================================================

  Future<String> upsertReadingProgress({
    required String id,
    required String bookId,
    required String userId,
    required int currentSection,
    required int currentChapter,
    required String progressStatus,
    required DateTime createdAt,
    required DateTime updatedAt,
    String? accessToken,
  }) async {
    final config = await _loadConfig();
    final uri = Uri.parse('${config.url}/rest/v1/club_reading_progress');

    final payload = <String, dynamic>{
      'id': id,
      'book_id': bookId,
      'user_id': userId,
      'current_section': currentSection,
      'current_chapter': currentChapter,
      'progress_status': progressStatus,
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
      return _extractId(response, id);
    }

    throw SupabaseClubServiceException(
      'Error ${response.statusCode}: ${response.body}',
    );
  }

  // =====================================================================
  // SECTION COMMENTS
  // =====================================================================

  Future<String> createSectionComment({
    required String id,
    required String bookId,
    required int sectionNumber,
    required String authorUserId,
    required String content,
    required DateTime createdAt,
    required DateTime updatedAt,
    String? accessToken,
  }) async {
    final config = await _loadConfig();
    final uri = Uri.parse('${config.url}/rest/v1/section_comments');

    final payload = <String, dynamic>{
      'id': id,
      'book_id': bookId,
      'section_number': sectionNumber,
      'author_user_id': authorUserId,
      'content': content,
      'report_count': 0,
      'is_hidden': false,
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
      return _extractId(response, id);
    }

    throw SupabaseClubServiceException(
      'Error ${response.statusCode}: ${response.body}',
    );
  }

  Future<String> createCommentReport({
    required String id,
    required String commentId,
    required String reportedByUserId,
    String? reason,
    required DateTime createdAt,
    String? accessToken,
  }) async {
    final config = await _loadConfig();
    final uri = Uri.parse('${config.url}/rest/v1/comment_reports');

    final payload = <String, dynamic>{
      'id': id,
      'comment_id': commentId,
      'reported_by_user_id': reportedByUserId,
      'reason': reason,
      'created_at': createdAt.toUtc().toIso8601String(),
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
      return _extractId(response, id);
    }

    throw SupabaseClubServiceException(
      'Error ${response.statusCode}: ${response.body}',
    );
  }

  Future<String> createModerationLog({
    required String id,
    required String clubId,
    required String action,
    required String performedByUserId,
    required String targetId,
    String? reason,
    required DateTime createdAt,
    String? accessToken,
  }) async {
    final config = await _loadConfig();
    final uri = Uri.parse('${config.url}/rest/v1/moderation_logs');

    final payload = <String, dynamic>{
      'id': id,
      'club_id': clubId,
      'action': action,
      'performed_by_user_id': performedByUserId,
      'target_id': targetId,
      'reason': reason,
      'created_at': createdAt.toUtc().toIso8601String(),
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
      return _extractId(response, id);
    }

    throw SupabaseClubServiceException(
      'Error ${response.statusCode}: ${response.body}',
    );
  }

  Future<bool> updateSectionComment({
    required String id,
    required int reportCount,
    required bool isHidden,
    required DateTime updatedAt,
    String? accessToken,
  }) async {
    final config = await _loadConfig();
    final uri = Uri.parse('${config.url}/rest/v1/section_comments').replace(
      queryParameters: {'id': 'eq.$id'},
    );

    final payload = <String, dynamic>{
      'report_count': reportCount,
      'is_hidden': isHidden,
      'updated_at': updatedAt.toUtc().toIso8601String(),
    };

    final response = await _client.patch(
      uri,
      headers: _buildHeaders(config, accessToken: accessToken),
      body: jsonEncode(payload),
    );

    if (response.statusCode == 404) return false;
    if (response.statusCode >= 200 && response.statusCode < 300) return true;

    throw SupabaseClubServiceException(
      'Error ${response.statusCode}: ${response.body}',
    );
  }

  Future<bool> deleteSectionComment({
    required String id,
    String? accessToken,
  }) async {
    final config = await _loadConfig();
    final uri = Uri.parse('${config.url}/rest/v1/section_comments').replace(
      queryParameters: {'id': 'eq.$id'},
    );

    final response = await _client.delete(
      uri,
      headers: _buildHeaders(config, accessToken: accessToken),
    );

    if (response.statusCode == 404) return false;
    if (response.statusCode >= 200 && response.statusCode < 300) return true;

    throw SupabaseClubServiceException(
      'Error ${response.statusCode}: ${response.body}',
    );
  }

  // =====================================================================
  // HELPER METHODS
  // =====================================================================

  String _extractId(http.Response response, String fallbackId) {
    if (response.body.isEmpty) return fallbackId;

    final decoded = jsonDecode(response.body);
    if (decoded is List && decoded.isNotEmpty) {
      final first = decoded.first;
      if (first is Map<String, dynamic>) {
        return (first['id'] as String?) ?? fallbackId;
      }
    } else if (decoded is Map<String, dynamic>) {
      return (decoded['id'] as String?) ?? fallbackId;
    }
    return fallbackId;
  }

  void dispose() {
    _client.close();
  }
}

class SupabaseClubServiceException implements Exception {
  SupabaseClubServiceException(this.message);

  final String message;

  @override
  String toString() => 'SupabaseClubServiceException: $message';
}
