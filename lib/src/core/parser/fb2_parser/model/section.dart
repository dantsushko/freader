import 'package:freader/src/core/parser/fb2_parser/model/image.dart';
import 'package:freader/src/core/parser/fb2_parser/model/title_info.dart';
import 'package:xml/xml.dart';

import 'element.dart';
import 'link.dart';
import 'title.dart';

class FB2Text extends FB2Element {
  FB2Text(this.text, {this.emphasis = false});
  final String text;
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
        print(index);
        print(sectionTitle);
        children.add(FB2Title(index, node));
      } else if (node.name.local == 'subitle') {
        index++;
        children.add(FB2Subtitle(node));
      } else if (node.name.local == 'image') {
        index++;
        final href = node.getAttribute('l:href')!;
        final root = content.parentElement!.parentElement!;
        final binaries = root.findAllElements('binary');
        final image = binaries
            .firstWhere((element) => element.getAttribute('id') == href.replaceAll('#', ''));
        children.add(FB2Image(image));
      } else if (node.name.local == 'p') {
        index++;
        final p = FB2Paragraph();
        for (final child in node.children) {
          if (child is XmlElement && child.name.local == 'emphasis') {
            p.add(FB2Text(child.innerText, emphasis: true));
          }
          if (child is XmlElement && child.name.local == 'a') {
            final link = FB2Link(child);
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
