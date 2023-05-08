import 'dart:io';
import 'package:collection/collection.dart';
import 'package:freader/src/feature/catalogues/opds/util.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

Future<String> getDir([List<String> pathSegments = const []]) async {
  final absoulte = Platform.isIOS
      ? (await getApplicationDocumentsDirectory()).absolute
      : (await getExternalStorageDirectory())!.absolute;
  final dir = Directory(path.joinAll([absoulte.path, ...pathSegments]));
  if (!dir.existsSync()) {
    dir.createSync(recursive: true);
  }
  return dir.absolute.path;
}

String getFileName(String filePath) => path.basename(filePath);
String getDirName(String entityPath) => FileSystemEntity.typeSync(entityPath) == FileSystemEntityType.file ? path.basename(path.dirname(entityPath)) : path.basename(entityPath);
String getFileExtension(String filePath) => path.extension(filePath.replaceAll('.zip', ''));

BookFormat getBookFormat(String filePath) =>
    BookFormat.values.firstWhereOrNull((e) => e.name == getFileExtension(filePath).replaceAll('.', '')) ?? BookFormat.unsupported;


bool isBook(String filePath) => getBookFormat(filePath) != BookFormat.unsupported;

