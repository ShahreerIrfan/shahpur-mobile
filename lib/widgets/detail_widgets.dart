part of '../main.dart';

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
      case ArchiveType.announcements:
        return [
          text(item, 'category_display'),
          text(item, 'publisher_display'),
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
