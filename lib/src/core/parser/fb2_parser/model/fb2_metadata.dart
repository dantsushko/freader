
import 'dart:typed_data';

import 'package:freader/src/core/parser/fb2_parser/model/author.dart';
import 'package:freader/src/core/parser/fb2_parser/model/title_info.dart';

class Fb2Metadata{
  final List<FB2Author> authors = [];
  final FB2TitleInfo titleInfo;
  final Uint8List? cover;

  Fb2Metadata(this.titleInfo, {this.cover}){
    authors.addAll(titleInfo.authors);
  }

  @override
  String toString() => 'Fb2Metadata{authors: $authors, titleInfo: $titleInfo}';
}