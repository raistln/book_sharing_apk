import 'dart:convert';

import 'package:http/http.dart' as http;

import 'package:book_sharing_app/utils/isbn_utils.dart';

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
    final trimmedQuery = query?.trim();
    final isbnCandidates = IsbnUtils.expandCandidates(isbn);

    if ((trimmedQuery == null || trimmedQuery.isEmpty) &&
        isbnCandidates.isEmpty) {
      return [];
    }

    if (isbnCandidates.isEmpty) {
      return _searchInternal(
        query: trimmedQuery,
        isbn: null,
        limit: limit,
        offset: offset,
      );
    }

    // Intentar buscar con cada candidato ISBN
    for (final candidate in isbnCandidates) {
      final results = await _searchInternal(
        query: trimmedQuery,
        isbn: candidate,
        limit: limit,
        offset: offset,
      );
      if (results.isNotEmpty) {
        return results;
      }
    }

    return const [];
  }

  Future<List<OpenLibraryBookResult>> _searchInternal({
    required String? query,
    required String? isbn,
    required int limit,
    required int offset,
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

    final uri =
        Uri.parse('$_baseUrl/search.json').replace(queryParameters: params);
    final response =
        await _http.get(uri, headers: {'Accept': 'application/json'});

    if (response.statusCode != 200) {
      throw OpenLibraryException(
          'Error ${response.statusCode}: ${response.body}');
    }

    final json = jsonDecode(utf8.decode(response.bodyBytes));
    final docs =
        (json['docs'] as List<dynamic>? ?? []).cast<Map<String, dynamic>>();

    return docs
        .map((doc) => OpenLibraryBookResult.fromJson(doc, searchIsbn: isbn))
        .where((book) => book.title.isNotEmpty)
        .toList(growable: false);
  }

  Future<OpenLibraryAdditionalMetadata?> getWorkDetail(String key) async {
    if (key.isEmpty) return null;

    final uri = Uri.parse('$_baseUrl$key.json');

    try {
      final response = await _http.get(uri);
      if (response.statusCode == 200) {
        final json = jsonDecode(utf8.decode(response.bodyBytes));

        String? description;
        final descriptionData = json['description'];
        if (descriptionData is String) {
          description = descriptionData;
        } else if (descriptionData is Map) {
          description = descriptionData['value'] as String?;
        }

        String? coverUrl;
        final covers = json['covers'] as List<dynamic>?;
        if (covers != null && covers.isNotEmpty) {
          for (final id in covers) {
            if (id != null && id is num && id > 0) {
              coverUrl = 'https://covers.openlibrary.org/b/id/$id-L.jpg';
              break;
            }
          }
        }

        final subjects = (json['subjects'] as List<dynamic>?)
                ?.map((s) => s.toString())
                .toList() ??
            [];

        return OpenLibraryAdditionalMetadata(
          description: description,
          coverUrl: coverUrl,
          subjects: subjects,
        );
      }
    } catch (e) {
      return null;
    }
    return null;
  }

  Future<OpenLibraryAdditionalMetadata?> getEditionDetail(String isbn) async {
    if (isbn.isEmpty) return null;

    final uri = Uri.parse(
        '$_baseUrl/api/books?bibkeys=ISBN:$isbn&jscmd=details&format=json');

    try {
      final response = await _http.get(uri);
      if (response.statusCode == 200) {
        final json = jsonDecode(utf8.decode(response.bodyBytes));
        final bookKey = 'ISBN:$isbn';
        final bookData = json[bookKey];

        if (bookData == null) return null;

        final details = bookData['details'] as Map<String, dynamic>?;
        if (details == null) return null;

        String? description;
        final descriptionData = details['description'];
        if (descriptionData is String) {
          description = descriptionData;
        } else if (descriptionData is Map) {
          description = descriptionData['value'] as String?;
        }

        final subjects = (details['subjects'] as List<dynamic>?)
                ?.map((s) => s.toString())
                .toList() ??
            [];

        return OpenLibraryAdditionalMetadata(
          description: description,
          pageCount: (details['number_of_pages'] as num?)?.toInt(),
          publishDate: details['publish_date'] as String?,
          subjects: subjects,
          isbn: isbn, // Preservar el ISBN usado en la búsqueda
        );
      }
    } catch (e) {
      return null;
    }
    return null;
  }

  Future<OpenLibraryAdditionalMetadata?> getEditionDetailByKey(
      String editionKey) async {
    if (editionKey.isEmpty) return null;

    final uri = Uri.parse('$_baseUrl$editionKey.json');

    try {
      final response = await _http.get(uri);
      if (response.statusCode == 200) {
        final json = jsonDecode(utf8.decode(response.bodyBytes));

        String? description;
        final descriptionData = json['description'];
        if (descriptionData is String) {
          description = descriptionData;
        } else if (descriptionData is Map) {
          description = descriptionData['value'] as String?;
        }

        final subjects = (json['subjects'] as List<dynamic>?)
                ?.map((s) => s.toString())
                .toList() ??
            [];

        // Buscar ISBN-13 primero, luego ISBN-10
        String? isbn;
        final isbn13List = json['isbn_13'] as List<dynamic>?;
        final isbn10List = json['isbn_10'] as List<dynamic>?;

        if (isbn13List != null && isbn13List.isNotEmpty) {
          isbn = isbn13List.first?.toString();
        } else if (isbn10List != null && isbn10List.isNotEmpty) {
          isbn = isbn10List.first?.toString();
        }

        return OpenLibraryAdditionalMetadata(
          description: description,
          pageCount: (json['number_of_pages'] as num?)?.toInt(),
          publishDate: json['publish_date'] as String?,
          subjects: subjects,
          isbn: isbn,
        );
      }
    } catch (e) {
      return null;
    }
    return null;
  }

  /// Método mejorado que intenta obtener la metadata más completa posible
  /// combinando información de edición y work
  Future<OpenLibraryAdditionalMetadata?> getSmartMetadata({
    String? isbn,
    String? workKey,
    String? editionKey,
  }) async {
    OpenLibraryAdditionalMetadata? edition;
    OpenLibraryAdditionalMetadata? work;

    // 1. Intentar obtener datos de la edición (tiene ISBN, páginas, fecha específica)
    if (isbn != null && isbn.isNotEmpty) {
      edition = await getEditionDetail(isbn);
    }

    // 2. Si no tenemos edición pero sí editionKey, intentar por ahí
    if (edition == null && editionKey != null && editionKey.isNotEmpty) {
      edition = await getEditionDetailByKey(editionKey);
    }

    // 3. Intentar obtener datos del work (tiene descripción más completa, portada, temas)
    if (workKey != null && workKey.isNotEmpty) {
      work = await getWorkDetail(workKey);
    }

    // Si no conseguimos nada, retornar null
    if (edition == null && work == null) return null;

    // Combinar datos dando prioridad según el tipo de información:
    // - ISBN: siempre de edition o el parámetro original
    // - Descripción: preferir work (suele ser más completa) > edition
    // - Portada: preferir work (mejor calidad) > edition
    // - Páginas: solo viene de edition
    // - Fecha: solo viene de edition
    // - Temas: combinar ambos sin duplicados

    final combinedSubjects = <String>{
      ...(work?.subjects ?? []),
      ...(edition?.subjects ?? []),
    }.toList();

    return OpenLibraryAdditionalMetadata(
      description: work?.description ?? edition?.description,
      pageCount: edition?.pageCount,
      coverUrl: work?.coverUrl ?? edition?.coverUrl,
      publishDate: edition?.publishDate,
      subjects: combinedSubjects,
      // Preservar el ISBN: primero de edition, luego el parámetro original
      isbn: edition?.isbn ?? isbn,
    );
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
    this.subjects = const [],
    this.pageCount,
    this.publishedDate,
    this.description,
    this.key,
    this.editionKey,
  });

  /// Factory mejorado que prioriza ISBN-13 y preserva el ISBN de búsqueda
  factory OpenLibraryBookResult.fromJson(
    Map<String, dynamic> json, {
    String? searchIsbn,
  }) {
    // Obtener lista de ISBNs del resultado
    final isbns = json['isbn'] as List<dynamic>?;
    String? isbn;

    if (isbns != null && isbns.isNotEmpty) {
      // Priorizar ISBN-13 (13 dígitos sin guiones)
      final isbn13 = isbns.firstWhere(
        (i) => i.toString().replaceAll(RegExp(r'[-\s]'), '').length == 13,
        orElse: () => null,
      );

      isbn = (isbn13 ?? isbns.first).toString();
    }

    // Si no encontramos ISBN en los resultados pero buscamos por ISBN,
    // usar el ISBN de búsqueda
    isbn ??= searchIsbn;

    final coverId = json['cover_i'];

    return OpenLibraryBookResult(
      title: (json['title'] as String?)?.trim() ?? '',
      author: _parseAuthor(json),
      isbn: isbn,
      coverUrl: coverId != null
          ? 'https://covers.openlibrary.org/b/id/$coverId-L.jpg'
          : null,
      publishYear: (json['first_publish_year'] as num?)?.toInt(),
      subjects: (json['subject'] as List<dynamic>?)
              ?.map((s) => s.toString())
              .toList() ??
          const [],
      pageCount: (json['number_of_pages_median'] as num?)?.toInt(),
      publishedDate:
          (json['publish_date'] as List<dynamic>?)?.first?.toString(),
      key: json['key'] as String?,
      editionKey: _parseEditionKey(json),
    );
  }

  static String? _parseEditionKey(Map<String, dynamic> json) {
    var keys = json['edition_key'] as List<dynamic>?;
    if (keys == null || keys.isEmpty) {
      if (json['cover_edition_key'] != null) {
        return '/books/${json['cover_edition_key']}';
      }
      return null;
    }
    final firstKey = keys.first.toString();
    if (firstKey.startsWith('/books/')) return firstKey;
    return '/books/$firstKey';
  }

  final String title;
  final String? author;
  final String? isbn;
  final String? coverUrl;
  final int? publishYear;
  final List<String> subjects;
  final int? pageCount;
  final String? publishedDate;
  final String? description;
  final String? key;
  final String? editionKey;

  OpenLibraryBookResult copyWith({
    String? title,
    String? author,
    String? isbn,
    String? coverUrl,
    int? publishYear,
    List<String>? subjects,
    int? pageCount,
    String? publishedDate,
    String? description,
    String? key,
    String? editionKey,
  }) {
    return OpenLibraryBookResult(
      title: title ?? this.title,
      author: author ?? this.author,
      isbn: isbn ?? this.isbn,
      coverUrl: coverUrl ?? this.coverUrl,
      publishYear: publishYear ?? this.publishYear,
      subjects: subjects ?? this.subjects,
      pageCount: pageCount ?? this.pageCount,
      publishedDate: publishedDate ?? this.publishedDate,
      description: description ?? this.description,
      key: key ?? this.key,
      editionKey: editionKey ?? this.editionKey,
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

class OpenLibraryAdditionalMetadata {
  const OpenLibraryAdditionalMetadata({
    this.description,
    this.coverUrl,
    this.pageCount,
    this.publishDate,
    this.subjects = const [],
    this.isbn,
  });

  final String? description;
  final String? coverUrl;
  final int? pageCount;
  final String? publishDate;
  final List<String> subjects;
  final String? isbn;

  OpenLibraryAdditionalMetadata copyWith({
    String? description,
    String? coverUrl,
    int? pageCount,
    String? publishDate,
    List<String>? subjects,
    String? isbn,
  }) {
    return OpenLibraryAdditionalMetadata(
      description: description ?? this.description,
      coverUrl: coverUrl ?? this.coverUrl,
      pageCount: pageCount ?? this.pageCount,
      publishDate: publishDate ?? this.publishDate,
      subjects: subjects ?? this.subjects,
      isbn: isbn ?? this.isbn,
    );
  }
}

class OpenLibraryException implements Exception {
  OpenLibraryException(this.message);

  final String message;

  @override
  String toString() => 'OpenLibraryException: $message';
}
