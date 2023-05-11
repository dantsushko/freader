import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:freader/src/core/parser/fb2_parser/fb2_parser.dart';
import 'package:xml/xml.dart';

import '../../../core/parser/fb2_parser/model/section.dart';

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
        textSpans.add(TextSpan(text: node.toString()));
      } else if (node is XmlElement) {
        if (node.name.local == 'emphasis') {
          textSpans.add(
            TextSpan(
              text: node.innerText,
              style: const TextStyle(fontStyle: FontStyle.italic),
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
                    style: TextStyle(decoration: TextDecoration.underline, color: Theme.of(context).primaryColor),
                  ),),
            ),
          );
        }
      }
    }

    return SelectableText.rich(
      TextSpan(children: textSpans),
    );
  }

  Widget _buildWidget(XmlElement element) {
    if (element.name.local == 'section') {
      return Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: element.childElements.map(_buildWidget).toList(),
        ),
      );
    } else if (element.name.local == 'title') {
      final paragraphs = element.findElements('p').map((p) => p.innerText).toList();
      return Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: paragraphs
              .map(
                (paragraph) => Text(
                  paragraph,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
              )
              .toList(),
        ),
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
      return Padding(
        padding: const EdgeInsets.all(8),
        child: Center(
          child: Text(
            element.innerText,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),
      );
    } else if (element.name.local == 'p') {
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: _buildParagraphWidget(element),
      );
    }
    return const SizedBox.shrink();
  }

  @override
  void initState() {
    book = widget.book;
    super.initState();
  }

  @override
  Widget build(BuildContext context) => ListView(
        children: [
          Center(
            child: Text(
              book.bookTitle,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          Image.memory(book.cover.bytes),
          Text(book.body.epigraph ?? ''),
          ...book.body.sections.map((e) => _buildWidget(e.content!))
        ],
      );
}
