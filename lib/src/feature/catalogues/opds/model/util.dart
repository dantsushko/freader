import 'package:xml/xml.dart';
enum SupportedExtensions {
  epub,
  fb2,
}

String getValueFromXml(XmlNode doc, List<String> keys) {
  var value = 'NotFound';

  for (final key in keys) {
    try {
      value = doc.findAllElements(key).map((e) => e.text).join(', ');
    } catch (error) {
      print(error.toString());
    }
  }
  return value;
}
