import 'package:xml/xml.dart';

import 'section.dart';

class FB2Body {
  FB2Body(this.body) {
    epigraph = body.getElement('epigraph')?.innerText;
    sections = body.findAllElements('section').map(FB2Section.new).toList();
    
    // allParagraphs = sections.expand((e) => e.content.findAllElements('p')).toList();
  }

  /// epigraph
  late final String? epigraph;
  // late final List<XmlElement> allParagraphs;
  late final XmlElement body;

  /// book chapters
  late final List<FB2Section> sections;
}
