import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freader/src/core/data/database/daos/settings_dao.dart';
import 'package:freader/src/core/data/database/tables.dart';
import 'package:freader/src/core/parser/fb2_parser/fb2_parser.dart';
import 'package:freader/src/core/parser/fb2_parser/model/element.dart';
import 'package:freader/src/core/parser/fb2_parser/model/image.dart';
import 'package:freader/src/core/parser/fb2_parser/model/link.dart';
import 'package:freader/src/core/parser/fb2_parser/model/section.dart';
import 'package:freader/src/feature/initialization/widget/dependencies_scope.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import '../../../core/data/database/database.dart';
import '../../../core/parser/fb2_parser/model/title.dart';
import '../blocs/navigator/bloc/reader_navigator_bloc.dart';

class FB2Screen extends StatefulWidget {
  const FB2Screen({
    required this.book,
    super.key,
    required this.bid,
  });
  final FB2Book book;
  final int bid;

  @override
  State<FB2Screen> createState() => _FB2ScreenState();
}

class _FB2ScreenState extends State<FB2Screen> {
  final ItemScrollController _scrollController = ItemScrollController();
  late final FB2Book book;
  late final PageController _pageController;
  late SettingsModel settings;
  late Cursor? cursor;
  double get fontSize => settings.fontSize.toDouble();
  double get subtitleFontSize => fontSize + 2;
  double get titleFontSize => fontSize + 4;
  double get pageHorizontalPadding => settings.pageHorizontalPadding.toDouble();
  double get pageTopPadding => settings.pageTopPadding.toDouble();
  double get pageBottomPadding => settings.pageBottomPadding.toDouble();
  double get letterSpacing => settings.letterSpacing.toDouble();
  PageScrollStyle get pageScrollStyle => settings.pageScrollStyle;
  late final StreamSubscription<SettingsModel> subscription;

  @override
  void initState() {
    settings = DependenciesScope.dependenciesOf(context).database.settingsDao.initialSettings;

    subscription = DependenciesScope.dependenciesOf(context)
        .database
        .settingsDao
        .watch()
        .listen((event) => setState(() => settings = event));
    book = widget.book;

    super.initState();
  }

  Future<void> initCursor() async {
    cursor =
        await DependenciesScope.of(context).dependencies.database.cursorDao.getCursor(widget.bid);

    print('Cursor: $cursor');
    _pageController = PageController(initialPage: cursor?.page ?? 0);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    subscription.cancel();
    super.dispose();
  }

  Widget getScrollingWidget() {
    switch (pageScrollStyle) {
      case PageScrollStyle.scroll:
        return ScrollablePositionedList.builder(
          itemPositionsListener: ItemPositionsListener.create(),
          itemCount: book.elements.length,
          itemScrollController: _scrollController,
          itemBuilder: (context, index) => _buildFB2ElementWidget(book.elements[index]),
        );

      case PageScrollStyle.shift:
        return FutureBuilder(
          future: splitPages(book),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            final pages = snapshot.data!;
            return PageView.builder(
              controller: _pageController,
              onPageChanged: (page) => DependenciesScope.of(context)
                  .dependencies
                  .database
                  .cursorDao
                  .updateCursor(bid: widget.bid, page: page),
              itemCount: pages.length,
              itemBuilder: (context, index) => pages[index],
            );
          },
        );
      default:
        return Center(child: Text('Unsupported scroll style: $pageScrollStyle'));
    }
  }

  @override
  Widget build(BuildContext context) => FutureBuilder(
        future: initCursor(),
        builder: (
          ctx,
          snapshot,
        ) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          return BlocListener<ReaderNavigatorBloc, ReaderNavigatorState>(
            listener: (context, state) {
              _scrollController.jumpTo(index: state.chapterIndex);
            },
            child: SelectionArea(
              child: Padding(
                padding: EdgeInsets.only(
                  left: pageHorizontalPadding,
                  right: pageHorizontalPadding,
                  top: pageTopPadding,
                  bottom: pageBottomPadding,
                ),
                child: getScrollingWidget(),
              ),
            ),
          );
        },
      );

  Widget _buildFB2ElementWidget(FB2Element element) {
    if (element is FB2Image) {
      return Image.memory(element.bytes);
    }
    if (element is FB2Title) {
      return Text(
        element.text,
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: titleFontSize),
      );
    }
    if (element is FB2Subtitle) {
      return Center(
        child: Text(
          element.text,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: subtitleFontSize),
        ),
      );
    }
    if (element is FB2EmtpyLine) {
      return const SizedBox(height: 16);
    }
    if (element is FB2Paragraph) {
      final spans = <InlineSpan>[];
      for (final e in element.elements) {
        if (e is FB2Text) {
          spans.add(
            TextSpan(
              text: e.text,
              style: TextStyle(
                wordSpacing: 4,
                letterSpacing: letterSpacing,
                fontStyle: e.emphasis ? FontStyle.italic : FontStyle.normal,
                fontSize: fontSize,
              ),
            ),
          );
        }
        if (e is FB2Link) {
          spans.add(
            WidgetSpan(
              child: Tooltip(
                triggerMode: TooltipTriggerMode.tap,
                verticalOffset: 10,
                preferBelow: false,
                waitDuration: Duration.zero,
                showDuration: const Duration(seconds: 10),
                richMessage: TextSpan(text: e.value ?? 'Link'),
                child: Text(
                  e.text,
                  style: TextStyle(
                    decoration: TextDecoration.underline,
                    color: Theme.of(context).primaryColor,
                    fontSize: fontSize,
                  ),
                ),
              ),
            ),
          );
        }
      }
      return Text.rich(
        TextSpan(children: spans),
        softWrap: true,
      );
    }
    if (element is FB2Link && element.type != LinkType.note) {
      return Text(element.value ?? 'Note');
    }
    return Text(element.runtimeType.toString());
  }

  Future<List<Column>> splitPages(FB2Book book) async {
    final pageHeight = MediaQuery.of(context).size.height - pageTopPadding - pageBottomPadding;
    final pageWidth = MediaQuery.of(context).size.width - settings.pageHorizontalPadding * 2;
    final pages = <Column>[];
    var pageChildren = <Widget>[];
    num totalHeight = 0;

    for (final e in book.elements) {
      final height = await getHeight(e, pageWidth);
      if (totalHeight + height > pageHeight) {
        pages.add(
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: List.from(pageChildren),
          ),
        );
        pageChildren = [];
        totalHeight = 0;
      }
      totalHeight += height;
      pageChildren.add(_buildFB2ElementWidget(e));
    }

    if (pageChildren.isNotEmpty) {
      pages.add(
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: List.from(pageChildren)),
      );
    }
    return pages;
  }

  Future<num> getHeight(FB2Element element, double pageWidth) async {
    await Future.delayed(Duration.zero);
    if (element is FB2EmtpyLine) {
      return 16;
    }
    if (element is FB2Image) {
      final h = 900;
      return h;
    }
    if (element is FB2Paragraph) {
      num totalHeight = 0;
      for (final childElement in element.elements) {
        totalHeight += await getHeight(childElement, pageWidth);
      }
      return totalHeight;
    }
    if (element is FB2Text || element is FB2Link || element is FB2Title || element is FB2Subtitle) {
      final textPainter = TextPainter(
        text: TextSpan(
          text: element.text,
          style: TextStyle(
            wordSpacing: 4,
            letterSpacing: letterSpacing,
            fontStyle: FontStyle.normal,
            fontSize: fontSize,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout(maxWidth: pageWidth);
      return textPainter.size.height;
    }
    return 0;
  }
}
