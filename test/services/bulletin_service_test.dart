import 'package:book_sharing_app/services/bulletin_service.dart';
import 'package:book_sharing_app/services/supabase_config_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';

class _MockHttpClient extends Mock implements http.Client {}

class _MockSupabaseConfigService extends Mock implements SupabaseConfigService {}

void main() {
  late _MockHttpClient httpClient;
  late _MockSupabaseConfigService configService;
  late BulletinService service;

  setUpAll(() {
    registerFallbackValue(const SupabaseConfig(url: '', anonKey: ''));
    registerFallbackValue(Uri.parse(''));
  });

  setUp(() {
    httpClient = _MockHttpClient();
    configService = _MockSupabaseConfigService();
    service = BulletinService(
      client: httpClient,
      configService: configService,
    );
  });

  group('BulletinService', () {
    test('fetchLatestBulletin returns bulletin when data exists', () async {
      const config = SupabaseConfig(
        url: 'https://test.supabase.co',
        anonKey: 'test-anon-key',
      );

      when(() => configService.loadConfig()).thenAnswer((_) async => config);
      when(() => httpClient.get(any(), headers: any(named: 'headers')))
          .thenAnswer((_) async => http.Response('''
[
  {
    "province": "Test Province",
    "period": "2023-Q1",
    "title": "Test Bulletin",
    "content": "Test content"
  }
]
''', 200));

      final result = await service.fetchLatestBulletin('Test Province');

      expect(result, isNotNull);
      expect(result?.province, 'Test Province');
      verify(() => httpClient.get(any(), headers: any(named: 'headers'))).called(1);
    });

    test('fetchLatestBulletin returns null when no data', () async {
      const config = SupabaseConfig(
        url: 'https://test.supabase.co',
        anonKey: 'test-anon-key',
      );

      when(() => configService.loadConfig()).thenAnswer((_) async => config);
      when(() => httpClient.get(any(), headers: any(named: 'headers')))
          .thenAnswer((_) async => http.Response('[]', 200));

      final result = await service.fetchLatestBulletin('Test Province');

      expect(result, isNull);
      verify(() => httpClient.get(any(), headers: any(named: 'headers'))).called(1);
    });
  });
}
