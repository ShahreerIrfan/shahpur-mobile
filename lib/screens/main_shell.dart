part of '../main.dart';

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
