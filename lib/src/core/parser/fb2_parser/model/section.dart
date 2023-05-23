import 'package:collection/collection.dart';
import 'package:freader/src/core/parser/fb2_parser/model/image.dart';
import 'package:freader/src/core/parser/fb2_parser/model/title_info.dart';
import 'package:hyphenatorx/hyphenatorx.dart';
import 'package:hyphenatorx/languages/language_ru.dart';
import 'package:xml/xml.dart';

import 'element.dart';
import 'link.dart';
import 'title.dart';

final hyphenator = Hyphenator(Language_ru(), minWordLength: 4, symbol: '-');

class FB2Text extends FB2Element {
  FB2Text(String text, {this.emphasis = false}) {
    // this.text = hyphenator.hyphenateText(text);
    this.text = text.split('').join('\u{00AD}');
  }
  late final String text;
  final bool emphasis;
}

class FB2Paragraph extends FB2Element {
  List<FB2Element> _elements = [];
  List<FB2Element> get elements => _elements;

  void add(FB2Element element) {
    _elements.add(element);
  }
}

int index = 0;

class FB2Section {
  FB2Section(this.content) {
    children = [];
    for (final node in content.childElements) {
      if (node.name.local == 'title') {
        index++;
        final titleP = node.findAllElements('p');
        sectionTitle = titleP.map((e) => e.innerText).join(' ');
        children.add(FB2Title(index, node));
      } else if (node.name.local == 'subtitle') {
        index++;
        children.add(FB2Subtitle(node));
      } else if (node.name.local == 'image') {
        final href = node.getAttribute('l:href')!;
        final root = content.parentElement!.parentElement!;
        final binaries = root.findAllElements('binary');
        final image = binaries
            .firstWhereOrNull((element) => element.getAttribute('id') == href.replaceAll('#', ''));
        if (image != null) {
          children.add(FB2Image(image));
          index++;
        }
      } else if (node.name.local == 'p') {
        index++;
        final p = FB2Paragraph();
        for (final child in node.children) {
          if (child is XmlElement && child.name.local == 'emphasis') {
            p.add(FB2Text(child.innerText, emphasis: true));
            wordCount += child.innerText.split(' ').length;
          }
          if (child is XmlElement && child.name.local == 'a') {
            final link = FB2Link(child, child.getAttribute('type') ?? 'as');
            p.add(link);
            links.add(link);
          }
          if (child is XmlText) {
            p.add(FB2Text(child.toString()));
            wordCount += child.innerText.split(' ').length;
          }
        }
        children.add(p);
      } else if (node.name.local == 'empty-line') {
        index++;
        children.add(FB2EmtpyLine());
      }
    }
  }
  int wordCount = 0;
  final XmlElement content;
  late final List<FB2Element> children;
  List<FB2Link> links = [];
  late final String sectionTitle;
}
