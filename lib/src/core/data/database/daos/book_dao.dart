import 'dart:io';

import 'package:drift/drift.dart';
import 'package:freader/src/core/data/database/database.dart';
import 'package:freader/src/core/data/database/tables.dart';
import 'package:freader/src/core/parser/parser.dart';
import 'package:freader/src/core/utils/dominant_color.dart';

part 'book_dao.g.dart';

class BookWithMetadata {
  BookWithMetadata(this.book, this.metadata);
  final BookEntry book;
  final MetadataEntry metadata;
  @override
  String toString() =>
      'BookWithMetadata(book: ${book.filename}, dir: ${book.directory} metadata: ${metadata.language})';
}

@DriftAccessor(tables: [BookEntries, MetadataEntries])
class BookDao extends DatabaseAccessor<AppDatabase> with _$BookDaoMixin {
  BookDao(super.db);

  Future<void> importBook(CommonBook book) async {
    final dominantColors = DominantColor.get(book.cover);
    final newBook = BookEntriesCompanion.insert(
      timestamp: 0,
      filename: book.fileName,
      filepath: book.filePath,
      cover: Value(book.cover),
      filesize: File(book.filePath).lengthSync(),
      directory: Value(book.directory),
      format: book.format,
      coverDominantColor1: dominantColors.first.value,
      coverDominantColor2: dominantColors.last.value,
      coverFontColor: DominantColor.getReverseWhiteOrBlack(dominantColors.first).value,
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
      timestamp: 0,
    );
    await into(metadataEntries).insert(metaData);
  }

  Future<void> deleteBook(String fileName) async {
    await (delete(bookEntries)..where((tbl) => tbl.filename.equals(fileName))).go();
  }

  Future<BookWithMetadata> getBook(int id) async {
    final query = select(bookEntries).join([
      leftOuterJoin(metadataEntries, metadataEntries.bid.equalsExp(bookEntries.bid)),
    ])
      ..where(bookEntries.bid.equals(id));
    final book = await query.getSingle();
    return BookWithMetadata(book.readTable(bookEntries), book.readTable(metadataEntries));
  }

  Stream<BookWithMetadata?> watchByFileName(String fileName) {
    final query = select(bookEntries).join([
      leftOuterJoin(metadataEntries, metadataEntries.bid.equalsExp(bookEntries.bid)),
    ])
      ..where(bookEntries.filename.equals(fileName));
    return query.watchSingleOrNull().map(
          (book) => book == null
              ? null
              : BookWithMetadata(book.readTable(bookEntries), book.readTable(metadataEntries)),
        );
  }

  Future<bool> bookExists(String filePath) async {
    final query = select(bookEntries)..where((tbl) => tbl.filepath.equals(filePath));
    final book = await query.get();
    return book.isNotEmpty;
  }

  Stream<List<BookWithMetadata>> watchAll({String? directory, bool lastRead = false}) {
    final query = select(bookEntries).join([
      leftOuterJoin(metadataEntries, metadataEntries.bid.equalsExp(bookEntries.bid)),
    ]);
    if (directory != null) {
      query.where(bookEntries.directory.equals(directory));
    }
    if (lastRead) {
      query.orderBy([OrderingTerm.desc(metadataEntries.timestamp)]);
      query.where(metadataEntries.timestamp.isBiggerThanValue(0));
    }
    return query.watch().map(
          (books) => books
              .map((e) => BookWithMetadata(e.readTable(bookEntries), e.readTable(metadataEntries)))
              .toList(),
        );
  }

  Future<void> updateTimestamp(int bookId) async {
    await (update(metadataEntries)..where((tbl) => tbl.bid.equals(bookId)))
        .write(MetadataEntriesCompanion(
      timestamp: Value(DateTime.now().millisecondsSinceEpoch.toDouble()),
    ));
  }
}
