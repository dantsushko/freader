import 'package:xml/xml.dart';

enum BookFormat {
  epub,
  fb2,
  pdf,
  djvu,
  mobi,
  txt,
  rtf,
  doc,
  djv,
  docx,
  unsupported
}

String? getValueFromXml(XmlNode doc, String key) {
  final elements = doc.findAllElements(key);
  if (elements.isEmpty) return null;
  return doc.findAllElements(key).map((e) => e.text).join(', ');
}
