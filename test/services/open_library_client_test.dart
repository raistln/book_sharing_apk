import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:book_sharing_app/services/open_library_client.dart';

void main() {
  group('OpenLibraryClient', () {
    test('returns parsed results from OpenLibrary', () async {
      final mockResponse = {
        'docs': [
          {
            'title': 'Clean Code',
            'author_name': ['Robert C. Martin'],
            'isbn': ['9780132350884'],
            'cover_i': 12345,
            'first_publish_year': 2008,
          },
        ],
      };

      final client = OpenLibraryClient(
        httpClient: MockClient((request) async {
          expect(request.url.path, '/search.json');
          expect(request.url.queryParameters['q'], 'clean code');
          return http.Response(jsonEncode(mockResponse), 200, headers: {
            'content-type': 'application/json',
          });
        }),
      );
      addTearDown(client.close);

      final results = await client.search(query: 'clean code');

      expect(results, hasLength(1));
      final result = results.single;
      expect(result.title, 'Clean Code');
      expect(result.author, 'Robert C. Martin');
      expect(result.isbn, '9780132350884');
      expect(result.coverUrl, isNotEmpty);
      expect(result.publishYear, 2008);
    });

    test('throws OpenLibraryException on non-200 responses', () async {
      final client = OpenLibraryClient(
        httpClient: MockClient((request) async {
          return http.Response('Internal Error', 500);
        }),
      );
      addTearDown(client.close);

      expect(
        () => client.search(query: 'any'),
        throwsA(isA<OpenLibraryException>()),
      );
    });

    test('returns empty list when no filters provided', () async {
      final client = OpenLibraryClient();
      addTearDown(client.close);

      final results = await client.search();
      expect(results, isEmpty);
    });
  });
}
