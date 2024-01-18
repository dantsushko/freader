// import 'dart:io';
// import 'dart:typed_data';

// import 'package:archive/archive.dart';
// import 'package:epubx/epubx.dart';
// import 'package:flutter_test/flutter_test.dart';

// void main() {
//   late final EpubBook witcher;
//   late final EpubBookRef witcherRef;
//   setUp(() async {
//     var bytes = File('test/unit/epub/witcher.epub').readAsBytesSync();
//     witcher = await EpubReader.readBook(bytes);
//     witcherRef = await EpubReader.openBook(bytes);
//   });
//   group('witcher.epub', () {
//     test('Check titleInfo parsing', () {
//       for (final c in witcher.Chapters ?? <EpubChapter>[]) {
//         print(c.Title);
//         for (final s in c.SubChapters ?? <EpubChapter>[]) {
//           print('--${s.Title}');
//           print(s.Anchor);
//           for (final s in s.SubChapters ?? <EpubChapter>[]) {
//             print('----${s.Title}');
//             print(s.Anchor);
//           }
//         }
//       }
//     });
//   });
// }
