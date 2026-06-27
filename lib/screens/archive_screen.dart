part of '../main.dart';

class SectionHeader extends StatelessWidget {
  const SectionHeader(this.title, {super.key});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 12),
      child: Center(
        child: Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w900,
            color: primaryDark,
            letterSpacing: 0.2,
          ),
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

        String viewAllLabel;
        switch (type) {
          case ArchiveType.madrasha:
            viewAllLabel = 'সব মাদ্রাসা দেখুন';
            break;
          case ArchiveType.khankah:
            viewAllLabel = 'সব খানকাহ দেখুন';
            break;
          case ArchiveType.events:
            viewAllLabel = 'সব ইভেন্ট দেখুন';
            break;
          case ArchiveType.books:
            viewAllLabel = 'সব বই দেখুন';
            break;
        }

        return Column(
          children: [
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              childAspectRatio: type == ArchiveType.events ? 0.64 : 1.05,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              children: [
                for (final item in items)
                  HomeGridCard(
                    item: item,
                    type: type,
                    onTap: () => openDetail(context, type, item),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Center(
              child: TextButton.icon(
                style: TextButton.styleFrom(
                  foregroundColor: primary,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: primary.withValues(alpha: 0.2)),
                  ),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ApiArchiveScreen(type: type),
                    ),
                  );
                },
                icon: const Icon(Icons.arrow_forward, size: 14),
                label: Text(
                  viewAllLabel,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class HomeGridCard extends StatelessWidget {
  const HomeGridCard({
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
    if (type == ArchiveType.events) {
      return _EventGridCard(item: item, onTap: onTap);
    }
    final title = text(item, type.titleKey, fallback: 'শিরোনাম নেই');
    final image = api.mediaUrl(text(item, type.imageKey));
    final subtitle = _subtitle(item, type);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: primary.withValues(alpha: 0.08)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.015),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Top Image
            Expanded(
              child: Stack(
                children: [
                  Positioned.fill(
                    child: image.isEmpty
                        ? Container(
                            color: primary.withValues(alpha: 0.06),
                            child: Icon(type.icon, color: primary, size: 28),
                          )
                        : CachedNetworkImage(
                            imageUrl: image,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Container(
                              color: primary.withValues(alpha: 0.06),
                            ),
                            errorWidget: (context, url, error) => Container(
                              color: primary.withValues(alpha: 0.06),
                              child: Icon(type.icon, color: primary, size: 28),
                            ),
                          ),
                  ),
                  // If Event, show Status badge on top of image
                  if (type == ArchiveType.events)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: _getEventStatusColor(item).withValues(alpha: 0.95),
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x25000000),
                              blurRadius: 4,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Text(
                          getEventCountdownText(item),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            // Bottom Info
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1F2937),
                      height: 1.25,
                    ),
                  ),
                  if (subtitle.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String getEventCountdownText(Map<String, dynamic> item) {
  final status = effectiveEventStatus(item);
  if (status == 'cancelled') return 'বাতিল';
  if (status == 'completed') return 'সম্পন্ন';
  if (status == 'ongoing') return 'চলমান';

  final start = eventStartDateTime(item);
  if (start == null) return 'আসন্ন';

  final diff = start.difference(DateTime.now());
  if (diff.isNegative) return 'চলমান';

  if (diff.inDays >= 1) {
    return '${toBanglaNumber(diff.inDays)} দিন বাকি';
  } else if (diff.inHours >= 1) {
    return '${toBanglaNumber(diff.inHours)} ঘণ্টা বাকি';
  } else {
    final mins = diff.inMinutes;
    return '${toBanglaNumber(mins > 0 ? mins : 1)} মিনিট বাকি';
  }
}

Color _getEventStatusColor(Map<String, dynamic> item) {
  final status = effectiveEventStatus(item);
  switch (status) {
    case 'ongoing':
      return const Color(0xFF10B981);
    case 'completed':
      return const Color(0xFF6B7280);
    case 'cancelled':
      return const Color(0xFFEF4444);
    default:
      return primary;
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

class _EventGridCard extends StatefulWidget {
  const _EventGridCard({required this.item, required this.onTap});

  final Map<String, dynamic> item;
  final VoidCallback onTap;

  @override
  State<_EventGridCard> createState() => _EventGridCardState();
}

class _EventGridCardState extends State<_EventGridCard> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final title = text(widget.item, 'title', fallback: 'ইভেন্ট');
    final image = api.mediaUrl(text(widget.item, 'poster'));
    final category = text(widget.item, 'category_display', fallback: 'মাহফিল');
    final dateText = text(widget.item, 'start_date');
    final parsedDate = DateTime.tryParse(dateText);
    final formattedDate = parsedDate != null ? formatBanglaDate(parsedDate) : '';

    final status = effectiveEventStatus(widget.item);
    final remaining = eventRemaining(widget.item);
    final info = eventStatusInfo(status);
    final showCountdown = status == 'upcoming' && remaining != null;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: primary.withValues(alpha: 0.08)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.015),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: widget.onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Top Image
            Expanded(
              flex: 10,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: image.isEmpty
                        ? Container(
                            color: primary.withValues(alpha: 0.06),
                            child: const Icon(Icons.event_outlined, color: primary, size: 28),
                          )
                        : CachedNetworkImage(
                            imageUrl: image,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Container(
                              color: primary.withValues(alpha: 0.06),
                            ),
                            errorWidget: (context, url, error) => Container(
                              color: primary.withValues(alpha: 0.06),
                              child: const Icon(Icons.event_outlined, color: primary, size: 28),
                            ),
                          ),
                  ),
                  // Dark overlay gradient
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withValues(alpha: 0.15),
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.25),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Category Badge (Overlay Top-Left)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        category,
                        style: const TextStyle(
                          color: primaryDark,
                          fontSize: 8.5,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  // Date Badge (Overlay Top-Right)
                  if (formattedDate.isNotEmpty)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: primary.withValues(alpha: 0.95),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          formattedDate,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 8.5,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            // Bottom Info
            Expanded(
              flex: 13,
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'দাওয়াতনামা',
                          style: TextStyle(
                            color: Color(0xFFD97706),
                            fontSize: 9.5,
                            fontWeight: FontWeight.w900,
                            letterSpacing: .5,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                      ],
                    ),
                    // Countdown Panel
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: info.background,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: info.border.withValues(alpha: 0.6), width: 0.8),
                      ),
                      child: showCountdown
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                _buildTimerBox(remaining.inDays, 'দিন'),
                                _buildTimerBox(remaining.inHours % 24, 'ঘণ্টা'),
                                _buildTimerBox(remaining.inMinutes % 60, 'মি.'),
                                _buildTimerBox(remaining.inSeconds % 60, 'সে.'),
                              ],
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(info.icon, color: info.textColor, size: 11),
                                const SizedBox(width: 4),
                                Flexible(
                                  child: Text(
                                    info.title,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: info.textColor,
                                      fontSize: 9.5,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                    ),
                    // Venue Row
                    Row(
                      children: [
                        const Icon(Icons.location_on_outlined, color: primary, size: 10),
                        const SizedBox(width: 3),
                        Expanded(
                          child: Text(
                            text(widget.item, 'venue_name', fallback: 'শাহপুর দরবার শরীফ প্রাঙ্গণ'),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 9,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimerBox(int val, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: primary.withValues(alpha: 0.1)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            toBanglaNumber(val),
            style: const TextStyle(
              color: primaryDark,
              fontSize: 10,
              fontWeight: FontWeight.w900,
              height: 1.1,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              color: primary,
              fontSize: 7.5,
              fontWeight: FontWeight.w900,
              height: 1.1,
            ),
          ),
        ],
      ),
    );
  }
}
