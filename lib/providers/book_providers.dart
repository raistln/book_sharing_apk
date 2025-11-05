import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/local/book_dao.dart';
import '../data/local/database.dart';
import '../data/local/user_dao.dart';
import '../data/repositories/book_repository.dart';
import '../data/repositories/user_repository.dart';
import '../services/book_export_service.dart';
import '../services/cover_image_service.dart';
import '../services/supabase_config_service.dart';
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

final supabaseUserServiceProvider = Provider<SupabaseUserService>((ref) {
  final service = SupabaseUserService(
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
