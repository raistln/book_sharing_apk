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
            'key': '/works/OL123W',
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
      expect(result.key, '/works/OL123W');
    });

    test(
        'getWorkDetail returns string description, fallback cover and subjects',
        () async {
      final mockResponse = {
        'description': 'A great book about clean code.',
        'covers': [12345],
        'subjects': ['Software Design', 'Architecture'],
      };

      final client = OpenLibraryClient(
        httpClient: MockClient((request) async {
          expect(request.url.path, '/works/OL123W.json');
          return http.Response(jsonEncode(mockResponse), 200);
        }),
      );
      addTearDown(client.close);

      final detail = await client.getWorkDetail('/works/OL123W');
      expect(detail?.description, 'A great book about clean code.');
      expect(detail?.coverUrl, contains('12345'));
      expect(detail?.subjects, contains('Architecture'));
    });

    test('getEditionDetail returns physical details from Books API', () async {
      final mockResponse = {
        'ISBN:9780132350884': {
          'details': {
            'number_of_pages': 431,
            'publish_date': 'July 2008',
            'description': 'Description from Edition.',
            'subjects': ['Clean Code'],
          },
        },
      };

      final client = OpenLibraryClient(
        httpClient: MockClient((request) async {
          expect(request.url.queryParameters['bibkeys'], 'ISBN:9780132350884');
          return http.Response(jsonEncode(mockResponse), 200);
        }),
      );
      addTearDown(client.close);

      final detail = await client.getEditionDetail('9780132350884');
      expect(detail?.pageCount, 431);
      expect(detail?.publishDate, 'July 2008');
      expect(detail?.description, 'Description from Edition.');
    });

    test('getSmartMetadata merges and deduplicates subjects', () async {
      final mockEdition = {
        'ISBN:123': {
          'details': {
            'number_of_pages': 100,
            'publish_date': '2020',
            'subjects': ['Science Fiction', 'Adventure'],
          },
        },
      };
      final mockWork = {
        'description': 'Long synopsis from Work.',
        'covers': [999],
        'subjects': ['Adventure', 'Space'],
      };

      final client = OpenLibraryClient(
        httpClient: MockClient((request) async {
          if (request.url.path.contains('api/books')) {
            return http.Response(jsonEncode(mockEdition), 200);
          } else {
            return http.Response(jsonEncode(mockWork), 200);
          }
        }),
      );
      addTearDown(client.close);

      final detail = await client.getSmartMetadata(
        isbn: '123',
        workKey: '/works/OL123W',
      );

      expect(detail?.pageCount, 100);
      expect(detail?.subjects,
          containsAll(['Science Fiction', 'Adventure', 'Space']));
      expect(detail?.subjects, hasLength(3)); // Deduplicated
    });

    test('getWorkDetail ignores invalid cover IDs (0, -1)', () async {
      final mockResponse = {
        'description': 'Any',
        'covers': [-1, 0, 123],
      };

      final client = OpenLibraryClient(
        httpClient: MockClient((request) async {
          return http.Response(jsonEncode(mockResponse), 200);
        }),
      );
      addTearDown(client.close);

      final detail = await client.getWorkDetail('/any');
      expect(detail?.coverUrl, contains('123')); // Skips -1 and 0
    });

    test('getWorkDetail returns map description without cover', () async {
      final mockResponse = {
        'description': {
          'type': '/type/text',
          'value': 'Detailed description here.',
        },
      };

      final client = OpenLibraryClient(
        httpClient: MockClient((request) async {
          return http.Response(jsonEncode(mockResponse), 200);
        }),
      );
      addTearDown(client.close);

      final detail = await client.getWorkDetail('/any');
      expect(detail?.description, 'Detailed description here.');
      expect(detail?.coverUrl, isNull);
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
