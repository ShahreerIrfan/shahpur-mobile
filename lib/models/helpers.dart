part of '../main.dart';

String toBanglaNumber(num value) {
  const en = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
  const bn = ['০', '১', '২', '৩', '৪', '৫', '৬', '৭', '৮', '৯'];
  var result = value.toString();
  for (var i = 0; i < en.length; i++) {
    result = result.replaceAll(en[i], bn[i]);
  }
  return result;
}

String digitsToBangla(String value) {
  var result = value;
  for (var i = 0; i <= 9; i++) {
    result = result.replaceAll('$i', toBanglaNumber(i));
  }
  return result;
}

String timeToBangla(String value) {
  if (value.isEmpty) return '';
  final parts = value.split(':');
  if (parts.length >= 2) return digitsToBangla('${parts[0]}:${parts[1]}');
  return digitsToBangla(value);
}

DateTime? parseEventDateTime(
  String date,
  String time, {
  bool endOfDay = false,
}) {
  if (date.isEmpty) return null;
  var normalizedTime = time.trim();
  if (normalizedTime.isEmpty) {
    normalizedTime = endOfDay ? '23:59:59' : '00:00:00';
  } else if (normalizedTime.length == 5) {
    normalizedTime = '$normalizedTime:00';
  } else if (normalizedTime.length > 8) {
    normalizedTime = normalizedTime.substring(0, 8);
  }
  return DateTime.tryParse('${date}T$normalizedTime');
}

DateTime? eventStartDateTime(Map<String, dynamic> item) {
  return parseEventDateTime(text(item, 'start_date'), text(item, 'start_time'));
}

DateTime? eventEndDateTime(Map<String, dynamic> item) {
  final startDate = text(item, 'start_date');
  final endDate = text(item, 'end_date', fallback: startDate);
  final endTime = text(item, 'end_time');
  return parseEventDateTime(endDate, endTime, endOfDay: endTime.isEmpty);
}

String effectiveEventStatus(Map<String, dynamic> item) {
  final raw = text(item, 'status');
  if (raw == 'cancelled') return 'cancelled';
  final start = eventStartDateTime(item);
  final end = eventEndDateTime(item);
  final now = DateTime.now();
  if (start == null) return raw.isEmpty ? 'upcoming' : raw;
  if (now.isBefore(start)) return 'upcoming';
  if (end != null && now.isAfter(end)) return 'completed';
  return 'ongoing';
}

Duration? eventRemaining(Map<String, dynamic> item) {
  final start = eventStartDateTime(item);
  if (start == null) return null;
  final diff = start.difference(DateTime.now());
  return diff.isNegative ? null : diff;
}

String eventStatusLabel(String status) {
  switch (status) {
    case 'upcoming':
      return 'আসন্ন';
    case 'ongoing':
      return 'চলমান';
    case 'completed':
      return 'সম্পন্ন';
    case 'cancelled':
      return 'বাতিল';
    default:
      return status.isEmpty ? 'আসন্ন' : status;
  }
}

class EventStatusVisual {
  const EventStatusVisual({
    required this.title,
    required this.message,
    required this.icon,
    required this.color,
    required this.background,
    required this.border,
    required this.textColor,
  });

  final String title;
  final String message;
  final IconData icon;
  final Color color;
  final Color background;
  final Color border;
  final Color textColor;
}

EventStatusVisual eventStatusInfo(String status) {
  switch (status) {
    case 'ongoing':
      return const EventStatusVisual(
        title: 'অনুষ্ঠান চলছে',
        message: 'আলহামদুলিল্লাহ, এই ইভেন্ট এখন চলমান',
        icon: Icons.play_arrow_rounded,
        color: primary,
        background: Color(0xFFEFFFF8),
        border: Color(0xFF86E7C4),
        textColor: primaryDark,
      );
    case 'completed':
      return EventStatusVisual(
        title: 'অনুষ্ঠান সম্পন্ন',
        message: 'আলহামদুলিল্লাহ, এই ইভেন্ট সম্পন্ন হয়েছে',
        icon: Icons.check_circle_outline,
        color: Colors.blueGrey.shade700,
        background: const Color(0xFFF8FAFC),
        border: const Color(0xFFE2E8F0),
        textColor: const Color(0xFF334155),
      );
    case 'cancelled':
      return EventStatusVisual(
        title: 'অনুষ্ঠান বাতিল',
        message: 'এই ইভেন্টটি বাতিল করা হয়েছে',
        icon: Icons.cancel_outlined,
        color: Colors.red.shade600,
        background: const Color(0xFFFFF1F2),
        border: const Color(0xFFFECACA),
        textColor: const Color(0xFF991B1B),
      );
    default:
      return const EventStatusVisual(
        title: 'ইভেন্ট শুরু হতে বাকি',
        message: '',
        icon: Icons.hourglass_bottom_rounded,
        color: primary,
        background: Color(0xFFEFFFF8),
        border: Color(0xFF4ADE80),
        textColor: primaryDark,
      );
  }
}

String formatEventDateRange(Map<String, dynamic> item) {
  final start = DateTime.tryParse(text(item, 'start_date'));
  final endText = text(item, 'end_date');
  final end = endText.isEmpty ? null : DateTime.tryParse(endText);
  if (start == null) return text(item, 'start_date');
  final startText = formatBanglaDate(start);
  if (end == null || sameDay(start, end)) return startText;
  return '$startText - ${formatBanglaDate(end)}';
}

String formatBanglaDate(DateTime date) {
  const months = [
    '',
    'জানুয়ারি',
    'ফেব্রুয়ারি',
    'মার্চ',
    'এপ্রিল',
    'মে',
    'জুন',
    'জুলাই',
    'আগস্ট',
    'সেপ্টেম্বর',
    'অক্টোবর',
    'নভেম্বর',
    'ডিসেম্বর',
  ];
  return '${toBanglaNumber(date.day)} ${months[date.month]}, ${toBanglaNumber(date.year)}';
}

bool sameDay(DateTime a, DateTime b) {
  return a.year == b.year && a.month == b.month && a.day == b.day;
}

String formatEventTimeRange(Map<String, dynamic> item) {
  final start = timeToBangla(text(item, 'start_time'));
  final end = timeToBangla(text(item, 'end_time'));
  if (start.isEmpty && end.isEmpty) return '';
  if (end.isEmpty) return start;
  return '$start - $end';
}

String text(Map<String, dynamic> item, String key, {String fallback = ''}) {
  final value = item[key];
  if (value == null) return fallback;
  final result = '$value';
  return result.isEmpty || result == 'null' ? fallback : result;
}

int intValue(dynamic value) {
  if (value is int) return value;
  return int.tryParse('$value') ?? 0;
}

List<Map<String, dynamic>> listOfMaps(dynamic value) {
  if (value is List) {
    return value
        .whereType<Map>()
        .map((item) => item.cast<String, dynamic>())
        .toList();
  }
  return [];
}

List<String> madrashaImages(Map<String, dynamic> item) {
  final images = <String>[];
  final featured = api.mediaUrl(text(item, 'featured_image'));
  if (featured.isNotEmpty) images.add(featured);
  for (final photo in listOfMaps(item['photos'])) {
    final url = api.mediaUrl(text(photo, 'image'));
    if (url.isNotEmpty && !images.contains(url)) images.add(url);
  }
  return images;
}

String madrashaTypeLabel(String value) {
  switch (value) {
    case 'nurani':
      return 'নূরানী';
    case 'hifz':
      return 'হিফজ';
    case 'najera':
      return 'নাজেরা';
    case 'academic':
      return 'একাডেমিক';
    default:
      return value;
  }
}

String mediumLabel(String value) {
  switch (value) {
    case 'bangla':
      return 'বাংলা';
    case 'english':
      return 'ইংরেজি';
    default:
      return value;
  }
}

String _formatApiError(dynamic data) {
  if (data is Map) {
    return data.entries
        .map((entry) {
          final value = entry.value;
          if (value is List) return '${entry.key}: ${value.join(', ')}';
          return '${entry.key}: $value';
        })
        .join('; ');
  }
  return 'অনুরোধ সম্পন্ন করা যায়নি';
}
