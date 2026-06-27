part of '../main.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Key _sliderKey = UniqueKey();
  Key _madrashaKey = UniqueKey();
  Key _khankahKey = UniqueKey();
  Key _eventsKey = UniqueKey();
  Key _booksKey = UniqueKey();

  Future<void> _refresh() async {
    setState(() {
      _sliderKey = UniqueKey();
      _madrashaKey = UniqueKey();
      _khankahKey = UniqueKey();
      _eventsKey = UniqueKey();
      _booksKey = UniqueKey();
    });
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _refresh,
      child: ListView(
        padding: const EdgeInsets.only(bottom: 28),
        children: [
          HeroSlider(key: _sliderKey),
          const SizedBox(height: 28),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const AboutDarbarSection(),
                const SizedBox(height: 22),
                const QuoteBand(),
                const SizedBox(height: 28),
                const ActivitiesSectionMobile(),
                const SizedBox(height: 28),
                const SectionHeader('আমাদের মাদ্রাসা সমূহ'),
                HomePreviewList(
                  key: _madrashaKey,
                  type: ArchiveType.madrasha,
                  query: const {'homepage': 'true'},
                ),
                const SizedBox(height: 22),
                const SectionHeader('খানকাহ শরীফ সমূহ'),
                HomePreviewList(
                  key: _khankahKey,
                  type: ArchiveType.khankah,
                  query: const {'homepage': 'true'},
                ),
                const SizedBox(height: 22),
                const SectionHeader('আসন্ন মাহফিল ও ইভেন্ট'),
                HomePreviewList(
                  key: _eventsKey,
                  type: ArchiveType.events,
                  query: const {'status': 'upcoming'},
                ),
                const SizedBox(height: 28),
                const BiographyHighlights(),
                const SizedBox(height: 28),
                const TimelineMobile(),
                const SizedBox(height: 28),
                const SectionHeader('নির্বাচিত বই'),
                HomePreviewList(
                  key: _booksKey,
                  type: ArchiveType.books,
                  query: const {'featured': 'true'},
                ),
                const SizedBox(height: 28),
                const WrittenBooksMobile(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class HeroSlider extends StatefulWidget {
  const HeroSlider({super.key});

  @override
  State<HeroSlider> createState() => _HeroSliderState();
}

class _HeroSliderState extends State<HeroSlider> {
  late Future<List<Map<String, dynamic>>> _slidesFuture;
  int _currentIndex = 0;
  final PageController _pageController = PageController();
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _loadSlides();
  }

  void _loadSlides() {
    _slidesFuture = api.list('/core/sliders/');
    _slidesFuture.then((slides) {
      if (slides.length > 1) {
        _startAutoPlay(slides.length);
      }
    }).catchError((_) {});
  }

  void _startAutoPlay(int slideCount) {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 6), (timer) {
      if (!mounted) return;
      final nextIndex = (_currentIndex + 1) % slideCount;
      _pageController.animateToPage(
        nextIndex,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _slidesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            height: 240,
            child: LoadingBox(),
          );
        }

        final slides = snapshot.data ?? [];
        if (slides.isEmpty) {
          return const _HeroSlideItem(slide: {
            'eyebrow': 'আধ্যাত্মিক সাধনার কেন্দ্র',
            'title': 'শাহপুর দরবার শরীফ',
            'primary_button_url': '/biography/baghdadi',
          });
        }

        return Column(
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  height: 240,
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: slides.length,
                    onPageChanged: (index) {
                      setState(() {
                        _currentIndex = index;
                      });
                    },
                    itemBuilder: (context, index) {
                      return _HeroSlideItem(slide: slides[index]);
                    },
                  ),
                ),
                // Left Arrow Overlay (Matches Web Mobile)
                if (slides.length > 1)
                  Positioned(
                    left: 12,
                    child: _ArrowNavButton(
                      icon: Icons.chevron_left,
                      onTap: () {
                        final prevIndex = (_currentIndex - 1 + slides.length) % slides.length;
                        _pageController.animateToPage(
                          prevIndex,
                          duration: const Duration(milliseconds: 400),
                          curve: Curves.easeInOut,
                        );
                      },
                    ),
                  ),
                // Right Arrow Overlay (Matches Web Mobile)
                if (slides.length > 1)
                  Positioned(
                    right: 12,
                    child: _ArrowNavButton(
                      icon: Icons.chevron_right,
                      onTap: () {
                        final nextIndex = (_currentIndex + 1) % slides.length;
                        _pageController.animateToPage(
                          nextIndex,
                          duration: const Duration(milliseconds: 400),
                          curve: Curves.easeInOut,
                        );
                      },
                    ),
                  ),
              ],
            ),
            if (slides.length > 1) ...[
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  slides.length,
                  (index) => Container(
                    width: _currentIndex == index ? 18.0 : 7.0,
                    height: 7.0,
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      color: _currentIndex == index
                          ? primary
                          : Colors.grey.shade400,
                    ),
                  ),
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}

class _HeroSlideItem extends StatelessWidget {
  const _HeroSlideItem({required this.slide});

  final Map<String, dynamic> slide;

  @override
  Widget build(BuildContext context) {
    final eyebrow = text(slide, 'eyebrow', fallback: 'আধ্যাত্মিক সাধনার কেন্দ্র');
    final title = text(slide, 'title', fallback: 'শাহপুর দরবার শরীফ');

    final bgImg = text(slide, 'background_image').isNotEmpty
        ? text(slide, 'background_image')
        : text(slide, 'image');

    final bgUrl = bgImg.isNotEmpty
        ? api.mediaUrl(bgImg)
        : 'https://images.unsplash.com/photo-1591604129939-f1efa4d9f7fa?q=80&w=1200&auto=format';

    final primaryBtnText = text(slide, 'primary_button_text');
    final primaryBtnUrl = text(slide, 'primary_button_url');
    final secondaryBtnText = text(slide, 'secondary_button_text');
    final secondaryBtnUrl = text(slide, 'secondary_button_url');

    return Container(
      margin: EdgeInsets.zero, // Full bleed (matches web mobile layout)
      decoration: BoxDecoration(
        borderRadius: BorderRadius.zero, // Full bleed (matches web mobile layout)
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: CachedNetworkImage(
              imageUrl: bgUrl,
              fit: BoxFit.cover,
              alignment: Alignment.center,
              placeholder: (context, url) => Container(color: const Color(0xFF034838)),
              errorWidget: (context, error, stackTrace) => Container(
                color: const Color(0xFF034838),
                alignment: Alignment.center,
                child: Icon(
                  Icons.mosque_outlined,
                  size: 80,
                  color: Colors.white.withValues(alpha: 0.1),
                ),
              ),
            ),
          ),
          // Dark green gradient overlay (Opacity reduced to show bg clearly)
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    const Color(0xFF034838).withValues(alpha: 0.45),
                    const Color(0xFF000000).withValues(alpha: 0.65),
                  ],
                ),
              ),
            ),
          ),
          // Content Layout
          Padding(
            padding: const EdgeInsets.fromLTRB(28, 20, 28, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Eyebrow Tag
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.mosque, color: Color(0xFFA7F3D0), size: 11),
                      const SizedBox(width: 5),
                      Text(
                        eyebrow,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                // Main Title (Multi-line)
                Text(
                  title.replaceAll('\\n', '\n'),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    height: 1.3,
                    shadows: [
                      Shadow(
                        color: Colors.black45,
                        offset: Offset(0, 1.5),
                        blurRadius: 3,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                // Horizontal Pill Buttons Row (Matches Web Mobile layout)
                if (primaryBtnText.isNotEmpty || secondaryBtnText.isNotEmpty)
                  Row(
                    children: [
                      if (primaryBtnText.isNotEmpty) ...[
                        _SlideButton(
                          title: primaryBtnText,
                          filled: true,
                          icon: Icons.menu_book_outlined,
                          onTap: () => _handleNav(context, primaryBtnUrl),
                        ),
                      ],
                      if (primaryBtnText.isNotEmpty && secondaryBtnText.isNotEmpty)
                        const SizedBox(width: 8),
                      if (secondaryBtnText.isNotEmpty)
                        _SlideButton(
                          title: secondaryBtnText,
                          filled: false,
                          icon: Icons.open_in_new,
                          onTap: () => _handleNav(context, secondaryBtnUrl),
                        ),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _handleNav(BuildContext context, String url) {
    if (url == '/biography/baghdadi' || url.endsWith('/biography/baghdadi')) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const BaghdadiBiographyScreen()),
      );
    } else if (url == '/biography/subhan' || url.endsWith('/biography/subhan')) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const SubhanBiographyScreen()),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const BiographyScreen()),
      );
    }
  }
}

class _SlideButton extends StatelessWidget {
  const _SlideButton({
    required this.title,
    required this.filled,
    required this.icon,
    required this.onTap,
  });

  final String title;
  final bool filled;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Material(
        color: filled ? primary : Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: filled ? primary : Colors.white.withValues(alpha: 0.35),
                width: 1.2,
              ),
            ),
            alignment: Alignment.center,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 12, color: Colors.white),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 10.5,
                    ),
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

class _ArrowNavButton extends StatelessWidget {
  const _ArrowNavButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withValues(alpha: 0.35),
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Container(
          width: 32,
          height: 32,
          alignment: Alignment.center,
          child: Icon(
            icon,
            color: Colors.white,
            size: 20,
          ),
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
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SectionHeader('দরবার শরীফ সম্পর্কে'),
        const SizedBox(height: 4),
        const Text(
          'কুমিল্লার শাহপুরে ইসলামী শরীয়াত, কাদেরীয়া তরিকা ও আধ্যাত্মিক সাধনার ঐতিহাসিক কেন্দ্র',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Color(0xFF6B7280),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 20),
        // Description Card (Matches the premium rounded container of web)
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: primary.withValues(alpha: 0.08)),
            boxShadow: [
              BoxShadow(
                color: primary.withValues(alpha: 0.04),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Location badge
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: primary.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: primary.withValues(alpha: 0.12)),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.location_on_outlined, color: primary, size: 13),
                      SizedBox(width: 4),
                      Text(
                        'শাহপুর, কুমিল্লা',
                        style: TextStyle(
                          color: primary,
                          fontWeight: FontWeight.w800,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'বাংলাদেশের সুফি দরবেশদের ইতিহাসে কুমিল্লার শাহপুর দরবার শরীফ একটি উজ্জ্বল নাম। গোমতী নদীর উত্তর পাড় ঘেঁষে পাঁচথুবী ইউনিয়নের সীমান্তবর্তী গ্রাম শাহপুরে এই দরবারের অবস্থান।',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF1F2937),
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'ইসলামী শরীয়াতের অনুশীলন, কাদেরীয়া তরিকার প্রচার, আত্মশুদ্ধি, কঠোর রিয়াজত ও আধ্যাত্মিক শিক্ষা সাধনার জন্য শাহপুর দরবার শরীফ দেশ-বিদেশে সুপরিচিত। লক্ষ লক্ষ আশেক, ভক্ত ও মুরিদের হৃদয়ে এই দরবার নবীপ্রেমের আলোকবর্তিকা।',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF4B5563),
                  fontSize: 14,
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'জিকরুল্লাহ ইসলামিয়া কমিটির উদ্যোগে দরিদ্রদের স্বাবলম্বীকরণ, বন্যার্তদের ত্রাণ ও পুনর্বাসন, শীতবস্ত্র, কুরবানী ও ইফতার বিতরণসহ মানবসেবামূলক কার্যক্রম পরিচালিত হচ্ছে।',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF4B5563),
                  fontSize: 14,
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 20),
              // Stats
              Row(
                children: [
                  _buildMiniStat('৪০+', 'মাদ্রাসা'),
                  const SizedBox(width: 8),
                  _buildMiniStat('১৫০+', 'খানকাহ'),
                  const SizedBox(width: 8),
                  _buildMiniStat('১৭+', 'দেশ সফর'),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        // Features list (like web: 01, 02, 03, 04)
        _buildFeatureItem(
          '01',
          'দরবার শরীফ',
          'আধ্যাত্মিক সাধনার ঐতিহাসিক কেন্দ্র',
          Icons.mosque_outlined,
        ),
        _buildFeatureItem(
          '02',
          'কাদেরীয়া তরিকা',
          'গাউছে পাক (রাঃ)-এর সিলসিলার ধারা',
          Icons.menu_book_outlined,
        ),
        _buildFeatureItem(
          '03',
          'মানবসেবা',
          'দরিদ্র ও অসহায় মানুষের পাশে থাকা',
          Icons.favorite_outline,
        ),
        _buildFeatureItem(
          '04',
          'বিশ্বব্যাপী দাওয়াত',
          'দেশ-বিদেশে নবীপ্রেমের বার্তা',
          Icons.public_outlined,
        ),
        const SizedBox(height: 12),
        // Bottom bar feature card
        Container(
          padding: const EdgeInsets.all(18),
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF034838), Color(0xFF012019)],
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.star_outline, color: gold, size: 20),
              ),
              const SizedBox(height: 12),
              const Text(
                'নবীপ্রেম, আত্মশুদ্ধি ও মানবতার সেবা',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'দরবার শরীফের মূল শিক্ষা হলো শরীয়াতের অনুশীলন, সুন্নাহর অনুসরণ, আত্মিক পরিশুদ্ধি এবং মানুষের কল্যাণে নিবেদিত জীবন।',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                  height: 1.45,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMiniStat(String value, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFF9FAFB),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: primary.withValues(alpha: 0.08)),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: const TextStyle(
                color: primary,
                fontSize: 18,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(
                color: Color(0xFF6B7280),
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureItem(String num, String title, String desc, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: primary.withValues(alpha: 0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: primary, size: 20),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF111827),
              fontWeight: FontWeight.w900,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            desc,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF6B7280),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class QuoteBand extends StatelessWidget {
  const QuoteBand({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF05644C), Color(0xFF034838)],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: primary.withOpacity(0.12),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: const Column(
        children: [
          Text(
            'فَادْخُلِي فِي عِبَادِي وَادْخُلِي جَنَّتِي',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: gold,
              fontSize: 20,
              fontWeight: FontWeight.bold,
              height: 1.8,
            ),
          ),
          SizedBox(height: 10),
          Text(
            '“অতঃপর আমার বান্দাদের মধ্যে প্রবেশ কর এবং আমার জান্নাতে প্রবেশ কর।”',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w600,
              height: 1.5,
            ),
          ),
          SizedBox(height: 6),
          Text(
            '— সূরা আল-ফাজর (৮৯:২৯-৩০)',
            style: TextStyle(
              color: Color(0xFFA7F3D0), // light green
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
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
      _ActivityData(
        title: 'মাদ্রাসা শিক্ষা',
        subtitle: 'প্রায় ৪০টি মাদ্রাসায় দ্বীনি, নৈতিক ও মানবিক শিক্ষার আলো ছড়িয়ে দেওয়া হচ্ছে।',
        note: 'ইলমের আলো',
        icon: Icons.menu_book_outlined,
      ),
      _ActivityData(
        title: 'সেবা কার্যক্রম',
        subtitle: 'দরিদ্রদের স্বাবলম্বীকরণ, বন্যার্তদের ত্রাণ ও পুনর্বাসন কার্যক্রম।',
        note: 'মানবতার পাশে',
        icon: Icons.favorite,
        color: Color(0xFFE91E63),
      ),
      _ActivityData(
        title: 'আন্তর্জাতিক দাওয়াত',
        subtitle: '১৭+ দেশে ইসলামের সুমহান বার্তা ও নবীপ্রেমের দাওয়াত পৌঁছে দেওয়া।',
        note: 'বিশ্বময় বার্তা',
        icon: Icons.public,
        color: Color(0xFF536DFE),
      ),
      _ActivityData(
        title: 'খানকাহ শরীফ',
        subtitle: 'বিশ্বের বিভিন্ন দেশে ১৫০+ কাদেরীয়া তরিকার খানকাহ শরীফ প্রতিষ্ঠা।',
        note: 'আত্মশুদ্ধির কেন্দ্র',
        icon: Icons.mosque_outlined,
        color: Color(0xFF7C3AED),
      ),
      _ActivityData(
        title: 'পীর-মুরীদী',
        subtitle: 'কাদেরীয়া তরিকায় বায়াত ও আধ্যাত্মিক প্রশিক্ষণের মাধ্যমে আত্মশুদ্ধি।',
        note: 'তরিকতের শিক্ষা',
        icon: Icons.group_outlined,
        color: Color(0xFFF97316),
      ),
      _ActivityData(
        title: 'কুরবানী ও ইফতার',
        subtitle: 'রমজানে ইফতার বিতরণ ও ঈদুল আযহায় কুরবানী কার্যক্রম পরিচালনা।',
        note: 'ভ্রাতৃত্বের বন্ধন',
        icon: Icons.handshake_outlined,
        color: Color(0xFF0EA5E9),
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader('আমাদের কার্যক্রম'),
        const SizedBox(height: 4),
        const Text(
          'শাহপুর দরবার শরীফ কর্তৃক পরিচালিত ধর্মীয়, আধ্যাত্মিক ও সমাজসেবামূলক কার্যক্রম',
          style: TextStyle(
            color: Color(0xFF6B7280),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 18),
        for (int i = 0; i < items.length; i++)
          _buildActivityCard(items[i], i + 1),
      ],
    );
  }

  Widget _buildActivityCard(_ActivityData data, int index) {
    final bnNumber = _toBanglaNumber(index);
    final color = data.color ?? primary;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF3F4F6)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.015),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(data.icon, color: color, size: 20),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.04),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: color.withValues(alpha: 0.12)),
                ),
                child: Text(
                  data.note,
                  style: TextStyle(
                    color: color,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            data.title,
            style: const TextStyle(
              color: Color(0xFF1F2937),
              fontWeight: FontWeight.w700,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            data.subtitle,
            style: const TextStyle(
              color: Color(0xFF6B7280),
              fontSize: 12,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 14),
          const Divider(height: 1, color: Color(0xFFF3F4F6)),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'কার্যক্রম $bnNumber',
                style: const TextStyle(
                  color: Color(0xFF9CA3AF),
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color.withValues(alpha: 0.35),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _toBanglaNumber(int number) {
    final Map<String, String> bnDigits = {
      '0': '০',
      '1': '১',
      '2': '২',
      '3': '৩',
      '4': '৪',
      '5': '৫',
      '6': '৬',
      '7': '৭',
      '8': '৮',
      '9': '৯',
    };
    final str = number < 10 ? '0$number' : number.toString();
    return str.split('').map((char) => bnDigits[char] ?? char).join('');
  }
}

class _ActivityData {
  const _ActivityData({
    required this.title,
    required this.subtitle,
    required this.note,
    required this.icon,
    this.color,
  });

  final String title;
  final String subtitle;
  final String note;
  final IconData icon;
  final Color? color;
}

class BiographyHighlights extends StatelessWidget {
  const BiographyHighlights({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SectionHeader('মহান সাধকগণ'),
        const SizedBox(height: 4),
        const Center(
          child: Text(
            'শাহপুর দরবার শরীফের আধ্যাত্মিক ধারার মহান ব্যক্তিত্বগণ',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF6B7280),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const SizedBox(height: 18),
        // Baghdadi Card
        _buildHighlightCard(
          context,
          name: 'আল্লামা ড. আহমদ পেয়ারা বাগদাদী (রাঃ)',
          title: 'মেহমানে গাউছুল আজম | আন্তর্জাতিক ইসলাম প্রচারক',
          years: '১৯৩৮ - ২০০৫ ঈসায়ী',
          desc: 'আন্তর্জাতিক ইসলাম প্রচারক, বহু ইসলামী গ্রন্থের প্রণেতা, ভাষাবিদ ও বিজ্ঞানী। চেকোস্লোভাকিয়ার Academy of Science থেকে Radiation Biology বিষয়ে পিএইচ.ডি অর্জন করে বিশ্ব রেকর্ড স্থাপন করেন।',
          imageWidget: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.asset(
              'assets/images/ahmed-peyara.jpeg',
              fit: BoxFit.cover,
              width: 72,
              height: 72,
            ),
          ),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const BaghdadiBiographyScreen(),
              ),
            );
          },
        ),
        const SizedBox(height: 14),
        // Subhan Card
        _buildHighlightCard(
          context,
          name: 'হযরত মাওলানা আব্দুস সুবহান আল-কাদেরী (রাঃ)',
          title: 'গাউছে জামান | শাহপুর দরবার শরীফের প্রতিষ্ঠাতা',
          years: '১৮৭৬ - ১৯৫৫ ঈসায়ী',
          desc: 'শাহপুর দরবার শরীফের প্রতিষ্ঠাতা। ইসলামী শরীয়াতের অনুশীলন ও কাদেরীয়া তরিকার প্রচারের মাধ্যমে আত্মশুদ্ধি ও আধ্যাত্মিক সাধনার কেন্দ্র হিসেবে দরবার শরীফ প্রতিষ্ঠা করেন।',
          imageWidget: Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: primary.withOpacity(0.08),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: primary.withOpacity(0.12)),
            ),
            alignment: Alignment.center,
            child: const Text(
              'আ',
              style: TextStyle(
                color: primary,
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const SubhanBiographyScreen(),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildHighlightCard(
    BuildContext context, {
    required String name,
    required String title,
    required String years,
    required String desc,
    required Widget imageWidget,
    required VoidCallback onTap,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: primary.withValues(alpha: 0.08)),
        boxShadow: [
          BoxShadow(
            color: primary.withValues(alpha: 0.04),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Center(child: imageWidget),
          const SizedBox(height: 14),
          Text(
            name,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF111827),
              fontWeight: FontWeight.w700,
              fontSize: 15,
              height: 1.25,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: primary,
              fontWeight: FontWeight.bold,
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            years,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF9CA3AF),
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            desc,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF4B5563),
              fontSize: 13,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 14),
          Center(
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'বিস্তারিত পড়ুন',
                      style: TextStyle(
                        color: primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.arrow_forward,
                      color: primary,
                      size: 13,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class TimelineMobile extends StatelessWidget {
  const TimelineMobile({super.key});

  @override
  Widget build(BuildContext context) {
    final timeline = const [
      _TimelineItemData("১৮৭৬", "গাউছে জামান হযরত মাওলানা আব্দুস সুবহান আল-কাদেরী (রাঃ) এর জন্ম"),
      _TimelineItemData("১৯১৭", "প্রথম বিশ্বযুদ্ধে তুরস্কের পক্ষে যুদ্ধ — গাজী উপাধি লাভ"),
      _TimelineItemData("১৯৩৮", "আল্লামা ড. আহমদ পেয়ারা বাগদাদী (রাঃ) এর জন্ম"),
      _TimelineItemData("১৯৫৫", "গাউছে জামান হযরত মাওলানা আব্দুস সুবহান আল-কাদেরী (রাঃ) এর ওফাত"),
      _TimelineItemData("১৯৭৪", "বাগদাদী হুজুর ইরাকের বসরা বিশ্ববিদ্যালয়ে অধ্যাপনা শুরু"),
      _TimelineItemData("১৯৮০", "জাতিসংঘে বক্তৃতা ও শাহপুর দরবার শরীফের পীরের দায়িত্ব গ্রহণ"),
      _TimelineItemData("২০০৫", "বাগদাদী হুজুরের ইন্তেকাল — কুমিল্লার ইতিহাসে সর্ববৃহৎ জানাজা"),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader('ঐতিহাসিক পটভূমি'),
        const SizedBox(height: 4),
        const Text(
          'শাহপুর দরবার শরীফের গুরুত্বপূর্ণ ঘটনাবলী',
          style: TextStyle(
            color: Color(0xFF6B7280),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 20),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: timeline.length,
          itemBuilder: (context, index) {
            final item = timeline[index];
            final isLast = index == timeline.length - 1;
            return IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Column(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(color: primary, width: 3),
                          boxShadow: [
                            BoxShadow(
                              color: primary.withOpacity(0.15),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        alignment: Alignment.center,
                        child: const Icon(Icons.star, color: gold, size: 14),
                      ),
                      if (!isLast)
                        Expanded(
                          child: Container(
                            width: 2,
                            color: primary.withOpacity(0.35),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: primary.withOpacity(0.06)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.01),
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: primary,
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(
                                item.year,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              item.event,
                              style: const TextStyle(
                                color: Color(0xFF374151),
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                height: 1.45,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}

class _TimelineItemData {
  const _TimelineItemData(this.year, this.event);
  final String year;
  final String event;
}

class WrittenBooksMobile extends StatefulWidget {
  const WrittenBooksMobile({super.key});

  @override
  State<WrittenBooksMobile> createState() => _WrittenBooksMobileState();
}

class _WrittenBooksMobileState extends State<WrittenBooksMobile> {
  bool _showAll = false;

  final List<String> _books = const [
    "Five Pillars of Islam",
    "Light Upon Light",
    "Marriage of Muhammad (ﷺ)",
    "Marriage of Prophets",
    "Prophet's Love",
    "Arrival of Prophet Muhammad (ﷺ)",
    "Magnanimity of Muhammad (ﷺ) in the Holy Quran",
    "Allah is the Light: From Heaven to Earth",
    "Heart & Soul",
    "নূরুন্নবী (ﷺ) শুভাগমন",
    "নবী প্রেম",
    "নূরের জিকির",
    "কল্ব ও আত্মা",
    "শোগলে কল্ব",
    "বায়াতের দলিল",
    "ইয়া পাক পাঞ্জাতান (আ.) লাখো সালাম",
    "Prophets of Islam",
  ];

  @override
  Widget build(BuildContext context) {
    final visibleBooks = _showAll ? _books : _books.take(10).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader('রচিত গ্রন্থসমূহ'),
        const SizedBox(height: 14),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 1,
            mainAxisExtent: 68,
            mainAxisSpacing: 10,
          ),
          itemCount: visibleBooks.length,
          itemBuilder: (context, index) {
            final bookName = visibleBooks[index];
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFF3F4F6)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.01),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 30,
                    height: 30,
                    decoration: const BoxDecoration(
                      color: primary,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '${index + 1}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  const Icon(Icons.menu_book, color: primary, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      bookName,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF1F2937),
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        if (_books.length > 10) ...[
          const SizedBox(height: 16),
          Center(
            child: TextButton.icon(
              style: TextButton.styleFrom(
                foregroundColor: primary,
                padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: primary.withOpacity(0.2)),
                ),
                backgroundColor: primary.withOpacity(0.04),
              ),
              onPressed: () {
                setState(() {
                  _showAll = !_showAll;
                });
              },
              icon: Icon(
                _showAll ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                size: 16,
              ),
              label: Text(
                _showAll ? 'সংক্ষেপে দেখুন' : 'সব গ্রন্থ দেখুন (${_books.length}টি)',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
            ),
          ),
        ],
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: primary.withOpacity(0.04),
            borderRadius: BorderRadius.circular(12),
            border: const Border(
              left: BorderSide(color: primary, width: 4),
            ),
          ),
          child: const Text(
            '৫৫ লক্ষ টাকার কিতাব নিজ খরচে ছাপিয়ে বিশ্বব্যাপী বিনামূল্যে বিতরণ করে গেছেন।',
            style: TextStyle(
              color: Color(0xFF4B5563),
              fontSize: 13,
              fontStyle: FontStyle.italic,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
