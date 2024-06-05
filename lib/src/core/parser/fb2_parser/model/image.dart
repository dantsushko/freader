import 'dart:convert';
import 'dart:typed_data';

import 'package:freader/src/core/parser/fb2_parser/model/element.dart';
import 'package:xml/xml.dart';

enum FB2ImageType { png, jpeg }

class FB2Image extends FB2Element{
  FB2Image(XmlElement image) {
    base64 = image.innerText;
    type = image.getAttribute('content-type') == 'image/png' ? FB2ImageType.png : FB2ImageType.jpeg;
    name = image.getAttribute('id') ?? '';
  }
  FB2Image.empty() : base64 = '', type = FB2ImageType.png, name = '';
  late final String base64;
  Uint8List get bytes => base64Decode(base64.replaceAll(RegExp(r'\s+'), ''));
  late final FB2ImageType type;
  late final String name;

  
  @override
  String toString() => 'FB2Image(name: $name)';
}
