import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/cover_refresh_service.dart';
import 'api_providers.dart';
import 'book_providers.dart';

final coverRefreshServiceProvider = Provider<CoverRefreshService>((ref) {
  return CoverRefreshService(
    bookRepository: ref.watch(bookRepositoryProvider),
    coverService: ref.watch(coverImageServiceProvider),
    openLibraryClient: ref.watch(openLibraryClientProvider),
    googleBooksClient: ref.watch(googleBooksClientProvider),
  );
});
