import 'package:xml/xml.dart';

String? getElementText(XmlElement root, String tagName) {
  final element = root.getElement(tagName);
  return element?.innerText;
}
String? getElementAttribute(XmlElement root, String tagName, String attributeName) {
  final element = root.getElement(tagName);
  return element?.getAttribute(attributeName);
}
