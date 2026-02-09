import 'package:book_sharing_app/data/local/database.dart';
import 'package:book_sharing_app/data/local/user_dao.dart';
import 'package:book_sharing_app/data/repositories/supabase_user_sync_repository.dart';
import 'package:book_sharing_app/services/supabase_user_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockUserDao extends Mock implements UserDao {}

class _MockSupabaseUserService extends Mock implements SupabaseUserService {}

void main() {
  late _MockUserDao userDao;
  late _MockSupabaseUserService userService;
  late SupabaseUserSyncRepository repository;

  LocalUser buildUser({
    int id = 1,
    String? remoteId,
    bool isDirty = true,
    bool isDeleted = false,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    final now = DateTime.now();
    return LocalUser(
      id: id,
      uuid: 'uuid-$id',
      username: 'user$id',
      remoteId: remoteId,
      isDirty: isDirty,
      isDeleted: isDeleted,
      syncedAt: null,
      createdAt: createdAt ?? now.subtract(const Duration(days: 1)),
      updatedAt: updatedAt ?? now,
    );
  }

  setUpAll(() {
    registerFallbackValue(const LocalUsersCompanion());
  });

  setUp(() {
    userDao = _MockUserDao();
    userService = _MockSupabaseUserService();
    repository = SupabaseUserSyncRepository(
      userDao: userDao,
      userService: userService,
    );
  });

  test('returns early when there are no dirty users', () async {
    when(() => userDao.getDirtyUsers()).thenAnswer((_) async => []);

    await repository.pushLocalChanges();

    verify(() => userDao.getDirtyUsers()).called(1);
    verifyNever(() => userService.createUser(
          id: any(named: 'id'),
          username: any(named: 'username'),
          isDeleted: any(named: 'isDeleted'),
          createdAt: any(named: 'createdAt'),
          updatedAt: any(named: 'updatedAt'),
          accessToken: any(named: 'accessToken'),
        ));
    verifyNever(() => userDao.updateUser(
          any(),
        ));
  });

  test('creates remote user when missing remoteId and updates local record',
      () async {
    final user = buildUser();

    when(() => userDao.getDirtyUsers()).thenAnswer((_) async => [user]);
    when(() => userDao.updateUser(
          any(),
        )).thenAnswer((_) async => 1);
    when(() => userService.createUser(
          id: user.uuid,
          username: user.username,
          isDeleted: user.isDeleted,
          createdAt: user.createdAt,
          updatedAt: user.updatedAt,
          accessToken: any(named: 'accessToken'),
        )).thenAnswer((_) async => 'remote-${user.id}');

    await repository.pushLocalChanges();

    verify(() => userService.createUser(
          id: user.uuid,
          username: user.username,
          isDeleted: user.isDeleted,
          createdAt: user.createdAt,
          updatedAt: user.updatedAt,
          accessToken: any(named: 'accessToken'),
        )).called(1);

    final capturedEntry = verify(() => userDao.updateUser(
          captureAny(),
        )).captured.single as LocalUsersCompanion;

    expect(capturedEntry.remoteId.present, isTrue);
    expect(capturedEntry.remoteId.value, 'remote-${user.id}');
    expect(capturedEntry.isDirty.present, isTrue);
    expect(capturedEntry.isDirty.value, isFalse);
    expect(capturedEntry.syncedAt.present, isTrue);
    expect(capturedEntry.syncedAt.value, isA<DateTime>());
  });

  test('updates remote user when remoteId exists', () async {
    final user = buildUser(remoteId: 'remote-1');

    when(() => userDao.getDirtyUsers()).thenAnswer((_) async => [user]);
    when(() => userService.updateUser(
          id: user.remoteId!,
          username: user.username,
          isDeleted: user.isDeleted,
          updatedAt: user.updatedAt,
          accessToken: any(named: 'accessToken'),
        )).thenAnswer((_) async => true);
    when(() => userDao.updateUser(
          any(),
        )).thenAnswer((_) async => 1);

    await repository.pushLocalChanges();

    verify(() => userService.updateUser(
          id: user.remoteId!,
          username: user.username,
          isDeleted: user.isDeleted,
          updatedAt: user.updatedAt,
          accessToken: any(named: 'accessToken'),
        )).called(1);
    verifyNever(() => userService.createUser(
          id: any(named: 'id'),
          username: any(named: 'username'),
          isDeleted: any(named: 'isDeleted'),
          createdAt: any(named: 'createdAt'),
          updatedAt: any(named: 'updatedAt'),
          accessToken: any(named: 'accessToken'),
        ));
  });

  test('retries with create when update returns false', () async {
    final user = buildUser(remoteId: 'remote-2');

    when(() => userDao.getDirtyUsers()).thenAnswer((_) async => [user]);
    when(() => userService.updateUser(
          id: user.remoteId!,
          username: user.username,
          isDeleted: user.isDeleted,
          updatedAt: user.updatedAt,
          accessToken: any(named: 'accessToken'),
        )).thenAnswer((_) async => false);
    when(() => userService.createUser(
          id: user.remoteId!,
          username: user.username,
          isDeleted: user.isDeleted,
          createdAt: user.createdAt,
          updatedAt: user.updatedAt,
          accessToken: any(named: 'accessToken'),
        )).thenAnswer((_) async => 'remote-new');
    when(() => userDao.updateUser(
          any(),
        )).thenAnswer((_) async => 1);

    await repository.pushLocalChanges();

    verify(() => userService.updateUser(
          id: user.remoteId!,
          username: user.username,
          isDeleted: user.isDeleted,
          updatedAt: user.updatedAt,
          accessToken: any(named: 'accessToken'),
        )).called(1);
    verify(() => userService.createUser(
          id: user.remoteId!,
          username: user.username,
          isDeleted: user.isDeleted,
          createdAt: user.createdAt,
          updatedAt: user.updatedAt,
          accessToken: any(named: 'accessToken'),
        )).called(1);
  });

  test('propagates SupabaseUserServiceException', () async {
    final user = buildUser();
    final exception = SupabaseUserServiceException('Boom', 400);

    when(() => userDao.getDirtyUsers()).thenAnswer((_) async => [user]);
    when(() => userService.createUser(
          id: user.uuid,
          username: user.username,
          isDeleted: user.isDeleted,
          createdAt: user.createdAt,
          updatedAt: user.updatedAt,
          accessToken: any(named: 'accessToken'),
        )).thenThrow(exception);

    expect(
      repository.pushLocalChanges,
      throwsA(same(exception)),
    );
  });

  test('wraps unexpected errors with SupabaseUserSyncException', () async {
    final user = buildUser();

    when(() => userDao.getDirtyUsers()).thenAnswer((_) async => [user]);
    when(() => userService.createUser(
          id: user.uuid,
          username: user.username,
          isDeleted: user.isDeleted,
          createdAt: user.createdAt,
          updatedAt: user.updatedAt,
          accessToken: any(named: 'accessToken'),
        )).thenThrow(Exception('unexpected'));

    expect(
      repository.pushLocalChanges,
      throwsA(isA<SupabaseUserSyncException>()),
    );
  });
}
