import 'package:book_sharing_app/services/supabase_config_service.dart';
import 'package:book_sharing_app/services/supabase_user_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';

class _MockHttpClient extends Mock implements http.Client {}

class _MockSupabaseConfigService extends Mock implements SupabaseConfigService {}

void main() {
  late _MockHttpClient httpClient;
  late _MockSupabaseConfigService configService;
  late SupabaseUserService service;

  setUpAll(() {
    registerFallbackValue(const SupabaseConfig(url: '', anonKey: ''));
    registerFallbackValue(Uri.parse(''));
  });

  setUp(() {
    httpClient = _MockHttpClient();
    configService = _MockSupabaseConfigService();
    service = SupabaseUserService(
      client: httpClient,
      configService: configService,
    );
  });

  group('SupabaseUserService', () {
    test('isUsernameAvailable returns true when username is available', () async {
      const config = SupabaseConfig(
        url: 'https://test.supabase.co',
        anonKey: 'test-anon-key',
      );

      when(() => configService.loadConfig()).thenAnswer((_) async => config);
      when(() => httpClient.get(any(), headers: any(named: 'headers')))
          .thenAnswer((_) async => http.Response('[]', 200));

      final result = await service.isUsernameAvailable('testuser');

      expect(result, true);
      verify(() => httpClient.get(any(), headers: any(named: 'headers'))).called(1);
    });

    test('isUsernameAvailable returns false when username is taken', () async {
      const config = SupabaseConfig(
        url: 'https://test.supabase.co',
        anonKey: 'test-anon-key',
      );

      when(() => configService.loadConfig()).thenAnswer((_) async => config);
      when(() => httpClient.get(any(), headers: any(named: 'headers')))
          .thenAnswer((_) async => http.Response('[{"id": "123"}]', 200));

      final result = await service.isUsernameAvailable('testuser');

      expect(result, false);
      verify(() => httpClient.get(any(), headers: any(named: 'headers'))).called(1);
    });
  });
}
