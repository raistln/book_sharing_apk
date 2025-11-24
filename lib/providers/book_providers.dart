import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/local/book_dao.dart';
import '../data/local/database.dart';
import '../data/local/group_dao.dart';
import '../data/local/notification_dao.dart';
import '../data/local/user_dao.dart';
import '../data/repositories/book_repository.dart';
import '../data/repositories/loan_repository.dart';
import '../data/repositories/notification_repository.dart';
import '../data/repositories/supabase_notification_sync_repository.dart';
import '../data/repositories/supabase_group_repository.dart';
import '../data/repositories/supabase_book_sync_repository.dart';
import '../data/repositories/supabase_user_sync_repository.dart';
import '../data/repositories/user_repository.dart';
import '../services/book_export_service.dart';
import '../services/cover_image_service.dart';
import '../services/group_sync_controller.dart';
import '../services/loan_controller.dart';
import '../services/sync_service.dart';
import '../services/supabase_config_service.dart';
import '../services/supabase_book_service.dart';
import '../services/supabase_group_service.dart';
import '../services/supabase_notification_service.dart';
import '../services/supabase_user_service.dart';
import '../data/repositories/group_push_repository.dart';
import '../services/group_push_controller.dart';
import '../services/discover_group_controller.dart';
import '../services/onboarding_service.dart';
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

final notificationDaoProvider = Provider<NotificationDao>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return NotificationDao(db);
});

final onboardingServiceProvider = Provider<OnboardingService>((ref) {
  return OnboardingService();
});

final onboardingProgressProvider = FutureProvider<OnboardingProgress>((ref) {
  final service = ref.watch(onboardingServiceProvider);
  return service.loadProgress();
});

final bookRepositoryProvider = Provider<BookRepository>((ref) {
  final dao = ref.watch(bookDaoProvider);
  final groupDao = ref.watch(groupDaoProvider);
  final groupSyncController = ref.watch(groupSyncControllerProvider.notifier);
  final syncController = ref.watch(bookSyncControllerProvider.notifier);
  return BookRepository(
    dao,
    groupDao: groupDao,
    groupSyncController: groupSyncController,
    bookSyncController: syncController,
  );
});

final groupDaoProvider = Provider<GroupDao>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return GroupDao(db);
});

final groupListProvider = StreamProvider.autoDispose<List<Group>>((ref) {
  final dao = ref.watch(groupDaoProvider);
  final activeUser = ref.watch(activeUserProvider).value;

  if (activeUser == null) {
    return const Stream.empty();
  }

  return dao.watchGroupsForUser(activeUser.id);
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

final discoverGroupControllerProvider = StateNotifierProvider.autoDispose
    .family<DiscoverGroupController, DiscoverGroupState, int>((ref, groupId) {
  final dao = ref.watch(groupDaoProvider);
  return DiscoverGroupController(groupDao: dao, groupId: groupId);
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

final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  final dao = ref.watch(notificationDaoProvider);
  final syncController = ref.watch(notificationSyncControllerProvider.notifier);
  final repository = NotificationRepository(
    notificationDao: dao,
    notificationSyncController: syncController,
  );

  // Ejecuta la limpieza local de notificaciones caducadas en segundo plano.
  Future.microtask(() => repository.purgeExpired());

  ref.onDispose(repository.dispose);

  return repository;
});

final supabaseNotificationServiceProvider = Provider<SupabaseNotificationService>((ref) {
  final service = SupabaseNotificationService();
  ref.onDispose(service.dispose);
  return service;
});

final supabaseNotificationSyncRepositoryProvider =
    Provider<SupabaseNotificationSyncRepository>((ref) {
  final notificationDao = ref.watch(notificationDaoProvider);
  final userDao = ref.watch(userDaoProvider);
  final groupDao = ref.watch(groupDaoProvider);
  final service = ref.watch(supabaseNotificationServiceProvider);
  return SupabaseNotificationSyncRepository(
    notificationDao: notificationDao,
    userDao: userDao,
    groupDao: groupDao,
    notificationService: service,
  );
});

final notificationSyncControllerProvider =
    StateNotifierProvider<SyncController, SyncState>((ref) {
  final userRepository = ref.watch(userRepositoryProvider);
  final syncRepository = ref.watch(supabaseNotificationSyncRepositoryProvider);

  Future<void> fetchRemote() async {
    final user = await userRepository.getActiveUser();
    if (user == null) {
      throw const SyncException('No hay usuario local configurado.');
    }

    await syncRepository.syncFromRemote(target: user);
  }

  Future<void> pushLocal() async {
    final user = await userRepository.getActiveUser();
    if (user == null) {
      throw const SyncException('No hay usuario local configurado.');
    }

    await syncRepository.pushLocalChanges(target: user);
  }

  final controller = SyncController(
    getActiveUser: () => userRepository.getActiveUser(),
    fetchRemoteChanges: fetchRemote,
    pushLocalChanges: pushLocal,
    loadConfig: () => const SupabaseConfigService().loadConfig(),
  );

  ref.onDispose(controller.dispose);

  return controller;
});

final unreadNotificationCountProvider = StreamProvider.autoDispose<int>((ref) {
  final activeUserAsync = ref.watch(activeUserProvider);
  final repository = ref.watch(notificationRepositoryProvider);

  return activeUserAsync.when<Stream<int>>(
    data: (user) {
      if (user == null) {
        return Stream.value(0);
      }
      return repository.watchUnreadCount(user.id);
    },
    loading: () => Stream.value(0),
    error: (_, __) => Stream.value(0),
  );
});

final inAppNotificationsProvider =
    StreamProvider.autoDispose<List<InAppNotification>>((ref) {
  final activeUserAsync = ref.watch(activeUserProvider);
  final repository = ref.watch(notificationRepositoryProvider);

  return activeUserAsync.when<Stream<List<InAppNotification>>>(
    data: (user) {
      if (user == null) {
        return Stream.value(const <InAppNotification>[]);
      }
      return repository.watchForUser(user.id);
    },
    loading: () => Stream.value(const <InAppNotification>[]),
    error: (_, __) => Stream.value(const <InAppNotification>[]),
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
    fetchRemoteChanges: () => syncRepository.syncFromRemote(),
    pushLocalChanges: () => syncRepository.pushLocalChanges(),
    loadConfig: () => const SupabaseConfigService().loadConfig(),
  );

  return controller;
});

final supabaseBookServiceProvider = Provider<SupabaseBookService>((ref) {
  final service = SupabaseBookService();
  ref.onDispose(service.dispose);
  return service;
});

final supabaseBookSyncRepositoryProvider =
    Provider<SupabaseBookSyncRepository>((ref) {
  final bookDao = ref.watch(bookDaoProvider);
  final bookService = ref.watch(supabaseBookServiceProvider);
  return SupabaseBookSyncRepository(
    bookDao: bookDao,
    bookService: bookService,
  );
});

final bookSyncControllerProvider =
    StateNotifierProvider<SyncController, SyncState>((ref) {
  final userRepository = ref.watch(userRepositoryProvider);
  final syncRepository = ref.watch(supabaseBookSyncRepositoryProvider);

  Future<void> fetchRemote() async {
    final user = await userRepository.getActiveUser();
    if (user == null) {
      throw const SyncException('No hay usuario local configurado.');
    }

    await syncRepository.syncFromRemote(owner: user);
  }

  Future<void> pushLocal() async {
    final user = await userRepository.getActiveUser();
    if (user == null) {
      throw const SyncException('No hay usuario local configurado.');
    }

    await syncRepository.pushLocalChanges(owner: user);
  }

  final controller = SyncController(
    getActiveUser: () => userRepository.getActiveUser(),
    fetchRemoteChanges: fetchRemote,
    pushLocalChanges: pushLocal,
    loadConfig: () => const SupabaseConfigService().loadConfig(),
  );

  ref.onDispose(controller.dispose);

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
  final activeUserAsync = ref.watch(activeUserProvider);

  return activeUserAsync.when<Stream<List<Book>>>(
    data: (user) {
      if (user == null) {
        return Stream.value(const <Book>[]);
      }
      return repository.watchAll(ownerUserId: user.id);
    },
    loading: () => Stream.value(const <Book>[]),
    error: (_, __) => Stream.value(const <Book>[]),
  );
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
  final notificationRepository = ref.watch(notificationRepositoryProvider);
  return LoanController(
    loanRepository: repository,
    groupSyncController: syncController,
    notificationClient: notificationClient,
    notificationRepository: notificationRepository,
  );
});

final groupPushControllerProvider =
    StateNotifierProvider<GroupPushController, GroupActionState>((ref) {
  final repository = ref.watch(groupPushRepositoryProvider);
  final syncController = ref.watch(groupSyncControllerProvider.notifier);
  final notificationClient = ref.watch(notificationServiceProvider);
  final bookRepository = ref.watch(bookRepositoryProvider);
  final groupDao = ref.watch(groupDaoProvider);
  return GroupPushController(
    groupPushRepository: repository,
    groupSyncController: syncController,
    notificationClient: notificationClient,
    bookRepository: bookRepository,
    groupDao: groupDao,
  );
});
