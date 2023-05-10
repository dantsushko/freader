import 'package:xml/xml.dart';

import 'annotation.dart';
import 'author.dart';

class FB2TitleInfo {
  FB2TitleInfo(XmlElement titleInfo) {
    genres = titleInfo.findAllElements('genre').map((e) => e.innerText).toList();
    authors = titleInfo.findAllElements('author').map(FB2Author.new).toList();
    bookTitle = titleInfo.getElement('book-title')?.innerText ?? '';
    language = titleInfo.getElement('lang')?.innerText;
    annotation = titleInfo.getElement('annotation')!.innerText;
    publishDate = DateTime.tryParse(titleInfo.getElement('date')?.value ?? '');
  }

  late final String annotation;
  late final String? language;
  late final List<String> genres;
  late final List<FB2Author> authors;
  late final String bookTitle;
  late final DateTime? publishDate;
}
