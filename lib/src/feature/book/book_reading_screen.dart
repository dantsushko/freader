import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freader/src/core/data/database/database.dart';
import 'package:freader/src/core/parser/parser.dart';
import 'package:freader/src/feature/book/epub/epub_screen.dart';
import 'package:freader/src/feature/catalogues/opds/util.dart';
import 'package:freader/src/feature/initialization/widget/dependencies_scope.dart';

import 'blocs/navigator/bloc/reader_navigator_bloc.dart';
import 'fb2/fb2_screen.dart';
import 'floating_app_bar.dart';

class BookReadingScreen extends StatefulWidget {
  const BookReadingScreen({required this.bookId, super.key});
  final int bookId;
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
    // SystemChrome.setEnabledSystemUIMode(SystemUiMode.leanBack, overlays: SystemUiOverlay.values);
    // }
  }

  ValueNotifier<bool> showControls = ValueNotifier<bool>(false);
  BookFormat format = BookFormat.unsupported;
  late final Future<CommonBook?> _compute;
  late final AppDatabase _db;
  @override
  void initState() {
    _db = DependenciesScope.dependenciesOf(context).database;
    _compute = getBook();
    initAppBar();
    super.initState();
  }

  Future<CommonBook?> getBook() async {
    final bookWithMetadata = await _db.bookDao.getBook(widget.bookId);
    await _db.bookDao.updateTimestamp(widget.bookId);
    return compute(Parser().parse, bookWithMetadata.book.filepath);
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
                body: Builder(
                  builder: (context) {
                    if (snapshot.hasError) {
                      return Center(child: Text(snapshot.error.toString()));
                    }
                    if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                    final book = snapshot.data!;
                    return BlocProvider(
                      create: (context) => ReaderNavigatorBloc(book),
                      child: Stack(
                        children: [
                          Builder(
                            builder: (context) {
                              
                              if (book.fb2book != null) {
                                return FB2Screen(book: book.fb2book!);
                              }
                              if (book.epubBook != null) {
                                return EpubScreen(book: book.epubBook!);
                              }

                              return const Center(child: CircularProgressIndicator());
                            },
                          ),
                          FloatingAppBar(
                              showControls: showControls,
                              title: snapshot.data?.title ?? '',
                              book: snapshot.data),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      );
}
