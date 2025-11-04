import 'dart:convert';

import 'package:book_sharing_app/services/supabase_config_service.dart';
import 'package:book_sharing_app/services/supabase_user_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  const config = SupabaseConfig(
    url: 'https://example.supabase.co',
    anonKey: 'anon-key',
  );

  group('SupabaseUserService', () {
    test('returns true when username is available', () async {
      late Uri capturedUri;
      late Map<String, String> capturedHeaders;

      final client = MockClient((request) async {
        capturedUri = request.url;
        capturedHeaders = request.headers;
        expect(request.method, equals('GET'));

        return http.Response(jsonEncode(<dynamic>[]), 200, headers: {
          'content-type': 'application/json',
        });
      });

      final service = SupabaseUserService(
        client: client,
        configLoader: () async => config,
      );
      addTearDown(service.dispose);

      final available = await service.isUsernameAvailable('alice');

      expect(available, isTrue);
      expect(capturedUri.path, '/rest/v1/local_users');
      expect(capturedUri.queryParameters, {
        'username': 'eq.alice',
        'select': 'id',
      });
      expect(capturedHeaders['apikey'], config.anonKey);
      expect(capturedHeaders['Authorization'], 'Bearer ${config.anonKey}');
    });

    test('returns false when Supabase finds an existing user', () async {
      final client = MockClient((request) async {
        final payload = [
          {'id': 1},
        ];
        return http.Response(jsonEncode(payload), 200,
            headers: {'content-type': 'application/json'});
      });

      final service = SupabaseUserService(
        client: client,
        configLoader: () async => config,
      );
      addTearDown(service.dispose);

      final available = await service.isUsernameAvailable('bob');

      expect(available, isFalse);
    });

    test('throws SupabaseUserServiceException on HTTP error', () async {
      final client = MockClient((request) async {
        return http.Response('something bad', 500);
      });

      final service = SupabaseUserService(
        client: client,
        configLoader: () async => config,
      );
      addTearDown(service.dispose);

      expect(
        () => service.isUsernameAvailable('carol'),
        throwsA(isA<SupabaseUserServiceException>()),
      );
    });
  });
}
