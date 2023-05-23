import 'package:freader/src/core/parser/fb2_parser/model/element.dart';
import 'package:xml/xml.dart';

class FB2Title extends FB2Element {
  int index;
  FB2Title(this.index, XmlElement element) {
    text = element.findAllElements('p').map((e) => e.innerText).join('\n');
  }
  late final String text;
}

class FB2Subtitle extends FB2Element {
  FB2Subtitle(XmlElement element) {
    text = element.innerText;
  }
  late final String text;
}
