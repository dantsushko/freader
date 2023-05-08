import 'dart:io';

import 'package:drift/drift.dart';
import 'package:freader/src/core/data/database/database.dart';
import 'package:freader/src/core/data/database/tables.dart';
import 'package:freader/src/core/parser/parser.dart';
import 'package:freader/src/core/utils/path.dart';

part 'book_dao.g.dart';

class BookWithMetadata {
  BookWithMetadata(this.book, this.metadata);
  final BookEntry book;
  final MetadataEntry metadata;
  @override
  String toString() {
    return 'BookWithMetadata(book: ${book.filename}, dir: ${book.directory} metadata: ${metadata.language})';
  }
}

@DriftAccessor(tables: [BookEntries, MetadataEntries])
class BookDao extends DatabaseAccessor<AppDatabase> with _$BookDaoMixin {
  BookDao(super.db);

  Future<void> importBook(CommonBook book) async {
    final newBook = BookEntriesCompanion.insert(
      timestamp: 0,
      filename: book.fileName,
      filepath: book.filePath,
      cover: Value(book.cover),
      filesize: File(book.filePath).lengthSync(),
      directory: Value(book.directory),
      format: book.format,
    );

    final bid = await into(bookEntries).insert(newBook);
    final metaData = MetadataEntriesCompanion.insert(
        bid: bid,
        title: book.title,
        language: book.language,
        published: book.published,
        annotation: book.annotation,
        keywords: '',
        source: '',
        pagecount: 100,
        wordcount: 100,
        color: 25,
        coverhash: 'coverhash',
        specific: 'specific',
        coverurl: 'coverurl',
        downloadurl: 'downloadurl',
        timestamp: 0);
    await into(metadataEntries).insert(metaData);
  }

  Future<void> deleteBook(String fileName) async {
    await (delete(bookEntries)..where((tbl) => tbl.filename.equals(fileName))).go();
  }

  Stream<List<BookWithMetadata>> watchAll({String? directory}) {
    final query = select(bookEntries).join([
      leftOuterJoin(metadataEntries, metadataEntries.bid.equalsExp(bookEntries.bid)),
    ]);
    if (directory != null) {
      query.where(bookEntries.directory.equals(directory));
    }
    return query.watch().map((books) => books
        .map((e) => BookWithMetadata(e.readTable(bookEntries), e.readTable(metadataEntries)))
        .toList());
  }
}
