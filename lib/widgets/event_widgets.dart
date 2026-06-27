part of '../main.dart';

class EventArchiveCard extends StatelessWidget {
  const EventArchiveCard({
    super.key,
    required this.item,
    required this.onTap,
    this.compact = false,
  });

  final Map<String, dynamic> item;
  final VoidCallback onTap;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final title = text(item, 'title', fallback: 'ইভেন্ট');
    final image = api.mediaUrl(text(item, 'poster'));
    final status = effectiveEventStatus(item);
    return Container(
      margin: EdgeInsets.only(bottom: compact ? 14 : 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: primaryDark.withValues(alpha: .07),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(26),
              border: Border.all(color: primary.withValues(alpha: .22)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    image.isEmpty
                        ? Container(
                            height: compact ? 160 : 190,
                            width: double.infinity,
                            color: primary.withValues(alpha: .08),
                            child: const Icon(
                              Icons.event_outlined,
                              color: primary,
                              size: 52,
                            ),
                          )
                        : CachedNetworkImage(
                            imageUrl: image,
                            height: compact ? 160 : 190,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorWidget: (context, url, error) => Container(
                              height: compact ? 160 : 190,
                              width: double.infinity,
                              color: primary.withValues(alpha: .08),
                              child: const Icon(
                                Icons.event_outlined,
                                color: primary,
                                size: 52,
                              ),
                            ),
                          ),
                    Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              primaryDark.withValues(alpha: .12),
                              primaryDark.withValues(alpha: .02),
                              primaryDark.withValues(alpha: .18),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 14,
                      left: 14,
                      right: 14,
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          EventPill(
                            label: text(
                              item,
                              'category_display',
                              fallback: 'মাহফিল',
                            ),
                            filled: false,
                          ),
                          EventPill(
                            label: eventStatusLabel(status),
                            filled: true,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'দাওয়াতনামা',
                        style: TextStyle(
                          color: Color(0xFFD97706),
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          letterSpacing: .6,
                        ),
                      ),
                      const SizedBox(height: 7),
                      Text(
                        title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFF0F172A),
                          fontSize: 18,
                          height: 1.25,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 9),
                      Text(
                        text(
                          item,
                          'short_description',
                          fallback:
                              'শাহপুর দরবার শরীফের মাহফিল ও দোয়া অনুষ্ঠান',
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          height: 1.45,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      EventCountdownPanel(item: item, compact: true),
                      EventMetaPanel(item: item),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          const Expanded(
                            child: Text(
                              'বিস্তারিত দেখুন',
                              style: TextStyle(
                                color: primary,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: primary.withValues(alpha: .10),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.arrow_forward,
                              color: primary,
                              size: 18,
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
        ),
      ),
    );
  }
}

class EventPill extends StatelessWidget {
  const EventPill({super.key, required this.label, required this.filled});

  final String label;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    if (label.isEmpty) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: filled ? primary : Colors.white.withValues(alpha: .95),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: primary.withValues(alpha: .18)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Text(
        label,
        style: TextStyle(
          color: filled ? Colors.white : primary,
          fontSize: 11,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class EventCountdownPanel extends StatefulWidget {
  const EventCountdownPanel({
    super.key,
    required this.item,
    this.compact = false,
  });

  final Map<String, dynamic> item;
  final bool compact;

  @override
  State<EventCountdownPanel> createState() => _EventCountdownPanelState();
}

class _EventCountdownPanelState extends State<EventCountdownPanel> {
  Timer? timer;

  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final status = effectiveEventStatus(widget.item);
    final remaining = eventRemaining(widget.item);
    final info = eventStatusInfo(status);
    final showCountdown = status == 'upcoming' && remaining != null;
    final blocks = showCountdown
        ? [
            ('দিন', remaining.inDays),
            ('ঘন্টা', remaining.inHours % 24),
            ('মিনিট', remaining.inMinutes % 60),
            ('সেকেন্ড', remaining.inSeconds % 60),
          ]
        : <(String, int)>[];

    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(top: widget.compact ? 18 : 22),
      padding: EdgeInsets.all(showCountdown ? 14 : 13),
      decoration: BoxDecoration(
        color: info.background,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: info.border, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: info.border.withValues(alpha: .12),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: info.color,
                  shape: BoxShape.circle,
                ),
                child: Icon(info.icon, color: Colors.white, size: 18),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      info.title,
                      style: TextStyle(
                        color: info.textColor,
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    if (!showCountdown) ...[
                      const SizedBox(height: 3),
                      Text(
                        info.message,
                        style: TextStyle(
                          color: info.textColor.withValues(alpha: .78),
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          if (showCountdown) ...[
            const SizedBox(height: 13),
            Row(
              children: [
                for (final block in blocks)
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: .58),
                        borderRadius: BorderRadius.circular(13),
                        border: Border.all(
                          color: primary.withValues(alpha: .15),
                        ),
                      ),
                      child: Column(
                        children: [
                          Text(
                            toBanglaNumber(block.$2),
                            style: const TextStyle(
                              color: primaryDark,
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            block.$1,
                            style: const TextStyle(
                              color: primary,
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class EventMetaPanel extends StatelessWidget {
  const EventMetaPanel({super.key, required this.item});

  final Map<String, dynamic> item;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFAFAFA),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.black.withValues(alpha: .05)),
      ),
      child: Column(
        children: [
          EventInfoLine(
            Icons.calendar_month_outlined,
            formatEventDateRange(item),
          ),
          EventInfoLine(Icons.access_time, formatEventTimeRange(item)),
          EventInfoLine(
            Icons.location_on_outlined,
            text(
              item,
              'venue_name',
              fallback: text(
                item,
                'district_name',
                fallback: 'স্থান উল্লেখ নেই',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class EventInfoLine extends StatelessWidget {
  const EventInfoLine(this.icon, this.label, {super.key});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    if (label.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: primary.withValues(alpha: .12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: primary, size: 15),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 5),
              child: Text(
                label,
                style: const TextStyle(
                  color: Color(0xFF4B5563),
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  height: 1.35,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class EventDetailBody extends StatelessWidget {
  const EventDetailBody({super.key, required this.item});

  final Map<String, dynamic> item;

  @override
  Widget build(BuildContext context) {
    final title = text(item, 'title', fallback: 'ইভেন্ট');
    final image = api.mediaUrl(text(item, 'poster'));
    final photos = listOfMaps(item['photos']);
    final schedule = listOfMaps(item['schedule']);
    final speakers = listOfMaps(item['speakers']);
    final status = effectiveEventStatus(item);

    return ListView(
      padding: EdgeInsets.zero,
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(16, 18, 16, 22),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFEFFFF8), Colors.white, Color(0xFFEFFFF8)],
            ),
            border: Border(
              bottom: BorderSide(color: primary.withValues(alpha: .12)),
            ),
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  OutlinedButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back, size: 16),
                    label: const Text('সকল ইভেন্ট'),
                  ),
                  const SizedBox(height: 14),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      EventPill(
                        label: text(
                          item,
                          'category_display',
                          fallback: 'মাহফিল',
                        ),
                        filled: false,
                      ),
                      EventPill(label: eventStatusLabel(status), filled: true),
                      if (text(item, 'hijri_date').isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF3C4),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            text(item, 'hijri_date'),
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Text(
                    title,
                    style: const TextStyle(
                      color: Color(0xFF111827),
                      fontSize: 27,
                      height: 1.18,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    text(item, 'short_description'),
                    style: TextStyle(
                      color: Colors.grey.shade700,
                      height: 1.55,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      DetailChip(
                        Icons.calendar_month_outlined,
                        formatEventDateRange(item),
                      ),
                      DetailChip(Icons.access_time, formatEventTimeRange(item)),
                      DetailChip(
                        Icons.location_on_outlined,
                        text(item, 'venue_name'),
                      ),
                    ],
                  ),
                  EventCountdownPanel(item: item),
                  const SizedBox(height: 18),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(22),
                    child: image.isEmpty
                        ? Container(
                            height: 220,
                            width: double.infinity,
                            color: primary.withValues(alpha: .10),
                            child: const Icon(
                              Icons.event_outlined,
                              color: primary,
                              size: 60,
                            ),
                          )
                        : CachedNetworkImage(
                            imageUrl: image,
                            height: 240,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              BreadcrumbPill(items: ['হোম', 'ইভেন্ট', title]),
              const SizedBox(height: 18),
              EventDetailSection(
                title: 'ইভেন্টের বিস্তারিত',
                child: Text(
                  text(
                    item,
                    'description',
                    fallback: text(
                      item,
                      'short_description',
                      fallback: 'বিস্তারিত যোগ করা হয়নি',
                    ),
                  ),
                  style: const TextStyle(
                    height: 1.75,
                    color: Color(0xFF374151),
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.justify,
                ),
              ),
              if (schedule.isNotEmpty) EventScheduleTimeline(items: schedule),
              if (photos.isNotEmpty)
                EventGalleryGrid(photos: photos, title: title),
              EventDetailSection(
                title: 'ইভেন্ট তথ্য',
                child: Column(
                  children: [
                    EventInfoLine(
                      Icons.calendar_month_outlined,
                      formatEventDateRange(item),
                    ),
                    EventInfoLine(
                      Icons.access_time,
                      formatEventTimeRange(item),
                    ),
                    EventInfoLine(
                      Icons.location_on_outlined,
                      text(item, 'venue_name'),
                    ),
                    EventInfoLine(
                      Icons.map_outlined,
                      text(item, 'full_address'),
                    ),
                  ],
                ),
              ),
              if (speakers.isNotEmpty) EventSpeakersCard(speakers: speakers),
              if (text(item, 'related_madrasha_name').isNotEmpty ||
                  text(item, 'related_khankah_name').isNotEmpty)
                EventDetailSection(
                  title: 'সম্পর্কিত নির্দেশনা',
                  tinted: true,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (text(item, 'related_madrasha_name').isNotEmpty)
                        Text(
                          'মাদ্রাসা: ${text(item, 'related_madrasha_name')}',
                          style: const TextStyle(fontWeight: FontWeight.w900),
                        ),
                      if (text(item, 'related_khankah_name').isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          'খানকাহ: ${text(item, 'related_khankah_name')}',
                          style: const TextStyle(fontWeight: FontWeight.w900),
                        ),
                      ],
                    ],
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class EventDetailSection extends StatelessWidget {
  const EventDetailSection({
    super.key,
    required this.title,
    required this.child,
    this.tinted = false,
  });

  final String title;
  final Widget child;
  final bool tinted;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      color: tinted ? const Color(0xFFEFFFF8) : Colors.white,
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

class EventScheduleTimeline extends StatelessWidget {
  const EventScheduleTimeline({super.key, required this.items});

  final List<Map<String, dynamic>> items;

  @override
  Widget build(BuildContext context) {
    return EventDetailSection(
      title: 'অনুষ্ঠান সূচি',
      child: Column(
        children: [
          for (final item in items)
            Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.black.withValues(alpha: .04)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 70,
                    padding: const EdgeInsets.symmetric(
                      vertical: 16,
                      horizontal: 8,
                    ),
                    decoration: BoxDecoration(
                      color: primary.withValues(alpha: .10),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Text(
                      timeToBangla(text(item, 'time', fallback: 'সময়')),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: primary,
                        fontWeight: FontWeight.w900,
                        fontSize: 11,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          text(item, 'title'),
                          style: const TextStyle(fontWeight: FontWeight.w900),
                        ),
                        if (text(item, 'speaker').isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 3),
                            child: Text(
                              text(item, 'speaker'),
                              style: const TextStyle(
                                color: primary,
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        if (text(item, 'description').isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Text(
                              text(item, 'description'),
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                height: 1.4,
                                fontSize: 12,
                              ),
                            ),
                          ),
                      ],
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

class EventGalleryGrid extends StatelessWidget {
  const EventGalleryGrid({
    super.key,
    required this.photos,
    required this.title,
  });

  final List<Map<String, dynamic>> photos;
  final String title;

  @override
  Widget build(BuildContext context) {
    return EventDetailSection(
      title: 'ফটো গ্যালারি',
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: photos.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: 1.25,
        ),
        itemBuilder: (context, index) {
          final url = api.mediaUrl(text(photos[index], 'image'));
          return ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: CachedNetworkImage(
              imageUrl: url,
              fit: BoxFit.cover,
              errorWidget: (context, url, error) => Container(
                color: primary.withValues(alpha: .08),
                child: const Icon(Icons.photo_outlined, color: primary),
              ),
            ),
          );
        },
      ),
    );
  }
}

class EventSpeakersCard extends StatelessWidget {
  const EventSpeakersCard({super.key, required this.speakers});

  final List<Map<String, dynamic>> speakers;

  @override
  Widget build(BuildContext context) {
    return EventDetailSection(
      title: 'বক্তা / মেহমান',
      child: Column(
        children: [
          for (final speaker in speakers)
            Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: primary.withValues(alpha: .12),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(Icons.person_outline, color: primary),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          text(speaker, 'name'),
                          style: const TextStyle(fontWeight: FontWeight.w900),
                        ),
                        if (text(speaker, 'title').isNotEmpty)
                          Text(
                            text(speaker, 'title'),
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 12,
                            ),
                          ),
                        if (text(speaker, 'topic').isNotEmpty)
                          Text(
                            text(speaker, 'topic'),
                            style: const TextStyle(
                              color: primary,
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                      ],
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
