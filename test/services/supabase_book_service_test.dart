import 'package:book_sharing_app/services/supabase_book_service.dart';
import 'package:book_sharing_app/services/supabase_config_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';

class _MockHttpClient extends Mock implements http.Client {}

class _MockSupabaseConfigService extends Mock implements SupabaseConfigService {}

void main() {
  late _MockHttpClient httpClient;
  late _MockSupabaseConfigService configService;
  late SupabaseBookService service;

  setUpAll(() {
    registerFallbackValue(const SupabaseConfig(url: '', anonKey: ''));
    registerFallbackValue(Uri.parse(''));
  });

  setUp(() {
    httpClient = _MockHttpClient();
    configService = _MockSupabaseConfigService();
    service = SupabaseBookService(
      client: httpClient,
      configService: configService,
    );
  });

  group('SupabaseBookService', () {
    test('fetchBooks returns list of books', () async {
      const config = SupabaseConfig(
        url: 'https://test.supabase.co',
        anonKey: 'test-anon-key',
      );

      when(() => configService.loadConfig()).thenAnswer((_) async => config);
      when(() => httpClient.get(any(), headers: any(named: 'headers')))
          .thenAnswer((_) async => http.Response('''
[
  {
    "id": "1",
    "owner_id": "user-1",
    "title": "Test Book",
    "author": "Test Author",
    "is_deleted": false,
    "created_at": "2023-01-01T00:00:00Z"
  }
]
''', 200));

      final result = await service.fetchBooks(ownerId: 'user-1');

      expect(result, hasLength(1));
      expect(result.first.title, 'Test Book');
      expect(result.first.ownerId, 'user-1');
      verify(() => httpClient.get(any(), headers: any(named: 'headers'))).called(1);
    });
  });
}
