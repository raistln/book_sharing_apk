import 'package:book_sharing_app/data/local/database.dart';
import 'package:book_sharing_app/data/local/user_dao.dart';
import 'package:book_sharing_app/data/local/group_dao.dart';
import 'package:book_sharing_app/data/local/book_dao.dart';
import 'package:book_sharing_app/services/notification_service.dart';
import 'package:book_sharing_app/services/unified_sync_coordinator.dart';
import 'package:drift/drift.dart' as drift;
import 'package:drift/native.dart';
import 'package:mocktail/mocktail.dart';
import 'package:book_sharing_app/models/global_sync_state.dart'
    show SyncEvent, SyncEntity, SyncPriority;

import 'package:book_sharing_app/services/supabase_loan_service.dart';
import 'package:book_sharing_app/data/repositories/book_repository.dart';

// Mock classes for external dependencies
class MockNotificationClient extends Mock implements NotificationClient {}

class MockUnifiedSyncCoordinator extends Mock
    implements UnifiedSyncCoordinator {}

class MockSupabaseLoanService extends Mock implements SupabaseLoanService {}

class MockBookRepository extends Mock implements BookRepository {}

/// Register common fallback values for Mocktail
void setupTestFallbacks() {
  registerFallbackValue(NotificationType.loanDueSoon);
  registerFallbackValue(SyncEvent.loanCreated);
  registerFallbackValue(SyncEntity.books);
  registerFallbackValue(SyncPriority.high);
}

/// Utility to create an in-memory test database
AppDatabase createTestDatabase() {
  return AppDatabase.test(NativeDatabase.memory());
}

/// Helper to insert a local user for testing
Future<LocalUser> insertTestUser(UserDao userDao,
    {required String username, String? uuid}) async {
  final now = DateTime(2024, 1, 1, 12);
  final userId = await userDao.insertUser(
    LocalUsersCompanion.insert(
      uuid: uuid ?? 'user-$username',
      username: username,
      remoteId: drift.Value('remote-$username'),
      isDirty: const drift.Value(false),
      isDeleted: const drift.Value(false),
      createdAt: drift.Value(now),
      updatedAt: drift.Value(now),
    ),
  );
  return (await userDao.getById(userId))!;
}

/// Helper to insert a group for testing
Future<Group> insertTestGroup(GroupDao groupDao, LocalUser owner,
    {String uuid = 'group-1'}) async {
  final now = DateTime(2024, 1, 1, 12);
  final groupId = await groupDao.insertGroup(
    GroupsCompanion.insert(
      uuid: uuid,
      remoteId: drift.Value('remote-$uuid'),
      name: 'Test Group',
      ownerUserId: drift.Value(owner.id),
      ownerRemoteId: drift.Value(owner.remoteId ?? 'remote-owner'),
      isDirty: const drift.Value(false),
      isDeleted: const drift.Value(false),
      syncedAt: drift.Value(now),
      createdAt: drift.Value(now),
      updatedAt: drift.Value(now),
    ),
  );
  return (await groupDao.findGroupById(groupId))!;
}

/// Helper to insert a book for testing
Future<Book> insertTestBook(BookDao bookDao,
    {required int ownerUserId, required String uuid}) async {
  final now = DateTime(2024, 1, 1, 12);
  final bookId = await bookDao.insertBook(
    BooksCompanion.insert(
      uuid: uuid,
      remoteId: drift.Value('remote-$uuid'),
      ownerUserId: drift.Value(ownerUserId),
      ownerRemoteId: const drift.Value('remote-owner'),
      title: 'Test Book',
      status: const drift.Value('available'),
      isDirty: const drift.Value(false),
      isDeleted: const drift.Value(false),
      syncedAt: drift.Value(now),
      createdAt: drift.Value(now),
      updatedAt: drift.Value(now),
    ),
  );
  return (await bookDao.findById(bookId))!;
}

/// Helper to insert a shared book for testing
Future<SharedBook> insertTestSharedBook(
  GroupDao groupDao, {
  required Group group,
  required Book book,
  required LocalUser owner,
}) async {
  final now = DateTime(2024, 1, 1, 12);
  final sharedId = await groupDao.insertSharedBook(
    SharedBooksCompanion.insert(
      uuid: 'shared-${book.uuid}',
      remoteId: drift.Value('remote-shared-${book.uuid}'),
      groupId: group.id,
      groupUuid: group.uuid,
      bookId: book.id,
      bookUuid: book.uuid,
      ownerUserId: owner.id,
      ownerRemoteId: drift.Value(owner.remoteId ?? 'remote-owner'),
      visibility: const drift.Value('group'),
      isAvailable: const drift.Value(true),
      isDirty: const drift.Value(false),
      isDeleted: const drift.Value(false),
      syncedAt: drift.Value(now),
      createdAt: drift.Value(now),
      updatedAt: drift.Value(now),
    ),
  );
  return (await groupDao.findSharedBookById(sharedId))!;
}
