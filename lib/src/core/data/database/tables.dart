import 'package:drift/drift.dart';

mixin AutoIncrementingPrimaryKey on Table {
  IntColumn get id => integer().autoIncrement()();
}

@DataClassName('OpdsCatalogueEntry')
class OpdsCatalogueEntries extends Table with AutoIncrementingPrimaryKey {
  TextColumn get url => text()();
  TextColumn get name => text()();
}

@DataClassName('MetadataEntry')
class MetadataEntries extends Table {
  IntColumn get bid => integer().references(BookEntries, #bid, onDelete: KeyAction.cascade)();
  TextColumn get title => text()();
  TextColumn get published => text()();
  TextColumn get language => text()();
  TextColumn get annotation => text()();
  TextColumn get keywords => text()();
  TextColumn get source => text()();
  IntColumn get pagecount => integer()();
  IntColumn get wordcount => integer()();
  IntColumn get color => integer()();
  TextColumn get coverhash => text()();
  TextColumn get specific => text()();
  TextColumn get coverurl => text()();
  TextColumn get downloadurl => text()();
  RealColumn get timestamp => real()();
}

@DataClassName('BookEntry')
class BookEntries extends Table {
  IntColumn get bid => integer().autoIncrement()();
  TextColumn get filename => text()();
  TextColumn get filepath => text()();
  IntColumn get filesize => integer()();
  TextColumn get format => text()();
  RealColumn get timestamp => real()();
  TextColumn get directory => text().nullable()();
  TextColumn get cover => text().nullable()();
}

@DataClassName('FileEntry')
class FileEntries extends Table {
  TextColumn get path => text()();
  IntColumn get bid => integer().references(BookEntries, #bid, onDelete: KeyAction.cascade)();
  IntColumn get size => integer()();
  IntColumn get date => integer()();
  RealColumn get timestamp => real()();
}
