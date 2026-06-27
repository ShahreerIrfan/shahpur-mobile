part of '../main.dart';

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
        if (items.isEmpty) {
          return const EmptyBox('এখনো কোনো তথ্য নেই');
        }
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
    if (type == ArchiveType.events) {
      return EventArchiveCard(item: item, onTap: onTap, compact: dense);
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
