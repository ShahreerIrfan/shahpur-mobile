import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

const apiBaseUrl = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'https://api.shahpurdarbarsharif.org/api',
);

const primary = Color(0xFF009966);
const primaryDark = Color(0xFF064532);
const gold = Color(0xFFF4C95D);
const paper = Color(0xFFF7FBF8);

void main() {
  runApp(const ShahpurApp());
}

class ShahpurApp extends StatefulWidget {
  const ShahpurApp({super.key});

  @override
  State<ShahpurApp> createState() => _ShahpurAppState();
}

class _ShahpurAppState extends State<ShahpurApp> {
  final auth = AuthStore();

  @override
  void initState() {
    super.initState();
    auth.load();
  }

  @override
  Widget build(BuildContext context) {
    return AuthScope(
      auth: auth,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'শাহপুর দরবার শরীফ',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: primary,
            primary: primary,
            secondary: gold,
            surface: Colors.white,
          ),
          scaffoldBackgroundColor: paper,
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.white,
            foregroundColor: primaryDark,
            centerTitle: false,
            elevation: 0,
          ),
          cardTheme: CardThemeData(
            color: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
              side: BorderSide(color: Colors.black.withValues(alpha: .05)),
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: primary, width: 1.5),
            ),
          ),
        ),
        home: const MainShell(),
      ),
    );
  }
}

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
}

bool _usesCreatedOrder(String path) {
  return path == '/madrasha/list/' ||
      path == '/khankah/list/' ||
      path == '/events/list/';
}

final api = ApiService();

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int index = 0;
  final List<int> tabHistory = [];

  final pages = const [
    HomeScreen(),
    ApiArchiveScreen(type: ArchiveType.madrasha),
    ApiArchiveScreen(type: ArchiveType.events),
    ApiArchiveScreen(type: ArchiveType.books),
    AccountScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final titles = ['হোম', 'মাদ্রাসা', 'ইভেন্ট', 'বই', 'অ্যাকাউন্ট'];
    return PopScope(
      canPop: index == 0 && tabHistory.isEmpty,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        setState(() {
          if (tabHistory.isNotEmpty) {
            index = tabHistory.removeLast();
          } else {
            index = 0;
          }
        });
      },
      child: Scaffold(
        appBar: AppBar(
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'শাহপুর দরবার শরীফ',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
              ),
              Text(
                titles[index],
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        drawer: AppDrawer(
          onSelect: _openDrawerPage,
          onTabSelect: _openDrawerTab,
        ),
        body: pages[index],
        bottomNavigationBar: NavigationBar(
          selectedIndex: index,
          onDestinationSelected: _selectTab,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              label: 'হোম',
            ),
            NavigationDestination(
              icon: Icon(Icons.menu_book_outlined),
              label: 'মাদ্রাসা',
            ),
            NavigationDestination(
              icon: Icon(Icons.event_outlined),
              label: 'ইভেন্ট',
            ),
            NavigationDestination(
              icon: Icon(Icons.picture_as_pdf_outlined),
              label: 'বই',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline),
              label: 'আমি',
            ),
          ],
        ),
      ),
    );
  }

  void _selectTab(int value) {
    if (value == index) return;
    setState(() {
      tabHistory.remove(index);
      tabHistory.add(index);
      index = value;
    });
  }

  void _openDrawerPage(Widget page) {
    Navigator.pop(context);
    Navigator.push(context, MaterialPageRoute(builder: (_) => page));
  }

  void _openDrawerTab(int value) {
    Navigator.pop(context);
    _selectTab(value);
  }
}

class AppDrawer extends StatelessWidget {
  const AppDrawer({
    super.key,
    required this.onSelect,
    required this.onTabSelect,
  });

  final void Function(Widget page) onSelect;
  final void Function(int index) onTabSelect;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              color: primaryDark,
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    backgroundColor: primary,
                    radius: 26,
                    child: Text(
                      'শ',
                      style: TextStyle(color: Colors.white, fontSize: 22),
                    ),
                  ),
                  SizedBox(height: 12),
                  Text(
                    'শাহপুর দরবার শরীফ',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    'بِسْمِ اللَّهِ الرَّحْمَنِ الرَّحِيمِ',
                    style: TextStyle(color: gold),
                  ),
                ],
              ),
            ),
            _drawerTabTile(context, Icons.home_outlined, 'হোম', 0),
            _drawerTile(
              context,
              Icons.auto_stories_outlined,
              'জীবনী',
              const BiographyScreen(),
            ),
            _drawerTabTile(context, Icons.menu_book_outlined, 'মাদ্রাসা', 1),
            _drawerTile(
              context,
              Icons.mosque_outlined,
              'খানকাহ',
              const ApiArchiveScreen(type: ArchiveType.khankah),
            ),
            _drawerTabTile(context, Icons.event_outlined, 'ইভেন্ট / মাহফিল', 2),
            _drawerTabTile(
              context,
              Icons.picture_as_pdf_outlined,
              'বই / PDF',
              3,
            ),
            _drawerTile(
              context,
              Icons.volunteer_activism_outlined,
              'সেবা কার্যক্রম',
              const ServicesScreen(),
            ),
            _drawerTile(
              context,
              Icons.photo_library_outlined,
              'গ্যালারি',
              const GalleryScreen(),
            ),
            _drawerTile(
              context,
              Icons.contact_mail_outlined,
              'যোগাযোগ',
              const ContactScreen(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _drawerTile(
    BuildContext context,
    IconData icon,
    String title,
    Widget page,
  ) {
    return ListTile(
      leading: Icon(icon, color: primary),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
      onTap: () => onSelect(page),
    );
  }

  Widget _drawerTabTile(
    BuildContext context,
    IconData icon,
    String title,
    int tabIndex,
  ) {
    return ListTile(
      leading: Icon(icon, color: primary),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
      onTap: () => onTabSelect(tabIndex),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {},
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
        children: [
          const HeroCard(),
          const SizedBox(height: 28),
          const AboutDarbarSection(),
          const SizedBox(height: 22),
          const QuoteBand(),
          const SizedBox(height: 28),
          const ActivitiesSectionMobile(),
          const SizedBox(height: 28),
          const BiographyHighlights(),
          const SizedBox(height: 28),
          const SectionHeader('আসন্ন মাহফিল ও ইভেন্ট'),
          HomePreviewList(
            type: ArchiveType.events,
            query: const {'status': 'upcoming'},
          ),
          const SizedBox(height: 22),
          const SectionHeader('নির্বাচিত বই'),
          HomePreviewList(
            type: ArchiveType.books,
            query: const {'featured': 'true'},
          ),
          const SizedBox(height: 28),
          const TimelineMobile(),
          const SizedBox(height: 28),
          const WrittenBooksMobile(),
        ],
      ),
    );
  }
}

class HeroCard extends StatelessWidget {
  const HeroCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: primary.withValues(alpha: .10),
            blurRadius: 30,
            offset: const Offset(0, 18),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned.fill(
            child: Image.network(
              'https://images.unsplash.com/photo-1591604129939-f1efa4d9f7fa?q=80&w=1200&auto=format',
              fit: BoxFit.cover,
              alignment: Alignment.centerRight,
              errorBuilder: (context, error, stackTrace) => Container(
                color: const Color(0xFFEAF7F1),
                alignment: Alignment.centerRight,
                child: Icon(
                  Icons.mosque_outlined,
                  size: 120,
                  color: primary.withValues(alpha: .18),
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    Color(0xF9FFFFFF),
                    Color(0xEFFFFFFF),
                    Color(0xBFFFFFFF),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: primary.withValues(alpha: .10),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: primary.withValues(alpha: .18)),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.mosque_outlined, color: primary, size: 16),
                      SizedBox(width: 6),
                      Text(
                        'আধ্যাত্মিক সাধনার কেন্দ্র',
                        style: TextStyle(
                          color: primary,
                          fontWeight: FontWeight.w800,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'শাহপুর দরবার\nশরীফ',
                  style: TextStyle(
                    color: Color(0xFF111827),
                    fontSize: 33,
                    fontWeight: FontWeight.w900,
                    height: 1.08,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'কুমিল্লার গোমতী নদী তীরবর্তী ইসলামী শরীয়াতের অনুশীলন, কাদেরীয়া তরিকার প্রচার ও আধ্যাত্মিক সাধনার ঐতিহাসিক কেন্দ্র',
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    fontSize: 14,
                    height: 1.55,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 18),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    HeroActionButton(
                      title: 'বাগদাদী হুজুর (রাঃ) এঁর জীবনী',
                      filled: true,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const BiographyScreen(),
                        ),
                      ),
                    ),
                    HeroActionButton(
                      title: 'মাও. আব্দুস সুবহান (রাঃ)',
                      filled: false,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const BiographyScreen(),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                const Row(
                  children: [
                    HeroStat('৪০+', 'মাদ্রাসা'),
                    SizedBox(width: 14),
                    HeroStat('১৫০+', 'খানকাহ শরীফ'),
                    SizedBox(width: 14),
                    HeroStat('১৭+', 'দেশ সফর'),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class HeroActionButton extends StatelessWidget {
  const HeroActionButton({
    super.key,
    required this.title,
    required this.filled,
    required this.onTap,
  });

  final String title;
  final bool filled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: filled ? primary : Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: filled ? primary : primary.withValues(alpha: .35),
              width: 1.5,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                filled ? Icons.menu_book_outlined : Icons.person_outline,
                size: 15,
                color: filled ? Colors.white : primary,
              ),
              const SizedBox(width: 6),
              Text(
                title,
                style: TextStyle(
                  color: filled ? Colors.white : primaryDark,
                  fontWeight: FontWeight.w900,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class HeroStat extends StatelessWidget {
  const HeroStat(this.value, this.label, {super.key});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: const TextStyle(
                color: primary,
                fontSize: 21,
                fontWeight: FontWeight.w900,
              ),
            ),
            Text(
              label,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 11),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class AboutDarbarSection extends StatelessWidget {
  const AboutDarbarSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader('দরবার শরীফ সম্পর্কে'),
        const Text(
          'বাংলাদেশের সূফি আধ্যাত্মিক ঐতিহ্যের ধারাবাহিকতায় শাহপুর দরবার শরীফ কুরআন-সুন্নাহভিত্তিক শিক্ষা, আত্মশুদ্ধি, মানবসেবা ও ইসলামী জ্ঞান বিস্তারে কাজ করছে।',
          style: TextStyle(color: Color(0xFF4B5563), height: 1.65),
        ),
        const SizedBox(height: 14),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: 1.45,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          children: const [
            MiniInfoCard(
              Icons.mosque_outlined,
              'মসজিদ-মাদ্রাসা',
              'আল্লাহর ঘরের খেদমত',
            ),
            MiniInfoCard(
              Icons.auto_stories_outlined,
              'আধ্যাত্মিক শিক্ষা',
              'তাজকিয়া ও তাসাউফ',
            ),
            MiniInfoCard(
              Icons.school_outlined,
              'মাদ্রাসা',
              'দ্বীনি ও নৈতিক শিক্ষা',
            ),
            MiniInfoCard(Icons.public_outlined, 'বিশ্বব্যাপী', 'দাওয়াত ও সফর'),
          ],
        ),
      ],
    );
  }
}

class MiniInfoCard extends StatelessWidget {
  const MiniInfoCard(this.icon, this.title, this.subtitle, {super.key});

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(13),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: primary, size: 22),
            const Spacer(),
            Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
            Text(
              subtitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}

class QuoteBand extends StatelessWidget {
  const QuoteBand({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: primary,
        borderRadius: BorderRadius.circular(24),
      ),
      child: const Column(
        children: [
          Text(
            'فَادْخُلِي فِي عِبَادِي وَادْخُلِي جَنَّتِي',
            textAlign: TextAlign.center,
            style: TextStyle(color: gold, fontSize: 19, height: 1.8),
          ),
          SizedBox(height: 8),
          Text(
            '“অতএব আমার বান্দাদের মাঝে প্রবেশ কর এবং আমার জান্নাতে প্রবেশ কর।”',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white, height: 1.5),
          ),
          Text(
            'সূরা আল-ফজর: ২৯-৩০',
            style: TextStyle(color: Colors.white70, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class ActivitiesSectionMobile extends StatelessWidget {
  const ActivitiesSectionMobile({super.key});

  @override
  Widget build(BuildContext context) {
    final items = const [
      ActivityCard(
        Icons.menu_book_outlined,
        'মাদ্রাসা শিক্ষা',
        'প্রায় ৪০টি মাদ্রাসায় দ্বীনি ও নৈতিক শিক্ষার আলো ছড়িয়ে দেওয়া হচ্ছে।',
        primary,
      ),
      ActivityCard(
        Icons.favorite,
        'সেবা কার্যক্রম',
        'মানবতার কল্যাণে খাদ্য, চিকিৎসা ও সহায়তামূলক কার্যক্রম পরিচালিত হয়।',
        Color(0xFFE91E63),
      ),
      ActivityCard(
        Icons.public,
        'আন্তর্জাতিক দাওয়াত',
        'দেশ-বিদেশে ইসলামী দাওয়াত ও আধ্যাত্মিক বার্তা পৌঁছে দেওয়া হয়।',
        Color(0xFF536DFE),
      ),
      ActivityCard(
        Icons.payments_outlined,
        'খানকাহ ফান্ড',
        'দরবার ও খানকাহ কার্যক্রম পরিচালনার জন্য সহায়তা গ্রহণ করা হয়।',
        Color(0xFF7C3AED),
      ),
      ActivityCard(
        Icons.group_outlined,
        'শিক্ষা-দীক্ষা',
        'আধ্যাত্মিক প্রশিক্ষণ ও ইসলামী শিক্ষার প্রসারে নিয়মিত কাজ।',
        Color(0xFFF97316),
      ),
      ActivityCard(
        Icons.handshake_outlined,
        'কুরবানি ও ইফতার',
        'রমজান ও কুরবানির সময় দরিদ্র মানুষের পাশে দাঁড়ানো হয়।',
        Color(0xFF0EA5E9),
      ),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Center(
          child: Column(
            children: [
              Text(
                'আমাদের কার্যক্রম',
                style: TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF111827),
                ),
              ),
              SizedBox(height: 6),
              Text(
                'শাহপুর দরবার শরীফের দ্বীনি ও সামাজিক কার্যক্রম',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        ...items,
      ],
    );
  }
}

class ActivityCard extends StatelessWidget {
  const ActivityCard(
    this.icon,
    this.title,
    this.subtitle,
    this.color, {
    super.key,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: color.withValues(alpha: .12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    subtitle,
                    style: TextStyle(color: Colors.grey.shade600, height: 1.45),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class BiographyHighlights extends StatelessWidget {
  const BiographyHighlights({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader('মহান সাধকগণ'),
        InfoCard(
          'আল্লামা ড. আহমদ পেয়ারা বাগদাদী (রাঃ)',
          'কুরআন, বিজ্ঞান ও আধ্যাত্মিকতার আলোকে দ্বীনের খেদমতে নিবেদিত আন্তর্জাতিক ইসলাম প্রচারক।',
        ),
        InfoCard(
          'হযরত মাওলানা আব্দুস সুবহান আল-কাদেরী (রাঃ)',
          'শাহপুর দরবার শরীফের প্রতিষ্ঠাতা শায়খুল কুররা, গাউছে জামান।',
        ),
      ],
    );
  }
}

class TimelineMobile extends StatelessWidget {
  const TimelineMobile({super.key});

  @override
  Widget build(BuildContext context) {
    final items = const [
      'শাহপুর দরবার শরীফের আধ্যাত্মিক যাত্রার সূচনা',
      'মাদ্রাসা ও খানকাহ কার্যক্রমের বিস্তার',
      'দেশ-বিদেশে দ্বীনি দাওয়াত ও সফর',
      'বই, মাহফিল ও সেবা কার্যক্রমের সম্প্রসারণ',
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader('ঐতিহাসিক মাইলফলক'),
        for (var i = 0; i < items.length; i++)
          TimelineRow(index: i + 1, title: items[i]),
      ],
    );
  }
}

class TimelineRow extends StatelessWidget {
  const TimelineRow({super.key, required this.index, required this.title});

  final int index;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            CircleAvatar(
              radius: 13,
              backgroundColor: primary,
              child: Text(
                '$index',
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
            Container(
              width: 2,
              height: 40,
              color: primary.withValues(alpha: .2),
            ),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class WrittenBooksMobile extends StatelessWidget {
  const WrittenBooksMobile({super.key});

  @override
  Widget build(BuildContext context) {
    final books = const [
      'Five Pillars of Islam',
      'Light Upon Light',
      'Marriage of Muhammad (ﷺ)',
      'Prophet’s Love',
      'Heart & Soul',
      'ইসলাম (ﷺ) চিরন্তন',
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader('রচিত গ্রন্থসমূহ'),
        for (var i = 0; i < books.length; i++)
          Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              dense: true,
              leading: CircleAvatar(
                radius: 14,
                backgroundColor: primary,
                child: Text(
                  '${i + 1}',
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
              title: Text(
                books[i],
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
              trailing: const Icon(Icons.menu_book_outlined, color: primary),
            ),
          ),
      ],
    );
  }
}

class FeatureButton extends StatelessWidget {
  const FeatureButton(this.title, this.icon, this.onTap, {super.key});

  final String title;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: (MediaQuery.sizeOf(context).width - 44) / 2,
      child: Card(
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: primary.withValues(alpha: .1),
                  child: Icon(icon, color: primary),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class SectionHeader extends StatelessWidget {
  const SectionHeader(this.title, {super.key});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w900,
          color: primaryDark,
        ),
      ),
    );
  }
}

enum ArchiveType { madrasha, khankah, events, books }

extension ArchiveConfig on ArchiveType {
  String get title {
    switch (this) {
      case ArchiveType.madrasha:
        return 'মাদ্রাসা সমূহ';
      case ArchiveType.khankah:
        return 'খানকাহ সমূহ';
      case ArchiveType.events:
        return 'ইভেন্ট / মাহফিল';
      case ArchiveType.books:
        return 'বই ও PDF লাইব্রেরি';
    }
  }

  String get endpoint {
    switch (this) {
      case ArchiveType.madrasha:
        return '/madrasha/list/';
      case ArchiveType.khankah:
        return '/khankah/list/';
      case ArchiveType.events:
        return '/events/list/';
      case ArchiveType.books:
        return '/books/list/';
    }
  }

  String get titleKey {
    switch (this) {
      case ArchiveType.madrasha:
        return 'madrasha_name';
      case ArchiveType.khankah:
        return 'khankah_name';
      case ArchiveType.events:
      case ArchiveType.books:
        return 'title';
    }
  }

  String get imageKey {
    switch (this) {
      case ArchiveType.madrasha:
      case ArchiveType.khankah:
        return 'featured_image';
      case ArchiveType.events:
        return 'poster';
      case ArchiveType.books:
        return 'cover_image';
    }
  }

  IconData get icon {
    switch (this) {
      case ArchiveType.madrasha:
        return Icons.menu_book_outlined;
      case ArchiveType.khankah:
        return Icons.mosque_outlined;
      case ArchiveType.events:
        return Icons.event_outlined;
      case ArchiveType.books:
        return Icons.picture_as_pdf_outlined;
    }
  }
}

class HomePreviewList extends StatelessWidget {
  const HomePreviewList({super.key, required this.type, this.query});

  final ArchiveType type;
  final Map<String, String>? query;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: api.list(type.endpoint, query: query),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const LoadingBox();
        }
        final items = (snapshot.data ?? []).take(4).toList();
        if (items.isEmpty) return const EmptyBox('এখনো কোনো তথ্য নেই');
        return Column(
          children: [
            for (final item in items)
              ContentTile(
                item: item,
                type: type,
                dense: true,
                onTap: () => openDetail(context, type, item),
              ),
          ],
        );
      },
    );
  }
}

class ApiArchiveScreen extends StatefulWidget {
  const ApiArchiveScreen({super.key, required this.type});

  final ArchiveType type;

  @override
  State<ApiArchiveScreen> createState() => _ApiArchiveScreenState();
}

class _ApiArchiveScreenState extends State<ApiArchiveScreen> {
  String search = '';

  @override
  Widget build(BuildContext context) {
    final query = widget.type == ArchiveType.books && search.trim().isNotEmpty
        ? {'search': search.trim()}
        : null;
    return Scaffold(
      appBar: Navigator.canPop(context)
          ? AppBar(title: Text(widget.type.title))
          : null,
      body: RefreshIndicator(
        onRefresh: () async => setState(() {}),
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: api.list(widget.type.endpoint, query: query),
          builder: (context, snapshot) {
            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (widget.type == ArchiveType.madrasha) ...[
                  const PatternPageHero(
                    title: 'মাদ্রাসা সমূহ',
                    subtitle: 'শাহপুর দরবার শরীফ কর্তৃক পরিচালিত মাদ্রাসা সমূহ',
                  ),
                  const SizedBox(height: 14),
                  const BreadcrumbPill(items: ['হোম', 'মাদ্রাসা সমূহ']),
                ] else
                  PageIntro(title: widget.type.title, icon: widget.type.icon),
                if (widget.type == ArchiveType.books) ...[
                  const SizedBox(height: 12),
                  TextField(
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.search),
                      hintText: 'বই বা লেখক খুঁজুন',
                    ),
                    onSubmitted: (value) => setState(() => search = value),
                  ),
                ],
                const SizedBox(height: 14),
                if (snapshot.connectionState == ConnectionState.waiting)
                  const LoadingBox()
                else if (snapshot.hasError)
                  ErrorBox('${snapshot.error}')
                else if ((snapshot.data ?? []).isEmpty)
                  const EmptyBox('কোনো তথ্য পাওয়া যায়নি')
                else
                  for (final item in snapshot.data!)
                    ContentTile(
                      item: item,
                      type: widget.type,
                      onTap: () => openDetail(context, widget.type, item),
                    ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class PageIntro extends StatelessWidget {
  const PageIntro({super.key, required this.title, required this.icon});

  final String title;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: primary.withValues(alpha: .12)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: primary.withValues(alpha: .1),
            child: Icon(icon, color: primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
            ),
          ),
        ],
      ),
    );
  }
}

class PatternPageHero extends StatelessWidget {
  const PatternPageHero({
    super.key,
    required this.title,
    required this.subtitle,
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 34),
      decoration: BoxDecoration(
        color: const Color(0xFFF1FFF9),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: primary.withValues(alpha: .10)),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: Opacity(
              opacity: .06,
              child: CustomPaint(painter: PatternPainter()),
            ),
          ),
          Column(
            children: [
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 27,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF111827),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: primaryDark,
                  fontWeight: FontWeight.w800,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class PatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = primary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    const step = 42.0;
    for (double y = -step; y < size.height + step; y += step) {
      for (double x = -step; x < size.width + step; x += step) {
        final path = Path()
          ..moveTo(x + step / 2, y)
          ..lineTo(x + step, y + step / 2)
          ..lineTo(x + step / 2, y + step)
          ..lineTo(x, y + step / 2)
          ..close();
        canvas.drawPath(path, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class BreadcrumbPill extends StatelessWidget {
  const BreadcrumbPill({super.key, required this.items});

  final List<String> items;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.black.withValues(alpha: .06)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.home, color: primary, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              items.join('  ›  '),
              style: const TextStyle(
                color: primaryDark,
                fontWeight: FontWeight.w800,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ContentTile extends StatelessWidget {
  const ContentTile({
    super.key,
    required this.item,
    required this.type,
    required this.onTap,
    this.dense = false,
  });

  final Map<String, dynamic> item;
  final ArchiveType type;
  final VoidCallback onTap;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    if (!dense &&
        (type == ArchiveType.madrasha || type == ArchiveType.khankah)) {
      return InstitutionArchiveCard(item: item, type: type, onTap: onTap);
    }

    final title = text(item, type.titleKey, fallback: 'শিরোনাম নেই');
    final image = api.mediaUrl(text(item, type.imageKey));
    final subtitle = _subtitle(item, type);
    return Card(
      margin: EdgeInsets.only(bottom: dense ? 8 : 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.all(dense ? 10 : 12),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: image.isEmpty
                    ? Container(
                        width: 74,
                        height: 74,
                        color: primary.withValues(alpha: .08),
                        child: Icon(type.icon, color: primary),
                      )
                    : CachedNetworkImage(
                        imageUrl: image,
                        width: 74,
                        height: 74,
                        fit: BoxFit.cover,
                        errorWidget: (context, url, error) => Container(
                          width: 74,
                          height: 74,
                          color: primary.withValues(alpha: .08),
                          child: Icon(type.icon, color: primary),
                        ),
                      ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: primary),
            ],
          ),
        ),
      ),
    );
  }

  String _subtitle(Map<String, dynamic> item, ArchiveType type) {
    switch (type) {
      case ArchiveType.madrasha:
        return [
          text(item, 'district_name'),
          text(item, 'upazila_name'),
          text(item, 'madrasha_description'),
        ].where((value) => value.isNotEmpty).join(' • ');
      case ArchiveType.khankah:
        return [
          text(item, 'district_name'),
          text(item, 'upazila_name'),
          text(item, 'khankah_description'),
        ].where((value) => value.isNotEmpty).join(' • ');
      case ArchiveType.events:
        return [
          text(item, 'category_display'),
          text(item, 'status_display'),
          text(item, 'venue_name'),
        ].where((value) => value.isNotEmpty).join(' • ');
      case ArchiveType.books:
        return [
          text(item, 'author_name', fallback: 'লেখক উল্লেখ নেই'),
          text(item, 'category_display'),
          text(item, 'language_display'),
        ].where((value) => value.isNotEmpty).join(' • ');
    }
  }
}

class InstitutionArchiveCard extends StatelessWidget {
  const InstitutionArchiveCard({
    super.key,
    required this.item,
    required this.type,
    required this.onTap,
  });

  final Map<String, dynamic> item;
  final ArchiveType type;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final image = api.mediaUrl(text(item, type.imageKey));
    final title = text(item, type.titleKey, fallback: 'শিরোনাম নেই');
    final description = type == ArchiveType.madrasha
        ? text(item, 'madrasha_description')
        : text(item, 'khankah_description');
    final address = [
      text(item, 'village'),
      text(item, 'district_name'),
      text(item, 'upazila_name'),
    ].where((value) => value.isNotEmpty).join(', ');
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                image.isEmpty
                    ? Container(
                        height: 178,
                        width: double.infinity,
                        color: primary.withValues(alpha: .08),
                        child: Icon(type.icon, size: 54, color: primary),
                      )
                    : CachedNetworkImage(
                        imageUrl: image,
                        height: 178,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                Positioned(
                  left: 14,
                  top: 14,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 11,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: .92),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      _chipLabel(item, type),
                      style: const TextStyle(
                        color: primary,
                        fontWeight: FontWeight.w900,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF111827),
                    ),
                  ),
                  const SizedBox(height: 10),
                  if (type == ArchiveType.madrasha)
                    Wrap(
                      spacing: 12,
                      runSpacing: 8,
                      children: [
                        InlineMeta(
                          Icons.person_outline,
                          '${text(item, 'number_of_teachers', fallback: '0')} শিক্ষক',
                        ),
                        InlineMeta(
                          Icons.groups_outlined,
                          '${text(item, 'number_of_students', fallback: '0')} শিক্ষার্থী',
                        ),
                        InlineMeta(
                          Icons.calendar_month_outlined,
                          '${text(item, 'year_of_establishment')} সন',
                        ),
                      ],
                    )
                  else
                    Wrap(
                      spacing: 12,
                      runSpacing: 8,
                      children: [
                        InlineMeta(
                          Icons.account_circle_outlined,
                          text(
                            item,
                            'director_name',
                            fallback: 'পরিচালক উল্লেখ নেই',
                          ),
                        ),
                        InlineMeta(
                          Icons.location_on_outlined,
                          text(
                            item,
                            'district_name',
                            fallback: 'জেলা উল্লেখ নেই',
                          ),
                        ),
                      ],
                    ),
                  const SizedBox(height: 12),
                  Text(
                    description,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: Colors.grey.shade700, height: 1.55),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        size: 17,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          address.isEmpty ? 'ঠিকানা উল্লেখ নেই' : address,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      const Text(
                        'বিস্তারিত দেখুন →',
                        style: TextStyle(
                          color: primary,
                          fontWeight: FontWeight.w900,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _chipLabel(Map<String, dynamic> item, ArchiveType type) {
    if (type == ArchiveType.madrasha) {
      final raw = text(item, 'type_of_madrasha');
      switch (raw) {
        case 'nurani':
          return 'নূরানী';
        case 'hifz':
          return 'হিফজ';
        case 'najera':
          return 'নাজেরা';
        case 'academic':
          return 'একাডেমিক';
      }
      return raw.isEmpty ? 'মাদ্রাসা' : raw;
    }
    return 'খানকাহ';
  }
}

class InlineMeta extends StatelessWidget {
  const InlineMeta(this.icon, this.label, {super.key});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 15, color: primary),
        const SizedBox(width: 4),
        Text(
          label.isEmpty ? 'উল্লেখ নেই' : label,
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF4B5563),
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

void openDetail(
  BuildContext context,
  ArchiveType type,
  Map<String, dynamic> item,
) {
  final id = item['id'];
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => DetailScreen(type: type, id: id),
    ),
  );
}

class DetailScreen extends StatelessWidget {
  const DetailScreen({super.key, required this.type, required this.id});

  final ArchiveType type;
  final dynamic id;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(type.title)),
      body: FutureBuilder<Map<String, dynamic>>(
        future: api.detail('${type.endpoint}$id/'),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || !snapshot.hasData) {
            return ErrorBox('${snapshot.error ?? 'তথ্য পাওয়া যায়নি'}');
          }
          final item = snapshot.data!;
          if (type == ArchiveType.madrasha) {
            return MadrashaDetailBody(item: item);
          }
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              DetailHero(item: item, type: type),
              const SizedBox(height: 14),
              ..._detailSections(context, item, type),
            ],
          );
        },
      ),
    );
  }

  List<Widget> _detailSections(
    BuildContext context,
    Map<String, dynamic> item,
    ArchiveType type,
  ) {
    switch (type) {
      case ArchiveType.madrasha:
        return [
          InfoCard(
            'পরিচিতি',
            text(
              item,
              'madrasha_description',
              fallback: 'বর্ণনা যোগ করা হয়নি',
            ),
          ),
          InfoGrid([
            InfoItem('শিক্ষক', text(item, 'number_of_teachers')),
            InfoItem('শিক্ষার্থী', text(item, 'number_of_students')),
            InfoItem('প্রতিষ্ঠা', text(item, 'year_of_establishment')),
            InfoItem('ধরণ', madrashaTypeLabel(text(item, 'type_of_madrasha'))),
            InfoItem(
              'শিক্ষার মাধ্যম',
              mediumLabel(text(item, 'medium_of_instruction')),
            ),
            InfoItem('প্রতিষ্ঠাতা', text(item, 'founder_of_madrasha')),
            InfoItem('জেলা', text(item, 'district_name')),
            InfoItem('উপজেলা', text(item, 'upazila_name')),
          ]),
          InfoCard(
            'ঠিকানা',
            [
              text(item, 'full_address_madrsha'),
              text(item, 'village'),
              text(item, 'union_parishad'),
              text(item, 'post_office'),
              text(item, 'district_name'),
              text(item, 'upazila_name'),
            ].where((value) => value.isNotEmpty).join(', '),
          ),
          CommitteeCard(
            title: 'পরিচালনা কমিটি',
            people: [
              InfoItem('সভাপতি', text(item, 'president')),
              InfoItem('সেক্রেটারি', text(item, 'secretary')),
              InfoItem('সহ-সভাপতি', text(item, 'vice_president')),
              InfoItem('কেশিয়ার', text(item, 'treasurer')),
              InfoItem('পাঠ্যক্রম পরিচালক', text(item, 'curriculum_director')),
              InfoItem(
                'মিডিয়া কর্মকর্তা',
                text(item, 'public_relations_officer'),
              ),
              InfoItem('আইটি পরিচালক', text(item, 'technology_it_director')),
            ],
          ),
          TeacherList(teachers: listOfMaps(item['teachers'])),
          PhotoStrip(photos: listOfMaps(item['photos'])),
        ];
      case ArchiveType.khankah:
        return [
          InfoCard(
            'পরিচিতি',
            text(item, 'khankah_description', fallback: 'বর্ণনা যোগ করা হয়নি'),
          ),
          InfoGrid([
            InfoItem('পরিচালক', text(item, 'director_name')),
            InfoItem('ফোন', text(item, 'director_phone')),
            InfoItem('গ্রাম', text(item, 'village')),
            InfoItem('ইউনিয়ন', text(item, 'union')),
            InfoItem('জেলা', text(item, 'district_name')),
            InfoItem('উপজেলা', text(item, 'upazila_name')),
          ]),
          InfoCard(
            'ঠিকানা',
            [
              text(item, 'full_address'),
              text(item, 'village'),
              text(item, 'ward'),
              text(item, 'union'),
              text(item, 'district_name'),
              text(item, 'upazila_name'),
            ].where((value) => value.isNotEmpty).join(', '),
          ),
          CommitteeCard(
            title: 'খানকাহ পরিচালনা',
            people: [
              InfoItem('পরিচালক', text(item, 'director_name')),
              InfoItem('সভাপতি', text(item, 'president_name')),
              InfoItem('সহ-সভাপতি', text(item, 'vice_president_name')),
              InfoItem('সেক্রেটারি', text(item, 'secretary_name')),
              InfoItem('ক্যাশিয়ার', text(item, 'cashier_name')),
            ],
          ),
          PhotoStrip(photos: listOfMaps(item['photos'])),
        ];
      case ArchiveType.events:
        return [
          InfoCard(
            'ইভেন্ট পরিচিতি',
            text(
              item,
              'description',
              fallback: text(item, 'short_description'),
            ),
          ),
          InfoGrid([
            InfoItem('তারিখ', text(item, 'start_date')),
            InfoItem('হিজরি', text(item, 'hijri_date')),
            InfoItem(
              'সময়',
              '${text(item, 'start_time')} - ${text(item, 'end_time')}',
            ),
            InfoItem('স্থান', text(item, 'venue_name')),
            InfoItem('জেলা', text(item, 'district_name')),
            InfoItem('অবস্থা', text(item, 'status_display')),
          ]),
          ScheduleList(items: listOfMaps(item['schedule'])),
          PhotoStrip(photos: listOfMaps(item['photos'])),
        ];
      case ArchiveType.books:
        return [
          InfoCard(
            'বই পরিচিতি',
            text(
              item,
              'description',
              fallback: text(item, 'short_description'),
            ),
          ),
          InfoGrid([
            InfoItem('লেখক', text(item, 'author_name')),
            InfoItem('ক্যাটাগরি', text(item, 'category_display')),
            InfoItem('ভাষা', text(item, 'language_display')),
            InfoItem('পৃষ্ঠা', text(item, 'pages')),
            InfoItem('প্রকাশক', text(item, 'publisher')),
            InfoItem('ডাউনলোড', text(item, 'download_count')),
          ]),
          FilledButton.icon(
            onPressed: () => openPdf(context, item),
            icon: const Icon(Icons.picture_as_pdf_outlined),
            label: const Text('PDF খুলুন / পড়ুন'),
          ),
        ];
    }
  }

  Future<void> openPdf(BuildContext context, Map<String, dynamic> item) async {
    final url = api.mediaUrl(text(item, 'pdf_file'));
    if (url.isEmpty) return;
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => MobilePdfReaderScreen(item: item)),
    );
  }
}

enum MobileReaderTone { light, sepia, dark }

class MobilePdfReaderScreen extends StatefulWidget {
  const MobilePdfReaderScreen({super.key, required this.item});

  final Map<String, dynamic> item;

  @override
  State<MobilePdfReaderScreen> createState() => _MobilePdfReaderScreenState();
}

class _MobilePdfReaderScreenState extends State<MobilePdfReaderScreen> {
  final controller = PdfViewerController();
  final searchController = TextEditingController();
  PdfTextSearchResult? searchResult;
  MobileReaderTone tone = MobileReaderTone.light;
  PdfPageLayoutMode layoutMode = PdfPageLayoutMode.single;
  int page = 1;
  int pageCount = 0;
  bool favorite = false;
  List<int> bookmarks = [];
  bool loadingProgress = true;

  String get url => api.mediaUrl(text(widget.item, 'pdf_file'));
  String get title => text(widget.item, 'title', fallback: 'বই রিডার');
  String get storageKey => 'mobile-reader:${url.hashCode}';

  @override
  void initState() {
    super.initState();
    loadSavedState();
  }

  @override
  void dispose() {
    searchController.dispose();
    searchResult?.removeListener(updateSearchState);
    super.dispose();
  }

  Future<void> loadSavedState() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      page = prefs.getInt('$storageKey:page') ?? 1;
      favorite = prefs.getBool('$storageKey:favorite') ?? false;
      bookmarks = (prefs.getStringList('$storageKey:bookmarks') ?? [])
          .map((value) => int.tryParse(value) ?? 0)
          .where((value) => value > 0)
          .toList();
      loadingProgress = false;
    });
  }

  Future<void> savePage(int value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('$storageKey:page', value);
    await prefs.setString(
      '$storageKey:progress',
      '$title|$value|$pageCount|${DateTime.now().millisecondsSinceEpoch}',
    );
  }

  Future<void> saveBookmarks() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      '$storageKey:bookmarks',
      bookmarks.map((value) => '$value').toList(),
    );
  }

  Future<void> toggleFavorite() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() => favorite = !favorite);
    await prefs.setBool('$storageKey:favorite', favorite);
  }

  Future<void> toggleBookmark() async {
    setState(() {
      if (bookmarks.contains(page)) {
        bookmarks.remove(page);
      } else {
        bookmarks.add(page);
        bookmarks.sort();
      }
    });
    await saveBookmarks();
  }

  void updateSearchState() {
    if (mounted) setState(() {});
  }

  void runSearch() {
    final query = searchController.text.trim();
    if (query.isEmpty) return;
    searchResult?.removeListener(updateSearchState);
    searchResult = controller.searchText(query);
    searchResult?.addListener(updateSearchState);
    setState(() {});
  }

  void jumpToPage(int value) {
    final nextPage = value.clamp(1, pageCount == 0 ? 1 : pageCount);
    controller.jumpToPage(nextPage);
    setState(() => page = nextPage);
    savePage(nextPage);
  }

  Color get backgroundColor {
    switch (tone) {
      case MobileReaderTone.light:
        return const Color(0xFFF4F7F5);
      case MobileReaderTone.sepia:
        return const Color(0xFFF1E4C7);
      case MobileReaderTone.dark:
        return const Color(0xFF111827);
    }
  }

  @override
  Widget build(BuildContext context) {
    final reader = SfPdfViewer.network(
      url,
      controller: controller,
      pageLayoutMode: layoutMode,
      canShowScrollHead: true,
      canShowScrollStatus: true,
      enableDoubleTapZooming: true,
      onDocumentLoaded: (details) {
        final count = details.document.pages.count;
        setState(() => pageCount = count);
        if (!loadingProgress && page > 1) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            controller.jumpToPage(page.clamp(1, count));
          });
        }
      },
      onPageChanged: (details) {
        setState(() => page = details.newPageNumber);
        savePage(details.newPageNumber);
      },
    );

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis),
        actions: [
          IconButton(
            onPressed: toggleBookmark,
            icon: Icon(
              bookmarks.contains(page) ? Icons.bookmark : Icons.bookmark_border,
            ),
          ),
          IconButton(
            onPressed: toggleFavorite,
            icon: Icon(favorite ? Icons.star : Icons.star_border),
          ),
          IconButton(onPressed: showReaderTools, icon: const Icon(Icons.tune)),
        ],
      ),
      body: Column(
        children: [
          LinearProgressIndicator(
            value: pageCount == 0 ? null : page / pageCount,
            color: primary,
            backgroundColor: primary.withValues(alpha: .12),
          ),
          Expanded(
            child: ColoredBox(color: backgroundColor, child: reader),
          ),
        ],
      ),
    );
  }

  void showReaderTools() {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final progress = pageCount == 0
                ? 0
                : ((page / pageCount) * 100).round();
            return SafeArea(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  16,
                  0,
                  16,
                  16 + MediaQuery.viewInsetsOf(context).bottom,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        IconButton.filledTonal(
                          onPressed: page > 1
                              ? () {
                                  jumpToPage(page - 1);
                                  setSheetState(() {});
                                }
                              : null,
                          icon: const Icon(Icons.chevron_left),
                        ),
                        Expanded(
                          child: Column(
                            children: [
                              Text(
                                'পৃষ্ঠা $page / ${pageCount == 0 ? "..." : pageCount}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              Text(
                                '$progress% সম্পন্ন',
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton.filledTonal(
                          onPressed: pageCount == 0 || page >= pageCount
                              ? null
                              : () {
                                  jumpToPage(page + 1);
                                  setSheetState(() {});
                                },
                          icon: const Icon(Icons.chevron_right),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    SegmentedButton<MobileReaderTone>(
                      selected: {tone},
                      showSelectedIcon: false,
                      segments: const [
                        ButtonSegment(
                          value: MobileReaderTone.light,
                          label: Text('Light'),
                        ),
                        ButtonSegment(
                          value: MobileReaderTone.sepia,
                          label: Text('Sepia'),
                        ),
                        ButtonSegment(
                          value: MobileReaderTone.dark,
                          label: Text('Dark'),
                        ),
                      ],
                      onSelectionChanged: (value) {
                        setState(() => tone = value.first);
                        setSheetState(() {});
                      },
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: searchController,
                            decoration: InputDecoration(
                              hintText: 'PDF সার্চ করুন',
                              isDense: true,
                              prefixIcon: const Icon(Icons.search),
                              suffixIcon: IconButton(
                                onPressed: runSearch,
                                icon: const Icon(Icons.arrow_forward),
                              ),
                            ),
                            onSubmitted: (_) => runSearch(),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton.filledTonal(
                          tooltip: 'আগের ফলাফল',
                          onPressed: searchResult == null
                              ? null
                              : () => searchResult!.previousInstance(),
                          icon: const Icon(Icons.keyboard_arrow_up),
                        ),
                        IconButton.filledTonal(
                          tooltip: 'পরের ফলাফল',
                          onPressed: searchResult == null
                              ? null
                              : () => searchResult!.nextInstance(),
                          icon: const Icon(Icons.keyboard_arrow_down),
                        ),
                      ],
                    ),
                    if (searchResult != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text(
                          'সার্চ ফলাফল: ${searchResult!.currentInstanceIndex}/${searchResult!.totalInstanceCount}',
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: showBookmarks,
                            icon: const Icon(Icons.bookmarks_outlined),
                            label: Text('বুকমার্ক (${bookmarks.length})'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              setState(() {
                                layoutMode =
                                    layoutMode == PdfPageLayoutMode.single
                                    ? PdfPageLayoutMode.continuous
                                    : PdfPageLayoutMode.single;
                              });
                              setSheetState(() {});
                            },
                            icon: const Icon(Icons.view_day_outlined),
                            label: Text(
                              layoutMode == PdfPageLayoutMode.single
                                  ? 'Single'
                                  : 'Scroll',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void showBookmarks() {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const Text(
                'বুকমার্ক তালিকা',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 10),
              if (bookmarks.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Center(child: Text('এখনো কোনো বুকমার্ক নেই')),
                )
              else
                for (final bookmark in bookmarks)
                  ListTile(
                    leading: const Icon(Icons.bookmark, color: primary),
                    title: Text('পৃষ্ঠা $bookmark'),
                    onTap: () {
                      Navigator.pop(context);
                      jumpToPage(bookmark);
                    },
                  ),
            ],
          ),
        );
      },
    );
  }
}

class MadrashaDetailBody extends StatelessWidget {
  const MadrashaDetailBody({super.key, required this.item});

  final Map<String, dynamic> item;

  @override
  Widget build(BuildContext context) {
    final title = text(item, 'madrasha_name', fallback: 'মাদ্রাসা');
    final gallery = madrashaImages(item);
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        PatternPageHero(
          title: title,
          subtitle: [
            text(item, 'village'),
            text(item, 'district_name'),
            text(item, 'upazila_name'),
          ].where((value) => value.isNotEmpty).join(', '),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            DetailChip(
              Icons.location_on_outlined,
              [
                text(item, 'village'),
                text(item, 'district_name'),
              ].where((value) => value.isNotEmpty).join(', '),
            ),
            DetailChip(
              Icons.school_outlined,
              madrashaTypeLabel(text(item, 'type_of_madrasha')),
            ),
            DetailChip(
              Icons.calendar_month_outlined,
              'প্রতিষ্ঠিত ${text(item, 'year_of_establishment', fallback: 'উল্লেখ নেই')}',
            ),
          ],
        ),
        const SizedBox(height: 14),
        BreadcrumbPill(items: ['হোম', 'মাদ্রাসা', title]),
        const SizedBox(height: 18),
        const WebSectionTitle('ছবি ও গ্যালারি'),
        MadrashaGalleryGrid(images: gallery),
        const SizedBox(height: 18),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: 1.35,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          children: [
            DetailStatCard(
              Icons.groups_outlined,
              'শিক্ষার্থী',
              text(item, 'number_of_students', fallback: '0'),
            ),
            DetailStatCard(
              Icons.person_outline,
              'শিক্ষক',
              text(item, 'number_of_teachers', fallback: '0'),
            ),
            DetailStatCard(
              Icons.calendar_month_outlined,
              'প্রতিষ্ঠার সন',
              text(item, 'year_of_establishment', fallback: 'উল্লেখ নেই'),
            ),
            DetailStatCard(
              Icons.location_on_outlined,
              'অবস্থান',
              text(item, 'upazila_name', fallback: 'উল্লেখ নেই'),
            ),
          ],
        ),
        const SizedBox(height: 18),
        WebInfoPanel(
          title: 'মাদ্রাসার বর্ণনা',
          child: Text(
            text(
              item,
              'madrasha_description',
              fallback: 'বর্ণনা যোগ করা হয়নি',
            ),
            style: const TextStyle(height: 1.75, color: Color(0xFF374151)),
            textAlign: TextAlign.justify,
          ),
        ),
        const MadrashaQuoteCard(),
        CommitteeCard(
          title: 'কমিটি সদস্যবৃন্দ',
          people: [
            InfoItem('সভাপতি', text(item, 'president')),
            InfoItem('সেক্রেটারি', text(item, 'secretary')),
            InfoItem('সহ-সভাপতি', text(item, 'vice_president')),
            InfoItem('কেশিয়ার', text(item, 'treasurer')),
            InfoItem('পাঠ্যক্রম পরিচালক', text(item, 'curriculum_director')),
            InfoItem(
              'যোগাযোগ কর্মকর্তা',
              text(item, 'public_relations_officer'),
            ),
            InfoItem('আইটি পরিচালক', text(item, 'technology_it_director')),
          ],
        ),
        WebInfoPanel(
          title: 'ঠিকানা ও মাদ্রাসার তথ্য',
          child: Column(
            children: [
              AddressRow(Icons.map_outlined, 'গ্রাম', text(item, 'village')),
              AddressRow(
                Icons.account_tree_outlined,
                'ইউনিয়ন',
                text(item, 'union_parishad'),
              ),
              AddressRow(
                Icons.local_post_office_outlined,
                'পোস্ট অফিস',
                text(item, 'post_office'),
              ),
              AddressRow(
                Icons.location_city_outlined,
                'থানা/উপজেলা',
                text(item, 'upazila_name'),
              ),
              AddressRow(Icons.map, 'জেলা', text(item, 'district_name')),
              AddressRow(
                Icons.language,
                'শিক্ষার মাধ্যম',
                mediumLabel(text(item, 'medium_of_instruction')),
              ),
            ],
          ),
        ),
        TeacherList(teachers: listOfMaps(item['teachers'])),
      ],
    );
  }
}

class DetailChip extends StatelessWidget {
  const DetailChip(this.icon, this.label, {super.key});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    if (label.isEmpty) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: primary.withValues(alpha: .16)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: primary, size: 15),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class WebSectionTitle extends StatelessWidget {
  const WebSectionTitle(this.title, {super.key});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(width: 4, height: 24, color: primary),
          const SizedBox(width: 10),
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFF111827),
              fontSize: 19,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class MadrashaGalleryGrid extends StatelessWidget {
  const MadrashaGalleryGrid({super.key, required this.images});

  final List<String> images;

  @override
  Widget build(BuildContext context) {
    if (images.isEmpty) {
      return const EmptyBox('গ্যালারি ছবি যোগ করা হয়নি');
    }
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: CachedNetworkImage(
            imageUrl: images.first,
            height: 220,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
        ),
        const SizedBox(height: 10),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: images.skip(1).take(4).length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 1.45,
          ),
          itemBuilder: (context, index) {
            final url = images[index + 1];
            return ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: CachedNetworkImage(imageUrl: url, fit: BoxFit.cover),
            );
          },
        ),
      ],
    );
  }
}

class DetailStatCard extends StatelessWidget {
  const DetailStatCard(this.icon, this.label, this.value, {super.key});

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF111827), width: 1.2),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            backgroundColor: primary.withValues(alpha: .10),
            child: Icon(icon, color: primary),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
          ),
          const SizedBox(height: 3),
          Text(
            value.isEmpty ? 'উল্লেখ নেই' : value,
            style: const TextStyle(fontWeight: FontWeight.w900),
          ),
        ],
      ),
    );
  }
}

class WebInfoPanel extends StatelessWidget {
  const WebInfoPanel({super.key, required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [WebSectionTitle(title), child],
        ),
      ),
    );
  }
}

class MadrashaQuoteCard extends StatelessWidget {
  const MadrashaQuoteCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFE3FFF4),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: primary.withValues(alpha: .12)),
      ),
      child: const Column(
        children: [
          Text(
            'طلب العلم فريضة على كل مسلم',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: primary,
              fontWeight: FontWeight.w900,
              fontSize: 18,
            ),
          ),
          SizedBox(height: 8),
          Text(
            '“ইলম অর্জন করা প্রত্যেক মুসলমানের উপর ফরজ।”',
            textAlign: TextAlign.center,
            style: TextStyle(color: primaryDark, fontWeight: FontWeight.w800),
          ),
          Text(
            'শাহপুর দরবার শরীফ',
            style: TextStyle(color: Colors.grey, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class AddressRow extends StatelessWidget {
  const AddressRow(this.icon, this.label, this.value, {super.key});

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.black.withValues(alpha: .05)),
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: primary, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(label, style: TextStyle(color: Colors.grey.shade600)),
          ),
          Flexible(
            child: Text(
              value.isEmpty ? 'উল্লেখ নেই' : value,
              textAlign: TextAlign.right,
              style: const TextStyle(fontWeight: FontWeight.w900),
            ),
          ),
        ],
      ),
    );
  }
}

class DetailHero extends StatelessWidget {
  const DetailHero({super.key, required this.item, required this.type});

  final Map<String, dynamic> item;
  final ArchiveType type;

  @override
  Widget build(BuildContext context) {
    final title = text(item, type.titleKey, fallback: 'শিরোনাম নেই');
    final image = api.mediaUrl(text(item, type.imageKey));
    return Container(
      decoration: BoxDecoration(
        color: primaryDark,
        borderRadius: BorderRadius.circular(26),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (image.isNotEmpty)
            CachedNetworkImage(
              imageUrl: image,
              height: 220,
              width: double.infinity,
              fit: BoxFit.cover,
            )
          else
            Container(
              height: 160,
              width: double.infinity,
              color: primary.withValues(alpha: .2),
              child: Icon(type.icon, color: Colors.white, size: 54),
            ),
          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _heroSubtitle(item, type),
                  style: const TextStyle(color: Colors.white70, height: 1.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _heroSubtitle(Map<String, dynamic> item, ArchiveType type) {
    switch (type) {
      case ArchiveType.madrasha:
        return [
          text(item, 'village'),
          text(item, 'district_name'),
          text(item, 'upazila_name'),
        ].where((e) => e.isNotEmpty).join(' • ');
      case ArchiveType.khankah:
        return [
          text(item, 'village'),
          text(item, 'district_name'),
          text(item, 'upazila_name'),
        ].where((e) => e.isNotEmpty).join(' • ');
      case ArchiveType.events:
        return [
          text(item, 'category_display'),
          text(item, 'start_date'),
          text(item, 'venue_name'),
        ].where((e) => e.isNotEmpty).join(' • ');
      case ArchiveType.books:
        return [
          text(item, 'author_name'),
          text(item, 'category_display'),
          text(item, 'language_display'),
        ].where((e) => e.isNotEmpty).join(' • ');
    }
  }
}

class InfoCard extends StatelessWidget {
  const InfoCard(this.title, this.body, {super.key});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: primaryDark,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              body.isEmpty ? 'তথ্য যোগ করা হয়নি' : body,
              style: const TextStyle(height: 1.65),
            ),
          ],
        ),
      ),
    );
  }
}

class InfoItem {
  InfoItem(this.label, this.value);
  final String label;
  final String value;
}

class InfoGrid extends StatelessWidget {
  const InfoGrid(this.items, {super.key});

  final List<InfoItem> items;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Wrap(
          spacing: 10,
          runSpacing: 10,
          children: items.map((item) {
            return SizedBox(
              width: (MediaQuery.sizeOf(context).width - 70) / 2,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: primary.withValues(alpha: .06),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.label,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.value.isEmpty ? 'উল্লেখ নেই' : item.value,
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

class CommitteeCard extends StatelessWidget {
  const CommitteeCard({super.key, required this.title, required this.people});

  final String title;
  final List<InfoItem> people;

  @override
  Widget build(BuildContext context) {
    final visible = people.where((item) => item.value.isNotEmpty).toList();
    if (visible.isEmpty) return const SizedBox.shrink();
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: primaryDark,
              ),
            ),
            const SizedBox(height: 8),
            for (final person in visible)
              ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                leading: const CircleAvatar(
                  backgroundColor: Color(0xFFE8F8F1),
                  child: Icon(Icons.person_outline, color: primary),
                ),
                title: Text(
                  person.value,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                subtitle: Text(person.label),
              ),
          ],
        ),
      ),
    );
  }
}

class TeacherList extends StatelessWidget {
  const TeacherList({super.key, required this.teachers});

  final List<Map<String, dynamic>> teachers;

  @override
  Widget build(BuildContext context) {
    if (teachers.isEmpty) return const SizedBox.shrink();
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'শিক্ষক তালিকা',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: primaryDark,
              ),
            ),
            const SizedBox(height: 8),
            for (final teacher in teachers)
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: TeacherAvatar(
                  url: api.mediaUrl(text(teacher, 'teacher_image')),
                ),
                title: Text(
                  text(teacher, 'teacher_name'),
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
                subtitle: Text(
                  [
                    text(teacher, 'teacher_education_qualification'),
                    text(teacher, 'teacher_phone_number'),
                  ].where((value) => value.isNotEmpty).join(' • '),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class TeacherAvatar extends StatelessWidget {
  const TeacherAvatar({super.key, required this.url});

  final String url;

  @override
  Widget build(BuildContext context) {
    if (url.isEmpty) {
      return const CircleAvatar(
        backgroundColor: Color(0xFFE8F8F1),
        child: Icon(Icons.person_outline, color: primary),
      );
    }
    return CircleAvatar(backgroundImage: CachedNetworkImageProvider(url));
  }
}

class PhotoStrip extends StatelessWidget {
  const PhotoStrip({super.key, required this.photos});

  final List<Map<String, dynamic>> photos;

  @override
  Widget build(BuildContext context) {
    if (photos.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader('গ্যালারি'),
        SizedBox(
          height: 122,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemBuilder: (context, index) {
              final url = api.mediaUrl(text(photos[index], 'image'));
              return ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: CachedNetworkImage(
                  imageUrl: url,
                  width: 160,
                  fit: BoxFit.cover,
                ),
              );
            },
            separatorBuilder: (context, index) => const SizedBox(width: 10),
            itemCount: photos.length,
          ),
        ),
      ],
    );
  }
}

class ScheduleList extends StatelessWidget {
  const ScheduleList({super.key, required this.items});

  final List<Map<String, dynamic>> items;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'অনুষ্ঠানসূচি',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 8),
            for (final item in items)
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.schedule, color: primary),
                title: Text(
                  text(item, 'title'),
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                subtitle: Text(
                  [
                    text(item, 'time'),
                    text(item, 'speaker'),
                    text(item, 'description'),
                  ].where((e) => e.isNotEmpty).join(' • '),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = AuthScope.of(context);
    return AnimatedBuilder(
      animation: auth,
      builder: (context, _) {
        if (!auth.initialized) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!auth.isLoggedIn) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const PageIntro(
                title: 'লগইন / নিবন্ধন',
                icon: Icons.person_outline,
              ),
              const SizedBox(height: 14),
              const InfoCard(
                'অ্যাকাউন্ট সুবিধা',
                'প্রোফাইল দেখা, ঠিকানা সংরক্ষণ এবং ভবিষ্যৎ অনলাইন সেবা ব্যবহারের জন্য অ্যাকাউন্ট তৈরি করুন।',
              ),
              FilledButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                ),
                child: const Text('লগইন করুন'),
              ),
              const SizedBox(height: 10),
              OutlinedButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const RegisterScreen()),
                ),
                child: const Text('নিবন্ধন করুন'),
              ),
            ],
          );
        }
        final profile = auth.profile;
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            PageIntro(title: 'আমার প্রোফাইল', icon: Icons.person_outline),
            const SizedBox(height: 14),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${text(profile ?? {}, 'first_name')} ${text(profile ?? {}, 'last_name')}'
                          .trim(),
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 12),
                    profileRow('ইমেইল', text(profile ?? {}, 'email')),
                    profileRow('মোবাইল', text(profile ?? {}, 'phone')),
                    profileRow('ঠিকানা', text(profile ?? {}, 'street_address')),
                    const SizedBox(height: 18),
                    FilledButton.icon(
                      onPressed: () => auth.logout(),
                      icon: const Icon(Icons.logout),
                      label: const Text('লগআউট'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget profileRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(label, style: const TextStyle(color: Colors.grey)),
          ),
          Expanded(
            child: Text(
              value.isEmpty ? 'প্রদান করা হয়নি' : value,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final email = TextEditingController();
  final password = TextEditingController();
  bool loading = false;
  bool showPassword = false;
  String error = '';

  @override
  Widget build(BuildContext context) {
    final auth = AuthScope.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('লগইন')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const PageIntro(title: 'লগইন করুন', icon: Icons.login),
          const SizedBox(height: 14),
          if (error.isNotEmpty) ErrorBox(error),
          TextField(
            controller: email,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(labelText: 'ইমেইল'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: password,
            obscureText: !showPassword,
            decoration: InputDecoration(
              labelText: 'পাসওয়ার্ড',
              suffixIcon: IconButton(
                onPressed: () => setState(() => showPassword = !showPassword),
                icon: Icon(
                  showPassword ? Icons.visibility_off : Icons.visibility,
                ),
              ),
            ),
          ),
          const SizedBox(height: 18),
          FilledButton(
            onPressed: loading
                ? null
                : () async {
                    setState(() {
                      loading = true;
                      error = '';
                    });
                    try {
                      await auth.login(email.text.trim(), password.text);
                      if (context.mounted) Navigator.pop(context);
                    } catch (e) {
                      setState(
                        () => error = e.toString().replaceFirst(
                          'Exception: ',
                          '',
                        ),
                      );
                    } finally {
                      if (mounted) setState(() => loading = false);
                    }
                  },
            child: Text(loading ? 'লগইন হচ্ছে...' : 'লগইন'),
          ),
        ],
      ),
    );
  }
}

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final firstName = TextEditingController();
  final lastName = TextEditingController();
  final phone = TextEditingController();
  final email = TextEditingController();
  final address = TextEditingController();
  final password = TextEditingController();
  final confirm = TextEditingController();
  List<Map<String, dynamic>> districts = [];
  List<Map<String, dynamic>> upazilas = [];
  String? district;
  String? upazila;
  String error = '';
  bool loading = false;
  bool showPassword = false;
  bool showConfirmPassword = false;

  @override
  void initState() {
    super.initState();
    api.list('/madrasha/districts/').then((items) {
      if (mounted) setState(() => districts = items);
    });
  }

  Future<void> loadUpazilas(String districtId) async {
    final items = await api.list(
      '/madrasha/upazilas/',
      query: {'district': districtId},
    );
    if (mounted) {
      setState(() {
        upazilas = items;
        upazila = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = AuthScope.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('নিবন্ধন')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const PageIntro(
            title: 'নতুন অ্যাকাউন্ট',
            icon: Icons.person_add_alt_1,
          ),
          const SizedBox(height: 14),
          if (error.isNotEmpty) ErrorBox(error),
          TextField(
            controller: firstName,
            decoration: const InputDecoration(labelText: 'ফার্স্ট নেম'),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: lastName,
            decoration: const InputDecoration(labelText: 'লাস্ট নেম'),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: phone,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(labelText: 'মোবাইল'),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: email,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(labelText: 'ইমেইল'),
          ),
          const SizedBox(height: 10),
          DropdownButtonFormField<String>(
            key: ValueKey('district-$district-${districts.length}'),
            initialValue: district,
            decoration: const InputDecoration(labelText: 'জেলা'),
            items: districts
                .map(
                  (item) => DropdownMenuItem(
                    value: '${item['id']}',
                    child: Text(text(item, 'name')),
                  ),
                )
                .toList(),
            onChanged: (value) {
              setState(() => district = value);
              if (value != null) loadUpazilas(value);
            },
          ),
          const SizedBox(height: 10),
          DropdownButtonFormField<String>(
            key: ValueKey('upazila-$upazila-${upazilas.length}'),
            initialValue: upazila,
            decoration: const InputDecoration(labelText: 'থানা / উপজেলা'),
            items: upazilas
                .map(
                  (item) => DropdownMenuItem(
                    value: '${item['id']}',
                    child: Text(text(item, 'name')),
                  ),
                )
                .toList(),
            onChanged: (value) => setState(() => upazila = value),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: address,
            decoration: const InputDecoration(
              labelText: 'গ্রাম / রাস্তা / মহল্লা',
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: password,
            obscureText: !showPassword,
            decoration: InputDecoration(
              labelText: 'পাসওয়ার্ড',
              suffixIcon: IconButton(
                onPressed: () => setState(() => showPassword = !showPassword),
                icon: Icon(
                  showPassword ? Icons.visibility_off : Icons.visibility,
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: confirm,
            obscureText: !showConfirmPassword,
            decoration:
                const InputDecoration(
                  labelText: 'পাসওয়ার্ড নিশ্চিত করুন',
                ).copyWith(
                  suffixIcon: IconButton(
                    onPressed: () => setState(
                      () => showConfirmPassword = !showConfirmPassword,
                    ),
                    icon: Icon(
                      showConfirmPassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                    ),
                  ),
                ),
          ),
          const SizedBox(height: 18),
          FilledButton(
            onPressed: loading ? null : () => submit(auth),
            child: Text(loading ? 'নিবন্ধন হচ্ছে...' : 'নিবন্ধন করুন'),
          ),
        ],
      ),
    );
  }

  Future<void> submit(AuthStore auth) async {
    if (password.text != confirm.text) {
      setState(() => error = 'পাসওয়ার্ড দুটি মিলছে না');
      return;
    }
    setState(() {
      loading = true;
      error = '';
    });
    try {
      await auth.register({
        'first_name': firstName.text.trim(),
        'last_name': lastName.text.trim(),
        'phone': phone.text.trim(),
        'email': email.text.trim(),
        'district': district == null ? null : int.parse(district!),
        'upazila': upazila == null ? null : int.parse(upazila!),
        'street_address': address.text.trim(),
        'password': password.text,
      }, password.text);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      setState(() => error = e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }
}

class BiographyScreen extends StatelessWidget {
  const BiographyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('জীবনী')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          PageIntro(title: 'জীবনী', icon: Icons.auto_stories_outlined),
          SizedBox(height: 12),
          InfoCard(
            'আল্লামা ড. আহমদ পেয়ারা বাগদাদী (রাঃ)',
            'আন্তর্জাতিক ইসলাম প্রচারক, বিজ্ঞানী ও সুফিসাধক আল্লামা ডঃ শাহজাদা সৈয়দ শেখ আহমদ পেয়ারা বাগদাদী (রাঃ) এঁর জীবন, শিক্ষা ও খেদমতের পরিচিতি।',
          ),
          InfoCard(
            'মাওলানা আব্দুস সুবহান আল-কাদেরী (রাঃ)',
            'শাহপুর দরবার শরীফের প্রতিষ্ঠাতা শায়খুল কুররা গাউছে জামান হযরত মাওলানা আব্দুস সুবহান আল-কাদেরী (রাঃ) এঁর জীবন ও অবদান।',
          ),
        ],
      ),
    );
  }
}

class ServicesScreen extends StatelessWidget {
  const ServicesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const StaticPage(
      title: 'সেবা কার্যক্রম',
      icon: Icons.volunteer_activism_outlined,
      body:
          'দ্বীনি শিক্ষা, মাদ্রাসা পরিচালনা, খানকাহ কার্যক্রম, মাহফিল, সামাজিক সহায়তা এবং ইসলামী বই-পাঠের মাধ্যমে মানুষের কল্যাণে শাহপুর দরবার শরীফ কাজ করে যাচ্ছে।',
    );
  }
}

class GalleryScreen extends StatelessWidget {
  const GalleryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const StaticPage(
      title: 'গ্যালারি',
      icon: Icons.photo_library_outlined,
      body:
          'মাদ্রাসা, খানকাহ ও মাহফিলের বিস্তারিত পেজে সংশ্লিষ্ট ছবির গ্যালারি দেখা যাবে। ভবিষ্যতে এখানে সব ছবির একত্রিত গ্যালারি যুক্ত করা যাবে।',
    );
  }
}

class ContactScreen extends StatelessWidget {
  const ContactScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const StaticPage(
      title: 'যোগাযোগ',
      icon: Icons.contact_mail_outlined,
      body:
          'শাহপুর দরবার শরীফের সাথে যোগাযোগের জন্য অফিসিয়াল ওয়েবসাইটের যোগাযোগ পেজ ব্যবহার করুন। মোবাইল অ্যাপে সরাসরি যোগাযোগ ফর্ম পরবর্তী ধাপে যুক্ত করা যাবে।',
    );
  }
}

class StaticPage extends StatelessWidget {
  const StaticPage({
    super.key,
    required this.title,
    required this.icon,
    required this.body,
  });

  final String title;
  final IconData icon;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          PageIntro(title: title, icon: icon),
          const SizedBox(height: 14),
          InfoCard(title, body),
        ],
      ),
    );
  }
}

class LoadingBox extends StatelessWidget {
  const LoadingBox({super.key});

  @override
  Widget build(BuildContext context) {
    return const Card(
      child: Padding(
        padding: EdgeInsets.all(28),
        child: Center(child: CircularProgressIndicator()),
      ),
    );
  }
}

class EmptyBox extends StatelessWidget {
  const EmptyBox(this.message, {super.key});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Center(
          child: Text(message, style: const TextStyle(color: Colors.grey)),
        ),
      ),
    );
  }
}

class ErrorBox extends StatelessWidget {
  const ErrorBox(this.message, {super.key});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.red.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Text(message, style: TextStyle(color: Colors.red.shade800)),
      ),
    );
  }
}

String text(Map<String, dynamic> item, String key, {String fallback = ''}) {
  final value = item[key];
  if (value == null) return fallback;
  final result = '$value';
  return result.isEmpty || result == 'null' ? fallback : result;
}

int intValue(dynamic value) {
  if (value is int) return value;
  return int.tryParse('$value') ?? 0;
}

List<Map<String, dynamic>> listOfMaps(dynamic value) {
  if (value is List) {
    return value
        .whereType<Map>()
        .map((item) => item.cast<String, dynamic>())
        .toList();
  }
  return [];
}

List<String> madrashaImages(Map<String, dynamic> item) {
  final images = <String>[];
  final featured = api.mediaUrl(text(item, 'featured_image'));
  if (featured.isNotEmpty) images.add(featured);
  for (final photo in listOfMaps(item['photos'])) {
    final url = api.mediaUrl(text(photo, 'image'));
    if (url.isNotEmpty && !images.contains(url)) images.add(url);
  }
  return images;
}

String madrashaTypeLabel(String value) {
  switch (value) {
    case 'nurani':
      return 'নূরানী';
    case 'hifz':
      return 'হিফজ';
    case 'najera':
      return 'নাজেরা';
    case 'academic':
      return 'একাডেমিক';
    default:
      return value;
  }
}

String mediumLabel(String value) {
  switch (value) {
    case 'bangla':
      return 'বাংলা';
    case 'english':
      return 'ইংরেজি';
    default:
      return value;
  }
}

String _formatApiError(dynamic data) {
  if (data is Map) {
    return data.entries
        .map((entry) {
          final value = entry.value;
          if (value is List) return '${entry.key}: ${value.join(', ')}';
          return '${entry.key}: $value';
        })
        .join('; ');
  }
  return 'অনুরোধ সম্পন্ন করা যায়নি';
}
