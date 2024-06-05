import 'package:drift/drift.dart';
import 'package:freader/src/feature/book/book_card/card.dart';

enum ThemeName { day, sepia, night, dusk, dawn, pastel, sand, tango }

enum PageScrollStyle {
  scroll('Прокрутка'),
  flip('Перелистывание'),
  shift('Сдвиг'),
  noAnimation('Без анимации');

  const PageScrollStyle(this.label);
  final String label;
}

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
  BlobColumn get cover => blob().nullable()();
  IntColumn get coverDominantColor1 => integer()();
  IntColumn get coverDominantColor2 => integer()();
  IntColumn get coverFontColor => integer()();
}

@DataClassName('FileEntry')
class FileEntries extends Table {
  TextColumn get path => text()();
  IntColumn get bid => integer().references(BookEntries, #bid, onDelete: KeyAction.cascade)();
  IntColumn get size => integer()();
  IntColumn get date => integer()();
  RealColumn get timestamp => real()();
}

@DataClassName('ThemeEntry')
class ThemeEntries extends Table with AutoIncrementingPrimaryKey {
  TextColumn get name => text().unique()();

  IntColumn get accentColor => integer()();
  IntColumn get textColor => integer()();
  IntColumn get backgroundColor => integer()();
  IntColumn get separatorColor => integer()();
  IntColumn get greyColor => integer()();
  IntColumn get controlColor => integer()();
  IntColumn get highlightColor => integer()();
  IntColumn get secondaryTextColor => integer()();
}

@DataClassName('SettingsEntry')
class SettingsEntries extends Table with AutoIncrementingPrimaryKey {
  IntColumn get tid => integer().references(ThemeEntries, #id, onDelete: KeyAction.cascade)();
  IntColumn get pageScrollStyle => intEnum<PageScrollStyle>()();
  IntColumn get fontSize => integer()();
  IntColumn get pageHorizontalPadding => integer()();
  IntColumn get pageTopPadding => integer()();
  IntColumn get pageBottomPadding => integer()();
  IntColumn get letterSpacing => integer()();
  IntColumn get bookCardType => intEnum<BookCardType>()();
  BoolColumn get softHyphen => boolean()();
}

@DataClassName('Cursor')
class CursorEntries extends Table {
  IntColumn get bid => integer().references(BookEntries, #bid, onDelete: KeyAction.cascade)();
  IntColumn get page => integer()();
  RealColumn get offset => real()();
}

@DataClassName('Author')
class AuthorEntries extends Table {
  IntColumn get aid => integer().autoIncrement()();
  TextColumn get nameKey => text()();
  TextColumn get name => text()();
  TextColumn get secondName => text().nullable()();
  TextColumn get lastName => text()();
}

@DataClassName('BookAuthor')
class BookAuthorEntries extends Table {
  IntColumn get bid => integer().references(BookEntries, #bid, onDelete: KeyAction.cascade)();
  IntColumn get aid => integer().references(AuthorEntries, #aid, onDelete: KeyAction.cascade)();
}
