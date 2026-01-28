import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/bulletin_service.dart';
import '../models/bulletin.dart';
import 'user_profile_provider.dart';

final bulletinServiceProvider = Provider((ref) => BulletinService());

final latestBulletinProvider =
    FutureProvider.autoDispose<Bulletin?>((ref) async {
  final userProfile = ref.watch(userProfileProvider).value;
  final province = userProfile?.residence;

  if (province == null || province.isEmpty) {
    return null;
  }

  final service = ref.watch(bulletinServiceProvider);
  return service.fetchLatestBulletin(province);
});
