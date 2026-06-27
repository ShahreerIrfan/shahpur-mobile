part of '../main.dart';

class BiographyScreen extends StatelessWidget {
  const BiographyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('জীবনী')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const PageIntro(title: 'জীবনী', icon: Icons.auto_stories_outlined),
          const SizedBox(height: 12),
          InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const BaghdadiBiographyScreen()),
              );
            },
            borderRadius: BorderRadius.circular(18),
            child: const InfoCard(
              'আল্লামা ড. আহমদ পেয়ারা বাগদাদী (রাঃ)',
              'আন্তর্জাতিক ইসলাম প্রচারক, বিজ্ঞানী ও সুফিসাধক আল্লামা ডঃ শাহজাদা সৈয়দ শেখ আহমদ পেয়ারা বাগদাদী (রাঃ) এঁর জীবন, শিক্ষা ও খেদমতের পরিচিতি।',
            ),
          ),
          InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SubhanBiographyScreen()),
              );
            },
            borderRadius: BorderRadius.circular(18),
            child: const InfoCard(
              'মাওলানা আব্দুস সুবহান আল-কাদেরী (রাঃ)',
              'শাহপুর দরবার শরীফের প্রতিষ্ঠাতা শায়খুল কুররা গাউছে জামান হযরত মাওলানা আব্দুস সুবহান আল-কাদেরী (রাঃ) এঁর জীবন ও অবদান।',
            ),
          ),
        ],
      ),
    );
  }
}

class BaghdadiBiographyScreen extends StatelessWidget {
  const BaghdadiBiographyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('জীবনী'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero section
            Stack(
              children: [
                // Background Image
                Container(
                  height: 280,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage(
                        'https://images.unsplash.com/photo-1564769625905-50e93615e769?q=80&w=2000&auto=format',
                      ),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                // Overlay Gradient
                Container(
                  height: 280,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.white.withValues(alpha: 0.95),
                        Colors.white.withValues(alpha: 0.85),
                        paper.withValues(alpha: 0.7),
                      ],
                    ),
                  ),
                ),
                // Content
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'بِسْمِ اللَّهِ الرَّحْمَنِ الرَّحِيمِ',
                        style: TextStyle(
                          color: primary,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'আল্লামা ডঃ শাহজাদা সৈয়দ শেখ আহমদ পেয়ারা বাগদাদী (রাঃ)',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: primaryDark,
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: const [
                          _Badge('মেহমানে গাউছুল আজম'),
                          _Badge('মুজাদ্দেদে জামান'),
                          _Badge('আন্তর্জাতিক ইসলাম প্রচারক'),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        '৯ ডিসেম্বর ১৯৩৮ — ২৭ ফেব্রুয়ারী ২০০৫',
                        style: TextStyle(
                          color: primary,
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Center(
                        child: Container(
                          width: 160,
                          height: 160,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: primary.withValues(alpha: 0.3),
                              width: 4,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.1),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                            image: const DecorationImage(
                              image: AssetImage('assets/images/ahmed-peyara.jpeg'),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // Quick Stats
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                childAspectRatio: 1.6,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                children: const [
                  _StatCard(
                    icon: Icons.school,
                    title: 'পিএইচ.ডি',
                    subtitle: 'Radiation Biology',
                  ),
                  _StatCard(
                    icon: Icons.public,
                    title: '১৭+ দেশ',
                    subtitle: 'ইসলাম প্রচার সফর',
                  ),
                  _StatCard(
                    icon: Icons.menu_book,
                    title: '১৭ কিতাব',
                    subtitle: 'বহু ভাষায় রচিত',
                  ),
                  _StatCard(
                    icon: Icons.mosque,
                    title: '১৫০+ খানকাহ',
                    subtitle: 'বিশ্বব্যাপী প্রতিষ্ঠিত',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Main biography content
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // সংক্ষিপ্ত পরিচিতি
                  const _SectionHeader(
                    title: 'সংক্ষিপ্ত পরিচিতি',
                    icon: Icons.workspace_premium,
                  ),
                  _HighlightCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'আন্তর্জাতিক ইসলাম প্রচারক, বহু ইসলামী গ্রন্থের প্রণেতা, ভাষাবিদ ও বিজ্ঞানী, আশেকে রাসূল সাল্লাল্লাহু আলাইহি ওয়াসাল্লাম, পেদানে পাক পাঞ্জাতান আলাইহিমুস সালাম, জিকিনে রাসূল সাল্লাল্লাহু আলাইহি ওয়াসাল্লাম এঁর প্রবর্তক, মেহমানে গাউছুল আজম (রাঃ), মুজাদ্দেদে জামান, আলহাজ্ব শেখ শাহজাদা সৈয়দ ড. আহমদ পেয়ারা বাগদাদী আল-কাদেরী (রা:) ছিলেন বিশ্বব্যাপী আলোড়ন সৃষ্টিকারী ইসলামী গবেষক ও সূফিসাধক।',
                          style: TextStyle(height: 1.6, fontSize: 14),
                        ),
                        SizedBox(height: 10),
                        Text(
                          'লক্ষ লক্ষ মুরিদ ভক্তের নয়নমণি, ইরাক বসরা বিশ্ববিদ্যালয়ের প্রাক্তন অধ্যাপক, পীরে কামেল ড. শাহজাদা শেখ আহমদ পেয়ারা বাগদাদী (রাঃ) মহান আধ্যাত্মিক সাধক গাউছুজ্জামান হযরত মাওলানা আবদুছ ছোবহান আল-কাদেরী (রাঃ)-এর দ্বিতীয় ছাহেবজাদা। তাঁর পিতা শাহ আবদুছ ছোবহান আল-কাদেরী (রা:) একজন কামেল মুর্শিদ ও জগত বিখ্যাত আলেম। তিনি দীনের মুজাদ্দেদ ও মক্কা শরীফ থেকে খেতাব প্রাপ্ত শায়খুল কেবারাহ ছিলেন।',
                          style: TextStyle(height: 1.6, fontSize: 14),
                        ),
                      ],
                    ),
                  ),

                  // জন্ম ও বংশ পরিচয়
                  const _SectionHeader(
                    title: 'জন্ম ও বংশ পরিচয়',
                    icon: Icons.people_outline,
                  ),
                  const _ParagraphText(
                    'শাহজাদা সৈয়দ শেখ আহমদ পেয়ারা বাগদাদী কুমিল্লা জেলার কোতোয়ালী থানার পাঁচথুবী ইউনিয়নের শাহপুর গ্রামে ১৯৩৮ খ্রিস্টাব্দের ৯ ডিসেম্বর জন্ম গ্রহণ করেন। তিনি মাতৃ ও পিতৃ উভয় কূল থেকে সৈয়দ বংশীয় ছিলেন।',
                  ),
                  const _ParagraphText(
                    'তাঁর মূল নাম শাহজাদা আহমদ পেয়ারা। শৈশব থেকে তাঁর আম্মা তাকে বাগদাদী নামে ডাকতেন। পরবর্তীতে তিনি বাগদাদ শরীফ থেকেও "মেহমানে গাউছুল আজম" ও "বাগদাদী" উপাধি লাভ করেন। শৈশব কাল থেকেই মহান আধ্যাত্মিক সাধনা ও খোদাভীরু, নবী সাল্লাল্লাহু আলাইহি ওয়াসাল্লাম এর প্রেম, গাউছে পাক (রাঃ) এঁর প্রেম, মিতভাষী, সংযমী, বিনয়ী, অতিথিপরায়ন, আত্মপ্রত্যয়ী, ন্যায়নিষ্ঠাবান ও कर्तव्यপরায়নতা লক্ষণগুলি প্রকাশ পায়।',
                  ),
                  const _ParagraphText(
                    'হযরত আবদুল কাদের জীলানী (রাঃ) এর চার নাতি ইসলাম প্রচারের জন্য বাংলাদেশে আগমন করেন। কুমিল্লার দেবিদ্বার উপজেলার চরবাকর এলাকায় হযরত সৈয়দ বাকের (রাঃ) এর মাজার শরীফ অবস্থিত। হযরত সৈয়দ বাকের (রাঃ) এর বংশে জন্ম গ্রহণ করেন বাগদাদী হুজুরের পিতা গাউছুজ্জামান মাওলানা শাহ আবদুছ ছোবহান আল-কাদেরী (রাঃ)।',
                  ),

                  // শিক্ষাজীবন ও গবেষণা
                  const _SectionHeader(
                    title: 'শিক্ষাজীবন ও গবেষণা',
                    icon: Icons.school_outlined,
                  ),
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    childAspectRatio: 1.6,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    children: const [
                      _EducationCard(
                        school: 'কুমিল্লা জিলা স্কুল',
                        degree: 'মাধ্যমিক',
                      ),
                      _EducationCard(
                        school: 'নটরডেম কলেজ, ঢাকা',
                        degree: 'উচ্চ মাধ্যমিক',
                      ),
                      _EducationCard(
                        school: 'বাকৃবি, ময়মনসিংহ',
                        degree: 'Entomology — অনার্স',
                      ),
                      _EducationCard(
                        school: 'Academy of Science, Czechoslovakia',
                        degree: 'Radiation Biology — পিএইচ.ডি (বিশ্ব রেকর্ড)',
                        isGold: true,
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  const _ParagraphText(
                    'তিনি আরবী, বাংলা, ইংরেজি, উর্দু, ফার্সি, হিন্দি ও জাপানি — মোট ৭টি ভাষা জানতেন।',
                  ),

                  // কর্মজীবন
                  const _SectionHeader(
                    title: 'কর্মজীবন',
                    icon: Icons.work_outline,
                  ),
                  const _ParagraphText(
                    '১৯৭৪ সালে ইরাক সরকার কর্তৃক বাংলাদেশ থেকে প্রফেসর পদে লোক নিয়োগের বিজ্ঞপ্তি দেওয়া হয়। এতে প্রায় দুই হাজার দরখাস্ত পড়ে। তাঁর আম্মাজানের ভবিষ্যদ্বাণী অনুসারে তিনি ইরাকের বসরা বিশ্ববিদ্যালয়ে ১৯৭৪-১৯৭৬ সাল পর্যন্ত অধ্যাপনা করেন। বসরা বিশ্ববিদ্যালয় তাকে তৎকালে ৬০,০০০ টাকা মাসিক বেতন পরিশোধ করত।',
                  ),
                  const _ParagraphText(
                    'তদুপরি চাকরির জৌলুসপূর্ণ জীবন ছেড়ে তিনি বড় পীর হযরত আবদুল কাদের জীলানী (রাঃ) এর দরবারে খেদমত ও রিয়াজত সাধনায় চলে আসেন। গাউছে পাকের দরবারে তাঁকে "বাবে শেখ" নামে মাকাম প্রদান করা হয়। দুনিয়া বিমুখ বাগদাদী হুজুর নিজের পরিবারের জন্য একটি ভাল ঘরও তৈরী করে যাননি।',
                  ),

                  // বিশ্বব্যাপী ইসলাম প্রচার
                  const _SectionHeader(
                    title: 'বিশ্বব্যাপী ইসলাম প্রচার',
                    icon: Icons.flight_takeoff,
                  ),
                  Column(
                    children: const [
                      _TimelineItem(
                        year: '১৯৮০',
                        title: 'আমেরিকায় ১৫০ গির্জার সুপারিনটেনডেন্টকে পরাজিত',
                        desc: 'হারভার্ড ইউনিভার্সিটি থেকে ২০০০ বৎসর পূর্বের বাইবেল সংগ্রহ করে প্রমাণ করলেন ইসলাম ধর্মই আল্লাহর মনোনীত ধর্ম। ফিলিপাইনের চারজন বিজ্ঞানী Five Pillars of Islam পড়ে মুসলমান হন।',
                      ),
                      _TimelineItem(
                        year: '১৯৮০',
                        title: 'জাতিসংঘে ঐতিহাসিক বক্তৃতা',
                        desc: 'প্রেসিডেন্ট জিমি কার্টারের আমন্ত্রণে আধ্যাত্মিক নেতা হিসেবে জাতিসংঘে ইসলামের উপর বক্তব্য রাখেন। ডাইরেক্টর কুরআন শরীফ উপহার দেন।',
                      ),
                      _TimelineItem(
                        year: '১৯৮৮',
                        title: 'যুক্তরাজ্যে ঈদে মিলাদুন্নবী কনফারেন্স',
                        desc: 'বার্মিংহামে প্রথম ঈদে মিলাদুন্নবী (ﷺ) কনফারেন্সে আখেরী মোনাজাত পরিচালনা করেন।',
                      ),
                      _TimelineItem(
                        year: '১৯৯৫-৯৮',
                        title: 'ইরাক ও ওয়াশিংটন ডিসি কনফারেন্স',
                        desc: 'ইরাকে হিউম্যান রাইটস কনফারেন্সে বক্তব্য রাখেন। ওয়াশিংটনে ১৫০ বক্তার মধ্যে প্রথম স্থান অধিকার করেন।',
                      ),
                      _TimelineItem(
                        year: '২০০০',
                        title: 'সিঙ্গাপুর, দক্ষিণ কোরিয়া ও জাপান',
                        desc: 'সিঙ্গাপুরে ২টি খানকা উদ্বোধন। দক্ষিণ কোরিয়া পাজু মসজিদ উদ্বোধন। জাপানে জুমার ইমামতি।',
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  const Card(
                    margin: EdgeInsets.only(bottom: 16),
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Text(
                        'সফর করা দেশসমূহ: সৌদি আরব, ইরাক, ইরান, কুয়েত, তুরস্ক, যুক্তরাষ্ট্র, যুক্তরাজ্য, বুলগেরিয়া, চেকোস্লোভাকিয়া, ফ্রান্স, জার্মানি, গ্রীস, হাঙ্গেরি, রুমানিয়া, সিঙ্গাপুর, দক্ষিণ কোরিয়া, ভারত ও জাপান।',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ),

                  // দাওয়াতি ও বক্তৃতার ধারা
                  const _SectionHeader(
                    title: 'দাওয়াতি ও বক্তৃতার ধারা',
                    icon: Icons.mic_none,
                  ),
                  const _ParagraphText(
                    'বক্তৃতায় "পয়েন্ট ভিত্তিক তাকরীর" পদ্ধতি অনুসরণ করতেন। মূল বিষয়: নবীপ্রেম, শানে মোস্তফা (ﷺ), তাকওয়া, দুনিয়াবিমুখ জীবন, দানশীলতা। তাঁর বক্তব্য শ্রোতাদের হৃদয়ে আলোর সঞ্চার করত।',
                  ),
                  const _ParagraphText(
                    'তিনি লিখিত দিয়েছেন যে, "বিধর্মীদের জন্য তাবলীগ, আর মুসলমানদের জন্য তা\'লিম"। আমেরিকান মুসলিম মিশনের নেতা ইমাম ওয়ারিদ দীন মুহাম্মদ যাঁর হাতে ১০ লক্ষ খৃস্টান মুসলমান হয়েছেন তাঁর সাথে সৈয়দ ড. আহমদ পেয়ারা বাগদাদী (রা:) বোস্টন মসজিদে ধর্মীয় নীতি মালার উপর গুরুত্বপূর্ণ আলোচনা করেছেন।',
                  ),

                  // রচিত গ্রন্থসমূহ
                  const _SectionHeader(
                    title: 'রচিত গ্রন্থসমূহ',
                    icon: Icons.book_outlined,
                  ),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _baghdadiBooks.length,
                    itemBuilder: (context, index) {
                      return _BookListItem(
                        number: index + 1,
                        title: _baghdadiBooks[index],
                      );
                    },
                  ),
                  const SizedBox(height: 10),
                  const _ParagraphText(
                    'বিশ্বে আলোড়ন সৃষ্টিকারী এসব কিতাব পড়ে সারা বিশ্বে অসংখ্য বিধর্মী মুসলমান হয়েছেন। তিনি জীবদ্দশায় ৫৫ লক্ষ টাকার কিতাব নিজ খরচে ছাপিয়ে বিনামূল্যে বিতরণ করেছেন। জীবনের শেষ গাড়িটিও বিক্রি করে বই ছেপে দান করে যান।',
                    isItalic: true,
                  ),

                  // খেলাফত ও আধ্যাত্মিক মর্যাদা
                  const _SectionHeader(
                    title: 'খেলাফত ও আধ্যাত্মিক মর্যাদা',
                    icon: Icons.mosque_outlined,
                  ),
                  const _ParagraphText(
                    'শরীয়তের কঠোর অনুসারী বাগদাদী হুজুর তাঁর পিতা এবং হযরত আবদুল কাদের জীলানী (রা) এর দরবার মোতাওয়াল্লী আল্লামা সৈয়দ ইউসুফ আল-জীলানী হতে খেলাফত প্রাপ্ত হন। পরবর্তী মোতাওয়াল্লী সৈয়দ আবদুর রহমান আল-জীলানীও তাঁকে খেলাফত প্রদান করেন। এছাড়াও বাগদাদ শরীফের ৩৩জন কুতুব/খাদেম হুজুরকে বরকতান খেলাফত দান করেন।',
                  ),
                  const _ParagraphText(
                    'তিনি দীর্ঘ ২৬ বৎসর পীর মুরীদীর দায়িত্ব পালন করে বাংলাদেশসহ বিশ্বের বিভিন্ন দেশে প্রায় ১৫০টির বেশী কাদেরীয়া তরিকার খানকাহ শরীফ (আধ্যাত্মিক কেন্দ্র) প্রতিষ্ঠা করেন। তিনি ছোবহানিয়া ইসলামিক সেন্টার-এর প্রতিষ্ঠাতা চেয়ারম্যান ছিলেন। বাংলাদেশ ইসলামী ফ্রন্টের প্রেসিডিয়াম মেম্বার ছিলেন।',
                  ),

                  // ইন্তেকাল
                  const _SectionHeader(
                    title: 'ইন্তেকাল',
                    icon: Icons.favorite_border,
                  ),
                  _HighlightCard(
                    isGrey: true,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          '১৯৮০ সালে কুমিল্লা শাহপুর দরবার শরীফের পীরের দায়িত্বভার গ্রহণ করে ২০০৫ সাল পর্যন্ত আধ্যাত্মিক খিদমতে আঞ্জাম দেন। তিনি ২৭ ফেব্রুয়ারী ২০০৫, ১৭ মুহররম ১৪ ২৬ হিজরী, সোমবার শাহ আবদুল্লাহ কাদেরী (রা) এর মাজার জিয়ারত করে দরূদ শরীফ পড়তে পড়তে সন্ধ্যা ৬:১১ মিনিটে ইন্তেকাল করেন।',
                          style: TextStyle(height: 1.6, fontSize: 14),
                        ),
                        SizedBox(height: 10),
                        Text(
                          'কুমিল্লার ইতিহাসের সর্ববৃহৎ মুসল্লী সমাগম হয়েছিল হুজুরের জানাযায়। জানাজার সময় লাখো মুসল্লীর ঢল নামলে গোমতী নদীর খেয়া নৌকায় পারাপার সংকুলান না হওয়ায় অলৌকিকভাবে নদী শুকিয়ে পথ হয়ে যায় — এ ঘটনা সর্বজনবিদিত।',
                          style: TextStyle(height: 1.6, fontSize: 14),
                        ),
                        SizedBox(height: 10),
                        Text(
                          'কুমিল্লা সদর উপজেলার পাঁচথুবী ইউনিয়নের শাহপুর গ্রামে গোমতী নদীর তীরে হুজুরের মায়ের কদমের নিচে মাজার শরীফ অবস্থিত। ইন্তেকালের পরও মক্কা শরীফে তাওয়াফরত অবস্থায় ও মাহফিলে ওয়াজরত অবস্থায় এবং বিভিন্ন মাজার জিয়ারত অবস্থায় স্বশরীরে অনেকে তাঁকে দেখেছেন এবং কথাও বলেছেন।',
                          style: TextStyle(height: 1.6, fontSize: 14),
                        ),
                      ],
                    ),
                  ),

                  // খেলাফত ও উত্তরসূরি
                  const SizedBox(height: 10),
                  _HighlightCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'খেলাফত ও উত্তরসূরি',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: primaryDark,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'তিনি ইন্তেকালের পূর্বে তার একমাত্র শাহজাদা শেখ সৈয়দ গোলাম মুহাম্মদ আবদুল কাদের কাওকাব আল-কাদেরী কে খেলাফত প্রদান করে যান। বর্তমানে তিনি দরবারের পীর ও আধ্যাত্মিক দায়িত্ব পালন করছেন।',
                          style: TextStyle(height: 1.6, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SubhanBiographyScreen extends StatelessWidget {
  const SubhanBiographyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('জীবনী'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero section
            Stack(
              children: [
                // Background Image
                Container(
                  height: 280,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage(
                        'https://images.unsplash.com/photo-1597075903824-7f8c0089e870?q=80&w=2000&auto=format',
                      ),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                // Overlay Gradient
                Container(
                  height: 280,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.white.withValues(alpha: 0.95),
                        Colors.white.withValues(alpha: 0.85),
                        paper.withValues(alpha: 0.7),
                      ],
                    ),
                  ),
                ),
                // Content
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'بِسْمِ اللَّهِ الرَّحْمَنِ الرَّحِيمِ',
                        style: TextStyle(
                          color: primary,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'শায়খুল কুররা গাউছে জামান হযরত মাওলানা আব্দুস সুবহান আল-কাদেরী (রাঃ)',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: primaryDark,
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: const [
                          _Badge('মোজাদ্দেদে জামান'),
                          _Badge('আলহাজ্ব গাজী শাহসুফি'),
                          _Badge('দরবার শরীফের প্রতিষ্ঠাতা'),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        '১৮৭৬ — ৩ মার্চ ১৯৫৫ ঈসায়ী',
                        style: TextStyle(
                          color: primary,
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Center(
                        child: Container(
                          width: 140,
                          height: 140,
                          decoration: BoxDecoration(
                            color: primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: primary.withValues(alpha: 0.3),
                              width: 4,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.08),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          alignment: Alignment.center,
                          child: const Text(
                            'আ',
                            style: TextStyle(
                              fontSize: 54,
                              fontWeight: FontWeight.bold,
                              color: primary,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // Quick Stats Grid
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                childAspectRatio: 1.6,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                children: const [
                  _StatCard(
                    icon: Icons.self_improvement,
                    title: 'শায়খুল কুররা',
                    subtitle: 'হেরেম শরীফ থেকে প্রাপ্ত',
                  ),
                  _StatCard(
                    icon: Icons.language,
                    title: '১০ বছর',
                    subtitle: 'বিদেশ সফর ও রিয়াজত',
                  ),
                  _StatCard(
                    icon: Icons.menu_book,
                    title: '৫ ভাষা',
                    subtitle: 'উর্দু, বাংলা, আরবি ও আরো',
                  ),
                  _StatCard(
                    icon: Icons.shield,
                    title: 'গাজী',
                    subtitle: 'প্রথম বিশ্বযুদ্ধ ১৯১৭',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Main Content
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // সংক্ষিপ্ত পরিচিতি
                  const _SectionHeader(
                    title: 'সংক্ষিপ্ত পরিচিতি',
                    icon: Icons.workspace_premium,
                  ),
                  _HighlightCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'বাংলাদেশের সুফি দরবেশদের ইতিহাসে কুমিল্লার শাহপুর দরবার শরীফ একটি উজ্জল নাম। গোমতী নদীর উত্তর পাড় ঘেঁষে পাঁচথুবী ইউনিয়নের সীমান্তবর্তী গ্রাম শাহপুর। ইসলামী শরীয়াতের অনুশীলন, কাদেরীয়া তরিকার প্রচার, আত্মশুদ্ধি, কঠোর রিয়াজত, আধ্যাত্মিক শিক্ষা সাধনার জন্য শাহপুর দরবার শরীফ অত্যন্ত পরিচিত। দেশ বিদেশে রয়েছে এ দরবারের লক্ষ লক্ষ আশেক-ভক্ত-মুরিদ।',
                          style: TextStyle(height: 1.6, fontSize: 14),
                        ),
                        SizedBox(height: 10),
                        Text(
                          'হযরত নুরুদ্দীন বন্দীশাহ (রা) এর আশেক ও ভক্ত মাওলানা আব্দুস সোবহান আল-কাদেরী (রা) এখানে রিয়াজত সাধনা করতেন এবং শরীয়ত তরিকত চর্চার অন্যতম আধ্যাত্মিক কেন্দ্র শাহপুর দরবার শরীফ প্রতিষ্ঠা করেন।',
                          style: TextStyle(height: 1.6, fontSize: 14),
                        ),
                      ],
                    ),
                  ),

                  // শাহপুরের ইতিহাস
                  const _SectionHeader(
                    title: 'শাহপুরের ইতিহাস',
                    icon: Icons.mosque_outlined,
                  ),
                  const _ParagraphText(
                    'হযরত নুরুদ্দীন শাহ (রা) নামে একজন মহান জ্ঞান তাপস ভারতের বিহার রাজ্যের ভাগলপুর জেলায় জন্ম নিয়েছিলেন। উনার পূর্ব পুরুষগণ আরব অঞ্চল থেকে বিহারে হিজরত করেন। তিনি ত্রিপুরা অঞ্চলে ইসলাম প্রচার করেন।',
                  ),
                  const _ParagraphText(
                    'হযরত নুরুদ্দীন শাহ (রা) একবার বিনা অপরাধে বন্দী হয়েছিলেন এবং জেলখানায় তাঁর অনেক অলৌকিক কারামত প্রকাশ পায়। এজন্য তাকে বন্দীশাহ (রা) বলা হয়। এ সাধক বন্দীশাহ বর্তমান শাহপুর অঞ্চলে আগমন করলে উনার নাম অনুসারে এলাকার নাম হয় "শাহপুর"। শাহপুর দরবার শরীফে বকুল তলে হযরত নুরুদ্দীন বন্দীশাহ (রা) এর পবিত্র মাজার অবস্থিত।',
                  ),

                  // জন্ম ও বংশ পরিচয়
                  const _SectionHeader(
                    title: 'জন্ম ও বংশ পরিচয়',
                    icon: Icons.people_outline,
                  ),
                  const _ParagraphText(
                    'শাইখুল কুররাহ গাউছে জামান মোজাদ্দেদে জামান আলহাজ্ব গাজী শাহসুফি আব্দুস সোবহান আল কাদেরী (রা)-র জন্ম ১৮৭৬ ইংরেজী। পিতার নাম হযরত সাইয়েদ মীর কাসেম আলী, মাতা হযরত সৈয়দা জোহরা খাতুন, চাঁন্দপুর কুমিল্লা।',
                  ),
                  const _ParagraphText(
                    'বাংলার জমিনে ইসলাম প্রচার ও প্রসারের উদ্দেশ্যে পীরানে পীর মাহবুবে সোবহানী সাইয়্যেদেনা হযরত বড় পীর মহিউদ্দিন আব্দুল কাদের জিলানী (রা) এর শাহজাদাগণের মধ্যে পাঁচজন নাতি মোগল আমলে বহু পথ পরিক্রমা অতিক্রম করে ভারত বর্ষ হয়ে বাংলাদেশে আগমন করেন।',
                  ),

                  // শিক্ষা জীবন
                  const _SectionHeader(
                    title: 'শিক্ষা জীবন',
                    icon: Icons.school_outlined,
                  ),
                  const _ParagraphText(
                    'বাবা মায়ের কাছে প্রাথমিক শিক্ষা লাভের পর প্রাতিষ্ঠানিক শিক্ষার জন্য তিনি কুমিল্লা শহরে হুচ্ছামিয়া সিনিয়র মাদ্রাসায় ভর্তি হন। তিনি তার কঠোর অধ্যবসায় দ্বারা শিক্ষাজীবনে মাদ্রাসার সব শ্রেণীর পরীক্ষায় কৃতিত্বের সাথে উত্তীর্ণ হন। পাঁচটি ভাষা জানতেন।',
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'রচিত গ্রন্থসমূহ:',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: primaryDark,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _subhanBooks.length,
                    itemBuilder: (context, index) {
                      return _BookListItem(
                        number: index + 1,
                        title: _subhanBooks[index],
                      );
                    },
                  ),

                  // হজ্ব পালন ও বিদেশ সফর
                  const _SectionHeader(
                    title: 'হজ্ব পালন ও বিদেশ সফর',
                    icon: Icons.flight_takeoff,
                  ),
                  const _ParagraphText(
                    'মায়ের অনুমতি নিয়ে এই মহান সুফিসাধক আল্লাহ তালার উপর পরিপূর্ণ তাওয়াক্কুল করে মাত্র ২৩ টাকা নিয়ে পবিত্র হজ পালনের উদ্দেশ্যে রওনা হন এবং হজ কার্যক্রম সম্পূর্ণ করেন।',
                  ),
                  const _ParagraphText(
                    'এরপর দীর্ঘ ১০ বছর সময় মক্কা, মদিনা, ইরাক, মিশর, ও ভারত উপমহাদেশসহ বিভিন্ন স্থান ভ্রমণ করেন। হেরেম শরীফের ওস্তাদদের নিকট থেকে শায়খ-উল-কুররা ডিগ্রি লাভ করেন।',
                  ),

                  // আধ্যাত্মিক সাধনা
                  const _SectionHeader(
                    title: 'আধ্যাত্মিক সাধনা',
                    icon: Icons.self_improvement,
                  ),
                  const _ParagraphText(
                    'তিনি তৎকালীন প্রখ্যাত সুফি সাধক শাহ আব্দুল আজিজ (রা) এর কাছে জ্ঞান অর্জন করেন এবং আধ্যাত্মিক সাধনায় নিজেকে নিয়োজিত করেন। আজমীর শরীফে সুলতানুল হিন্দ খাজা মঈনুদ্দিন চিশতি (রা), দিল্লিতে হযরত খাজা নিজামুদ্দিন (রা) সহ অনেক আউলিয়া কেরামের জিয়ারত করেন।',
                  ),
                  _HighlightCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'কঠোর চিল্লা (আধ্যাত্মিক সাধনা):',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: primaryDark,
                          ),
                        ),
                        SizedBox(height: 10),
                        _ChillaItem('এক কেজি চনা বুট খেয়ে ৪০ দিন অতিবাহিত'),
                        _ChillaItem('সাতটি লাং দ্বারা ৪০ দিনের চিল্লা'),
                        _ChillaItem('লবণ-তেল-মসলা বিহীন কচু শাকের সিদ্ধ পানি খেয়ে ৬ মাসের চিল্লা'),
                        _ChillaItem('দিবারাত্র কোরআন তেলাওয়াত ও জিকিরে নিমগ্ন'),
                      ],
                    ),
                  ),

                  // যেভাবে গাজী হলেন
                  const _SectionHeader(
                    title: 'যেভাবে গাজী হলেন',
                    icon: Icons.shield_outlined,
                  ),
                  const _ParagraphText(
                    'হযরত মাওলানা আব্দুস সোবহান রাদিউল্লাহ একজন মুজাদ্দেদে জামান ছিলেন। ব্রিটিশদের বিরুদ্ধে যুদ্ধ করার জন্য ১৯১৭ সালে প্রথম মহাযুদ্ধে তুরস্কের পক্ষে যুদ্ধ করেন। ব্রিটিশ বন্দীশালায় মৃত্যুদণ্ডপ্রাপ্ত হয়ে বধভূমিতে দণ্ড দেয়ার জন্য নিয়ে যাওয়া হয়। তার বিরুদ্ধে আনীত দণ্ডলিপি অলৌকিকভাবে নিখোঁজ হয়ে যায় এবং তিনি রক্ষা পান।',
                  ),

                  // কারামত সমূহ
                  const _SectionHeader(
                    title: 'কারামত সমূহ',
                    icon: Icons.star_border,
                  ),
                  Column(
                    children: const [
                      _MiracleCard(
                        title: 'হযরত আবদুল কাদের জীলানী (রা) এর সাক্ষাৎ',
                        desc: 'আরবে মরুভূমির চোরাবালিতে গাধা পড়ে গেলে \'ইয়া গাউছে পাক\' বলার সাথে সাথে জ্যোতির্ময় ব্যক্তি ঘোড়ায় এসে উদ্ধার করেন।',
                      ),
                      _MiracleCard(
                        title: 'হযরত খিজির (আঃ) এর সাথে সাক্ষাৎ',
                        desc: 'নদীর তীরে মনে মনে ইচ্ছা করতেই সাদা পোশাক পরিহিত সুন্দর বৃদ্ধ এসে একসাথে আহার করলেন এবং মুহূর্তে অদৃশ্য হয়ে গেলেন।',
                      ),
                      _MiracleCard(
                        title: 'মৃত ব্যক্তিকে জীবিত করা',
                        desc: 'লাল মিয়া ওস্তাদ সাপে কামড়ে মারা গেলে জানাজার পর কবরে নেওয়ার সময় চিৎকার দিয়ে জীবিত হয়ে উঠেন — এরপর আরো ১৫ বছর জীবিত ছিলেন।',
                      ),
                      _MiracleCard(
                        title: 'ট্রেনের নিচ থেকে উদ্ধার',
                        desc: 'লাকসাম স্টেশনে ট্রেনের নিচে পড়া ব্যক্তির মাথায় হাত দিয়ে চাপ দিয়ে বললেন \'মাথা উঠিও না\' — ট্রেন চলে গেলে তিনি সম্পূর্ণ অক্ষত বেঁচে যান।',
                      ),
                    ],
                  ),

                  // সমাজ সেবা
                  const _SectionHeader(
                    title: 'সমাজ সেবা',
                    icon: Icons.favorite_border,
                  ),
                  const _ParagraphText(
                    'সমাজে মুসলমানরা মাছ ধরা, চুলকাটা, পান চাষ ও বিক্রি করাকে হেও চোখে দেখত। হুজুর নিজে তাদেরকে এসব পেশায় নিয়োজিত করে ব্যবসায় সুন্নতের অনুসারী করেন। এতে অনেক দরিদ্র শ্রেণীর লোক সফল ও বিত্তবান হয়ে ওঠেন।',
                  ),
                  const _ParagraphText(
                    'শিক্ষা বিস্তারে সমাজকে উৎসাহিত করে স্বাবলম্বী জীবন যাপনের নির্দেশ ও উৎসাহ দিতেন। মদিনার মডেলের মুসলিম রাষ্ট্র প্রতিষ্ঠার জন্য বহু পরিশ্রম করেন।',
                  ),

                  // কর্ম জীবন
                  const _SectionHeader(
                    title: 'কর্ম জীবন',
                    icon: Icons.work_outline,
                  ),
                  const _ParagraphText(
                    'হযরত শাহ আব্দুস সোবহান আল কাদেরী (রাঃ) চাঁনপুর জেলার জামরাবাদ মাদ্রাসায় এবং কুমিল্লা ইউসুফ হাই স্কুলে শিক্ষকতা করেন। তার পিতার ইন্তেকালের পর মায়ের সেবা এবং একমাত্র ছোট বোনের বিবাহ — ভাইদের প্রতি দায়দায়িত্ব তিনি পালন করেন।',
                  ),

                  // ওফাত
                  const _SectionHeader(
                    title: 'ওফাত',
                    icon: Icons.mosque_outlined,
                  ),
                  _HighlightCard(
                    isGrey: true,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'আল্লাহ প্রদত্ত সব দায়িত্ব পরিপূর্ণভাবে পালন করার পর গাউছে জামান হযরত শাহ আব্দুস সোবহান আল কাদেরী পৃথিবী থেকে বিদায় নেন।',
                          style: TextStyle(height: 1.6, fontSize: 14),
                        ),
                        SizedBox(height: 10),
                        Text(
                          '১৯৫৫ সালের ৩ মার্চ বৃহস্পতিবার রাত নয়টায় তিনি পরলোক গমন করেন। উপস্থিত স্বজনদের সাক্ষ্য অনুসারে মৃত্যুকালে তার মুখ থেকে এক টুকরা উজ্জ্বল আলোকপিণ্ড বের হয়ে যায়।',
                          style: TextStyle(height: 1.6, fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 10),
                        Text(
                          'প্রতিবছর নির্দিষ্ট তারিখের সম্পূর্ণ শরীয়ত সম্মত ভাবে শাহ আব্দুস সুবহান আল কাদেরী (রাঃ) এর বার্ষিক উরুশ শরীফ কুমিল্লার শাহপুর দরবার শরীফে অনুষ্ঠিত হয়।',
                          style: TextStyle(height: 1.6, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

const _subhanBooks = [
  "কাসিদায়ে সোবহান",
  "শোগলে কাদেরী",
  "দরশে দেল",
  "মহাসফর",
  "কেরাত শিক্ষা",
  "মৌলুদ শরীফ",
];

class _Badge extends StatelessWidget {
  const _Badge(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: primary.withValues(alpha: 0.1),
        border: Border.all(color: primary.withValues(alpha: 0.2)),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: primaryDark,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: primary.withValues(alpha: 0.05),
        border: Border.all(color: primary.withValues(alpha: 0.1)),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: primary, size: 24),
          const SizedBox(height: 6),
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: primaryDark,
            ),
            textAlign: TextAlign.center,
          ),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.icon});
  final String title;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 24, bottom: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: primary, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: primaryDark,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HighlightCard extends StatelessWidget {
  const _HighlightCard({
    required this.child,
    this.isGrey = false,
  });

  final Widget child;
  final bool isGrey;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: isGrey
            ? LinearGradient(
                colors: [
                  Colors.grey.shade50,
                  Colors.white,
                ],
              )
            : LinearGradient(
                colors: [
                  primary.withValues(alpha: 0.06),
                  Colors.white,
                ],
              ),
        border: Border.all(
          color: isGrey ? Colors.grey.shade200 : primary.withValues(alpha: 0.15),
        ),
        borderRadius: BorderRadius.circular(18),
      ),
      child: child,
    );
  }
}

class _ParagraphText extends StatelessWidget {
  const _ParagraphText(this.text, {this.isItalic = false});
  final String text;
  final bool isItalic;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        text,
        style: TextStyle(
          height: 1.65,
          fontSize: 14,
          fontStyle: isItalic ? FontStyle.italic : FontStyle.normal,
          color: Colors.grey.shade800,
        ),
      ),
    );
  }
}

class _EducationCard extends StatelessWidget {
  const _EducationCard({
    required this.school,
    required this.degree,
    this.isGold = false,
  });

  final String school;
  final String degree;
  final bool isGold;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isGold ? gold.withValues(alpha: 0.08) : Colors.white,
        border: Border.all(
          color: isGold ? gold.withValues(alpha: 0.3) : Colors.grey.shade200,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isGold ? Icons.workspace_premium : Icons.school,
            color: isGold ? Colors.orange : primary,
            size: 20,
          ),
          const SizedBox(height: 6),
          Text(
            school,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
              height: 1.2,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            degree,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }
}

class _TimelineItem extends StatelessWidget {
  const _TimelineItem({
    required this.year,
    required this.title,
    required this.desc,
  });

  final String year;
  final String title;
  final String desc;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade100),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              year,
              style: const TextStyle(
                color: primary,
                fontSize: 11,
                fontWeight: FontWeight.bold,
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
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  desc,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BookListItem extends StatelessWidget {
  const _BookListItem({required this.number, required this.title});
  final int number;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade100),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: const BoxDecoration(
              color: primary,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              '$number',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),
          const Icon(Icons.book, color: primary, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChillaItem extends StatelessWidget {
  const _ChillaItem(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.star, color: primary, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 13, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}

class _MiracleCard extends StatelessWidget {
  const _MiracleCard({required this.title, required this.desc});
  final String title;
  final String desc;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade100),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.yellow.shade50,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.star, color: Colors.amber, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  desc,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

const _baghdadiBooks = [
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
