import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:book_sharing_app/providers/api_providers.dart';
import 'package:book_sharing_app/services/google_books_api_service.dart';
import 'package:book_sharing_app/services/open_library_client.dart';

void main() {
  group('ApiProviders', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('can create container', () {
      expect(container, isNotNull);
    });

    test('googleBooksApiServiceProvider provides GoogleBooksApiService instance', () {
      final service = container.read(googleBooksApiServiceProvider);
      expect(service, isA<GoogleBooksApiService>());
    });

    test('openLibraryClientProvider provides OpenLibraryClient instance', () {
      final client = container.read(openLibraryClientProvider);
      expect(client, isA<OpenLibraryClient>());
    });
  });
}
