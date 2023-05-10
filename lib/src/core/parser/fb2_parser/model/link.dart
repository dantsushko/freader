import 'package:xml/xml.dart';

class FB2Link {
  FB2Link(XmlElement section) {
    name = section.getAttribute('id')!;
    text = section.getElement('p')!.innerText;
  }
  late final String name;
  late final String text;

}
