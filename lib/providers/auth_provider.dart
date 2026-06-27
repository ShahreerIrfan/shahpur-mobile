part of '../main.dart';

class AuthScope extends InheritedNotifier<AuthStore> {
  const AuthScope({super.key, required AuthStore auth, required super.child})
    : super(notifier: auth);

  static AuthStore of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<AuthScope>()!.notifier!;
  }
}

class AuthStore extends ChangeNotifier {
  String? accessToken;
  String? refreshToken;
  Map<String, dynamic>? profile;
  bool initialized = false;

  bool get isLoggedIn => accessToken != null && accessToken!.isNotEmpty;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    accessToken = prefs.getString('access_token');
    refreshToken = prefs.getString('refresh_token');
    initialized = true;
    notifyListeners();
    if (isLoggedIn) {
      await loadProfile();
    }
  }

  Future<void> login(String email, String password) async {
    final res = await http.post(
      Uri.parse('$apiBaseUrl/auth/login/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'username': email, 'password': password}),
    );
    final data = jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;
    if (res.statusCode >= 400) {
      throw Exception('ইমেইল বা পাসওয়ার্ড ভুল হয়েছে');
    }
    accessToken = data['access'] as String?;
    refreshToken = data['refresh'] as String?;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('access_token', accessToken ?? '');
    await prefs.setString('refresh_token', refreshToken ?? '');
    await prefs.setString('username', '${data['username'] ?? ''}');
    await prefs.setBool('is_admin', data['is_admin'] == true);
    notifyListeners();
    await loadProfile();
  }

  Future<void> register(Map<String, dynamic> payload, String password) async {
    final res = await http.post(
      Uri.parse('$apiBaseUrl/auth/register/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(payload),
    );
    if (res.statusCode >= 400) {
      final data = jsonDecode(utf8.decode(res.bodyBytes));
      throw Exception(_formatApiError(data));
    }
    await login('${payload['email']}', password);
  }

  Future<void> loadProfile() async {
    if (!isLoggedIn) return;
    final res = await http.get(
      Uri.parse('$apiBaseUrl/auth/profile/'),
      headers: {'Authorization': 'Bearer $accessToken'},
    );
    if (res.statusCode == 401) {
      await logout();
      return;
    }
    if (res.statusCode < 400) {
      profile = jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');
    await prefs.remove('refresh_token');
    await prefs.remove('username');
    await prefs.remove('is_admin');
    accessToken = null;
    refreshToken = null;
    profile = null;
    notifyListeners();
  }
}
