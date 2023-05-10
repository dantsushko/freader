import 'dart:io';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:freader/src/core/parser/fb2_parser/fb2_parser.dart';

void main() {
  late FB2Book skazka;
  late FB2Book fool;
  setUp(() async {
    var bytes = File('test/unit/fb2/skazka.fb2.zip').readAsBytesSync();
    final archive = ZipDecoder().decodeBytes(bytes);
    bytes = archive.first.content as Uint8List;
    skazka = await parseFB2(bytes);
    bytes = File('test/unit/fb2/fool.fb2').readAsBytesSync();
    fool = await parseFB2(bytes);
  });
  group('skazka.fb2', () {
    test('Check titleInfo parsing', () {
      final titleInfo = skazka.description.titleInfo;
      expect(titleInfo.bookTitle, 'Сказка');
      expect(titleInfo.language, 'ru');
      expect(titleInfo.authors.length, 1);
      expect(titleInfo.authors.first.firstName, 'Стивен');
      expect(titleInfo.authors.first.lastName, 'Кинг'); 
      expect(titleInfo.genres, ['sf_fantasy']);    
    });
    
  });
  group('fool.fb2', () {
    test('Check titleInfo parsing', () {
      final titleInfo = fool.description.titleInfo;
      expect(titleInfo.bookTitle, 'Странствия убийцы');
      expect(titleInfo.language, 'ru');
      expect(titleInfo.authors.length, 1);
      expect(titleInfo.authors.first.firstName, 'Робин');
      expect(titleInfo.authors.first.lastName, 'Хобб');
      expect(titleInfo.genres, ['foreign_fantasy', 'magician_book']);    
    });
  });
}
