import 'package:book_sharing_app/data/local/group_dao.dart';
import 'package:book_sharing_app/data/local/user_dao.dart';
import 'package:book_sharing_app/data/repositories/group_push_repository.dart';
import 'package:book_sharing_app/services/supabase_config_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';
import 'package:uuid/uuid.dart';

class _MockGroupDao extends Mock implements GroupDao {}

class _MockUserDao extends Mock implements UserDao {}

class _MockSupabaseConfigService extends Mock implements SupabaseConfigService {}

class _MockHttpClient extends Mock implements http.Client {}

class _MockUuid extends Mock implements Uuid {}

void main() {
  late _MockGroupDao groupDao;
  late _MockUserDao userDao;
  late _MockSupabaseConfigService configService;
  late _MockHttpClient httpClient;
  late _MockUuid uuid;
  late GroupPushRepository repository;

  setUp(() {
    groupDao = _MockGroupDao();
    userDao = _MockUserDao();
    configService = _MockSupabaseConfigService();
    httpClient = _MockHttpClient();
    uuid = _MockUuid();
    repository = GroupPushRepository(
      groupDao: groupDao,
      userDao: userDao,
      configService: configService,
      client: httpClient,
      uuid: uuid,
    );
  });

  test('dispose closes the http client', () async {
    when(() => httpClient.close()).thenReturn(null);

    await repository.dispose();

    verify(() => httpClient.close()).called(1);
  });
}
