import 'package:drift/drift.dart';
import 'package:freader/src/core/data/database/database.dart';
import 'package:freader/src/core/data/database/tables.dart';

part 'opds_dao.g.dart';

@DriftAccessor(tables: [OpdsCatalogueEntries])
class OpdsDao extends DatabaseAccessor<AppDatabase> with _$OpdsDaoMixin {
  OpdsDao(super.db);

  Stream<List<OpdsCatalogueEntry>> watchAll() {
    final query = select(opdsCatalogueEntries);
    return query.watch();
  }

  Future<void> addNewOpds(String url, String name) async {
    final newOpds = OpdsCatalogueEntriesCompanion.insert(
      url: url,
      name: name,
    );
    await into(opdsCatalogueEntries).insert(newOpds);
  }

  Future<void> deleteOpds(int id) async {
    await (delete(opdsCatalogueEntries)..where((tbl) => tbl.id.equals(id))).go();
  }
}
