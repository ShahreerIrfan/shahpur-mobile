part of '../main.dart';

enum MobileReaderTone { light, sepia, dark }

class MobilePdfReaderScreen extends StatefulWidget {
  const MobilePdfReaderScreen({super.key, required this.item});

  final Map<String, dynamic> item;

  @override
  State<MobilePdfReaderScreen> createState() => _MobilePdfReaderScreenState();
}

class _MobilePdfReaderScreenState extends State<MobilePdfReaderScreen> {
  final controller = PdfViewerController();
  final searchController = TextEditingController();
  PdfTextSearchResult? searchResult;
  MobileReaderTone tone = MobileReaderTone.light;
  PdfPageLayoutMode layoutMode = PdfPageLayoutMode.single;
  int page = 1;
  int pageCount = 0;
  bool favorite = false;
  List<int> bookmarks = [];
  bool loadingProgress = true;

  String get url => api.mediaUrl(text(widget.item, 'pdf_file'));
  String get title => text(widget.item, 'title', fallback: 'বই রিডার');
  String get storageKey => 'mobile-reader:${url.hashCode}';

  @override
  void initState() {
    super.initState();
    loadSavedState();
  }

  @override
  void dispose() {
    searchController.dispose();
    searchResult?.removeListener(updateSearchState);
    super.dispose();
  }

  Future<void> loadSavedState() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      page = prefs.getInt('$storageKey:page') ?? 1;
      favorite = prefs.getBool('$storageKey:favorite') ?? false;
      bookmarks = (prefs.getStringList('$storageKey:bookmarks') ?? [])
          .map((value) => int.tryParse(value) ?? 0)
          .where((value) => value > 0)
          .toList();
      loadingProgress = false;
    });
  }

  Future<void> savePage(int value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('$storageKey:page', value);
    await prefs.setString(
      '$storageKey:progress',
      '$title|$value|$pageCount|${DateTime.now().millisecondsSinceEpoch}',
    );
  }

  Future<void> saveBookmarks() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      '$storageKey:bookmarks',
      bookmarks.map((value) => '$value').toList(),
    );
  }

  Future<void> toggleFavorite() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() => favorite = !favorite);
    await prefs.setBool('$storageKey:favorite', favorite);
  }

  Future<void> toggleBookmark() async {
    setState(() {
      if (bookmarks.contains(page)) {
        bookmarks.remove(page);
      } else {
        bookmarks.add(page);
        bookmarks.sort();
      }
    });
    await saveBookmarks();
  }

  void updateSearchState() {
    if (mounted) setState(() {});
  }

  void runSearch() {
    final query = searchController.text.trim();
    if (query.isEmpty) return;
    searchResult?.removeListener(updateSearchState);
    searchResult = controller.searchText(query);
    searchResult?.addListener(updateSearchState);
    setState(() {});
  }

  void jumpToPage(int value) {
    final nextPage = value.clamp(1, pageCount == 0 ? 1 : pageCount);
    controller.jumpToPage(nextPage);
    setState(() => page = nextPage);
    savePage(nextPage);
  }

  Color get backgroundColor {
    switch (tone) {
      case MobileReaderTone.light:
        return const Color(0xFFF4F7F5);
      case MobileReaderTone.sepia:
        return const Color(0xFFF1E4C7);
      case MobileReaderTone.dark:
        return const Color(0xFF111827);
    }
  }

  @override
  Widget build(BuildContext context) {
    final reader = SfPdfViewer.network(
      url,
      controller: controller,
      pageLayoutMode: layoutMode,
      canShowScrollHead: true,
      canShowScrollStatus: true,
      enableDoubleTapZooming: true,
      onDocumentLoaded: (details) {
        final count = details.document.pages.count;
        setState(() => pageCount = count);
        if (!loadingProgress && page > 1) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            controller.jumpToPage(page.clamp(1, count));
          });
        }
      },
      onPageChanged: (details) {
        setState(() => page = details.newPageNumber);
        savePage(details.newPageNumber);
      },
    );

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis),
        actions: [
          IconButton(
            onPressed: toggleBookmark,
            icon: Icon(
              bookmarks.contains(page) ? Icons.bookmark : Icons.bookmark_border,
            ),
          ),
          IconButton(
            onPressed: toggleFavorite,
            icon: Icon(favorite ? Icons.star : Icons.star_border),
          ),
          IconButton(onPressed: showReaderTools, icon: const Icon(Icons.tune)),
        ],
      ),
      body: Column(
        children: [
          LinearProgressIndicator(
            value: pageCount == 0 ? null : page / pageCount,
            color: primary,
            backgroundColor: primary.withValues(alpha: .12),
          ),
          Expanded(
            child: ColoredBox(color: backgroundColor, child: reader),
          ),
        ],
      ),
    );
  }

  void showReaderTools() {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final progress = pageCount == 0
                ? 0
                : ((page / pageCount) * 100).round();
            return SafeArea(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  16,
                  0,
                  16,
                  16 + MediaQuery.viewInsetsOf(context).bottom,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        IconButton.filledTonal(
                          onPressed: page > 1
                              ? () {
                                  jumpToPage(page - 1);
                                  setSheetState(() {});
                                }
                              : null,
                          icon: const Icon(Icons.chevron_left),
                        ),
                        Expanded(
                          child: Column(
                            children: [
                              Text(
                                'পৃষ্ঠা $page / ${pageCount == 0 ? "..." : pageCount}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              Text(
                                '$progress% সম্পন্ন',
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton.filledTonal(
                          onPressed: pageCount == 0 || page >= pageCount
                              ? null
                              : () {
                                  jumpToPage(page + 1);
                                  setSheetState(() {});
                                },
                          icon: const Icon(Icons.chevron_right),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    SegmentedButton<MobileReaderTone>(
                      selected: {tone},
                      showSelectedIcon: false,
                      segments: const [
                        ButtonSegment(
                          value: MobileReaderTone.light,
                          label: Text('Light'),
                        ),
                        ButtonSegment(
                          value: MobileReaderTone.sepia,
                          label: Text('Sepia'),
                        ),
                        ButtonSegment(
                          value: MobileReaderTone.dark,
                          label: Text('Dark'),
                        ),
                      ],
                      onSelectionChanged: (value) {
                        setState(() => tone = value.first);
                        setSheetState(() {});
                      },
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: searchController,
                            decoration: InputDecoration(
                              hintText: 'PDF সার্চ করুন',
                              isDense: true,
                              prefixIcon: const Icon(Icons.search),
                              suffixIcon: IconButton(
                                onPressed: runSearch,
                                icon: const Icon(Icons.arrow_forward),
                              ),
                            ),
                            onSubmitted: (_) => runSearch(),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton.filledTonal(
                          tooltip: 'আগের ফলাফল',
                          onPressed: searchResult == null
                              ? null
                              : () => searchResult!.previousInstance(),
                          icon: const Icon(Icons.keyboard_arrow_up),
                        ),
                        IconButton.filledTonal(
                          tooltip: 'পরের ফলাফল',
                          onPressed: searchResult == null
                              ? null
                              : () => searchResult!.nextInstance(),
                          icon: const Icon(Icons.keyboard_arrow_down),
                        ),
                      ],
                    ),
                    if (searchResult != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text(
                          'সার্চ ফলাফল: ${searchResult!.currentInstanceIndex}/${searchResult!.totalInstanceCount}',
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: showBookmarks,
                            icon: const Icon(Icons.bookmarks_outlined),
                            label: Text('বুকমার্ক (${bookmarks.length})'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              setState(() {
                                layoutMode =
                                    layoutMode == PdfPageLayoutMode.single
                                    ? PdfPageLayoutMode.continuous
                                    : PdfPageLayoutMode.single;
                              });
                              setSheetState(() {});
                            },
                            icon: const Icon(Icons.view_day_outlined),
                            label: Text(
                              layoutMode == PdfPageLayoutMode.single
                                  ? 'Single'
                                  : 'Scroll',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void showBookmarks() {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const Text(
                'বুকমার্ক তালিকা',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 10),
              if (bookmarks.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Center(child: Text('এখনো কোনো বুকমার্ক নেই')),
                )
              else
                for (final bookmark in bookmarks)
                  ListTile(
                    leading: const Icon(Icons.bookmark, color: primary),
                    title: Text('পৃষ্ঠা $bookmark'),
                    onTap: () {
                      Navigator.pop(context);
                      jumpToPage(bookmark);
                    },
                  ),
            ],
          ),
        );
      },
    );
  }
}
