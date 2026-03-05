import 'package:book_sharing_app/data/local/user_dao.dart';
import 'package:book_sharing_app/data/local/database.dart';
import 'package:book_sharing_app/data/repositories/user_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:uuid/uuid.dart';

class _MockUserDao extends Mock implements UserDao {}

class _MockAppDatabase extends Mock implements AppDatabase {}

class _MockUuid extends Mock implements Uuid {}

void main() {
  late _MockUserDao userDao;
  late _MockAppDatabase mockDatabase;
  late _MockUuid uuid;
  late UserRepository repository;

  LocalUser buildUser({
    int id = 1,
    String? remoteId,
    String username = 'testuser',
  }) {
    return LocalUser(
      id: id,
      uuid: 'uuid-$id',
      username: username,
      remoteId: remoteId,
      isDirty: false,
      isDeleted: false,
      syncedAt: null,
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      updatedAt: DateTime.now(),
    );
  }

  setUpAll(() {
    registerFallbackValue(const LocalUsersCompanion());
  });

  setUp(() {
    userDao = _MockUserDao();
    mockDatabase = _MockAppDatabase();
    uuid = _MockUuid();
    repository = UserRepository(userDao, uuid: uuid);

    when(() => userDao.attachedDatabase).thenReturn(mockDatabase);
    when(() => mockDatabase.transaction(any())).thenAnswer((invocation) async {
      final action = invocation.positionalArguments[0] as Future Function();
      return await action();
    });
  });

  group('UserRepository', () {
    test('getActiveUser delegates to userDao', () async {
      final user = buildUser();
      when(() => userDao.getActiveUser()).thenAnswer((_) async => user);

      final result = await repository.getActiveUser();

      expect(result, user);
      verify(() => userDao.getActiveUser()).called(1);
    });

    test('getById delegates to userDao', () async {
      final user = buildUser();
      when(() => userDao.getById(1)).thenAnswer((_) async => user);

      final result = await repository.getById(1);

      expect(result, user);
      verify(() => userDao.getById(1)).called(1);
    });

    test('getActiveUsers delegates to userDao', () async {
      final users = [buildUser()];
      when(() => userDao.getActiveUsers()).thenAnswer((_) async => users);

      final result = await repository.getActiveUsers();

      expect(result, users);
      verify(() => userDao.getActiveUsers()).called(1);
    });

    test('updateDisplayName updates the user', () async {
      const userId = 1;
      const displayName = 'New Display Name';

      when(() => userDao.updateUser(any())).thenAnswer((_) async => 1);

      await repository.updateDisplayName(userId: userId, displayName: displayName);

      verify(() => userDao.updateUser(any())).called(1);
    });
  });
}
