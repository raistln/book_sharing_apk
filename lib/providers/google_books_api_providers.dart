import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/google_books_api_controller.dart';

/// Provider for Google Books API key
final googleBooksApiKeyProvider = StateProvider<String?>((ref) => null);

/// Provider for managing Google Books API key operations
class GoogleBooksApiKeyController extends StateNotifier<String?> {
  static const String _apiKeyKey = 'google_books_api_key';

  GoogleBooksApiKeyController() : super(null) {
    _loadApiKey();
  }

  /// Load API key from SharedPreferences
  Future<void> _loadApiKey() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final apiKey = prefs.getString(_apiKeyKey);
      state = apiKey;
    } catch (e) {
      // Handle error silently or log it
      state = null;
    }
  }

  /// Save API key to SharedPreferences
  Future<void> saveApiKey(String apiKey) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (apiKey.isEmpty) {
        await prefs.remove(_apiKeyKey);
        state = null;
      } else {
        await prefs.setString(_apiKeyKey, apiKey);
        state = apiKey;
      }
    } catch (e) {
      throw Exception('Failed to save API key: $e');
    }
  }

  /// Clear API key
  Future<void> clearApiKey() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_apiKeyKey);
      state = null;
    } catch (e) {
      throw Exception('Failed to clear API key: $e');
    }
  }

  /// Check if API key is configured
  bool get hasApiKey => state != null && state!.isNotEmpty;

  /// Validate current API key
  Future<bool> validateApiKey() async {
    if (!hasApiKey) return false;
    
    try {
      return await GoogleBooksApiController.validateApiKey(state!);
    } catch (e) {
      return false;
    }
  }
}

/// Provider for Google Books API key controller
final googleBooksApiKeyControllerProvider = StateNotifierProvider<GoogleBooksApiKeyController, String?>((ref) {
  return GoogleBooksApiKeyController();
});
