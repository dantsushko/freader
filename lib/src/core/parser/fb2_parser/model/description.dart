import 'author.dart';

class FB2Description {
  /// genres of books
  late final List<String>? genres;

  /// book authors and document authors
  late final List<FB2Author>? authors;

  /// book title
  late final String? bookTitle;

  /// annotation
  late final String? annotation;

  /// date the book was written
  late final String? date;

  /// book language
  late final String? lang;

  /// language of the original book (if it's a translation)
  late final String? srcLang;

  /// sequence
  late final String? sequence;

  late final String? coverPageId;

  FB2Description(final String description) {
    /// parse [genres]
    final Iterable<RegExpMatch> _genres =
        RegExp(r'<genre>([\s\S]+?)<\/genre>').allMatches(description);
    genres = [];
    for (var _genre in _genres) {
      genres!.add(_genre.group(1).toString());
    }

    /// parse [authors]
    final Iterable<RegExpMatch> _authors =
        RegExp(r'<author>([\s\S]+?)<\/author>').allMatches(description);
    authors = [];
    for (var _author in _authors) {
      authors!.add(FB2Author(_author.group(1).toString()));
    }

    /// parse [bookTitle]
    bookTitle =
        RegExp(r'<book-title>([\s\S]+?)<\/book-title>').firstMatch(description)?.group(1);
    /// parse coverpage
    coverPageId =  RegExp(r'<coverpage[\s\S]+?image l:href="([\s\S]+?)"').firstMatch(description)?.group(0)?.replaceAll('#','');
    /// parse [annotation]
    annotation =
        RegExp(r'<annotation>([\s\S]+?)<\/annotation>').firstMatch(description)?.group(1);

    /// parse [date]
    date = RegExp(r'<date[\s\S]+?>([\s\S]+?)<\/date>').firstMatch(description)?.group(1);

    /// parse [lang]
    lang = RegExp(r'<lang>([\s\S]+?)<\/lang>').firstMatch(description)?.group(1);

    /// parse [srcLang]
    srcLang = RegExp(r'<src-lang>([\s\S]+?)<\/src-lang>').firstMatch(description)?.group(1);

    /// parse [sequence]
    sequence = RegExp(r'<sequence name="([\s\S]+?)"\/\>').firstMatch(description)?.group(1);
  }

  @override
  String toString() {
    return 'FB2Description(bookTitle: $bookTitle)';
  }
}
