import 'dart:convert';
import 'dart:typed_data';

import 'package:collection/collection.dart';
import 'package:freader/src/core/parser/fb2_parser/model/author.dart';
import 'package:freader/src/core/parser/fb2_parser/model/element.dart';
import 'package:freader/src/core/parser/fb2_parser/model/fb2_metadata.dart';
import 'package:freader/src/core/parser/fb2_parser/model/title_info.dart';
import 'package:l/l.dart';
import 'package:xml/xml.dart';

import 'model/body.dart';
import 'model/image.dart';
import 'model/link.dart';

class FB2Book {
  FB2Book({
    required this.titleInfo,
    required this.body,
    required this.images,
    required this.wordCount,
  });
  final FB2TitleInfo titleInfo;
  final FB2Body body;
  final List<FB2Image> images;
  final int wordCount;
  List<FB2Author> get authors => titleInfo.authors;
  String get bookTitle => titleInfo.bookTitle;
  String? get language => titleInfo.language;
  List<String> get genres => titleInfo.genres;
  FB2Image get cover =>
      images.firstWhereOrNull((element) => element.name == 'cover.jpg') ??
      images.firstOrNull ??
      FB2Image.empty();

  String? get publishDate => titleInfo.publishDate.toString();
  late final List<FB2Element> elements;
}

Future<Fb2Metadata> parseFB2MetaData(Uint8List bytes) async {
  final res = utf8.decode(bytes);
  final root = XmlDocument.parse(res).getElement('FictionBook')!;
  final titleInfo = FB2TitleInfo(root.getElement('description')!.getElement('title-info')!);
  final binaries = root.findAllElements('binary');
  final cover = binaries
      .firstWhereOrNull((element) => element.getAttribute('id') == 'cover.jpg') ?? binaries.firstOrNull;
  final metadata =
      Fb2Metadata(titleInfo, cover: cover != null ? FB2Image(cover).bytes : null);
  return metadata;
}

Future<FB2Book> parseFB2(Uint8List bytes) async {
  final res = utf8.decode(bytes);
  final root = XmlDocument.parse(res).getElement('FictionBook')!;
  final images = root.findAllElements('binary').map(FB2Image.new).toList();
  final titleInfo = FB2TitleInfo(root.getElement('description')!.getElement('title-info')!);
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
  final book = FB2Book(body: body, titleInfo: titleInfo, images: images, wordCount: wordCount);

  book.elements = [book.cover, ...body.sections.expand((e) => e.children)];
  return book;
}
