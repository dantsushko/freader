import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:collection/collection.dart';
import 'package:epubx/epubx.dart';
import 'package:flutter/foundation.dart';
import 'package:freader/src/core/parser/fb2_parser/model/body.dart';
import 'package:freader/src/core/utils/path.dart';
import 'package:freader/src/feature/catalogues/opds/util.dart';
import 'package:l/l.dart';
import 'package:path/path.dart' as path;

import 'fb2_parser/fb2_parser.dart';

class CommonBook {
  CommonBook.fromFb2(FB2Book fb2Book, this.downloadUrl, this.path)
      : title = fb2Book.description.bookTitle!,
        language = fb2Book.description.lang ?? '',
        published = fb2Book.description.date ?? '',
        directory = getDirName(path),
        fileName = getFileName(path),
        format = 'fb2',
        fb2body = fb2Book.body,
        annotation = fb2Book.description.annotation ?? 'No annotation',
        cover = fb2Book.cover?.bytes ?? '',
        filePath = path;
  CommonBook.fromEpub(EpubBook epubBook, this.downloadUrl, this.path)
      : title = epubBook.Title ?? '',
        language = epubBook.Schema?.Package?.Metadata?.Languages?.firstOrNull ?? '',
        published = epubBook.Schema?.Package?.Metadata?.Dates?.firstOrNull?.Date ?? '',
        directory = getDirName(path),
        fileName = getFileName(path),
        format = 'epub',
        filePath = path,
        annotation = epubBook.Schema?.Package?.Metadata?.Description ?? 'No annotation',
        cover = base64Encode(epubBook.CoverImage?.data ?? []);
  String title;
  String path;
  String? downloadUrl;
  String format;
  String language;
  String published;
  String directory;
  String fileName;
  String filePath;
  String cover;
  String annotation;
  FB2Body? fb2body;
}

class Parser {
  Parser({this.downloadUrl});
  FB2Book? fb2Book;
  String? downloadUrl;
  var attempts = 0;
  Future<CommonBook?> parse(String filePath) async {
    final format = getBookFormat(filePath);
    if(format == BookFormat.epub) {
      final bytes = File(filePath).readAsBytesSync();
      final epubBook = await compute(EpubReader.readBook, bytes);
      return CommonBook.fromEpub(epubBook, downloadUrl, filePath);
    }
    if (format == BookFormat.fb2) {
      var bytes = File(filePath).readAsBytesSync();
      if (filePath.contains('zip')) {
        try {
          attempts++;
          final archive = ZipDecoder().decodeBytes(bytes);
          bytes = archive.first.content as Uint8List;
        } on FormatException catch (e) {
          l.i('archive not ready');
          if (attempts <= 5) {
            await Future.delayed(const Duration(seconds: 1));
            return parse(filePath);
          }
          attempts = 0;
          return null;
        }
      }
      fb2Book = await compute(parseFB2, bytes);
      return CommonBook.fromFb2(fb2Book!, downloadUrl, filePath);
    }
  }
}
