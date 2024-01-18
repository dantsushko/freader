import 'dart:io';

// import 'package:epub_view/epub_view.dart';
// import 'package:epubx/epubx.dart';
import 'package:flutter/material.dart';

class EpubScreen extends StatelessWidget {
  const EpubScreen({
    super.key,
    // required this.book,
  });

  // final EpubBook book;

  @override
  Widget build(BuildContext context) {
    return Placeholder();

    // final EpubController _controller = EpubController(
    //   document: Future.value(book),
    // );

    // return Expanded(
    //   child: EpubView(
    //     controller: _controller,
    //     builders: EpubViewBuilders<DefaultBuilderOptions>(
    //       options: const DefaultBuilderOptions(),
    //       chapterDividerBuilder: (_) => const Divider(),
    //     ),
    //   ),
    // );
  }
}
