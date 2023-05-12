import 'dart:async';

import 'package:flutter/material.dart';
import 'package:freader/src/core/data/database/daos/settings_dao.dart';
import 'package:freader/src/core/parser/fb2_parser/fb2_parser.dart';
import 'package:freader/src/feature/initialization/widget/dependencies_scope.dart';
import 'package:xml/xml.dart';

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
  late final FB2Book book;
  Widget _buildParagraphWidget(XmlElement element) {
    final textSpans = <InlineSpan>[];

    for (final node in element.children) {
      if (node is XmlText) {
        textSpans.add(TextSpan(text: node.toString(), 
        
        style: TextStyle(
          overflow: TextOverflow.ellipsis,
          letterSpacing: letterSpacing,
          
          fontSize: fontSize)));
      } else if (node is XmlElement) {
        if (node.name.local == 'emphasis') {
          textSpans.add(
            TextSpan(
              text: node.innerText,
              style: TextStyle(fontStyle: FontStyle.italic, fontSize: fontSize),
            ),
          );
        } else if (node.name.local == 'a') {
          final href = node.getAttribute('l:href');
          final link = book.links[href];

          textSpans.add(
            WidgetSpan(
              child: Tooltip(
                triggerMode: TooltipTriggerMode.tap,
                verticalOffset: 10,
                preferBelow: false,
                waitDuration: Duration.zero,
                showDuration: const Duration(seconds: 10),
                richMessage: TextSpan(children: [TextSpan(text: link?.text ?? 'Link')]),
                child: Text(
                  node.innerText,
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
    }

    return SelectableText.rich(
    
      TextSpan(
        
        children: textSpans,
      ),
    );
  }

  Widget _buildWidget(XmlElement element) {
    if (element.name.local == 'section') {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: element.childElements.map(_buildWidget).toList(),
      );
    } else if (element.name.local == 'title') {
      final paragraphs = element.findElements('p').map((p) => p.innerText).toList();
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: paragraphs
            .map(
              (paragraph) => Text(
                paragraph,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: titleFontSize),
              ),
            )
            .toList(),
      );
    } else if (element.name.local == 'empty-line') {
      return const SizedBox(height: 16);
    } else if (element.name.local == 'image') {
      final imageUrl = element.getAttribute('l:href')!.replaceAll('#', '');
      final image = book.images.firstWhere((element) => element.name == imageUrl);
      return Padding(
        padding: const EdgeInsets.all(8),
        child: Image.memory(image.bytes),
      );
    } else if (element.name.local == 'subtitle') {
      return Center(
        child: Text(
          element.innerText,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: subtitleFontSize),
        ),
      );
    } else if (element.name.local == 'p') {
      return _buildParagraphWidget(element);
    }
    return const SizedBox.shrink();
  }

  late SettingsModel settings;
  double get fontSize => settings.fontSize.toDouble();
  double get subtitleFontSize => fontSize + 2;
  double get titleFontSize => fontSize + 4;
  double get pageHorizontalPadding => settings.pageHorizontalPadding.toDouble();
  double get pageTopPadding => settings.pageTopPadding.toDouble();
  double get pageBottomPadding => settings.pageBottomPadding.toDouble();
  double get letterSpacing => settings.letterSpacing.toDouble(); 
  late final StreamSubscription subscription;
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

  @override
  Widget build(BuildContext context) => Padding(
        padding: EdgeInsets.only(
            left: pageHorizontalPadding,
            right: pageHorizontalPadding,
            top: pageTopPadding,
            bottom: pageBottomPadding,),
        child: ListView(
          children: [
            Image.memory(book.cover.bytes),
            Text(book.body.epigraph ?? '', style: TextStyle(fontSize: fontSize)),
            ...book.body.sections.map((e) => _buildWidget(e.content))
          ],
        ),
      );
}
