import 'dart:convert';

import 'package:book_sharing_app/services/google_books_client.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  group('GoogleBooksClient', () {
    test('returns parsed volumes from API', () async {
      final mockClient = MockClient((request) async {
        expect(request.url.path, '/books/v1/volumes');
        expect(request.url.queryParameters['q'], 'Test isbn:1234567890');
        expect(request.url.queryParameters['key'], 'secret');

        final payload = {
          'items': [
            {
              'volumeInfo': {
                'title': 'Test Book',
                'subtitle': 'A unit test story',
                'authors': ['Tester One', 'Tester Two'],
                'industryIdentifiers': [
                  {'type': 'ISBN_13', 'identifier': '9781234567897'},
                ],
                'description': 'Example description',
                'publishedDate': '2022',
                'imageLinks': {
                  'thumbnail': 'https://example.com/thumb.jpg',
                },
              },
            }
          ],
        };

        return http.Response(jsonEncode(payload), 200, headers: {
          'content-type': 'application/json',
        });
      });

      final client = GoogleBooksClient(
        httpClient: mockClient,
        apiKeyResolver: () async => 'secret',
      );
      addTearDown(client.close);

      final results = await client.search(query: 'Test', isbn: '1234567890');

      expect(results, hasLength(1));
      final volume = results.single;
      expect(volume.title, 'Test Book');
      expect(volume.subtitle, 'A unit test story');
      expect(volume.primaryAuthor, 'Tester One');
      expect(volume.isbn, '9781234567897');
      expect(volume.description, 'Example description');
      expect(volume.publishedDate, '2022');
      expect(volume.thumbnailUrl, 'https://example.com/thumb.jpg');
    });

    test('throws when API key is missing', () async {
      final client = GoogleBooksClient(apiKeyResolver: () async => null);
      addTearDown(client.close);

      expect(
        () => client.search(query: 'No key'),
        throwsA(isA<GoogleBooksMissingApiKeyException>()),
      );
    });

    test('throws GoogleBooksException on API error', () async {
      final mockClient = MockClient((request) async {
        return http.Response('Bad Request', 400);
      });

      final client = GoogleBooksClient(
        httpClient: mockClient,
        apiKeyResolver: () async => 'secret',
      );
      addTearDown(client.close);

      expect(
        () => client.search(query: 'error'),
        throwsA(isA<GoogleBooksException>()),
      );
    });
  });
}
