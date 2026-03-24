
import 'package:book_sharing_app/data/local/database.dart';
import 'package:book_sharing_app/data/local/group_dao.dart';
import 'package:book_sharing_app/data/local/user_dao.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:drift/drift.dart';

void main() {
  late AppDatabase database;
  late GroupDao groupDao;
  late UserDao userDao;
  late LocalUser testUser;

  setUp(() async {
    database = AppDatabase.test(NativeDatabase.memory());
    groupDao = GroupDao(database);
    userDao = UserDao(database);

    final userCompanion = LocalUsersCompanion.insert(
      uuid: 'user-uuid-1',
      username: 'testuser',
      pinUpdatedAt: Value(DateTime.now()),
    );
    final id = await userDao.insertUser(userCompanion);
    testUser = (await userDao.getById(id))!;
  });

  tearDown(() async {
    await database.close();
  });

  test('insertGroup inserts a group and watchGroupsForUser retrieves it', () async {
    final group = GroupsCompanion(
      uuid: const Value('group-1'),
      name: const Value('Test Group'),
      ownerUserId: Value(testUser.id),
      createdAt: Value(DateTime.now()),
      updatedAt: Value(DateTime.now()),
    );

    final groupId = await groupDao.insertGroup(group);

    await groupDao.insertMember(GroupMembersCompanion.insert(
      uuid: 'member-uuid-1',
      groupUuid: 'group-1',
      memberUserId: testUser.id,
      role: const Value('owner'),
      createdAt: Value(DateTime.now()),
      updatedAt: Value(DateTime.now()),
      groupId: groupId,
    ));

    final groupsStream = groupDao.watchGroupsForUser(testUser.id);
    final groups = await groupsStream.first;

    expect(groups.length, 1);
    expect(groups[0].name, 'Test Group');
  });

  test('updateGroup updates an existing group', () async {
    final group = GroupsCompanion(
      uuid: const Value('group-1'),
      name: const Value('Test Group'),
      ownerUserId: Value(testUser.id),
      createdAt: Value(DateTime.now()),
      updatedAt: Value(DateTime.now()),
    );

    final insertedId = await groupDao.insertGroup(group);
    final insertedGroup = (await groupDao.findGroupById(insertedId))!;

    await groupDao.insertMember(GroupMembersCompanion.insert(
      uuid: 'member-uuid-2',
      groupUuid: 'group-1',
      memberUserId: testUser.id,
      role: const Value('owner'),
      createdAt: Value(DateTime.now()),
      updatedAt: Value(DateTime.now()),
      groupId: insertedGroup.id,
    ));

    final updatedGroup = GroupsCompanion(
      id: Value(insertedGroup.id),
      uuid: const Value('group-1'),
      name: const Value('Updated Group Name'),
      ownerUserId: Value(testUser.id),
      createdAt: Value(insertedGroup.createdAt),
      updatedAt: Value(DateTime.now()),
    );

    await groupDao.updateGroup(updatedGroup);

    final groupsStream = groupDao.watchGroupsForUser(testUser.id);
    final groups = await groupsStream.first;

    expect(groups.length, 1);
    expect(groups[0].name, 'Updated Group Name');
  });
}
