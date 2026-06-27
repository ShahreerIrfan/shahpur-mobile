part of '../main.dart';

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
