part of '../main.dart';

class DetailScreen extends StatelessWidget {
  const DetailScreen({super.key, required this.type, required this.id});

  final ArchiveType type;
  final dynamic id;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(type.title)),
      body: FutureBuilder<Map<String, dynamic>>(
        future: api.detail('${type.endpoint}$id/'),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || !snapshot.hasData) {
            return ErrorBox('${snapshot.error ?? 'তথ্য পাওয়া যায়নি'}');
          }
          final item = snapshot.data!;
          if (type == ArchiveType.madrasha) {
            return MadrashaDetailBody(item: item);
          }
          if (type == ArchiveType.events) {
            return EventDetailBody(item: item);
          }
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              DetailHero(item: item, type: type),
              const SizedBox(height: 14),
              ..._detailSections(context, item, type),
            ],
          );
        },
      ),
    );
  }

  List<Widget> _detailSections(
    BuildContext context,
    Map<String, dynamic> item,
    ArchiveType type,
  ) {
    switch (type) {
      case ArchiveType.madrasha:
        return [
          InfoCard(
            'পরিচিতি',
            text(
              item,
              'madrasha_description',
              fallback: 'বর্ণনা যোগ করা হয়নি',
            ),
          ),
          InfoGrid([
            InfoItem('শিক্ষক', text(item, 'number_of_teachers')),
            InfoItem('শিক্ষার্থী', text(item, 'number_of_students')),
            InfoItem('প্রতিষ্ঠা', text(item, 'year_of_establishment')),
            InfoItem('ধরণ', madrashaTypeLabel(text(item, 'type_of_madrasha'))),
            InfoItem(
              'শিক্ষার মাধ্যম',
              mediumLabel(text(item, 'medium_of_instruction')),
            ),
            InfoItem('প্রতিষ্ঠাতা', text(item, 'founder_of_madrasha')),
            InfoItem('জেলা', text(item, 'district_name')),
            InfoItem('উপজেলা', text(item, 'upazila_name')),
          ]),
          InfoCard(
            'ঠিকানা',
            [
              text(item, 'full_address_madrsha'),
              text(item, 'village'),
              text(item, 'union_parishad'),
              text(item, 'post_office'),
              text(item, 'district_name'),
              text(item, 'upazila_name'),
            ].where((value) => value.isNotEmpty).join(', '),
          ),
          CommitteeCard(
            title: 'পরিচালনা কমিটি',
            people: [
              InfoItem('সভাপতি', text(item, 'president')),
              InfoItem('সেক্রেটারি', text(item, 'secretary')),
              InfoItem('সহ-সভাপতি', text(item, 'vice_president')),
              InfoItem('কেশিয়ার', text(item, 'treasurer')),
              InfoItem('পাঠ্যক্রম পরিচালক', text(item, 'curriculum_director')),
              InfoItem(
                'মিডিয়া কর্মকর্তা',
                text(item, 'public_relations_officer'),
              ),
              InfoItem('আইটি পরিচালক', text(item, 'technology_it_director')),
            ],
          ),
          TeacherList(teachers: listOfMaps(item['teachers'])),
          PhotoStrip(photos: listOfMaps(item['photos'])),
        ];
      case ArchiveType.khankah:
        return [
          InfoCard(
            'পরিচিতি',
            text(item, 'khankah_description', fallback: 'বর্ণনা যোগ করা হয়নি'),
          ),
          InfoGrid([
            InfoItem('পরিচালক', text(item, 'director_name')),
            InfoItem('ফোন', text(item, 'director_phone')),
            InfoItem('গ্রাম', text(item, 'village')),
            InfoItem('ইউনিয়ন', text(item, 'union')),
            InfoItem('জেলা', text(item, 'district_name')),
            InfoItem('উপজেলা', text(item, 'upazila_name')),
          ]),
          InfoCard(
            'ঠিকানা',
            [
              text(item, 'full_address'),
              text(item, 'village'),
              text(item, 'ward'),
              text(item, 'union'),
              text(item, 'district_name'),
              text(item, 'upazila_name'),
            ].where((value) => value.isNotEmpty).join(', '),
          ),
          CommitteeCard(
            title: 'খানকাহ পরিচালনা',
            people: [
              InfoItem('পরিচালক', text(item, 'director_name')),
              InfoItem('সভাপতি', text(item, 'president_name')),
              InfoItem('সহ-সভাপতি', text(item, 'vice_president_name')),
              InfoItem('সেক্রেটারি', text(item, 'secretary_name')),
              InfoItem('ক্যাশিয়ার', text(item, 'cashier_name')),
            ],
          ),
          PhotoStrip(photos: listOfMaps(item['photos'])),
        ];
      case ArchiveType.events:
        return [
          InfoCard(
            'ইভেন্ট পরিচিতি',
            text(
              item,
              'description',
              fallback: text(item, 'short_description'),
            ),
          ),
          InfoGrid([
            InfoItem('তারিখ', text(item, 'start_date')),
            InfoItem('হিজরি', text(item, 'hijri_date')),
            InfoItem(
              'সময়',
              '${text(item, 'start_time')} - ${text(item, 'end_time')}',
            ),
            InfoItem('স্থান', text(item, 'venue_name')),
            InfoItem('জেলা', text(item, 'district_name')),
            InfoItem('অবস্থা', text(item, 'status_display')),
          ]),
          ScheduleList(items: listOfMaps(item['schedule'])),
          PhotoStrip(photos: listOfMaps(item['photos'])),
        ];
      case ArchiveType.books:
        return [
          InfoCard(
            'বই পরিচিতি',
            text(
              item,
              'description',
              fallback: text(item, 'short_description'),
            ),
          ),
          InfoGrid([
            InfoItem('লেখক', text(item, 'author_name')),
            InfoItem('ক্যাটাগরি', text(item, 'category_display')),
            InfoItem('ভাষা', text(item, 'language_display')),
            InfoItem('পৃষ্ঠা', text(item, 'pages')),
            InfoItem('প্রকাশক', text(item, 'publisher')),
            InfoItem('ডাউনলোড', text(item, 'download_count')),
          ]),
          FilledButton.icon(
            onPressed: () => openPdf(context, item),
            icon: const Icon(Icons.picture_as_pdf_outlined),
            label: const Text('PDF খুলুন / পড়ুন'),
          ),
        ];
    }
  }

  Future<void> openPdf(BuildContext context, Map<String, dynamic> item) async {
    final url = api.mediaUrl(text(item, 'pdf_file'));
    if (url.isEmpty) return;
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => MobilePdfReaderScreen(item: item)),
    );
  }
}
