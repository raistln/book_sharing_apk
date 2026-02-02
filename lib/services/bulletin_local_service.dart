import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/bulletin.dart';

class BulletinLocalService {
  static const _keyPrefix = 'cached_bulletin_';

  Future<void> saveBulletin(Bulletin bulletin) async {
    final prefs = await SharedPreferences.getInstance();
    final key = '$_keyPrefix${bulletin.province}';
    await prefs.setString(key, jsonEncode(bulletin.toJson()));
  }

  Future<Bulletin?> getCachedBulletin(String province) async {
    final prefs = await SharedPreferences.getInstance();
    final key = '$_keyPrefix$province';
    final jsonString = prefs.getString(key);
    if (jsonString == null) return null;

    try {
      return Bulletin.fromJson(jsonDecode(jsonString));
    } catch (e) {
      return null;
    }
  }

  Future<void> clearCache(String province) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('$_keyPrefix$province');
  }
}
