part of '../main.dart';

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
