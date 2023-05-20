import 'package:freader/src/core/parser/fb2_parser/model/body.dart';
import 'package:xml/xml.dart' as xml;

import 'fb2_parser/fb2_parser.dart';
import 'fb2_parser/model/title.dart';

class TableOfContents {
  List<Chapter> chapters;
  TableOfContents({this.chapters = const []}) {
    chapters = [];
  }

  void addChapter(Chapter chapter) {
    chapters.add(chapter);
  }

  factory TableOfContents.fromFB2(FB2Book book) {
    final toc = TableOfContents();
    final titles = book.elements.whereType<FB2Title>();
    for (final title in titles) {
      toc.addChapter(Chapter.fromFB2Title(title));
      ;
    }

    return toc;
  }

  // static Chapter _parseChapter(xml.XmlElement chapterElement) {
  //   final title = chapterElement.innerText.trim();
  //   final chapter = Chapter(title);

  //   final subchapters = chapterElement.findAllElements('subtitle');
  //   for (final subchapterElement in subchapters) {
  //     final subchapter = _parseChapter(subchapterElement);
  //     chapter.addSubchapter(subchapter);
  //   }

  //   return chapter;
  // }
}

class Chapter {
  late String title;
  late List<Chapter> subchapters;
  late int index;
  Chapter(this.title, this.index) {
    subchapters = [];
  }
  Chapter.fromFB2Title(FB2Title title) {
    this.title = title.text;
    index = title.index;
    subchapters = [];
  }
  void addSubchapter(Chapter subchapter) {
    subchapters.add(subchapter);
  }
}

// Usage

