import 'package:book_sharing_app/services/supabase_club_service.dart';
import 'package:book_sharing_app/services/supabase_config_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';

class _MockHttpClient extends Mock implements http.Client {}

class _MockSupabaseConfigService extends Mock implements SupabaseConfigService {}

void main() {
  late _MockHttpClient httpClient;
  late _MockSupabaseConfigService configService;
  late SupabaseClubService service;

  setUpAll(() {
    registerFallbackValue(const SupabaseConfig(url: '', anonKey: ''));
    registerFallbackValue(Uri.parse(''));
  });

  setUp(() {
    httpClient = _MockHttpClient();
    configService = _MockSupabaseConfigService();
    service = SupabaseClubService(
      client: httpClient,
      configService: configService,
    );
  });

  group('SupabaseClubService', () {
    test('fetchClubs returns list of clubs', () async {
      const config = SupabaseConfig(
        url: 'https://test.supabase.co',
        anonKey: 'test-anon-key',
      );

      when(() => configService.loadConfig()).thenAnswer((_) async => config);
      when(() => httpClient.get(any(), headers: any(named: 'headers')))
          .thenAnswer((_) async => http.Response('''
[
  {
    "id": "club-1",
    "name": "Test Club",
    "description": "A test club",
    "city": "Test City",
    "meeting_place": "Test Place",
    "frequency": "weekly",
    "frequency_days": 7,
    "visibility": "public",
    "next_books_visible": 5,
    "owner_id": "user-1",
    "current_book_id": "book-1",
    "created_at": "2023-01-01T00:00:00Z",
    "updated_at": "2023-01-01T00:00:00Z",
    "club_members": [],
    "club_books": []
  }
]
''', 200));

      final result = await service.fetchClubs();

      expect(result, hasLength(1));
      expect(result.first.name, 'Test Club');
      expect(result.first.ownerId, 'user-1');
      verify(() => httpClient.get(any(), headers: any(named: 'headers'))).called(1);
    });
  });
}
