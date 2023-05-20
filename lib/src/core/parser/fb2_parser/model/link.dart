import 'package:xml/xml.dart';

import 'element.dart';

enum LinkType { note, link }

class FB2Link extends FB2Element {
  FB2Link(XmlElement link) {
    name = link.getAttribute('href', namespace: '*')!;
    text = link.innerText;
  }
  late final String name;
  late final String text;
  String? value;
  final LinkType type = LinkType.note;
}
