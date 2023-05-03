import 'package:drift/drift.dart';
mixin AutoIncrementingPrimaryKey on Table {
  IntColumn get id => integer().autoIncrement()();
}

@DataClassName('OpdsCatalogueEntry')
class OpdsCatalogueEntries extends Table with AutoIncrementingPrimaryKey {
  TextColumn get url => text()();
  TextColumn get name => text()();
}
