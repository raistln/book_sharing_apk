import 'dart:collection';
import 'dart:convert';

import 'package:book_sharing_app/data/local/database.dart';
import 'package:book_sharing_app/data/local/group_dao.dart';
import 'package:book_sharing_app/data/local/user_dao.dart';
import 'package:book_sharing_app/data/repositories/group_push_repository.dart';
import 'package:book_sharing_app/services/supabase_config_service.dart';
import 'package:drift/drift.dart' hide isNotNull;
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

  test('acceptInvitationByCode fetches remote invitation and caches related data', () async {
    final joinerId = await userDao.insertUser(
      LocalUsersCompanion.insert(
        uuid: 'joiner-uuid',
        username: 'Joiner',
        remoteId: const Value('joiner-remote-id'),
        isDirty: const Value(false),
        isDeleted: const Value(false),
      ),
    );
    final joiner = (await userDao.getById(joinerId))!;

    final now = DateTime.now().toUtc();
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
        if (request.method == 'GET' &&
            request.url.path.endsWith('/rest/v1/group_invitations')) {
          final select = request.url.queryParameters['select'];
          expect(
            select,
            contains('inviter:local_users!group_invitations_inviter_id_fkey'),
          );
          return http.Response(
            jsonEncode([
              {
                'id': 'remote-invite-id',
                'group_id': 'remote-group-id',
                'inviter_id': 'inviter-remote-id',
                'accepted_user_id': null,
                'role': 'member',
                'code': 'invite-code',
                'status': 'pending',
                'expires_at': now.add(const Duration(days: 1)).toIso8601String(),
                'responded_at': null,
                'created_at': now.toIso8601String(),
                'updated_at': now.toIso8601String(),
                'group': {
                  'id': 'remote-group-id',
                  'name': 'Remote Group',
                  'description': 'Description',
                  'owner_id': 'owner-remote-id',
                  'created_at': now.toIso8601String(),
                  'updated_at': now.toIso8601String(),
                },
                'inviter': {
                  'id': 'inviter-remote-id',
                  'username': 'Inviter',
                  'is_deleted': false,
                  'created_at': now.toIso8601String(),
                  'updated_at': now.toIso8601String(),
                },
              },
            ]),
            200,
            headers: {'content-type': 'application/json'},
          );
        }

        if (request.method == 'POST' &&
            request.url.path.endsWith('/rest/v1/group_members')) {
          return http.Response('', 201);
        }

        if (request.method == 'PATCH' &&
            request.url.path.endsWith('/rest/v1/group_invitations')) {
          return http.Response('', 204);
        }

        fail('Unexpected request: ${request.method} ${request.url}');
      }),
      uuid: _FakeUuid(['member-joiner-uuid']),
    );

    final invitation = await repository.acceptInvitationByCode(
      code: 'invite-code',
      user: joiner,
      accessToken: 'session-token',
    );

    expect(invitation.status, 'accepted');
    expect(invitation.acceptedUserId, joinerId);

    final cachedInvitation = await groupDao.findInvitationByCode('invite-code');
    expect(cachedInvitation, isNotNull);
    expect(cachedInvitation!.acceptedUserId, joinerId);
    expect(cachedInvitation.status, 'accepted');

    final cachedGroup = await groupDao.findGroupByRemoteId('remote-group-id');
    expect(cachedGroup, isNotNull);
    expect(cachedGroup!.name, 'Remote Group');

    final inviter = await userDao.findByRemoteId('inviter-remote-id');
    expect(inviter, isNotNull);
    expect(inviter!.username, 'Inviter');

    expect(requests.where((request) => request.method == 'GET'), hasLength(1));
    expect(requests.where((request) => request.method == 'POST'), hasLength(1));
    expect(requests.where((request) => request.method == 'PATCH'), hasLength(1));
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
