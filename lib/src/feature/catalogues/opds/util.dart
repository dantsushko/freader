import 'package:xml/xml.dart';
enum SupportedExtensions {
  epub,
  fb2,
}

String? getValueFromXml(XmlNode doc, String key) {
final elements = doc.findAllElements(key);
if (elements.isEmpty) return null;
return doc.findAllElements(key).map((e) => e.text).join(', ');
}


