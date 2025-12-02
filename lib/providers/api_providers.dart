import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/google_books_api_service.dart';
import '../services/google_books_client.dart';
import '../services/open_library_client.dart';

final googleBooksApiServiceProvider = Provider<GoogleBooksApiService>((ref) {
  return GoogleBooksApiService();
});

final openLibraryClientProvider = Provider<OpenLibraryClient>((ref) {
  final client = OpenLibraryClient();
  ref.onDispose(client.close);
  return client;
});

final googleBooksClientProvider = Provider<GoogleBooksClient>((ref) {
  final service = ref.watch(googleBooksApiServiceProvider);
  final apiKeyState = ref.watch(googleBooksApiKeyControllerProvider);

  final client = GoogleBooksClient(
    apiService: service,
    apiKeyResolver: () async {
      final inMemoryKey = apiKeyState.valueOrNull;
      if (inMemoryKey != null && inMemoryKey.isNotEmpty) {
        return inMemoryKey;
      }
      return service.readApiKey();
    },
  );
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
  Future<String?> build() => _service.readApiKey();

  Future<void> saveApiKey(String apiKey) async {
    final cleanKey = apiKey.trim();
    if (cleanKey.isEmpty) {
      state = AsyncValue.error(
        ArgumentError('La API key no puede estar vacía'),
        StackTrace.current,
      );
      return;
    }

    state = const AsyncValue.loading();
    try {
      await _service.saveApiKey(cleanKey);
      state = AsyncValue.data(cleanKey);
    } catch (err, stack) {
      state = AsyncValue.error(err, stack);
      rethrow;
    }
  }

  Future<void> clearApiKey() async {
    state = const AsyncValue.loading();
    try {
      await _service.clearApiKey();
      state = const AsyncValue.data(null);
    } catch (err, stack) {
      state = AsyncValue.error(err, stack);
      rethrow;
    }
  }
}
