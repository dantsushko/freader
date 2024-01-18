import 'dart:convert';
import 'dart:typed_data';

import 'package:collection/collection.dart';
import 'package:freader/src/core/parser/fb2_parser/model/author.dart';
import 'package:freader/src/core/parser/fb2_parser/model/element.dart';
import 'package:xml/xml.dart';

import 'model/body.dart';
import 'model/description.dart';
import 'model/image.dart';
import 'model/link.dart';

class FB2Book {
  FB2Book({
    required this.description,
    required this.body,
    required this.images,
    required this.wordCount,
  });
  final FB2Description description;
  final FB2Body body;
  final List<FB2Image> images;
  final int wordCount;
  List<FB2Author> get authors => description.titleInfo.authors;
  String get bookTitle => description.titleInfo.bookTitle;
  String? get language => description.titleInfo.language;
  List<String> get genres => description.titleInfo.genres;
  FB2Image get cover =>
      images.firstWhereOrNull((element) => element.name == 'cover.jpg') ??
      images.firstOrNull ??
      FB2Image.empty();

  String? get publishDate => description.titleInfo.publishDate.toString();
  late final List<FB2Element> elements;
}


Future<FB2Book> parseFB2(Uint8List bytes) async {
  final res = utf8.decode(bytes);
  final root = XmlDocument.parse(res).getElement('FictionBook')!;
  final images = root.findAllElements('binary').map(FB2Image.new).toList();
  final description = FB2Description(root.getElement('description')!);
  final body = FB2Body(root.getElement('body')!);
  final allNotes = body.sections
      .map((e) => e.links.where((element) => element.type == LinkType.note))
      .expand((element) => element.map((e) => e))
      .toList();
  final allNoteValues =
      root.findAllElements('section').where((element) => element.getAttribute('id') != null);
  for (final note in allNotes) {
    final noteValue = allNoteValues
        .firstWhereOrNull((element) => element.getAttribute('id') == note.name.replaceAll('#', ''));
    note.value = noteValue?.getElement('p')?.innerText ?? '';
  }

  final wordCount =
      body.sections.map((e) => e.wordCount).reduce((value, element) => value + element);
  final book = FB2Book(body: body, description: description, images: images, wordCount: wordCount);

  book.elements = [book.cover, ...body.sections.expand((e) => e.children)];
  return book;
}
