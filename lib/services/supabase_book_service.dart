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
          'id,group_id,owner_id,book_uuid,title,author,isbn,cover_url,visibility,is_available,is_physical,is_read,is_deleted,genre,page_count,publication_year,created_at,updated_at',
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
            'id,group_id,owner_id,book_uuid,title,author,isbn,cover_url,visibility,is_available,is_physical,is_read,is_deleted,genre,page_count,publication_year,created_at,updated_at',
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
