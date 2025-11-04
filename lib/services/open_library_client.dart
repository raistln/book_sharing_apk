import 'dart:convert';

import 'package:http/http.dart' as http;

class OpenLibraryClient {
  OpenLibraryClient({http.Client? httpClient})
      : _http = httpClient ?? http.Client();

  final http.Client _http;

  static const _baseUrl = 'https://openlibrary.org';

  Future<List<OpenLibraryBookResult>> search({
    String? query,
    String? isbn,
    int limit = 10,
    int offset = 0,
  }) async {
    final params = <String, String>{
      'limit': limit.toString(),
      'offset': offset.toString(),
    };

    if (isbn != null && isbn.isNotEmpty) {
      params['isbn'] = isbn;
    }

    if (query != null && query.isNotEmpty) {
      params['q'] = query;
    }

    if (!params.containsKey('q') && !params.containsKey('isbn')) {
      return [];
    }

    final uri = Uri.parse('$_baseUrl/search.json').replace(queryParameters: params);
    final response = await _http.get(uri, headers: {'Accept': 'application/json'});

    if (response.statusCode != 200) {
      throw OpenLibraryException('Error ${response.statusCode}: ${response.body}');
    }

    final json = jsonDecode(utf8.decode(response.bodyBytes));
    final docs = (json['docs'] as List<dynamic>? ?? []).cast<Map<String, dynamic>>();
    return docs
        .map(OpenLibraryBookResult.fromJson)
        .where((book) => book.title.isNotEmpty)
        .toList(growable: false);
  }

  void close() {
    _http.close();
  }
}

class OpenLibraryBookResult {
  const OpenLibraryBookResult({
    required this.title,
    this.author,
    this.isbn,
    this.coverUrl,
    this.publishYear,
  });

  factory OpenLibraryBookResult.fromJson(Map<String, dynamic> json) {
    final isbns = json['isbn'] as List<dynamic>?;
    final coverId = json['cover_i'];
    return OpenLibraryBookResult(
      title: (json['title'] as String?)?.trim() ?? '',
      author: _parseAuthor(json),
      isbn: isbns != null && isbns.isNotEmpty ? isbns.first.toString() : null,
      coverUrl: coverId != null
          ? 'https://covers.openlibrary.org/b/id/$coverId-L.jpg'
          : null,
      publishYear: (json['first_publish_year'] as num?)?.toInt(),
    );
  }

  final String title;
  final String? author;
  final String? isbn;
  final String? coverUrl;
  final int? publishYear;

  OpenLibraryBookResult copyWith({
    String? title,
    String? author,
    String? isbn,
    String? coverUrl,
    int? publishYear,
  }) {
    return OpenLibraryBookResult(
      title: title ?? this.title,
      author: author ?? this.author,
      isbn: isbn ?? this.isbn,
      coverUrl: coverUrl ?? this.coverUrl,
      publishYear: publishYear ?? this.publishYear,
    );
  }

  static String? _parseAuthor(Map<String, dynamic> json) {
    final authors = json['author_name'] as List<dynamic>?;
    if (authors == null || authors.isEmpty) {
      return null;
    }
    return authors.first.toString();
  }
}

class OpenLibraryException implements Exception {
  OpenLibraryException(this.message);

  final String message;

  @override
  String toString() => 'OpenLibraryException: $message';
}
