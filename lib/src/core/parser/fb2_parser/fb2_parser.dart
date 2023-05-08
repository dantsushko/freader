import 'dart:convert';
import 'dart:typed_data';

import 'package:collection/collection.dart';

import 'model/body.dart';
import 'model/description.dart';
import 'model/image.dart';

class FB2Book {

  /// book description
  final FB2Description description;

  /// main body of the book
  final FB2Body body;

  /// all images in the book
  final List<FB2Image> images;
  FB2Image? get cover => images.firstWhereOrNull((element) => element.name == 'cover.jpg');
  // FB2Book(Uint8List bytes, this.path) {
  //   content = utf8.decode(bytes);
  // }
  FB2Book(
      {required this.description, required this.body, required this.images});

  /// Parsing the book
}

Future<FB2Book> parseFB2(Uint8List bytes) async {
  var res = utf8.decode(bytes);

  /// parse [images]
  final _images = RegExp(r'<binary[\s\S]+?>([\s\S]+?)<\/binary>').allMatches(res);
  var images = <FB2Image>[];
  for (var image in _images) {
    images.add(FB2Image(image.group(0)!));
  }

  /// replacing the fb2 tag <image ...> with html tag <img ...>
  res = res.replaceAllMapped(RegExp(r'<image([\s\S]+?)\/>'), (match) {
    final name = RegExp(r'="#([\s\S]+?)"').firstMatch(match.group(1)!)?.group(1) as String;
    FB2Image? currentImage;
    for (var image in images) {
      if (image.name == name) currentImage = image;
    }
    if (currentImage == null) return match.group(0)!;
    return '<img src="data:image/png;base64, ${currentImage.bytes}"/>';
  });

  /// replacing the fb2 tag <empty-line/> with html tag <br>
  res = res.replaceAllMapped(RegExp('<empty-line.?>'), (_) => '<br>');

  /// remove the tag <a l:href ...>
  res = res.replaceAllMapped(RegExp(r'<a ([a-zA-Z\:]*)href([\s\S]+?)>([\s\S]+?)<\/a>'), (match) => '${match.group(3)}');

  /// parse [description]
  final description =
      RegExp(r'<description>([\s\S]+)<\/description>').firstMatch(res)?.group(1);

  /// parse [body]
  final body = RegExp(r'<body>([\s\S]+)<\/body>').firstMatch(res)?.group(1);
  return FB2Book(
      body: FB2Body(body ?? ''), description: FB2Description(description ?? ''), images: images);
}
