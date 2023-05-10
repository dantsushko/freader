import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:freader/src/core/data/database/daos/book_dao.dart';
import 'package:freader/src/core/parser/fb2_parser/model/section.dart';
import 'package:freader/src/core/parser/parser.dart';
import 'package:freader/src/feature/app/widget/app.dart';
import 'package:freader/src/feature/catalogues/opds/util.dart';

import 'fb2/fb2_screen.dart';

@RoutePage()
class BookReadingScreen extends StatefulWidget {
  const BookReadingScreen({required this.bookWithMetadata, super.key});
  final BookWithMetadata bookWithMetadata;
  @override
  State<BookReadingScreen> createState() => _ReadingScreenState();
}

class _ReadingScreenState extends State<BookReadingScreen> {
  bool _showAppBar = false;
  void handleTap(TapDownDetails details) {
    double screenWidth = MediaQuery.of(context).size.width;
    double tapPositionX = details.globalPosition.dx;

    if (tapPositionX < screenWidth / 3) {
      // Left side tapped
      print('Left side tapped');
    } else if (tapPositionX > (screenWidth / 3) * 2) {
      // Right side tapped
      print('Right side tapped');
    } else {
      // Center tapped
      print('Center tapped');
      setState(() {
        _showAppBar = !_showAppBar;
        initAppBar(); // SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: [SystemUiOverlay.top]);
      });
    }
  }

  void initAppBar() {
    if (_showAppBar) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: SystemUiOverlay.values);
    } else {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.leanBack);
    }
  }

  BookFormat format = BookFormat.unsupported;
  @override
  void initState() {
    initAppBar();
    super.initState();
  }

  @override
  Widget build(BuildContext context) => SafeArea(
        child: FutureBuilder<CommonBook?>(
          future: Parser().parse(widget.bookWithMetadata.book.filepath),
          builder: (context, snapshot) => GestureDetector(
            // onTapDown: handleTap,
            onDoubleTapDown: handleTap,
            child: Scaffold(
              appBar: _showAppBar
                  ? PreferredSize(
                      preferredSize: const Size.fromHeight(30),
                      child: AppBar(
                        centerTitle: true,
                        title: Text(
                          snapshot.data?.title ?? '',
                          style: const TextStyle(color: Colors.black87, fontSize: 13),
                        ),
                        backgroundColor: Colors.white,
                        elevation: 0,
                        leading: InkWell(
                          onTap: () => context.router.pop(),
                          child: const Icon(
                            Icons.close,
                            color: Colors.black87,
                          ),
                        ),
                        actions: const [
                          Padding(
                            padding: EdgeInsets.all(4),
                            child: Icon(
                              Icons.settings,
                              color: Colors.black87,
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.all(4),
                            child: Icon(
                              Icons.menu_book_sharp,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    )
                  : null,
              body: Padding(
                padding: const EdgeInsets.all(8),
                child: Builder(
                  builder: (
                    context,
                  ) {
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
              ),
              // child: FutureBuilder<CommonBook?>(
              //       future: Parser().parse(widget.bookWithMetadata.book.filepath),
              //       builder: (context, snapshot) {
              //         if (snapshot.hasError) {
              //           return Center(child: Text(snapshot.error.toString()));
              //         }
              //         if (snapshot.hasData) {
              //           final book = snapshot.data!;
              //           return ListView(
              //             children: [
              //               Center(
              //                   child: Text(
              //                 book.title,
              //                 style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              //               )),
              //               if (book.fb2body != null) Text(book.fb2body!.epigraph ?? ''),
              //               ...book.fb2body!.sections!
              //                   .map((e) => Column(
              //                         children: [
              //                           HtmlWidget(e.title ?? ''),
              //                           HtmlWidget(e.content ?? ''),
              //                         ],
              //                       ))
              //                   .toList(),
              //             ],
              //           );
              //         }
              //         return const Center(child: CircularProgressIndicator());
              //       },
              //     ),
            ),
          ),
        ),
      );
}

class Screen extends StatelessWidget {
  const Screen({
    super.key,
    required this.book,
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
          // SelectableHtml(data: book.epubBook!.Content?.Html.values.first.Content ?? ''),
          // ...book.fb2body!.sections!.map(
          //   (e) => Column(
          //     children: [
          //       SelectableHtml(data: e.title ?? ''),
          //       SelectableHtml(
          //         data: e.epubBook.c ?? '',
          //       ),
          //     ],
          //   ),
          // ),
        ],
      );
    }
    return const Center(child: Text('Unsupported format'));
  }
}
