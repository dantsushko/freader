import 'dart:convert';
import 'dart:io';

import 'package:xml/xml.dart';

class Fb2Book {

  Fb2Book({
    required this.stylesheets,
    required this.description,
    required this.bodies,
    required this.binaries,
  });

  factory Fb2Book.fromXml(XmlElement xml) {
    final stylesheets = xml.findElements('stylesheet').map(Stylesheet.fromXml).toList();

    final descriptionElement = xml.getElement('description');
    if (descriptionElement == null) {
      throw Exception('Missing <description> element');
    }
    final description = Description.fromXml(descriptionElement);

    final bodyElements = xml.findElements('body');
    if (bodyElements.isEmpty) {
      throw Exception('At least one <body> element is required');
    }
    final bodies = bodyElements.map(Body.fromXml).toList();

    final binaries = xml.findElements('binary').map(Binary.fromXml).toList();

    return Fb2Book(
      stylesheets: stylesheets,
      description: description,
      bodies: bodies,
      binaries: binaries,
    );
  }
  final List<Stylesheet> stylesheets;
  final Description description;
  final List<Body> bodies;
  final List<Binary> binaries;
}

class Stylesheet {

  Stylesheet({
    required this.type,
    required this.content,
  });

  factory Stylesheet.fromXml(XmlElement xml) {
    final type = xml.getAttribute('type');
    if (type == null) {
      throw Exception('Stylesheet missing "type" attribute');
    }
    final content = xml.innerText.trim();
    return Stylesheet(
      type: type,
      content: content,
    );
  }
  final String type;
  final String content;
}

class Description {

  Description({
    required this.titleInfo,
    required this.documentInfo, required this.customInfos, this.srcTitleInfo,
    this.publishInfo,
    this.outputs,
  });

  factory Description.fromXml(XmlElement xml) {
    final titleInfoElement = xml.getElement('title-info');
    if (titleInfoElement == null) {
      throw Exception('Missing <title-info> element');
    }
    final titleInfo = TitleInfo.fromXml(titleInfoElement);

    final srcTitleInfoElement = xml.getElement('src-title-info');
    final srcTitleInfo =
        srcTitleInfoElement != null ? TitleInfo.fromXml(srcTitleInfoElement) : null;

    final documentInfoElement = xml.getElement('document-info');
    if (documentInfoElement == null) {
      throw Exception('Missing <document-info> element');
    }
    final documentInfo = DocumentInfo.fromXml(documentInfoElement);

    final publishInfoElement = xml.getElement('publish-info');
    final publishInfo = publishInfoElement != null ? PublishInfo.fromXml(publishInfoElement) : null;

    final customInfos = xml.findElements('custom-info').map(CustomInfo.fromXml).toList();

    final outputs = xml.findElements('output').map(Output.fromXml).toList();

    return Description(
      titleInfo: titleInfo,
      srcTitleInfo: srcTitleInfo,
      documentInfo: documentInfo,
      publishInfo: publishInfo,
      customInfos: customInfos,
      outputs: outputs.isNotEmpty ? outputs : null,
    );
  }
  final TitleInfo titleInfo;
  final TitleInfo? srcTitleInfo;
  final DocumentInfo documentInfo;
  final PublishInfo? publishInfo;
  final List<CustomInfo> customInfos;
  final List<Output>? outputs;
}

class TitleInfo {

  TitleInfo({
    required this.genres,
    required this.authors,
    required this.bookTitle,
    required this.lang, this.annotation,
    this.keywords,
    this.date,
    this.coverpage,
    this.srcLang,
    this.translators,
    this.sequences,
  });

  factory TitleInfo.fromXml(XmlElement xml) {
    final genres = xml.findElements('genre').map(Genre.fromXml).toList();

    final authors = xml.findElements('author').map(Author.fromXml).toList();

    final bookTitleElement = xml.getElement('book-title');
    if (bookTitleElement == null) {
      throw Exception('Missing <book-title> element');
    }
    final bookTitle = bookTitleElement.innerText.trim();

    final annotationElement = xml.getElement('annotation');
    final annotation = annotationElement != null ? Annotation.fromXml(annotationElement) : null;

    final keywordsElement = xml.getElement('keywords');
    final keywords = keywordsElement?.innerText.trim();

    final dateElement = xml.getElement('date');
    final date = dateElement != null ? Date.fromXml(dateElement) : null;

    final coverpageElement = xml.getElement('coverpage');
    final coverpage = coverpageElement != null ? Coverpage.fromXml(coverpageElement) : null;

    final langElement = xml.getElement('lang');
    if (langElement == null) {
      throw Exception('Missing <lang> element');
    }
    final lang = langElement.innerText.trim();

    final srcLangElement = xml.getElement('src-lang');
    final srcLang = srcLangElement?.innerText.trim();

    final translators = xml.findElements('translator').map(Author.fromXml).toList();

    final sequences = xml.findElements('sequence').map(Sequence.fromXml).toList();

    return TitleInfo(
      genres: genres,
      authors: authors,
      bookTitle: bookTitle,
      annotation: annotation,
      keywords: keywords,
      date: date,
      coverpage: coverpage,
      lang: lang,
      srcLang: srcLang,
      translators: translators.isNotEmpty ? translators : null,
      sequences: sequences.isNotEmpty ? sequences : null,
    );
  }
  final List<Genre> genres;
  final List<Author> authors;
  final String bookTitle;
  final Annotation? annotation;
  final String? keywords;
  final Date? date;
  final Coverpage? coverpage;
  final String lang;
  final String? srcLang;
  final List<Author>? translators;
  final List<Sequence>? sequences;
}

class Genre {

  Genre({
    required this.genre,
    this.match = 100,
  });

  factory Genre.fromXml(XmlElement xml) {
    final genre = xml.innerText.trim();
    final matchStr = xml.getAttribute('match');
    final match = matchStr != null ? int.parse(matchStr) : 100;
    return Genre(
      genre: genre,
      match: match,
    );
  }
  final String genre;
  final int match;
}

class Author {

  Author({
    this.firstName,
    this.middleName,
    this.lastName,
    this.nickname,
    this.homePages,
    this.emails,
    this.id,
  });

  factory Author.fromXml(XmlElement xml) {
    final firstName = xml.getElement('first-name')?.innerText.trim();
    final middleName = xml.getElement('middle-name')?.innerText.trim();
    final lastName = xml.getElement('last-name')?.innerText.trim();
    final nickname = xml.getElement('nickname')?.innerText.trim();

    // If first-name and last-name are missing, then nickname is required
    if (firstName == null && lastName == null && nickname == null) {
      throw Exception('Author must have either name or nickname');
    }

    final homePages = xml.findElements('home-page').map((e) => e.innerText.trim()).toList();

    final emails = xml.findElements('email').map((e) => e.innerText.trim()).toList();

    final id = xml.getElement('id')?.innerText.trim();

    return Author(
      firstName: firstName,
      middleName: middleName,
      lastName: lastName,
      nickname: nickname,
      homePages: homePages.isNotEmpty ? homePages : null,
      emails: emails.isNotEmpty ? emails : null,
      id: id,
    );
  }
  final String? firstName;
  final String? middleName;
  final String? lastName;
  final String? nickname;
  final List<String>? homePages;
  final List<String>? emails;
  final String? id;
}

class Annotation {

  Annotation({required this.content});

  factory Annotation.fromXml(XmlElement xml) {
    final content =
        xml.children.whereType<XmlElement>().map(ContentElement.fromXml).toList();
    return Annotation(content: content);
  }
  final List<ContentElement> content;
}

class ContentElement {

  ContentElement({required this.name, this.content});

  factory ContentElement.fromXml(XmlElement xml) {
    final name = xml.name.local;
    // Implement parsing for different content types
    switch (name) {
      case 'p':
        return ContentElement(
          name: name,
          content: xml.innerText.trim(),
        );
      // Add cases for 'poem', 'cite', 'subtitle', etc.
      default:
        return ContentElement(
          name: name,
          content: xml.innerText.trim(),
        );
    }
  }
  // This class can be extended to handle different types like p, poem, etc.
  final String name;
  final dynamic content;
}
class Subtitle {

  Subtitle({required this.content, this.lang});

  factory Subtitle.fromXml(XmlElement xml) {
    final lang = xml.getAttribute('xml:lang');
    final content = xml.children
        .whereType<XmlElement>()
        .map(ContentElement.fromXml)
        .toList();
    return Subtitle(content: content, lang: lang);
  }
  final List<ContentElement> content;
  final String? lang;
}
class Date {

  Date({required this.text, this.value});

  factory Date.fromXml(XmlElement xml) {
    final text = xml.innerText.trim();
    final value = xml.getAttribute('value');
    return Date(
      text: text,
      value: value,
    );
  }
  final String text;
  final String? value;
}

class Coverpage {

  Coverpage({required this.images});

  factory Coverpage.fromXml(XmlElement xml) {
    final images = xml.findElements('image').map(InlineImage.fromXml).toList();
    return Coverpage(images: images);
  }
  final List<InlineImage> images;
}

class InlineImage {

  InlineImage({required this.href, this.alt});

  factory InlineImage.fromXml(XmlElement xml) {
    final href = xml.getAttribute('l:href');
    if (href == null) {
      throw Exception('Image missing "l:href" attribute');
    }
    final alt = xml.getAttribute('alt');
    return InlineImage(
      href: href,
      alt: alt,
    );
  }
  final String href;
  final String? alt;
}

class Sequence {

  Sequence({
    required this.name,
    this.number,
    this.lang,
    this.subsequences,
  });

  factory Sequence.fromXml(XmlElement xml) {
    final name = xml.getAttribute('name');
    if (name == null) {
      throw Exception('Sequence missing "name" attribute');
    }
    final numberStr = xml.getAttribute('number');
    final number = numberStr != null ? int.parse(numberStr) : null;
    final lang = xml.getAttribute('xml:lang');

    final subsequences = xml.findElements('sequence').map(Sequence.fromXml).toList();

    return Sequence(
      name: name,
      number: number,
      lang: lang,
      subsequences: subsequences.isNotEmpty ? subsequences : null,
    );
  }
  final String name;
  final int? number;
  final String? lang;
  final List<Sequence>? subsequences;
}

class DocumentInfo {

  DocumentInfo({
    required this.authors,
    required this.date, required this.id, required this.version, this.programUsed,
    this.srcUrls,
    this.srcOcr,
    this.history,
    this.publishers,
  });

  factory DocumentInfo.fromXml(XmlElement xml) {
    final authors = xml.findElements('author').map(Author.fromXml).toList();

    final programUsed = xml.getElement('program-used')?.innerText.trim();

    final dateElement = xml.getElement('date');
    if (dateElement == null) {
      throw Exception('Missing <date> element in <document-info>');
    }
    final date = Date.fromXml(dateElement);

    final srcUrls = xml.findElements('src-url').map((e) => e.innerText.trim()).toList();

    final srcOcr = xml.getElement('src-ocr')?.innerText.trim();

    final idElement = xml.getElement('id');
    if (idElement == null) {
      throw Exception('Missing <id> element in <document-info>');
    }
    final id = idElement.innerText.trim();

    final versionElement = xml.getElement('version');
    if (versionElement == null) {
      throw Exception('Missing <version> element in <document-info>');
    }
    final version = double.parse(versionElement.innerText.trim());

    final historyElement = xml.getElement('history');
    final history = historyElement != null ? Annotation.fromXml(historyElement) : null;

    final publishers = xml.findElements('publisher').map(Author.fromXml).toList();

    return DocumentInfo(
      authors: authors,
      programUsed: programUsed,
      date: date,
      srcUrls: srcUrls.isNotEmpty ? srcUrls : null,
      srcOcr: srcOcr,
      id: id,
      version: version,
      history: history,
      publishers: publishers.isNotEmpty ? publishers : null,
    );
  }
  final List<Author> authors;
  final String? programUsed;
  final Date date;
  final List<String>? srcUrls;
  final String? srcOcr;
  final String id;
  final double version;
  final Annotation? history;
  final List<Author>? publishers;
}

class PublishInfo {

  PublishInfo({
    this.bookName,
    this.publisher,
    this.city,
    this.year,
    this.isbn,
    this.sequences,
  });

  factory PublishInfo.fromXml(XmlElement xml) {
    final bookName = xml.getElement('book-name')?.innerText.trim();
    final publisher = xml.getElement('publisher')?.innerText.trim();
    final city = xml.getElement('city')?.innerText.trim();
    final year = xml.getElement('year')?.innerText.trim();
    final isbn = xml.getElement('isbn')?.innerText.trim();

    final sequences = xml.findElements('sequence').map(Sequence.fromXml).toList();

    return PublishInfo(
      bookName: bookName,
      publisher: publisher,
      city: city,
      year: year,
      isbn: isbn,
      sequences: sequences.isNotEmpty ? sequences : null,
    );
  }
  final String? bookName;
  final String? publisher;
  final String? city;
  final String? year;
  final String? isbn;
  final List<Sequence>? sequences;
}

class CustomInfo {

  CustomInfo({
    required this.infoType,
    required this.content,
  });

  factory CustomInfo.fromXml(XmlElement xml) {
    final infoType = xml.getAttribute('info-type');
    if (infoType == null) {
      throw Exception('custom-info missing "info-type" attribute');
    }
    final content = xml.innerText.trim();
    return CustomInfo(
      infoType: infoType,
      content: content,
    );
  }
  final String infoType;
  final String content;
}

class Output {

  Output({
    required this.mode,
    required this.includeAll,
    this.price,
    this.currency,
    this.parts,
    this.outputDocumentClasses,
  });

  factory Output.fromXml(XmlElement xml) {
    final mode = xml.getAttribute('mode');
    final includeAll = xml.getAttribute('include-all');
    if (mode == null || includeAll == null) {
      throw Exception('output missing required attributes');
    }
    final priceStr = xml.getAttribute('price');
    final price = priceStr != null ? double.parse(priceStr) : null;
    final currency = xml.getAttribute('currency');

    final parts = xml.findElements('part').map(PartShareInstruction.fromXml).toList();

    final outputDocumentClasses = xml
        .findElements('output-document-class')
        .map(OutputDocumentClass.fromXml)
        .toList();

    return Output(
      mode: mode,
      includeAll: includeAll,
      price: price,
      currency: currency,
      parts: parts.isNotEmpty ? parts : null,
      outputDocumentClasses: outputDocumentClasses.isNotEmpty ? outputDocumentClasses : null,
    );
  }
  final String mode;
  final String includeAll;
  final double? price;
  final String? currency;
  final List<PartShareInstruction>? parts;
  final List<OutputDocumentClass>? outputDocumentClasses;
}

class PartShareInstruction {

  PartShareInstruction({
    required this.href,
    required this.include,
  });

  factory PartShareInstruction.fromXml(XmlElement xml) {
    final href = xml.getAttribute('xlink:href', namespace: 'http://www.w3.org/1999/xlink');
    final include = xml.getAttribute('include');
    if (href == null || include == null) {
      throw Exception('part missing required attributes');
    }
    return PartShareInstruction(
      href: href,
      include: include,
    );
  }
  final String href;
  final String include;
}

class OutputDocumentClass {

  OutputDocumentClass({
    required this.name,
    this.create,
    this.price,
    this.parts,
  });

  factory OutputDocumentClass.fromXml(XmlElement xml) {
    final name = xml.getAttribute('name');
    if (name == null) {
      throw Exception('output-document-class missing "name" attribute');
    }
    final create = xml.getAttribute('create');
    final priceStr = xml.getAttribute('price');
    final price = priceStr != null ? double.parse(priceStr) : null;

    final parts = xml.findElements('part').map(PartShareInstruction.fromXml).toList();

    return OutputDocumentClass(
      name: name,
      create: create,
      price: price,
      parts: parts.isNotEmpty ? parts : null,
    );
  }
  final String name;
  final String? create;
  final double? price;
  final List<PartShareInstruction>? parts;
}

class Body {

  Body({
    required this.sections, this.name,
    this.image,
    this.title,
    this.epigraphs,
    this.lang,
  });

  factory Body.fromXml(XmlElement xml) {
    final name = xml.getAttribute('name');
    final lang = xml.getAttribute('xml:lang');

    final imageElement = xml.getElement('image');
    final image = imageElement != null ? Image.fromXml(imageElement) : null;

    final titleElement = xml.getElement('title');
    final title = titleElement != null ? Title.fromXml(titleElement) : null;

    final epigraphs = xml.findElements('epigraph').map(Epigraph.fromXml).toList();

    final sections = xml.findElements('section').map(Section.fromXml).toList();

    return Body(
      name: name,
      image: image,
      title: title,
      epigraphs: epigraphs.isNotEmpty ? epigraphs : null,
      sections: sections,
      lang: lang,
    );
  }
  final String? name;
  final Image? image;
  final Title? title;
  final List<Epigraph>? epigraphs;
  final List<Section> sections;
  final String? lang;
}

class Image {

  Image({
    required this.href,
    this.alt,
    this.title,
    this.id,
  });

  factory Image.fromXml(XmlElement xml) {
    final href = xml.getAttribute('l:href');
    if (href == null) {
      throw Exception('Image missing "l:href" attribute');
    }
    final alt = xml.getAttribute('alt');
    final title = xml.getAttribute('title');
    final id = xml.getAttribute('id');
    return Image(
      href: href,
      alt: alt,
      title: title,
      id: id,
    );
  }
  final String href;
  final String? alt;
  final String? title;
  final String? id;
}

class Title {

  Title({required this.content, this.lang});

  factory Title.fromXml(XmlElement xml) {
    final lang = xml.getAttribute('xml:lang');
    final content =
        xml.children.whereType<XmlElement>().map(ContentElement.fromXml).toList();
    return Title(content: content, lang: lang);
  }
  final List<ContentElement> content;
  final String? lang;
}

class Epigraph {

  Epigraph({required this.content, this.textAuthors, this.id});

  factory Epigraph.fromXml(XmlElement xml) {
    final id = xml.getAttribute('id');
    final content =
        xml.children.whereType<XmlElement>().map(ContentElement.fromXml).toList();

    final textAuthors = xml.findElements('text-author').map((e) => e.innerText.trim()).toList();

    return Epigraph(
      content: content,
      textAuthors: textAuthors.isNotEmpty ? textAuthors : null,
      id: id,
    );
  }
  final List<ContentElement> content;
  final List<String>? textAuthors;
  final String? id;
}

class Section {

  Section({
    this.title,
    this.epigraphs,
    this.image,
    this.annotation,
    this.subsections,
    this.content,
    this.id,
    this.lang,
  });

  factory Section.fromXml(XmlElement xml) {
    final id = xml.getAttribute('id');
    final lang = xml.getAttribute('xml:lang');

    final titleElement = xml.getElement('title');
    final title = titleElement != null ? Title.fromXml(titleElement) : null;

    final epigraphs = xml.findElements('epigraph').map(Epigraph.fromXml).toList();

    final imageElement = xml.getElement('image');
    final image = imageElement != null ? Image.fromXml(imageElement) : null;

    final annotationElement = xml.getElement('annotation');
    final annotation = annotationElement != null ? Annotation.fromXml(annotationElement) : null;

    final sectionElements = xml.findElements('section');
    List<Section>? subsections;
    if (sectionElements.isNotEmpty) {
      subsections = sectionElements.map(Section.fromXml).toList();
    }

    // Content elements
    final contentElements = xml.children
        .whereType<XmlElement>()
        .where((e) {
          const contentTags = {
            'p',
            'poem',
            'subtitle',
            'cite',
            'empty-line',
            'table',
            'image',
          };
          return contentTags.contains(e.name.local);
        })
        .map(ContentElement.fromXml)
        .toList();

    return Section(
      id: id,
      lang: lang,
      title: title,
      epigraphs: epigraphs.isNotEmpty ? epigraphs : null,
      image: image,
      annotation: annotation,
      subsections: subsections,
      content: contentElements.isNotEmpty ? contentElements : null,
    );
  }
  final Title? title;
  final List<Epigraph>? epigraphs;
  final Image? image;
  final Annotation? annotation;
  final List<Section>? subsections;
  final List<ContentElement>? content;
  final String? id;
  final String? lang;
}

class Binary {

  Binary({
    required this.id,
    required this.contentType,
    required this.data,
  });

  factory Binary.fromXml(XmlElement xml) {
    final id = xml.getAttribute('id');
    final contentType = xml.getAttribute('content-type');
    if (id == null || contentType == null) {
      throw Exception('Binary missing required attributes');
    }
       final base64Data = xml.text.replaceAll(RegExp(r'\s+'), '');
    final data = base64.decode(base64Data);
    return Binary(
      id: id,
      contentType: contentType,
      data: data,
    );
  }
  final String id;
  final String contentType;
  final List<int> data;
}


class TOCEntry {

  TOCEntry({
    required this.title,
    required this.level, this.id,
  });
  final String title;
  final String? id;
  final int level;
}

List<TOCEntry> generateTOC(Fb2Book book) {
  final toc = <TOCEntry>[];
  for (final body in book.bodies) {
    // Start from level 1 for top-level sections
    for (final section in body.sections) {
      _traverseSection(section, toc, 1);
    }
  }
  return toc;
}

void _traverseSection(Section section, List<TOCEntry> toc, int level) {
  // Extract the title text
  var titleText = '';
  if (section.title != null) {
    titleText =
        section.title!.content.map((contentElement) => contentElement.content).join(' ').trim();
  }

  // If the title is not empty, add it to the TOC
  if (titleText.isNotEmpty) {
    toc.add(TOCEntry(
      title: titleText,
      id: section.id,
      level: level,
    ));
  }

  // Recursively traverse subsections
  if (section.subsections != null) {
    for (final subsection in section.subsections!) {
      _traverseSection(subsection, toc, level + 1);
    }
  }
}

void main() {
  final file = File('/Users/dantsushko/development/freader/test/unit/fb2/skazka.fb2');
  final xmlString = file.readAsStringSync();
  final document = XmlDocument.parse(xmlString);
  final fictionBookElement = document.getElement('FictionBook');
  if (fictionBookElement == null) {
    throw Exception('No FictionBook element found in the file');
  }
  final fb2Book = Fb2Book.fromXml(fictionBookElement);

  print(fb2Book.bodies.first.sections.first.subsections?.length);

  final toc = generateTOC(fb2Book);
  for (var entry in toc) {
    final indent = '  ' * (entry.level - 1);
    print('$indent- ${entry.title} (${entry.id ?? 'no id'})');
  }
}