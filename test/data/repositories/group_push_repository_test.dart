import 'dart:collection';
import 'dart:convert';

import 'package:book_sharing_app/data/local/database.dart';
import 'package:book_sharing_app/data/local/group_dao.dart';
import 'package:book_sharing_app/data/local/user_dao.dart';
import 'package:book_sharing_app/data/repositories/group_push_repository.dart';
import 'package:book_sharing_app/services/supabase_config_service.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:uuid/uuid.dart';

void main() {
  late AppDatabase db;
  late GroupDao groupDao;
  late UserDao userDao;

  setUp(() {
    db = AppDatabase.test(NativeDatabase.memory());
    groupDao = GroupDao(db);
    userDao = UserDao(db);
  });

  tearDown(() async {
    await db.close();
  });

  test('createGroup inserts local records and posts to Supabase', () async {
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

    final requests = <http.Request>[];
    final repository = GroupPushRepository(
      groupDao: groupDao,
      userDao: userDao,
      configService: _FakeSupabaseConfigService(
        const SupabaseConfig(
          url: 'https://example.supabase.co',
          anonKey: 'test-anon-key',
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

    final group = await repository.createGroup(
      name: 'My Group',
      description: 'Test group',
      owner: owner,
      accessToken: 'session-token',
    );

    expect(group.uuid, 'group-uuid');
    expect(group.remoteId, 'group-uuid');

    final groups = await groupDao.getActiveGroups();
    expect(groups, hasLength(1));
    expect(groups.first.ownerUserId, ownerId);
    expect(groups.first.ownerRemoteId, 'remote-owner');

    final members = await (db.select(db.groupMembers).get());
    expect(members, hasLength(1));
    expect(members.first.uuid, 'member-uuid');
    expect(members.first.remoteId, 'member-uuid');
    expect(members.first.memberUserId, ownerId);

    expect(requests, hasLength(2));

    final groupRequest = requests[0];
    expect(groupRequest.url.toString(), 'https://example.supabase.co/rest/v1/groups');
    expect(groupRequest.headers['Authorization'], 'Bearer session-token');
    final groupBody = jsonDecode(groupRequest.body) as Map<String, dynamic>;
    expect(groupBody['id'], 'group-uuid');
    expect(groupBody['name'], 'My Group');
    expect(groupBody['description'], 'Test group');
    expect(groupBody['owner_id'], 'remote-owner');

    final memberRequest = requests[1];
    expect(memberRequest.url.toString(), 'https://example.supabase.co/rest/v1/group_members');
    expect(memberRequest.headers['Authorization'], 'Bearer session-token');
    final memberBody = jsonDecode(memberRequest.body) as Map<String, dynamic>;
    expect(memberBody['id'], 'member-uuid');
    expect(memberBody['group_id'], 'group-uuid');
    expect(memberBody['user_id'], 'remote-owner');
    expect(memberBody['role'], 'admin');
  });

  test('createGroup throws when owner lacks remoteId', () async {
    final ownerId = await userDao.insertUser(
      LocalUsersCompanion.insert(
        uuid: 'user-uuid',
        username: 'owner',
        isDirty: const Value(false),
        isDeleted: const Value(false),
      ),
    );
    final owner = (await userDao.getById(ownerId))!;

    final repository = GroupPushRepository(
      groupDao: groupDao,
      userDao: userDao,
      configService: _FakeSupabaseConfigService(
        const SupabaseConfig(
          url: 'https://example.supabase.co',
          anonKey: 'test-anon-key',
        ),
      ),
      client: MockClient((request) async {
        fail('HTTP client should not be called when owner has no remoteId');
      }),
      uuid: _FakeUuid(['group-uuid']),
    );

    await expectLater(
      repository.createGroup(
        name: 'My Group',
        description: 'Test group',
        owner: owner,
      ),
      throwsA(isA<GroupPushException>()),
    );
  });
}

class _FakeSupabaseConfigService extends SupabaseConfigService {
  _FakeSupabaseConfigService(this._config);

  final SupabaseConfig _config;

  @override
  Future<SupabaseConfig> loadConfig() async => _config;
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
