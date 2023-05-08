import 'dart:convert';
import 'dart:io';


import 'package:freader/src/core/parser/fb2_parser/fb2_parser.dart';

void main(List<String> args) async{
  final file = File('test.fb2').readAsBytesSync();
  final book = FB2Book(file, 'test.fb2');
  await book.parse();
  print(book.description.coverPageId);
   print(base64Decode(book.cover!.bytes));
  print(book.images.map((e) => e.name).toList());
  File('base64.txt').writeAsStringSync(book.images.first.bytes);
}
