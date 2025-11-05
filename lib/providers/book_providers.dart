import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../config/supabase_defaults.dart';
import '../data/local/book_dao.dart';
import '../data/local/database.dart';
import '../data/local/group_dao.dart';
import '../data/local/user_dao.dart';
import '../data/repositories/book_repository.dart';
import '../data/repositories/supabase_group_repository.dart';
import '../data/repositories/user_repository.dart';
import '../services/book_export_service.dart';
import '../services/cover_image_service.dart';
import '../services/group_sync_controller.dart';
import '../services/sync_service.dart';
import '../services/supabase_config_service.dart';
import '../services/supabase_group_service.dart';
import '../services/supabase_user_service.dart';

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

final userDaoProvider = Provider<UserDao>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return UserDao(db);
});

final userRepositoryProvider = Provider<UserRepository>((ref) {
  final dao = ref.watch(userDaoProvider);
  return UserRepository(dao);
});

final activeUserProvider = StreamProvider.autoDispose<LocalUser?>((ref) {
  final repository = ref.watch(userRepositoryProvider);
  return repository.watchActiveUser();
});

final supabaseConfigServiceProvider = Provider<SupabaseConfigService>((ref) {
  return SupabaseConfigService();
});

final supabaseConfigProvider = FutureProvider.autoDispose<SupabaseConfig>((ref) {
  final service = ref.watch(supabaseConfigServiceProvider);
  return service.loadConfig();
});

final supabaseConfigControllerProvider = AutoDisposeAsyncNotifierProvider<
    SupabaseConfigController, SupabaseConfig>(SupabaseConfigController.new);

final supabaseUserServiceProvider = Provider<SupabaseUserService>((ref) {
  final service = SupabaseUserService(
    configService: ref.watch(supabaseConfigServiceProvider),
  );
  ref.onDispose(service.dispose);
  return service;
});

final supabaseGroupServiceProvider = Provider<SupabaseGroupService>((ref) {
  final service = SupabaseGroupService(
    configService: ref.watch(supabaseConfigServiceProvider),
  );
  ref.onDispose(service.dispose);
  return service;
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
  final configService = ref.watch(supabaseConfigServiceProvider);
  return GroupSyncController(
    groupRepository: repository,
    userRepository: userRepository,
    configService: configService,
  );
});

class SupabaseConfigController
    extends AutoDisposeAsyncNotifier<SupabaseConfig> {
  SupabaseConfigService get _service =>
      ref.read(supabaseConfigServiceProvider);

  @override
  Future<SupabaseConfig> build() {
    return _service.loadConfig();
  }

  Future<void> saveConfig({required String url, required String anonKey}) async {
    final trimmedUrl = url.trim();
    final trimmedAnonKey = anonKey.trim();

    if (trimmedUrl.isEmpty || trimmedAnonKey.isEmpty) {
      throw ArgumentError('La URL y la anon key no pueden estar vacías.');
    }

    state = const AsyncValue.loading();
    try {
      final config = SupabaseConfig(url: trimmedUrl, anonKey: trimmedAnonKey);
      await _service.saveConfig(config);
      state = AsyncValue.data(config);
    } catch (err, stack) {
      state = AsyncValue.error(err, stack);
    }
  }

  Future<void> resetToDefaults() async {
    state = const AsyncValue.loading();
    try {
      await _service.clear();
      const config = SupabaseConfig(
        url: kSupabaseDefaultUrl,
        anonKey: kSupabaseDefaultAnonKey,
      );
      state = const AsyncValue.data(config);
    } catch (err, stack) {
      state = AsyncValue.error(err, stack);
    }
  }
}
