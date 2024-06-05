import 'package:collection/collection.dart';
import 'package:freader/src/core/parser/fb2_parser/model/image.dart';
import 'package:xml/xml.dart';

import 'element.dart';
import 'link.dart';
import 'title.dart';

String split(String sentence, {String separator = '\u{00AD}'}) {
  final words = sentence.split(' ');
  final res = [];
  for (final w in words) {
    final prefixMatch = RegExp(r'^\p{P}+', unicode: true).firstMatch(w);
    final wordMatch = RegExp(r'[^\p{P}\s]+', unicode: true).firstMatch(w);
    final postfixMatch = RegExp(r'\p{P}+$', unicode: true).firstMatch(w);

    final prefix = prefixMatch != null ? prefixMatch.group(0)! : '';
    final word = wordMatch != null ? wordMatch.group(0)! : '';
    final postfix = postfixMatch != null ? postfixMatch.group(0)! : '';

    final splitted = splitWord(word).join(separator);
    res.add('$prefix$splitted$postfix');
  }
  return res.join(' ');
}

List<String> splitWord(String word) {
  const vowels = 'аеёиоуыэюяАЕЁИОУЫЭЮЯ';
  const appendage = 'йьъЙЬЪ';
  const consonants = 'бвгджзйклмнпрстфхцчшщьъБВГДЖЗЙКЛМНПРСТФХЦЧШЩЬЪ';
  const sonorants = 'лмнрЛМНР';

  final syllableRegexp = RegExp('[$consonants]*[$vowels]([$consonants]*\$)?');
  final syllables = syllableRegexp.allMatches(word).map((match) => match.group(0)!).toList();
  for (var i = 1; i < syllables.length; i++) {
    final match = RegExp('^[$consonants]*[$appendage]').firstMatch(syllables[i]);
    if (match != null && syllables[i] != 'ться') {
      syllables[i - 1] += match.group(0)!;
      syllables[i] = syllables[i].substring(match.group(0)!.length);
    } else if (sonorants.contains(syllables[i][0]) && !vowels.contains(syllables[i][1])) {
      syllables[i - 1] += syllables[i][0];
      syllables[i] = syllables[i].substring(1);
    }
  }
  if (syllables.isEmpty) {
    return [word];
  }

  return syllables;
}

class FB2Text extends FB2Element {
  FB2Text(this.text, {this.emphasis = false});
  late final String text;
  final bool emphasis;
}

class FB2Paragraph extends FB2Element {
  final List<FB2Element> _elements = [];
  List<FB2Element> get elements => _elements;
  String get text => _elements.map((e) => e.text).join(' ');
  void add(FB2Element element) {
    _elements.add(element);
  }

  FB2Paragraph({List<FB2Element> elements = const []}) {
    _elements.addAll(elements);
  }

    List<FB2Paragraph> split(int splitIndex) {
    var currentIndex = 0;
    final firstPart = <FB2Element>[];
    final secondPart = <FB2Element>[];

    for (final element in _elements) {
      if (currentIndex + element.text.length <= splitIndex) {
        firstPart.add(element);
      } else if (currentIndex >= splitIndex) {
        secondPart.add(element);
      } else {
        final splitPoint = splitIndex - currentIndex;
        if (element is FB2Text) {
          final firstText = FB2Text(element.text.substring(0, splitPoint), emphasis: element.emphasis);
          final secondText = FB2Text(element.text.substring(splitPoint), emphasis: element.emphasis);
          firstPart.add(firstText);
          secondPart.add(secondText);
        // } else if (element is FB2Link) {
        //   var firstText = FB2Text(element.text.substring(0, splitPoint));
        //   var secondText = FB2Text(element.text.substring(splitPoint));
        //   firstPart.add(FB2Link.fromText(firstText, element.));
        //   secondPart.add(FB2Link.fromText(secondText, element.href));
        }
      }
      currentIndex += element.text.length;
    }

    return [FB2Paragraph(elements: firstPart), FB2Paragraph(elements: secondPart)];
  }

}
int findWordSplitIndex(String text) {
  for (var i = text.length - 1; i >= 0; i--) {
    if (RegExp(r'\w').hasMatch(text[i])) {
      return i;
    }
  }
  return -1;
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
