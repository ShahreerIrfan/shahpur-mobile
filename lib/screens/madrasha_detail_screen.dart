part of '../main.dart';

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
