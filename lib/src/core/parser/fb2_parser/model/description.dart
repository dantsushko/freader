import 'package:freader/src/core/parser/fb2_parser/model/document_info.dart';

import 'package:freader/src/core/parser/fb2_parser/model/title_info.dart';
import 'package:xml/xml.dart';

class FB2Description {

  FB2Description(XmlElement description) {
    titleInfo = FB2TitleInfo(description.getElement('title-info')!);
  } 
  late final FB2TitleInfo titleInfo;
  late final FB2DocumentInfo? documentInfo;



}
