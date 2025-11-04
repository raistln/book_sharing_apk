import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/google_books_api_service.dart';
import '../services/google_books_client.dart';
import '../services/open_library_client.dart';

final googleBooksApiServiceProvider = Provider<GoogleBooksApiService>((ref) {
  return GoogleBooksApiService();
});

final googleBooksApiKeyProvider = Provider<AsyncValue<String?>>((ref) {
  return ref.watch(googleBooksApiKeyControllerProvider);
});

final openLibraryClientProvider = Provider<OpenLibraryClient>((ref) {
  final client = OpenLibraryClient();
  ref.onDispose(client.close);
  return client;
});

final googleBooksClientProvider = Provider<GoogleBooksClient>((ref) {
  final service = ref.watch(googleBooksApiServiceProvider);
  final client = GoogleBooksClient(apiService: service);
  ref.onDispose(client.close);
  return client;
});

final googleBooksApiKeyControllerProvider =
    AutoDisposeAsyncNotifierProvider<GoogleBooksApiKeyController, String?>(
  GoogleBooksApiKeyController.new,
);

class GoogleBooksApiKeyController extends AutoDisposeAsyncNotifier<String?> {
  GoogleBooksApiService get _service => ref.read(googleBooksApiServiceProvider);

  @override
  Future<String?> build() {
    return _service.readApiKey();
  }

  Future<void> saveApiKey(String apiKey) async {
    state = const AsyncValue.loading();
    try {
      await _service.saveApiKey(apiKey);
      state = AsyncValue.data(apiKey.trim().isEmpty ? null : apiKey.trim());
    } catch (err, stack) {
      state = AsyncValue.error(err, stack);
    }
  }

  Future<void> clearApiKey() async {
    state = const AsyncValue.loading();
    try {
      await _service.clearApiKey();
      state = const AsyncValue.data(null);
    } catch (err, stack) {
      state = AsyncValue.error(err, stack);
    }
  }
}
