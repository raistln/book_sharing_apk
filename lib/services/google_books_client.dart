import 'dart:convert';

import 'package:http/http.dart' as http;

import 'google_books_api_service.dart';

class GoogleBooksClient {
  GoogleBooksClient({
    http.Client? httpClient,
    GoogleBooksApiService? apiService,
    Future<String?> Function()? apiKeyResolver,
  })  : _http = httpClient ?? http.Client(),
        _apiService = apiService ?? GoogleBooksApiService(),
        _apiKeyResolver = apiKeyResolver;

  final http.Client _http;
  final GoogleBooksApiService _apiService;
  final Future<String?> Function()? _apiKeyResolver;

  static const _baseAuthority = 'www.googleapis.com';
  static const _path = '/books/v1/volumes';

  Future<List<GoogleBooksVolume>> search({
    String? query,
    String? isbn,
    int maxResults = 10,
    int startIndex = 0,
  }) async {
    if ((query == null || query.isEmpty) && (isbn == null || isbn.isEmpty)) {
      return [];
    }

    final apiKey = await (_apiKeyResolver?.call() ?? _apiService.readApiKey());
    if (apiKey == null || apiKey.isEmpty) {
      throw GoogleBooksMissingApiKeyException();
    }

    final qParts = <String>[];
    if (query != null && query.isNotEmpty) {
      qParts.add(query);
    }
    if (isbn != null && isbn.isNotEmpty) {
      qParts.add('isbn:$isbn');
    }

    final params = <String, String>{
      'q': qParts.join(' '),
      'key': apiKey,
      'maxResults': maxResults.clamp(1, 40).toString(),
      'startIndex': startIndex.toString(),
    };

    final uri = Uri.https(_baseAuthority, _path, params);
    final response =
        await _http.get(uri, headers: {'Accept': 'application/json'});

    if (response.statusCode != 200) {
      throw GoogleBooksException(
          'Error ${response.statusCode}: ${response.body}');
    }

    final json =
        jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
    final items =
        (json['items'] as List<dynamic>? ?? []).cast<Map<String, dynamic>>();

    return items
        .map((item) => GoogleBooksVolume.fromJson(item))
        .where((volume) => volume.title.isNotEmpty)
        .toList(growable: false);
  }

  void close() {
    _http.close();
  }
}

class GoogleBooksVolume {
  const GoogleBooksVolume({
    required this.title,
    this.subtitle,
    this.authors = const [],
    this.isbn,
    this.description,
    this.publishedDate,
    this.thumbnailUrl,
    this.categories = const [],
  });

  factory GoogleBooksVolume.fromJson(Map<String, dynamic> json) {
    final volumeInfo = (json['volumeInfo'] as Map<String, dynamic>?) ?? {};
    return GoogleBooksVolume(
      title: (volumeInfo['title'] as String?)?.trim() ?? '',
      subtitle: (volumeInfo['subtitle'] as String?)?.trim(),
      authors: _parseAuthors(volumeInfo),
      isbn: _parseIsbn(volumeInfo),
      description: (volumeInfo['description'] as String?)?.trim(),
      publishedDate: (volumeInfo['publishedDate'] as String?)?.trim(),
      thumbnailUrl: _parseThumbnail(volumeInfo),
      categories: _parseCategories(volumeInfo),
    );
  }

  final String title;
  final String? subtitle;
  final List<String> authors;
  final String? isbn;
  final String? description;
  final String? publishedDate;
  final String? thumbnailUrl;
  final List<String> categories;

  String? get primaryAuthor => authors.isEmpty ? null : authors.first;

  GoogleBooksVolume copyWith({
    String? title,
    String? subtitle,
    List<String>? authors,
    String? isbn,
    String? description,
    String? publishedDate,
    String? thumbnailUrl,
    List<String>? categories,
  }) {
    return GoogleBooksVolume(
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      authors: authors ?? this.authors,
      isbn: isbn ?? this.isbn,
      description: description ?? this.description,
      publishedDate: publishedDate ?? this.publishedDate,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      categories: categories ?? this.categories,
    );
  }

  static List<String> _parseAuthors(Map<String, dynamic> volumeInfo) {
    final authors = volumeInfo['authors'] as List<dynamic>?;
    if (authors == null) return const [];
    return authors
        .map((author) => author.toString().trim())
        .where((a) => a.isNotEmpty)
        .toList();
  }

  static String? _parseIsbn(Map<String, dynamic> volumeInfo) {
    final identifiers = volumeInfo['industryIdentifiers'] as List<dynamic>?;
    if (identifiers == null) return null;

    for (final identifier in identifiers) {
      final map = identifier as Map<String, dynamic>;
      final type = map['type']?.toString();
      final value = map['identifier']?.toString();
      if (value == null || value.isEmpty) continue;
      if (type == 'ISBN_13' || type == 'ISBN_10') {
        return value;
      }
    }
    return null;
  }

  static String? _parseThumbnail(Map<String, dynamic> volumeInfo) {
    final imageLinks = volumeInfo['imageLinks'] as Map<String, dynamic>?;
    if (imageLinks == null) return null;
    final preferredKeys = ['thumbnail', 'smallThumbnail'];
    for (final key in preferredKeys) {
      final value = imageLinks[key]?.toString();
      if (value != null && value.isNotEmpty) {
        return value;
      }
    }
    return null;
  }

  static List<String> _parseCategories(Map<String, dynamic> volumeInfo) {
    final categories = volumeInfo['categories'] as List<dynamic>?;
    if (categories == null) return const [];
    return categories
        .map((c) => c.toString().trim())
        .where((c) => c.isNotEmpty)
        .toList();
  }
}

class GoogleBooksMissingApiKeyException implements Exception {
  @override
  String toString() =>
      'GoogleBooksMissingApiKeyException: API key no configurada.';
}

class GoogleBooksException implements Exception {
  GoogleBooksException(this.message);

  final String message;

  @override
  String toString() => 'GoogleBooksException: $message';
}
