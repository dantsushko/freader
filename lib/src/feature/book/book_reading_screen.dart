import 'package:auto_route/auto_route.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:freader/src/core/data/database/daos/book_dao.dart';
import 'package:freader/src/core/parser/parser.dart';
import 'package:freader/src/feature/catalogues/opds/util.dart';

import 'fb2/fb2_screen.dart';
import 'settings/book_settings_screen.dart';

@RoutePage()
class BookReadingScreen extends StatefulWidget {
  const BookReadingScreen({required this.bookWithMetadata, super.key});
  final BookWithMetadata bookWithMetadata;
  @override
  State<BookReadingScreen> createState() => _BookReadingScreenState();
}

class _BookReadingScreenState extends State<BookReadingScreen> {
  void handleTap(PointerUpEvent details) {
    stopwatch.stop();
    final ms = stopwatch.elapsedMilliseconds;

    stopwatch.reset();
    if (ms > 150 || _tapPosition != details.localPosition) {
      return;
    }

    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final tapPositionX = details.localPosition.dx;
    final tapPositionY = details.localPosition.dy;
    if (tapPositionX > screenWidth / 3 &&
        tapPositionX < (screenWidth / 3) * 2 &&
        tapPositionY > screenHeight / 3 &&
        tapPositionY < (screenHeight / 3) * 2) {
      showControls.value = !showControls.value;
      initAppBar();
    }
  }

  void initAppBar() {
    // if (_showAppBar) {
    // SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: SystemUiOverlay.values);
    // } else {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.leanBack);
    // }
  }

  ValueNotifier<bool> showControls = ValueNotifier<bool>(false);
  BookFormat format = BookFormat.unsupported;
  late final Future<CommonBook?> _compute;
  @override
  void initState() {
    _compute = compute(Parser().parse, widget.bookWithMetadata.book.filepath);
    initAppBar();
    super.initState();
  }

  Stopwatch stopwatch = Stopwatch();
  Offset _tapPosition = Offset.zero;
  @override
  Widget build(BuildContext context) => FutureBuilder<CommonBook?>(
        future: _compute,
        builder: (context, snapshot) => Listener(
          onPointerUp: handleTap,
          onPointerDown: (s) {
            _tapPosition = s.localPosition;
            stopwatch.start();
          },
          child: ColoredBox(
            color: Theme.of(context).colorScheme.background,
            child: SafeArea(
              bottom: false,
              left: false,
              right: false,
              child: Scaffold(
                body: Stack(
                  children: [
                    Builder(
                      builder: (context) {
                        if (snapshot.hasError) {
                          return Center(child: Text(snapshot.error.toString()));
                        }
                        if (snapshot.hasData) {
                          final book = snapshot.data!;
                          return Screen(book: book);
                        }
                        return const Center(child: CircularProgressIndicator());
                      },
                    ),
                    ValueListenableBuilder(
                      valueListenable: showControls,
                      builder: (ctx, show, child) {
                        if (!show) return const SizedBox.shrink();
                        return Positioned(
                          top: 0,
                          left: 0,
                          right: 0,
                          height: 30,
                          child: AppBar(
                            title: Text(
                              snapshot.data?.title ?? '',
                            ),
                            leading: InkWell(
                              onTap: () => context.router.pop(),
                              child: const Icon(
                                Icons.close,
                              ),
                            ),
                            actions: [
                              InkWell(
                                onTap: () => showModalBottomSheet<void>(
                                  isScrollControlled: true,
                                  context: context,
                                  builder: (ctx) => SizedBox(
                                    height: MediaQuery.of(context).size.height * 0.8,
                                    child: const BookSettingsScren(),
                                  ),
                                ),
                                child: const Icon(
                                  Icons.settings,
                                ),
                              ),
                              const Icon(
                                Icons.menu_book_sharp,
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
}

class Screen extends StatelessWidget {
  const Screen({
    required this.book,
    super.key,
  });

  final CommonBook book;

  @override
  Widget build(BuildContext context) {
    if (book.fb2book != null) {
      return FB2Screen(book: book.fb2book!);
    }
    if (book.epubBook != null) {
      return ListView(
        children: [
          Center(
            child: Text(
              book.title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          ...book.epubBook!.Content?.Html?.values
                  .map((e) => SelectableHtml(data: e.Content ?? '')) ??
              []
        ],
      );
    }
    return const Center(child: Text('Unsupported format'));
  }
}
