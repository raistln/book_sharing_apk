import 'dart:convert';
import 'dart:developer' as developer;

import 'package:http/http.dart' as http;

import 'supabase_config_service.dart';

class SupabaseBookService {
  SupabaseBookService({
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

    final headers = <String, String>{
      'apikey': apiKey,
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    headers['Prefer'] =
        preferRepresentation ? 'return=representation' : 'return=minimal';

    return headers;
  }

  Future<List<SupabaseBookRecord>> fetchBooks({
    required String ownerId,
    String? accessToken,
    DateTime? updatedAfter,
  }) async {
    final config = await _loadConfig();
    final query = <String, String>{
      'select':
          'id,group_id,owner_id,book_uuid,title,author,isbn,cover_url,visibility,is_available,is_physical,is_read,reading_status,description,barcode,read_at,is_borrowed_external,external_lender_name,is_deleted,genre,page_count,publication_year,created_at,updated_at',
      'owner_id': 'eq.$ownerId',
      'order': 'updated_at.asc',
    };

    if (updatedAfter != null) {
      query['updated_at'] = 'gte.${updatedAfter.toUtc().toIso8601String()}';
    }

    final uri = Uri.parse('${config.url}/rest/v1/shared_books').replace(
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
          .map(SupabaseBookRecord.fromJson)
          .toList();
    }

    throw SupabaseBookServiceException(
      'Error ${response.statusCode}: ${response.body}',
      response.statusCode,
    );
  }

  Future<SupabaseBookRecord?> fetchBookById({
    required String id,
    String? accessToken,
  }) async {
    final config = await _loadConfig();
    final uri = Uri.parse('${config.url}/rest/v1/shared_books').replace(
      queryParameters: {
        'select':
            'id,group_id,owner_id,book_uuid,title,author,isbn,cover_url,visibility,is_available,is_physical,is_read,reading_status,description,barcode,read_at,is_borrowed_external,external_lender_name,is_deleted,genre,page_count,publication_year,created_at,updated_at',
        'id': 'eq.$id',
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
        final record = payload.first;
        if (record is Map<String, dynamic>) {
          return SupabaseBookRecord.fromJson(record);
        }
      } else if (payload is Map<String, dynamic>) {
        return SupabaseBookRecord.fromJson(payload);
      }
      return null;
    }

    throw SupabaseBookServiceException(
      'Error ${response.statusCode}: ${response.body}',
      response.statusCode,
    );
  }

  Future<List<SupabaseBookReviewRecord>> fetchReviews({
    String? authorId,
    String? accessToken,
    DateTime? updatedAfter,
  }) async {
    final config = await _loadConfig();
    final query = <String, String>{
      'select':
          'id,book_id,author_id,rating,review,is_deleted,created_at,updated_at',
      'order': 'updated_at.asc',
    };

    if (authorId != null) {
      query['author_id'] = 'eq.$authorId';
    }

    if (updatedAfter != null) {
      query['updated_at'] = 'gte.${updatedAfter.toUtc().toIso8601String()}';
    }

    final uri = Uri.parse('${config.url}/rest/v1/book_reviews').replace(
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
          .map(SupabaseBookReviewRecord.fromJson)
          .toList();
    }

    throw SupabaseBookServiceException(
      'Error ${response.statusCode}: ${response.body}',
      response.statusCode,
    );
  }

  Future<String> createBook({
    required String id,
    String? groupId,
    required String ownerId,
    required String? bookUuid,
    required String title,
    String? author,
    String? isbn,
    String? coverUrl,
    String visibility = 'private',
    bool isAvailable = true,
    bool isPhysical = true,
    bool isDeleted = false,
    String? genre,
    int? pageCount,
    int? publicationYear,
    required DateTime createdAt,
    required DateTime updatedAt,
    String? readingStatus,
    String? description,
    String? barcode,
    DateTime? readAt,
    bool isBorrowedExternal = false,
    String? externalLenderName,
    String? accessToken,
  }) async {
    final config = await _loadConfig();
    final uri = Uri.parse('${config.url}/rest/v1/shared_books');

    final payload = {
      'id': id,
      'group_id': groupId,
      'owner_id': ownerId,
      'book_uuid': bookUuid,
      'title': title,
      'author': author,
      'isbn': isbn,
      'cover_url': coverUrl,
      'visibility': visibility,
      'is_available': isAvailable,
      'is_physical': isPhysical,
      'is_deleted': isDeleted,
      'genre': genre,
      'page_count': pageCount,
      'publication_year': publicationYear,
      'reading_status': readingStatus,
      'description': description,
      'barcode': barcode,
      'read_at': readAt?.toUtc().toIso8601String(),
      'is_borrowed_external': isBorrowedExternal,
      'external_lender_name': externalLenderName,
      'created_at': createdAt.toUtc().toIso8601String(),
      'updated_at': updatedAt.toUtc().toIso8601String(),
    };

    developer.log(
      'POST ${uri.path} → crear libro ${payload['id']}',
      name: 'SupabaseBookService',
      error: jsonEncode(payload),
    );

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
      if (decoded is Map<String, dynamic>) {
        return (decoded['id'] as String?) ?? id;
      }
      return id;
    }

    throw SupabaseBookServiceException(
      'Error ${response.statusCode}: ${response.body}',
      response.statusCode,
    );
  }

  Future<bool> updateBook({
    required String id,
    String? groupId,
    String? title,
    String? author,
    String? isbn,
    String? coverUrl,
    String? visibility,
    bool? isAvailable,
    bool? isPhysical,
    bool? isDeleted,
    String? genre,
    int? pageCount,
    int? publicationYear,
    required DateTime updatedAt,
    // New fields
    String? readingStatus,
    String? description,
    String? barcode,
    DateTime? readAt,
    bool? isBorrowedExternal,
    String? externalLenderName,
    String? accessToken,
  }) async {
    final config = await _loadConfig();
    final uri = Uri.parse('${config.url}/rest/v1/shared_books').replace(
      queryParameters: {'id': 'eq.$id'},
    );

    final payload = {
      if (groupId != null) 'group_id': groupId,
      if (title != null) 'title': title,
      if (author != null) 'author': author,
      if (isbn != null) 'isbn': isbn,
      if (coverUrl != null) 'cover_url': coverUrl,
      if (visibility != null) 'visibility': visibility,
      if (isAvailable != null) 'is_available': isAvailable,
      if (isPhysical != null) 'is_physical': isPhysical,
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (genre != null) 'genre': genre,
      if (pageCount != null) 'page_count': pageCount,
      if (publicationYear != null) 'publication_year': publicationYear,
      if (readingStatus != null) 'reading_status': readingStatus,
      if (description != null) 'description': description,
      if (barcode != null) 'barcode': barcode,
      if (readAt != null) 'read_at': readAt.toUtc().toIso8601String(),
      if (isBorrowedExternal != null)
        'is_borrowed_external': isBorrowedExternal,
      if (externalLenderName != null)
        'external_lender_name': externalLenderName,
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

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return true;
    }

    throw SupabaseBookServiceException(
      'Error ${response.statusCode}: ${response.body}',
      response.statusCode,
    );
  }

  Future<String> createReview({
    required String id,
    required String bookId,
    required String authorId,
    required int rating,
    String? review,
    required bool isDeleted,
    required DateTime createdAt,
    required DateTime updatedAt,
    String? accessToken,
  }) async {
    final config = await _loadConfig();
    final uri = Uri.parse('${config.url}/rest/v1/book_reviews');

    final payload = {
      'id': id,
      'book_id': bookId,
      'author_id': authorId,
      'rating': rating,
      'review': review,
      'is_deleted': isDeleted,
      'created_at': createdAt.toUtc().toIso8601String(),
      'updated_at': updatedAt.toUtc().toIso8601String(),
    };

    developer.log(
      'POST ${uri.path} → crear reseña ${payload['id']}',
      name: 'SupabaseBookService',
      error: jsonEncode(payload),
    );

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
      if (decoded is Map<String, dynamic>) {
        return (decoded['id'] as String?) ?? id;
      }
      return id;
    }

    throw SupabaseBookServiceException(
      'Error ${response.statusCode}: ${response.body}',
      response.statusCode,
    );
  }

  Future<bool> updateReview({
    required String id,
    required int rating,
    String? review,
    required bool isDeleted,
    required DateTime updatedAt,
    String? accessToken,
  }) async {
    final config = await _loadConfig();
    final uri = Uri.parse('${config.url}/rest/v1/book_reviews').replace(
      queryParameters: {'id': 'eq.$id'},
    );

    final payload = {
      'rating': rating,
      'review': review,
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

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return true;
    }

    throw SupabaseBookServiceException(
      'Error ${response.statusCode}: ${response.body}',
      response.statusCode,
    );
  }

  void dispose() {
    _client.close();
  }

  Future<List<SupabaseTimelineEntryRecord>> fetchTimelineEntries({
    required String ownerId,
    String? accessToken,
    DateTime? updatedAfter,
  }) async {
    final config = await _loadConfig();
    final query = <String, String>{
      'select':
          'id,book_uuid,owner_id,current_page,percentage_read,event_type,note,event_date,is_deleted,created_at,updated_at',
      'owner_id': 'eq.$ownerId',
      'order': 'updated_at.asc',
    };

    if (updatedAfter != null) {
      query['updated_at'] = 'gte.${updatedAfter.toUtc().toIso8601String()}';
    }

    final uri = Uri.parse('${config.url}/rest/v1/reading_timeline_entries')
        .replace(queryParameters: query);

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
          .map(SupabaseTimelineEntryRecord.fromJson)
          .toList();
    }

    throw SupabaseBookServiceException(
      'Error ${response.statusCode}: ${response.body}',
      response.statusCode,
    );
  }

  Future<String> createTimelineEntry({
    required String id,
    required String bookUuid,
    required String ownerId,
    int? currentPage,
    int? percentageRead,
    required String eventType,
    String? note,
    required DateTime eventDate,
    required DateTime createdAt,
    required DateTime updatedAt,
    bool isDeleted = false,
    String? accessToken,
  }) async {
    final config = await _loadConfig();
    final uri = Uri.parse('${config.url}/rest/v1/reading_timeline_entries');

    final payload = {
      'id': id,
      'book_uuid': bookUuid,
      'owner_id': ownerId,
      'current_page': currentPage,
      'percentage_read': percentageRead,
      'event_type': eventType,
      'note': note,
      'event_date': eventDate.toUtc().toIso8601String(),
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
      if (response.body.isEmpty) return id;
      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic>) {
        return (decoded['id'] as String?) ?? id;
      }
      return id;
    }

    throw SupabaseBookServiceException(
      'Error ${response.statusCode}: ${response.body}',
      response.statusCode,
    );
  }

  Future<bool> updateTimelineEntry({
    required String id,
    int? currentPage,
    int? percentageRead,
    String? eventType,
    String? note,
    DateTime? eventDate,
    bool? isDeleted,
    required DateTime updatedAt,
    String? accessToken,
  }) async {
    final config = await _loadConfig();
    final uri = Uri.parse('${config.url}/rest/v1/reading_timeline_entries')
        .replace(queryParameters: {'id': 'eq.$id'});

    final payload = {
      if (currentPage != null) 'current_page': currentPage,
      if (percentageRead != null) 'percentage_read': percentageRead,
      if (eventType != null) 'event_type': eventType,
      if (note != null) 'note': note,
      if (eventDate != null) 'event_date': eventDate.toUtc().toIso8601String(),
      if (isDeleted != null) 'is_deleted': isDeleted,
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

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return true;
    }

    throw SupabaseBookServiceException(
      'Error ${response.statusCode}: ${response.body}',
      response.statusCode,
    );
  }
}

class SupabaseBookServiceException implements Exception {
  SupabaseBookServiceException(this.message, [this.statusCode]);

  final String message;
  final int? statusCode;

  @override
  String toString() =>
      'SupabaseBookServiceException(${statusCode ?? 'unknown'}): $message';
}

class SupabaseBookRecord {
  const SupabaseBookRecord({
    required this.id,
    this.groupId,
    required this.ownerId,
    this.bookUuid,
    required this.title,
    this.author,
    this.isbn,
    this.coverUrl,
    this.visibility,
    this.isAvailable,
    this.isPhysical = true,
    this.isRead = false,
    required this.isDeleted,
    this.genre,
    this.pageCount,
    this.publicationYear,
    required this.createdAt,
    this.updatedAt,
    this.readingStatus,
    this.description,
    this.barcode,
    this.readAt,
    this.isBorrowedExternal = false,
    this.externalLenderName,
  });

  final String id;
  final String? groupId;
  final String ownerId;
  final String? bookUuid;
  final String title;
  final String? author;
  final String? isbn;
  final String? coverUrl;
  final String? visibility;
  final bool? isAvailable;
  final bool isPhysical;
  final bool isRead;
  final String? readingStatus;
  final String? description;
  final String? barcode;
  final DateTime? readAt;
  final bool isBorrowedExternal;
  final String? externalLenderName;
  final bool isDeleted;
  final String? genre;
  final int? pageCount;
  final int? publicationYear;
  final DateTime createdAt;
  final DateTime? updatedAt;

  factory SupabaseBookRecord.fromJson(Map<String, dynamic> json) {
    DateTime? parseDate(dynamic value) {
      if (value is String) {
        return DateTime.tryParse(value);
      }
      return null;
    }

    return SupabaseBookRecord(
      id: json['id'] as String,
      groupId: json['group_id'] as String?,
      ownerId: json['owner_id'] as String,
      bookUuid: json['book_uuid'] as String?,
      title: (json['title'] as String?) ?? '',
      author: json['author'] as String?,
      isbn: json['isbn'] as String?,
      coverUrl: json['cover_url'] as String?,
      visibility: json['visibility'] as String?,
      isAvailable: json['is_available'] as bool?,
      isPhysical: (json['is_physical'] as bool?) ?? true,
      isRead: (json['is_read'] as bool?) ?? false,
      isDeleted: (json['is_deleted'] as bool?) ?? false,
      genre: json['genre'] as String?,
      pageCount: json['page_count'] as int?,
      publicationYear: json['publication_year'] as int?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: parseDate(json['updated_at']),
      readingStatus: json['reading_status'] as String?,
      description: json['description'] as String?,
      barcode: json['barcode'] as String?,
      readAt: parseDate(json['read_at']),
      isBorrowedExternal: (json['is_borrowed_external'] as bool?) ?? false,
      externalLenderName: json['external_lender_name'] as String?,
    );
  }
}

class SupabaseTimelineEntryRecord {
  const SupabaseTimelineEntryRecord({
    required this.id,
    required this.bookUuid,
    required this.ownerId,
    this.currentPage,
    this.percentageRead,
    required this.eventType,
    this.note,
    required this.eventDate,
    required this.isDeleted,
    required this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String bookUuid;
  final String ownerId;
  final int? currentPage;
  final int? percentageRead;
  final String eventType;
  final String? note;
  final DateTime eventDate;
  final bool isDeleted;
  final DateTime createdAt;
  final DateTime? updatedAt;

  factory SupabaseTimelineEntryRecord.fromJson(Map<String, dynamic> json) {
    DateTime? parseDate(dynamic value) {
      if (value is String) {
        return DateTime.tryParse(value);
      }
      return null;
    }

    return SupabaseTimelineEntryRecord(
      id: json['id'] as String,
      bookUuid: json['book_uuid'] as String,
      ownerId: json['owner_id'] as String,
      currentPage: json['current_page'] as int?,
      percentageRead: json['percentage_read'] as int?,
      eventType: json['event_type'] as String,
      note: json['note'] as String?,
      eventDate: DateTime.parse(json['event_date'] as String),
      isDeleted: (json['is_deleted'] as bool?) ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: parseDate(json['updated_at']),
    );
  }
}

class SupabaseBookReviewRecord {
  const SupabaseBookReviewRecord({
    required this.id,
    required this.bookId,
    required this.authorId,
    required this.rating,
    this.review,
    required this.isDeleted,
    required this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String bookId;
  final String authorId;
  final int rating;
  final String? review;
  final bool isDeleted;
  final DateTime createdAt;
  final DateTime? updatedAt;

  factory SupabaseBookReviewRecord.fromJson(Map<String, dynamic> json) {
    DateTime? parseDate(dynamic value) {
      if (value is String) {
        return DateTime.tryParse(value);
      }
      return null;
    }

    return SupabaseBookReviewRecord(
      id: json['id'] as String,
      bookId: json['book_id'] as String,
      authorId: json['author_id'] as String,
      rating: (json['rating'] as num).toInt(),
      review: json['review'] as String?,
      isDeleted: (json['is_deleted'] as bool?) ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: parseDate(json['updated_at']),
    );
  }
}
