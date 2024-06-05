import 'dart:io';

import 'package:archive/archive.dart';
import 'package:collection/collection.dart';
// import 'package:epubx/epubx.dart';
import 'package:flutter/foundation.dart';
import 'package:freader/src/core/parser/fb2_parser/model/fb2_metadata.dart';
import 'package:freader/src/core/parser/model/book_metadata.dart';
import 'package:freader/src/core/parser/model/common_book.dart';
import 'package:freader/src/core/parser/toc.dart';
import 'package:freader/src/core/utils/path.dart';
import 'package:freader/src/feature/catalogues/opds/util.dart';
import 'package:l/l.dart';

import 'fb2_parser/fb2_parser.dart';





class Parser {
  Parser({this.downloadUrl});
  FB2Book? fb2Book;
  String? downloadUrl;
  int attempts = 0;

  Future<BookMetadata?> parseMetadata(String filePath) async {
    final format = getBookFormat(filePath);
    if (format == BookFormat.fb2) {
      final bytes = await getFb2Bytes(filePath);
      var fbMetaData = await compute(parseFB2MetaData, bytes);
      return BookMetadata.fromFb2Metadata(fbMetaData);
    }
  }

  Future<CommonBook?> parse(String filePath) async {
    final format = getBookFormat(filePath);
    // if (format == BookFormat.epub) {
    //   try {
    //     final bytes = File(filePath).readAsBytesSync();
    //     final epubBook = await compute(EpubReader.readBook, bytes);
    //     return CommonBook.fromEpub(epubBook, downloadUrl, filePath);
    //   } catch (e) {
    //     l.e(e);
    //     return null;
    //   }
    // }
    if (format == BookFormat.fb2) {
      final bytes = await getFb2Bytes(filePath);
      fb2Book = await compute(parseFB2, bytes);
      return CommonBook.fromFb2(fb2Book!, downloadUrl, filePath);
    }
    return null;
  }
}

Future<Uint8List> getFb2Bytes(String filePath) async {
  final file = File(filePath);
  if (!file.existsSync()) throw Exception('File not found');
  var bytes = await File(filePath).readAsBytes();
  if (filePath.contains('zip')) {
    final archive = ZipDecoder().decodeBytes(bytes);
    bytes = archive.first.content as Uint8List;
  }
  return bytes;
}
