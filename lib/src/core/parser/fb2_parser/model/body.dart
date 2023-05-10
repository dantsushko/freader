import 'package:xml/xml.dart';

import 'section.dart';

class FB2Body {
  FB2Body(XmlElement body) {
    epigraph = body.getElement('epigraph')?.innerText;
    sections = body.findAllElements('section').map(FB2Section.new).toList();
  }

  /// epigraph
  late final String? epigraph;
  
  /// book chapters
  late final List<FB2Section> sections;



}
