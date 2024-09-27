import 'dart:io';
import 'package:test/test.dart';
import 'package:xml/xml.dart';

import 'gpt_gb2.dart';


Fb2Book parseFb2Book(String filePath) {
  final file = File(filePath);
  final xmlString = file.readAsStringSync();
  final document = XmlDocument.parse(xmlString);
  final fictionBookElement = document.rootElement;
  if (fictionBookElement.name.local != 'FictionBook') {
    throw Exception('Root element is not FictionBook');
  }
  return Fb2Book.fromXml(fictionBookElement);
}

void main() {
  group('fool.fb2', () {
    late Fb2Book fb2Book;

    setUp(() {
      // Replace 'path_to_fb2_file.fb2' with the actual path to your FB2 file.
      fb2Book = parseFb2Book('/Users/dantsushko/development/freader/test/unit/fb2/fool.fb2');
    });

    test('Book Title', () {
      expect(fb2Book.description.titleInfo.bookTitle, 'Странствия убийцы');
    });

    test('Author Name', () {
      final authors = fb2Book.description.titleInfo.authors;
      expect(authors.length, greaterThan(0));
      final author = authors.first;
      expect(author.firstName, 'Робин');
      expect(author.lastName, 'Хобб');
    });

    test('Genres', () {
      final genres = fb2Book.description.titleInfo.genres;
      expect(genres.map((g) => g.genre), containsAll(['foreign_fantasy', 'magician_book']));
    });

    test('Annotation', () {
      final annotation = fb2Book.description.titleInfo.annotation;
      expect(annotation, isNotNull);
      // Verify that the annotation contains at least one paragraph
      expect(annotation!.content.length, greaterThan(0));
      final firstParagraph = annotation.content.first;
      expect(firstParagraph.name, 'p');
      // As per policy, avoid checking specific text content here
    });

    test('Coverpage Image', () {
      final coverpage = fb2Book.description.titleInfo.coverpage;
      expect(coverpage, isNotNull);
      expect(coverpage!.images.length, greaterThan(0));
      final image = coverpage.images.first;
      expect(image.href, '#cover.jpg');
    });

    test('Language', () {
      final lang = fb2Book.description.titleInfo.lang;
      expect(lang, 'ru');
      final srcLang = fb2Book.description.titleInfo.srcLang;
      expect(srcLang, 'en');
    });

    test('Translator', () {
      final translators = fb2Book.description.titleInfo.translators;
      expect(translators, isNotNull);
      expect(translators!.length, greaterThan(0));
      final translator = translators.first;
      expect(translator.firstName, 'Мария');
      expect(translator.middleName, 'Алексеевна');
      expect(translator.lastName, 'Юнгер');
    });

    test('Sequences', () {
      final sequences = fb2Book.description.titleInfo.sequences;
      expect(sequences, isNotNull);
      expect(sequences!.map((s) => s.name), contains('Звезды новой фэнтези'));
      // Check nested sequences
      final elderlingsSequence = sequences.firstWhere((s) => s.name == 'Мир Элдерлингов');
      expect(elderlingsSequence.subsequences, isNotNull);
      final sagaSequence = elderlingsSequence.subsequences!.first;
      expect(sagaSequence.name, 'Сага о Видящих');
      expect(sagaSequence.number, 3);
    });

    test('Document Info', () {
      final docInfo = fb2Book.description.documentInfo;
      expect(docInfo.authors.length, greaterThan(0));
      final docAuthor = docInfo.authors.first;
      expect(docAuthor.firstName, 'Roland');
      expect(docAuthor.lastName, isEmpty);
      expect(docInfo.programUsed, isNotNull);
      expect(docInfo.date.value, '2017-02-11');
      expect(docInfo.id, '3d2d0000-18af-4824-a7c0-e526371f6214');
      expect(docInfo.version, 1.0);
    });

    test('Publisher Info', () {
      final publishInfo = fb2Book.description.publishInfo;
      expect(publishInfo, isNotNull);
      expect(publishInfo!.bookName, contains('Странствия убийцы'));
      expect(publishInfo.publisher, 'Эксмо');
      expect(publishInfo.city, 'Санкт-Петербург');
      expect(publishInfo.year, '2017');
      expect(publishInfo.isbn, '978-5-389-12886-6');
    });

    test('Table of Contents', () {
      final toc = generateTOC(fb2Book);
      expect(toc, isNotNull);
      expect(toc.length, greaterThan(0));
      // Optionally, check the first entry
      final firstEntry = toc.first;
      // As per policy, avoid checking specific titles
      expect(firstEntry.level, 1);
      // Verify that the IDs are present if needed
      // expect(firstEntry.id, isNotNull);
    });

    test('Binary Data', () {
      final binaries = fb2Book.binaries;
      expect(binaries.length, greaterThan(0));
      final binary = binaries.firstWhere((b) => b.id == 'cover.jpg',
          orElse: () => Binary(id: '', contentType: '', data: []));
      expect(binary.id, 'cover.jpg');
      expect(binary.contentType, isNotEmpty);
      expect(binary.data.length, greaterThan(0));
    });
  });
}
