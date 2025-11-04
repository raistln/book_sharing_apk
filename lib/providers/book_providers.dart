import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/local/book_dao.dart';
import '../data/local/database.dart';
import '../data/repositories/book_repository.dart';
import '../services/cover_image_service.dart';

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
