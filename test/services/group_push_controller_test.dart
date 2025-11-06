import 'dart:collection';

import 'package:book_sharing_app/data/local/book_dao.dart';
import 'package:book_sharing_app/data/local/database.dart';
import 'package:book_sharing_app/data/local/group_dao.dart';
import 'package:book_sharing_app/data/local/user_dao.dart';
import 'package:book_sharing_app/data/repositories/group_push_repository.dart';
import 'package:book_sharing_app/data/repositories/supabase_group_repository.dart';
import 'package:book_sharing_app/data/repositories/user_repository.dart';
import 'package:book_sharing_app/services/group_push_controller.dart';
import 'package:book_sharing_app/services/group_sync_controller.dart';
import 'package:book_sharing_app/services/supabase_config_service.dart';
import 'package:book_sharing_app/services/supabase_group_service.dart';
import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:uuid/uuid.dart';

void main() {
  late AppDatabase db;
  late GroupDao groupDao;
  late UserDao userDao;
  late BookDao bookDao;
  late GroupPushRepository groupPushRepository;
  late GroupSyncController syncController;
  late GroupPushController controller;
  late List<http.Request> requests;

  setUp(() {
    db = AppDatabase.test(NativeDatabase.memory());
    groupDao = GroupDao(db);
    userDao = UserDao(db);
    bookDao = BookDao(db);
    requests = <http.Request>[];

    groupPushRepository = GroupPushRepository(
      groupDao: groupDao,
      userDao: userDao,
      configService: _FakeSupabaseConfigService(
        const SupabaseConfig(
          url: 'https://example.supabase.co',
          anonKey: 'anon-key',
        ),
      ),
      client: MockClient((request) async {
        requests.add(request);
        return http.Response('', 201);
      }),
      uuid: _FakeUuid([
        'group-uuid',
        'member-uuid',
      ]),
    );

    final syncRepository = SupabaseGroupSyncRepository(
      groupDao: groupDao,
      userDao: userDao,
      bookDao: bookDao,
      groupService: _FakeSupabaseGroupService(),
    );
    final userRepository = UserRepository(userDao);

    syncController = GroupSyncController(
      groupRepository: syncRepository,
      userRepository: userRepository,
      configService: _FakeSupabaseConfigService(
        const SupabaseConfig(
          url: 'https://example.supabase.co',
          anonKey: 'anon-key',
        ),
      ),
    );

    controller = GroupPushController(
      groupPushRepository: groupPushRepository,
      groupSyncController: syncController,
    );
  });

  tearDown(() async {
    await db.close();
  });

  test('createGroup updates state and marks pending changes', () async {
    final ownerId = await userDao.insertUser(
      LocalUsersCompanion.insert(
        uuid: 'user-uuid',
        username: 'owner',
        remoteId: const Value('remote-owner'),
        isDirty: const Value(false),
        isDeleted: const Value(false),
      ),
    );
    final owner = (await userDao.getById(ownerId))!;

    final group = await controller.createGroup(
      name: 'Club',
      description: 'Descripción',
      owner: owner,
      accessToken: 'access-token',
    );

    expect(group.uuid, 'group-uuid');
    expect(controller.state.lastSuccess, 'Grupo creado.');
    expect(controller.state.lastError, isNull);
    expect(syncController.state.hasPendingChanges, isTrue);
    expect(requests, hasLength(2));
  });

  test('createGroup exposes error when repository throws', () async {
    final ownerId = await userDao.insertUser(
      LocalUsersCompanion.insert(
        uuid: 'user-uuid',
        username: 'owner',
        isDirty: const Value(false),
        isDeleted: const Value(false),
      ),
    );
    final owner = (await userDao.getById(ownerId))!;

    await expectLater(
      controller.createGroup(
        name: 'Club',
        description: null,
        owner: owner,
      ),
      throwsA(isA<GroupPushException>()),
    );

    expect(controller.state.lastError, isNotNull);
    expect(controller.state.isLoading, isFalse);
  });
}

class _FakeSupabaseConfigService extends SupabaseConfigService {
  _FakeSupabaseConfigService(this._config);

  final SupabaseConfig _config;

  @override
  Future<SupabaseConfig> loadConfig() async => _config;
}

class _FakeSupabaseGroupService extends SupabaseGroupService {
  _FakeSupabaseGroupService() : super();

  @override
  Future<List<SupabaseGroupRecord>> fetchGroups({String? accessToken}) async => const [];
}

class _FakeUuid extends Uuid {
  _FakeUuid(Iterable<String> values)
      : _values = Queue<String>.of(values);

  final Queue<String> _values;

  @override
  String v4({Map<String, dynamic>? options}) {
    if (_values.isEmpty) {
      throw StateError('No more UUID values configured for fake UUID generator.');
    }
    return _values.removeFirst();
  }
}
