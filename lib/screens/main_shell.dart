part of '../main.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int index = 0;
  final List<int> tabHistory = [];

  @override
  void initState() {
    super.initState();
    _checkAndPromptNotifications();
    _setupFCMClickHandling();
  }

  Future<void> _checkAndPromptNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    final prompted = prefs.getBool('prompted_notifications') ?? false;
    if (!prompted) {
      Future.delayed(const Duration(seconds: 2), () {
        if (!mounted) return;
        _showCustomNotificationDialog(prefs);
      });
    } else {
      _initFCMDirectly();
    }
  }

  void _showCustomNotificationDialog(SharedPreferences prefs) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          backgroundColor: Colors.white,
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: Color(0xFFE6F4EA),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.notifications_active,
                  color: Color(0xFF034838),
                  size: 24,
                ),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'নোটিফিকেশন অন করুন',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Color(0xFF034838),
                  ),
                ),
              ),
            ],
          ),
          content: const Text(
            'শাহপুর দরবার শরীফের সব খবরাখবর এবং নোটিফিকেশন সবার আগে পেতে নোটিফিকেশন অন করে রাখুন।',
            style: TextStyle(
              fontSize: 14,
              color: Colors.black87,
              height: 1.4,
            ),
          ),
          actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          actions: [
            TextButton(
              onPressed: () {
                prefs.setBool('prompted_notifications', true);
                Navigator.pop(context);
              },
              child: const Text(
                'পরে',
                style: TextStyle(
                  color: Colors.grey,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF034838),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
              onPressed: () async {
                prefs.setBool('prompted_notifications', true);
                Navigator.pop(context);
                await _requestNativeNotificationPermission();
              },
              child: const Text(
                'অনুমতি দিন',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _requestNativeNotificationPermission() async {
    final messaging = FirebaseMessaging.instance;
    final settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      final token = await messaging.getToken();
      if (token != null) {
        debugPrint("FCM Registration Token: $token");
        await api.registerDeviceToken(token);
      }
      messaging.onTokenRefresh.listen((newToken) async {
        await api.registerDeviceToken(newToken);
      });
    }
  }

  Future<void> _initFCMDirectly() async {
    final messaging = FirebaseMessaging.instance;
    final settings = await messaging.getNotificationSettings();
    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      final token = await messaging.getToken();
      if (token != null) {
        await api.registerDeviceToken(token);
      }
      messaging.onTokenRefresh.listen((newToken) async {
        await api.registerDeviceToken(newToken);
      });
    }
  }

  Future<void> _setupFCMClickHandling() async {
    // Listen for notification clicks when the app is in the background or foreground
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      _handleNotificationClick(message);
    });

    // Check if the app was opened from a terminated state via a notification click
    final initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      Future.delayed(const Duration(milliseconds: 500), () {
        _handleNotificationClick(initialMessage);
      });
    }
  }

  void _handleNotificationClick(RemoteMessage message) {
    debugPrint("FCM Notification clicked: ${message.data}");
    final data = message.data;
    if (data['type'] == 'event' && data['event_id'] != null) {
      final eventId = int.tryParse(data['event_id'].toString()) ?? data['event_id'];
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetailScreen(
              type: ArchiveType.events,
              id: eventId,
            ),
          ),
        );
      } else {
        navigatorKey.currentState?.push(
          MaterialPageRoute(
            builder: (context) => DetailScreen(
              type: ArchiveType.events,
              id: eventId,
            ),
          ),
        );
      }
    } else if (data['type'] == 'announcement' && data['announcement_id'] != null) {
      final announcementId = int.tryParse(data['announcement_id'].toString()) ?? data['announcement_id'];
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetailScreen(
              type: ArchiveType.announcements,
              id: announcementId,
            ),
          ),
        );
      } else {
        navigatorKey.currentState?.push(
          MaterialPageRoute(
            builder: (context) => DetailScreen(
              type: ArchiveType.announcements,
              id: announcementId,
            ),
          ),
        );
      }
    }
  }

  final pages = const [
    HomeScreen(),
    ApiArchiveScreen(type: ArchiveType.madrasha),
    ApiArchiveScreen(type: ArchiveType.events),
    ApiArchiveScreen(type: ArchiveType.books),
    AccountScreen(),
  ];

  @override
  Widget build(BuildContext context) {
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
        drawer: AppDrawer(
          onSelect: _openDrawerPage,
          onTabSelect: _openDrawerTab,
        ),
        body: SafeArea(
          child: Column(
            children: [
              // Bismillah Top Bar (Matches Web Mobile)
              Container(
                width: double.infinity,
                color: const Color(0xFF034838),
                padding: const EdgeInsets.symmetric(vertical: 6),
                alignment: Alignment.center,
                child: const Text(
                  'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'serif',
                  ),
                ),
              ),
              // Main Header Card (Matches Web Mobile)
              Container(
                margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFFA7F3D0).withValues(alpha: 0.8),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    // Circular Logo
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFFF0FDF4),
                        border: Border.all(
                          color: const Color(0xFF10B981).withValues(alpha: 0.2),
                        ),
                      ),
                      padding: const EdgeInsets.all(4),
                      child: Image.asset(
                        'assets/images/logo_nobg.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                    const SizedBox(width: 10),
                    // Title & Subtitle Texts next to it
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'শাহপুর দরবার শরীফ',
                            style: TextStyle(
                              color: Color(0xFF034838),
                              fontWeight: FontWeight.w900,
                              fontSize: 15,
                            ),
                          ),
                          Text(
                            'Shahpur Darbar Sharif',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Hamburger Drawer Menu Icon
                    Builder(
                      builder: (context) => InkWell(
                        onTap: () => Scaffold.of(context).openDrawer(),
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          child: const Icon(
                            Icons.menu,
                            color: Color(0xFF1F2937),
                            size: 24,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: pages[index],
              ),
            ],
          ),
        ),
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const CircleAvatar(
                    backgroundColor: Colors.white,
                    radius: 26,
                    backgroundImage: AssetImage('assets/images/logo_nobg.png'),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'শাহপুর দরবার শরীফ',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const Text(
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
