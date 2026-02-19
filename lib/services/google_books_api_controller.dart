import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import 'package:book_sharing_app/utils/isbn_utils.dart';

/// Controller for Google Books API operations
class GoogleBooksApiController {
  static const String _baseUrl = 'https://www.googleapis.com/books/v1/volumes';

  /// Search for books by title, author, or ISBN
  static Future<List<GoogleBook>> searchBooks({
    required String query,
    String? apiKey,
    int maxResults = 20,
  }) async {
    final trimmedQuery = query.trim();
    final isbnCandidates = IsbnUtils.expandCandidates(trimmedQuery);
    if (isbnCandidates.isEmpty) {
      return _searchInternal(
        query: trimmedQuery,
        apiKey: apiKey,
        maxResults: maxResults,
      );
    }

    for (final candidate in isbnCandidates) {
      final books = await _searchInternal(
        query: candidate,
        apiKey: apiKey,
        maxResults: maxResults,
      );
      if (books.isNotEmpty) {
        return books;
      }
    }

    return const [];
  }

  static Future<List<GoogleBook>> _searchInternal({
    required String query,
    String? apiKey,
    int maxResults = 20,
  }) async {
    try {
      if (kDebugMode) {
        debugPrint('[GoogleBooksAPI] Searching for: $query');
      }

      final uri = Uri.parse(_baseUrl).replace(queryParameters: {
        'q': query,
        'maxResults': maxResults.toString(),
        if (apiKey != null && apiKey.isNotEmpty) 'key': apiKey,
      });

      final response = await http.get(
        uri,
        headers: {
          'Accept': 'application/json',
        },
      ).timeout(
        const Duration(seconds: 10),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        final items = data['items'] as List<dynamic>?;

        if (items == null) {
          if (kDebugMode) {
            debugPrint('[GoogleBooksAPI] No results found');
          }
          return [];
        }

        final books = items
            .map((item) => GoogleBook.fromJson(item as Map<String, dynamic>))
            .where((book) => book.title.isNotEmpty)
            .toList();

        if (kDebugMode) {
          debugPrint('[GoogleBooksAPI] Found ${books.length} books');
        }
        return books;
      } else {
        if (kDebugMode) {
          debugPrint(
              '[GoogleBooksAPI] Error ${response.statusCode}: ${response.body}');
        }
        throw GoogleBooksApiException(
          'Error searching books: ${response.statusCode}',
          response.statusCode,
        );
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[GoogleBooksAPI] Search failed: $e');
      }

      if (e is GoogleBooksApiException) {
        rethrow;
      }

      throw GoogleBooksApiException(
        'Failed to search books: $e',
        null,
      );
    }
  }

  /// Get detailed information about a specific book by its ID
  static Future<GoogleBook?> getBookById(String id, {String? apiKey}) async {
    try {
      if (kDebugMode) {
        debugPrint('[GoogleBooksAPI] Getting book details for: $id');
      }

      final uri = Uri.parse('$_baseUrl/$id').replace(queryParameters: {
        if (apiKey != null && apiKey.isNotEmpty) 'key': apiKey,
      });

      final response = await http.get(
        uri,
        headers: {
          'Accept': 'application/json',
        },
      ).timeout(
        const Duration(seconds: 10),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        return GoogleBook.fromJson(data);
      } else {
        if (kDebugMode) {
          debugPrint(
              '[GoogleBooksAPI] Error getting book ${response.statusCode}: ${response.body}');
        }
        return null;
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[GoogleBooksAPI] Get book failed: $e');
      }
      return null;
    }
  }

  /// Validate API key by making a test request
  static Future<bool> validateApiKey(String apiKey) async {
    try {
      if (kDebugMode) {
        debugPrint('[GoogleBooksAPI] Validating API key');
      }

      // Make a simple search request to validate the key
      await searchBooks(
        query: 'test',
        apiKey: apiKey,
        maxResults: 1,
      );

      return true;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[GoogleBooksAPI] API key validation failed: $e');
      }
      return false;
    }
  }
}

/// Model representing a Google Books API volume
class GoogleBook {
  final String id;
  final String title;
  final List<String> authors;
  final String? publisher;
  final String? publishedDate;
  final String? description;
  final String? isbn;
  final String? isbn13;
  final int? pageCount;
  final String? language;
  final List<String> categories;
  final String? thumbnailUrl;
  final String? smallThumbnailUrl;
  final double? averageRating;
  final int? ratingsCount;
  final String? previewLink;
  final String? infoLink;

  const GoogleBook({
    required this.id,
    required this.title,
    this.authors = const [],
    this.publisher,
    this.publishedDate,
    this.description,
    this.isbn,
    this.isbn13,
    this.pageCount,
    this.language,
    this.categories = const [],
    this.thumbnailUrl,
    this.smallThumbnailUrl,
    this.averageRating,
    this.ratingsCount,
    this.previewLink,
    this.infoLink,
  });

  factory GoogleBook.fromJson(Map<String, dynamic> json) {
    final volumeInfo = json['volumeInfo'] as Map<String, dynamic>? ?? {};

    // Extract ISBNs from industry identifiers
    String? isbn;
    String? isbn13;
    final industryIdentifiers =
        volumeInfo['industryIdentifiers'] as List<dynamic>?;
    if (industryIdentifiers != null) {
      for (final identifier in industryIdentifiers) {
        final idMap = identifier as Map<String, dynamic>;
        final type = idMap['type'] as String?;
        final idValue = idMap['identifier'] as String?;

        if (type == 'ISBN_10' && idValue != null) {
          isbn = idValue;
        } else if (type == 'ISBN_13' && idValue != null) {
          isbn13 = idValue;
        }
      }
    }

    // Extract authors
    final authorsList = volumeInfo['authors'] as List<dynamic>?;
    final authors =
        authorsList?.map((author) => author.toString()).toList() ?? <String>[];

    // Extract categories
    final categoriesList = volumeInfo['categories'] as List<dynamic>?;
    final categories =
        categoriesList?.map((category) => category.toString()).toList() ??
            <String>[];

    // Extract image links
    final imageLinks = volumeInfo['imageLinks'] as Map<String, dynamic>?;
    final thumbnailUrl = imageLinks?['thumbnail'] as String?;
    final smallThumbnailUrl = imageLinks?['smallThumbnail'] as String?;

    return GoogleBook(
      id: json['id'] as String,
      title: volumeInfo['title'] as String? ?? '',
      authors: authors,
      publisher: volumeInfo['publisher'] as String?,
      publishedDate: volumeInfo['publishedDate'] as String?,
      description: volumeInfo['description'] as String?,
      isbn: isbn,
      isbn13: isbn13,
      pageCount: volumeInfo['pageCount'] as int?,
      language: volumeInfo['language'] as String?,
      categories: categories,
      thumbnailUrl: thumbnailUrl,
      smallThumbnailUrl: smallThumbnailUrl,
      averageRating: (volumeInfo['averageRating'] as num?)?.toDouble(),
      ratingsCount: volumeInfo['ratingsCount'] as int?,
      previewLink: volumeInfo['previewLink'] as String?,
      infoLink: volumeInfo['infoLink'] as String?,
    );
  }

  /// Get the primary ISBN (prefer ISBN-13, fallback to ISBN-10)
  String? get primaryIsbn => isbn13 ?? isbn;

  /// Get formatted author names as a single string
  String get authorsText =>
      authors.isNotEmpty ? authors.join(', ') : 'Unknown Author';

  /// Get a formatted category string
  String get categoriesText =>
      categories.isNotEmpty ? categories.join(', ') : '';

  /// Check if the book has basic required information
  bool get isValid => title.isNotEmpty && (isbn != null || isbn13 != null);

  @override
  String toString() {
    return 'GoogleBook(id: $id, title: $title, authors: $authorsText, isbn: $primaryIsbn)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is GoogleBook &&
        other.id == id &&
        other.title == title &&
        other.primaryIsbn == primaryIsbn;
  }

  @override
  int get hashCode => Object.hash(id, title, primaryIsbn);
}

/// Exception for Google Books API errors
class GoogleBooksApiException implements Exception {
  final String message;
  final int? statusCode;

  const GoogleBooksApiException(this.message, this.statusCode);

  @override
  String toString() =>
      'GoogleBooksApiException: $message${statusCode != null ? ' (Status: $statusCode)' : ''}';
}
