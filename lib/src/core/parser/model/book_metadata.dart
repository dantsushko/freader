import 'dart:typed_data';

import 'package:freader/src/core/parser/model/author.dart';
import 'package:freader/src/feature/catalogues/opds/model/opds_entry.model.dart';

import '../fb2_parser/model/fb2_metadata.dart';

class BookMetadata {
  BookMetadata.fromFb2Metadata(Fb2Metadata metadata)
      : title = metadata.titleInfo.bookTitle,
        format = 'fb2',
        authors = metadata.authors.map(Author.fromFB2Author).toList(),
        annotation = metadata.titleInfo.annotation,
        cover = metadata.cover ?? Uint8List(0);
  Uint8List cover;
  final String title;
  final String annotation;
  final String format;
  List<Author> authors = [];
}
