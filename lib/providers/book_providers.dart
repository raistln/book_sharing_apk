import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/local/book_dao.dart';
import '../data/local/database.dart';
import '../data/local/group_dao.dart';
import '../data/local/user_dao.dart';
import '../data/repositories/book_repository.dart';
import '../data/repositories/loan_repository.dart';
import '../data/repositories/supabase_group_repository.dart';
import '../data/repositories/supabase_user_sync_repository.dart';
import '../data/repositories/user_repository.dart';
import '../services/book_export_service.dart';
import '../services/cover_image_service.dart';
import '../services/group_sync_controller.dart';
import '../services/loan_controller.dart';
import '../services/sync_service.dart';
import '../services/supabase_config_service.dart';
import '../services/supabase_group_service.dart';
import '../services/supabase_user_service.dart';
import '../data/repositories/group_push_repository.dart';
import '../services/group_push_controller.dart';
import 'notification_providers.dart';

final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

final bookDaoProvider = Provider<BookDao>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return BookDao(db);
});

final bookRepositoryProvider = Provider<BookRepository>((ref) {
  final dao = ref.watch(bookDaoProvider);
  return BookRepository(dao);
});

final groupDaoProvider = Provider<GroupDao>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return GroupDao(db);
});

final groupListProvider = StreamProvider.autoDispose<List<Group>>((ref) {
  final dao = ref.watch(groupDaoProvider);
  return dao.watchActiveGroups();
});

final groupMemberDetailsProvider = StreamProvider.autoDispose
    .family<List<GroupMemberDetail>, int>((ref, groupId) {
  final dao = ref.watch(groupDaoProvider);
  return dao.watchMemberDetails(groupId);
});

final sharedBookDetailsProvider = StreamProvider.autoDispose
    .family<List<SharedBookDetail>, int>((ref, groupId) {
  final dao = ref.watch(groupDaoProvider);
  return dao.watchSharedBookDetails(groupId);
});

final groupLoanDetailsProvider = StreamProvider.autoDispose
    .family<List<LoanDetail>, int>((ref, groupId) {
  final dao = ref.watch(groupDaoProvider);
  return dao.watchLoanDetailsForGroup(groupId);
});

final groupInvitationDetailsProvider = StreamProvider.autoDispose
    .family<List<GroupInvitationDetail>, int>((ref, groupId) {
  final dao = ref.watch(groupDaoProvider);
  return dao.watchInvitationDetailsForGroup(groupId);
});

final userDaoProvider = Provider<UserDao>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return UserDao(db);
});

final userRepositoryProvider = Provider<UserRepository>((ref) {
  final dao = ref.watch(userDaoProvider);
  return UserRepository(dao);
});

final loanRepositoryProvider = Provider<LoanRepository>((ref) {
  final groupDao = ref.watch(groupDaoProvider);
  final bookDao = ref.watch(bookDaoProvider);
  final userDao = ref.watch(userDaoProvider);
  return LoanRepository(
    groupDao: groupDao,
    bookDao: bookDao,
    userDao: userDao,
  );
});

final activeUserProvider = StreamProvider.autoDispose<LocalUser?>((ref) {
  final repository = ref.watch(userRepositoryProvider);
  return repository.watchActiveUser();
});

final supabaseUserServiceProvider = Provider<SupabaseUserService>((ref) {
  final service = SupabaseUserService();
  ref.onDispose(service.dispose);
  return service;
});

final supabaseUserSyncRepositoryProvider =
    Provider<SupabaseUserSyncRepository>((ref) {
  final userDao = ref.watch(userDaoProvider);
  final supabaseService = ref.watch(supabaseUserServiceProvider);
  return SupabaseUserSyncRepository(
    userDao: userDao,
    userService: supabaseService,
  );
});

final userSyncControllerProvider =
    StateNotifierProvider<SyncController, SyncState>((ref) {
  final userRepository = ref.watch(userRepositoryProvider);
  final syncRepository = ref.watch(supabaseUserSyncRepositoryProvider);
  final controller = SyncController(
    getActiveUser: () => userRepository.getActiveUser(),
    pushLocalChanges: () => syncRepository.pushLocalChanges(),
    loadConfig: () => const SupabaseConfigService().loadConfig(),
  );

  return controller;
});

final supabaseGroupServiceProvider = Provider<SupabaseGroupService>((ref) {
  final service = SupabaseGroupService();
  ref.onDispose(service.dispose);
  return service;
});

final groupPushRepositoryProvider = Provider<GroupPushRepository>((ref) {
  final groupDao = ref.watch(groupDaoProvider);
  final userDao = ref.watch(userDaoProvider);
  final repository = GroupPushRepository(
    groupDao: groupDao,
    userDao: userDao,
  );
  ref.onDispose(repository.dispose);
  return repository;
});

final coverImageServiceProvider = Provider<CoverImageService>((ref) {
  return createCoverImageService();
});

final bookListProvider = StreamProvider.autoDispose((ref) {
  final repository = ref.watch(bookRepositoryProvider);
  return repository.watchAll();
});

final bookReviewsProvider =
    StreamProvider.autoDispose.family<List<BookReview>, int>((ref, bookId) {
  final repository = ref.watch(bookRepositoryProvider);
  return repository.watchReviews(bookId);
});

final bookExportServiceProvider = Provider<BookExportService>((ref) {
  return const BookExportService();
});

final supabaseGroupSyncRepositoryProvider = Provider<SupabaseGroupSyncRepository>((ref) {
  final groupDao = ref.watch(groupDaoProvider);
  final userDao = ref.watch(userDaoProvider);
  final bookDao = ref.watch(bookDaoProvider);
  final service = ref.watch(supabaseGroupServiceProvider);
  return SupabaseGroupSyncRepository(
    groupDao: groupDao,
    userDao: userDao,
    bookDao: bookDao,
    groupService: service,
  );
});

final groupSyncControllerProvider =
    StateNotifierProvider<GroupSyncController, SyncState>((ref) {
  final repository = ref.watch(supabaseGroupSyncRepositoryProvider);
  final userRepository = ref.watch(userRepositoryProvider);
  return GroupSyncController(
    groupRepository: repository,
    userRepository: userRepository,
    configService: const SupabaseConfigService(),
  );
});

final loanControllerProvider =
    StateNotifierProvider<LoanController, LoanActionState>((ref) {
  final repository = ref.watch(loanRepositoryProvider);
  final syncController = ref.watch(groupSyncControllerProvider.notifier);
  final notificationClient = ref.watch(notificationServiceProvider);
  return LoanController(
    loanRepository: repository,
    groupSyncController: syncController,
    notificationClient: notificationClient,
  );
});

final groupPushControllerProvider =
    StateNotifierProvider<GroupPushController, GroupActionState>((ref) {
  final repository = ref.watch(groupPushRepositoryProvider);
  final syncController = ref.watch(groupSyncControllerProvider.notifier);
  final notificationClient = ref.watch(notificationServiceProvider);
  return GroupPushController(
    groupPushRepository: repository,
    groupSyncController: syncController,
    notificationClient: notificationClient,
  );
});
