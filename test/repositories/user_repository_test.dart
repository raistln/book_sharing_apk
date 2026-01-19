import 'package:book_sharing_app/data/local/database.dart';
import 'package:book_sharing_app/data/local/user_dao.dart';
import 'package:book_sharing_app/data/repositories/user_repository.dart';
import 'package:book_sharing_app/services/supabase_user_service.dart';
import 'package:flutter_test/flutter_test.dart';
import '../helpers/test_helper.dart';

void main() {
  group('UserRepository', () {
    late AppDatabase db;
    late UserDao userDao;
    late UserRepository repository;

    setUp(() {
      db = createTestDatabase();
      userDao = UserDao(db);
      repository = UserRepository(userDao);
    });

    tearDown(() async {
      await db.close();
    });

    test('createUser creates a new user and marks others as deleted', () async {
      // Create first user
      final user1 = await repository.createUser(username: 'user1');
      expect(user1.username, 'user1');
      expect(user1.isDeleted, isFalse);

      // Create second user (active user changes)
      final user2 = await repository.createUser(username: 'user2');
      expect(user2.username, 'user2');
      expect(user2.isDeleted, isFalse);

      // Check user1 is now deleted
      final refreshedUser1 = await repository.getById(user1.id);
      expect(refreshedUser1?.isDeleted, isTrue);
    });

    test('updateDisplayName updates the name and marks as dirty', () async {
      final user = await repository.createUser(username: 'original');

      await repository.updateDisplayName(
        userId: user.id,
        displayName: 'updated',
      );

      final updated = await repository.getById(user.id);
      expect(updated?.username, 'updated');
      expect(updated?.isDirty, isTrue);
    });

    test('updatePinData updates PIN fields correctly', () async {
      final user = await repository.createUser(username: 'pintest');
      final now = DateTime.now();

      await repository.updatePinData(
        userId: user.id,
        pinHash: 'hash',
        pinSalt: 'salt',
        pinUpdatedAt: now,
      );

      final updated = await repository.getById(user.id);
      expect(updated?.pinHash, 'hash');
      expect(updated?.pinSalt, 'salt');
      expect(updated?.pinUpdatedAt, isNotNull);
    });

    test('importRemoteUser handles existing vs new user', () async {
      final now = DateTime.now().toUtc();
      final record = SupabaseUserRecord(
        id: 'remote-uuid',
        username: 'remote_user',
        isDeleted: false,
        updatedAt: now,
      );

      final imported = await repository.importRemoteUser(record);

      expect(imported.remoteId, 'remote-uuid');
      expect(imported.username, 'remote_user');
      expect(imported.isDirty, isFalse);

      // Import again with updated name
      final updatedRecord = SupabaseUserRecord(
        id: 'remote-uuid',
        username: 'remote_user_updated',
        isDeleted: false,
        updatedAt: now.add(const Duration(minutes: 1)),
      );

      final reimported = await repository.importRemoteUser(updatedRecord);
      expect(reimported.id, imported.id);
      expect(reimported.username, 'remote_user_updated');
    });

    test('getActiveUser returns the non-deleted user', () async {
      await repository.createUser(username: 'active');

      final active = await repository.getActiveUser();
      expect(active?.username, 'active');
      expect(active?.isDeleted, isFalse);
    });
  });
}
