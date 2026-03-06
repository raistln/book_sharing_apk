import 'package:book_sharing_app/services/supabase_config_service.dart';
import 'package:book_sharing_app/services/supabase_notification_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';

class _MockHttpClient extends Mock implements http.Client {}

class _MockSupabaseConfigService extends Mock implements SupabaseConfigService {}

void main() {
  late _MockHttpClient httpClient;
  late _MockSupabaseConfigService configService;
  late SupabaseNotificationService service;

  setUpAll(() {
    registerFallbackValue(const SupabaseConfig(url: '', anonKey: ''));
    registerFallbackValue(Uri.parse(''));
  });

  setUp(() {
    httpClient = _MockHttpClient();
    configService = _MockSupabaseConfigService();
    service = SupabaseNotificationService(
      client: httpClient,
      configService: configService,
    );
  });

  group('SupabaseNotificationService', () {
    test('fetchNotifications returns list of notifications', () async {
      const config = SupabaseConfig(
        url: 'https://test.supabase.co',
        anonKey: 'test-anon-key',
      );

      when(() => configService.loadConfig()).thenAnswer((_) async => config);
      when(() => httpClient.get(any(), headers: any(named: 'headers')))
          .thenAnswer((_) async => http.Response('''
[
  {
    "id": "notif-1",
    "user_id": "user-1",
    "type": "loan_request",
    "title": "Loan Request",
    "message": "Someone wants to borrow your book",
    "status": "unread",
    "is_deleted": false,
    "created_at": "2023-01-01T00:00:00Z"
  }
]
''', 200));

      final result = await service.fetchNotifications(targetUserId: 'user-1');

      expect(result, hasLength(1));
      expect(result.first.title, 'Loan Request');
      expect(result.first.userId, 'user-1');
      verify(() => httpClient.get(any(), headers: any(named: 'headers'))).called(1);
    });
  });
}
