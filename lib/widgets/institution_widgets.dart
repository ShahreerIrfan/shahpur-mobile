part of '../main.dart';

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
