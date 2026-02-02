import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/bulletin.dart';
import 'supabase_config_service.dart';

class BulletinService {
  BulletinService({
    http.Client? client,
    SupabaseConfigService? configService,
  })  : _client = client ?? http.Client(),
        _configService = configService ?? const SupabaseConfigService();

  final http.Client _client;
  final SupabaseConfigService _configService;

  Future<Bulletin?> fetchLatestBulletin(String province) async {
    final config = await _configService.loadConfig();

    final uri = Uri.parse('${config.url}/rest/v1/literary_bulletins').replace(
      queryParameters: {
        'province': 'eq.$province',
        'order': 'period.desc',
        'limit': '1',
      },
    );

    final headers = {
      'apikey': config.anonKey,
      'Authorization': 'Bearer ${config.anonKey}',
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    final response = await _client.get(uri, headers: headers);

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      if (data.isNotEmpty) {
        return Bulletin.fromJson(data.first as Map<String, dynamic>);
      }
      return null;
    } else {
      throw Exception(
          'Error fetching bulletin: ${response.statusCode} ${response.body}');
    }
  }
}
