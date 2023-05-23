import 'package:xml/xml.dart';

import 'element.dart';

enum LinkType { note, link }

class FB2Link extends FB2Element {
  FB2Link(XmlElement link, String type) {
    name = link.getAttribute('href', namespace: '*')!;
    text = link.innerText;
    this.type = type == 'note' ? LinkType.note : LinkType.link;
  }
  late final String name;
  late final String text;
  String? value;
  late final LinkType type;
}
