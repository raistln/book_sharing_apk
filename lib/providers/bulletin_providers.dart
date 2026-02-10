import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../services/bulletin_service.dart';
import '../services/bulletin_local_service.dart';
import '../models/bulletin.dart';
import 'user_profile_provider.dart';

final bulletinServiceProvider = Provider((ref) => BulletinService());
final bulletinLocalServiceProvider = Provider((ref) => BulletinLocalService());

final latestBulletinProvider =
    FutureProvider.autoDispose<Bulletin?>((ref) async {
  final userProfile = ref.watch(userProfileProvider).value;
  final province = userProfile?.residence;

  if (province == null || province.isEmpty) {
    return null;
  }

  final remoteService = ref.watch(bulletinServiceProvider);
  final localService = ref.watch(bulletinLocalServiceProvider);

  // 1. Try to get from local cache
  final cached = await localService.getCachedBulletin(province);
  final now = DateTime.now();
  final currentPeriod = DateFormat('yyyy-MM').format(now);

  // 2. If cached and period matches current month AND province matches, return cached immediately
  if (cached != null &&
      cached.period == currentPeriod &&
      cached.province == province) {
    return cached;
  }

  // 3. Otherwise (or if cached is old/null), fetch from remote
  try {
    final remote = await remoteService.fetchLatestBulletin(province);
    if (remote != null) {
      // 4. Save to local cache
      await localService.saveBulletin(remote);
      return remote;
    }

    // If remote is null (no bulletin for this month yet)
    // We return the cached one if it exists, even if it's from a previous month,
    // assuming it's the most recent data we have.
    return cached;
  } catch (e) {
    // If fetch fails (network issue), return cached as fallback
    return cached;
  }
});
