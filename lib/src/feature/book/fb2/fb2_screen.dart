import 'dart:async';

import 'package:flutter/cupertino.dart';
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
import 'package:xml/xml.dart';

import '../../../core/parser/fb2_parser/model/title.dart';
import '../blocs/navigator/bloc/reader_navigator_bloc.dart';

class FB2Screen extends StatefulWidget {
  const FB2Screen({
    required this.book,
    super.key,
  });
  final FB2Book book;

  @override
  State<FB2Screen> createState() => _FB2ScreenState();
}

class _FB2ScreenState extends State<FB2Screen> {
  final ItemScrollController _scrollController = ItemScrollController();
  late final FB2Book book;
  late SettingsModel settings;
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

  @override
  void dispose() {
    subscription.cancel();
    super.dispose();
  }

  List<XmlElement> bookPages = [XmlElement(XmlName('p'), [], [])];

  Widget getScrollingWidget() {
    switch (pageScrollStyle) {
      case PageScrollStyle.scroll:
        return ScrollablePositionedList.builder(
            itemCount: book.elements.length,
            itemScrollController: _scrollController,
            itemBuilder: (context, index) => _buildFB2ElementWidget(book.elements[index])
            // children: [
            //   Image.memory(book.cover.bytes),
            //   Text(book.body.epigraph ?? '', style: TextStyle(fontSize: fontSize)),
            //   ....map((e) => _buildFB2ElementWidget(e.content)),
            // ],
            );

      case PageScrollStyle.shift:
        return PageView.builder(
          itemCount: bookPages.length,
          itemBuilder: (context, index) => Text(bookPages[index].toString()),
        );
      default:
        return Center(child: Text('Unsupported scroll style: $pageScrollStyle'));
    }
  }

  @override
  Widget build(BuildContext context) => BlocListener<ReaderNavigatorBloc, ReaderNavigatorState>(
        listener: (context, state) {
          _scrollController.jumpTo(index: state.chapterIndex, alignment: 0);
        },
        child: SelectionArea(
          child: Padding(
              padding: EdgeInsets.only(
                left: pageHorizontalPadding,
                right: pageHorizontalPadding,
                top: pageTopPadding,
                bottom: pageBottomPadding,
              ),
              child: getScrollingWidget()),
        ),
      );

  Widget _buildFB2ElementWidget(FB2Element element) {
    if (element is FB2Image) {
      return Image.memory(element.bytes);
    }
    if (element is FB2Title) {
      return Text(element.text,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: titleFontSize));
    }
    if (element is FB2Subtitle) {
      return Center(
        child: Text(element.text,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: subtitleFontSize)),
      );
    }
    if (element is FB2EmtpyLine) {
      return const SizedBox(height: 16);
    }
    if (element is FB2Paragraph) {
      final spans = <InlineSpan>[];
      for (final e in element.elements) {
        if (e is FB2Text) {
          spans.add(TextSpan(text:e.text,
              style: TextStyle(
                  letterSpacing: letterSpacing,
                  fontStyle: e.emphasis ? FontStyle.italic : FontStyle.normal,
                  fontSize: fontSize)));
        }
        if (e is FB2Link) {
          spans.add(WidgetSpan(
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
          ));
        }
      }
      return Text.rich(
        TextSpan(children: spans),
      );
    
    }
    if (element is FB2Link && element.type != LinkType.note) {
      return Text(element.value ?? 'Note');
    }
    return Text(element.runtimeType.toString());
  }
}
