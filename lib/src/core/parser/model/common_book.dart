import 'dart:typed_data';

import 'package:freader/src/core/parser/toc.dart';
import 'package:freader/src/core/utils/path.dart';

import '../fb2_parser/fb2_parser.dart';

class CommonBook {
  CommonBook.fromFb2(FB2Book fb2Book, this.downloadUrl, this.path)
      : title = fb2Book.bookTitle,
        language = fb2Book.language ?? '',
        published = fb2Book.publishDate ?? '',
        directory = getDirName(path),
        fileName = getFileName(path),
        format = 'fb2',
        fb2book = fb2Book,
        annotation = fb2Book.titleInfo.annotation,
        toc = TableOfContents.fromFB2(fb2Book),
        cover = fb2Book.cover.bytes,
        filePath = path;
  // CommonBook.fromEpub(this.epubBook, this.downloadUrl, this.path)
  //     : title = epubBook!.Title ?? '',
  //       language = epubBook.Schema?.Package?.Metadata?.Languages?.firstOrNull ?? '',
  //       published = epubBook.Schema?.Package?.Metadata?.Dates?.firstOrNull?.Date ?? '',
  //       directory = getDirName(path),
  //       fileName = getFileName(path),
  //       format = 'epub',
  //       filePath = path,
  //       annotation = epubBook.Schema?.Package?.Metadata?.Description ?? 'No annotation',
  //       cover = epubBook.CoverImage?.getBytes() ?? Uint8List(0);
  String title;
  String path;
  String? downloadUrl;
  String format;
  String language;
  String published;
  String directory;
  String fileName;
  String filePath;
  Uint8List cover;
  String annotation;
  FB2Book? fb2book;
  // EpubBook? epubBook;
  int wordCount = 0;
  TableOfContents? toc;
}
