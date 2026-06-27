part of '../main.dart';

class ApiService {
  Uri uri(String path, [Map<String, String>? query]) {
    return Uri.parse('$apiBaseUrl$path').replace(queryParameters: query);
  }

  Future<List<Map<String, dynamic>>> list(
    String path, {
    Map<String, String>? query,
  }) async {
    try {
      final res = await http.get(uri(path, query));
      if (res.statusCode >= 400) {
        throw Exception('ডাটা লোড করতে সমস্যা হয়েছে');
      }
      final decoded = jsonDecode(utf8.decode(res.bodyBytes));
      final rawList = decoded is List
          ? decoded
          : (decoded['results'] as List? ?? []);
      final items = rawList.cast<Map<String, dynamic>>();
      if (_usesCreatedOrder(path)) {
        items.sort((a, b) => intValue(b['id']).compareTo(intValue(a['id'])));
      }
      return items;
    } catch (_) {
      throw Exception(
        'সার্ভারের সাথে সংযোগ করা যাচ্ছে না। ইন্টারনেট বা API ঠিকানা পরীক্ষা করুন।',
      );
    }
  }

  Future<Map<String, dynamic>> detail(String path) async {
    try {
      final res = await http.get(uri(path));
      if (res.statusCode >= 400) {
        throw Exception('তথ্য পাওয়া যায়নি');
      }
      return jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;
    } catch (_) {
      throw Exception('সার্ভারের সাথে সংযোগ করা যাচ্ছে না।');
    }
  }

  String mediaUrl(String? path) {
    if (path == null || path.isEmpty) return '';
    final root = apiBaseUrl.replaceFirst('/api', '');
    if (path.startsWith('http')) {
      return path.replaceFirst('http://localhost:8000', root);
    }
    return path.startsWith('/') ? '$root$path' : '$root/$path';
  }
  Future<void> registerDeviceToken(String token) async {
    try {
      await http.post(
        uri('/core/register-device/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'token': token, 'platform': 'android'}),
      );
    } catch (e) {
      debugPrint('Failed to register FCM token to backend: $e');
    }
  }
}

bool _usesCreatedOrder(String path) {
  return path == '/madrasha/list/' ||
      path == '/khankah/list/' ||
      path == '/events/list/';
}

final api = ApiService();
