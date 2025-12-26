import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_profile.dart';
import '../services/user_profile_service.dart';

final userProfileServiceProvider = Provider((ref) => UserProfileService());

final userProfileProvider =
    StateNotifierProvider<UserProfileNotifier, AsyncValue<UserProfile>>((ref) {
  final service = ref.watch(userProfileServiceProvider);
  return UserProfileNotifier(service);
});

class UserProfileNotifier extends StateNotifier<AsyncValue<UserProfile>> {
  UserProfileNotifier(this._service) : super(const AsyncValue.loading()) {
    load();
  }

  final UserProfileService _service;

  Future<void> load() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _service.loadProfile());
  }

  Future<void> save(UserProfile profile) async {
    state = AsyncValue.data(profile); // Optimistic update
    try {
      await _service.saveProfile(profile);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}
