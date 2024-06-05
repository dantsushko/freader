import 'package:xml/xml.dart';

import 'section.dart';

class FB2Body {
  FB2Body(this.body) {
    epigraph = body.getElement('epigraph')?.innerText;
    sections = body.findAllElements('section').map(FB2Section.new).toList();
  }
  late final String? epigraph;
  late final XmlElement body;
  late final List<FB2Section> sections;
}
