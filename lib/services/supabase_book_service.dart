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

    headers['Prefer'] = preferRepresentation
        ? 'return=representation'
        : 'return=minimal';

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
          'id,owner_id,title,author,isbn,barcode,cover_url,status,notes,is_deleted,created_at,updated_at',
      'owner_id': 'eq.$ownerId',
      'order': 'updated_at.asc',
    };

    if (updatedAfter != null) {
      query['updated_at'] = 'gte.${updatedAfter.toUtc().toIso8601String()}';
    }

    final uri = Uri.parse('${config.url}/rest/v1/books').replace(
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

  Future<List<SupabaseBookReviewRecord>> fetchReviews({
    required String authorId,
    String? accessToken,
    DateTime? updatedAfter,
  }) async {
    final config = await _loadConfig();
    final query = <String, String>{
      'select':
          'id,book_id,author_id,rating,review,is_deleted,created_at,updated_at',
      'author_id': 'eq.$authorId',
      'order': 'updated_at.asc',
    };

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
    required String ownerId,
    required String title,
    String? author,
    String? isbn,
    String? barcode,
    String? coverUrl,
    required String status,
    String? notes,
    required bool isDeleted,
    required DateTime createdAt,
    required DateTime updatedAt,
    String? accessToken,
  }) async {
    final config = await _loadConfig();
    final uri = Uri.parse('${config.url}/rest/v1/books');

    final payload = {
      'id': id,
      'owner_id': ownerId,
      'title': title,
      'author': author,
      'isbn': isbn,
      'barcode': barcode,
      'cover_url': coverUrl,
      'status': status,
      'notes': notes,
      'is_deleted': isDeleted,
      'created_at': createdAt.toUtc().toIso8601String(),
      'updated_at': updatedAt.toUtc().toIso8601String(),
    };

    developer.log(
      'POST ${uri.path} → crear libro ${payload['title']} (${payload['id']})',
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

    developer.log(
      'Respuesta POST ${uri.path}: ${response.statusCode}',
      name: 'SupabaseBookService',
      error: response.body,
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

    throw SupabaseBookServiceException(
      'Error ${response.statusCode}: ${response.body}',
      response.statusCode,
    );
  }

  Future<bool> updateBook({
    required String id,
    required String title,
    String? author,
    String? isbn,
    String? barcode,
    String? coverUrl,
    required String status,
    String? notes,
    required bool isDeleted,
    required DateTime updatedAt,
    String? accessToken,
  }) async {
    final config = await _loadConfig();
    final uri = Uri.parse('${config.url}/rest/v1/books').replace(
      queryParameters: {
        'id': 'eq.$id',
      },
    );

    final payload = {
      'title': title,
      'author': author,
      'isbn': isbn,
      'barcode': barcode,
      'cover_url': coverUrl,
      'status': status,
      'notes': notes,
      'is_deleted': isDeleted,
      'updated_at': updatedAt.toUtc().toIso8601String(),
    };

    developer.log(
      'PATCH ${uri.toString()} → actualizar libro $id',
      name: 'SupabaseBookService',
      error: jsonEncode(payload),
    );

    final response = await _client.patch(
      uri,
      headers: _buildHeaders(
        config,
        accessToken: accessToken,
      ),
      body: jsonEncode(payload),
    );

    developer.log(
      'Respuesta PATCH ${uri.path}: ${response.statusCode}',
      name: 'SupabaseBookService',
      error: response.body,
    );

    if (response.statusCode == 404) {
      return false;
    }

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

    final response = await _client.post(
      uri,
      headers: _buildHeaders(
        config,
        accessToken: accessToken,
        preferRepresentation: true,
      ),
      body: jsonEncode({
        'id': id,
        'book_id': bookId,
        'author_id': authorId,
        'rating': rating,
        'review': review,
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
      queryParameters: {
        'id': 'eq.$id',
      },
    );

    final response = await _client.patch(
      uri,
      headers: _buildHeaders(
        config,
        accessToken: accessToken,
      ),
      body: jsonEncode({
        'rating': rating,
        'review': review,
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
    required this.ownerId,
    required this.title,
    this.author,
    this.isbn,
    this.barcode,
    this.coverUrl,
    required this.status,
    this.notes,
    required this.isDeleted,
    required this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String ownerId;
  final String title;
  final String? author;
  final String? isbn;
  final String? barcode;
  final String? coverUrl;
  final String status;
  final String? notes;
  final bool isDeleted;
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
      ownerId: json['owner_id'] as String,
      title: (json['title'] as String?) ?? '',
      author: json['author'] as String?,
      isbn: json['isbn'] as String?,
      barcode: json['barcode'] as String?,
      coverUrl: json['cover_url'] as String?,
      status: (json['status'] as String?) ?? 'available',
      notes: json['notes'] as String?,
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
