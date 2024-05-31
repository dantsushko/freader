import 'package:drift/drift.dart';
import 'package:freader/src/core/data/database/database.dart';
import 'package:freader/src/core/data/database/tables.dart';

part 'cursor_dao.g.dart';

@DriftAccessor(tables: [CursorEntries])
class CursorDao extends DatabaseAccessor<AppDatabase> with _$CursorDaoMixin {
  CursorDao(super.db);

  Future<Cursor?> getCursor(int bid) async {
    final query = select(cursorEntries)..where((tbl) => tbl.bid.equals(bid));
    return query.getSingleOrNull();
  }

  Future<void> updateCursor({required int bid, int? page, double? offset}) async {
    final query = select(cursorEntries)..where((tbl) => tbl.bid.equals(bid));
    final cursor = await query.getSingleOrNull();
    if (cursor == null) {
      await into(cursorEntries).insert(
        CursorEntriesCompanion.insert(
          bid: bid,
          page: page ?? cursor?.page ?? 0,
          offset: offset ?? cursor?.offset ?? 0,
        ),
      );
    } else {
      await (update(cursorEntries)..where((tbl) => tbl.bid.equals(bid))).write(
        CursorEntriesCompanion(
          page: Value(page ?? cursor.page),
          offset: Value(offset ?? cursor.offset),
        ),
      );
    }

    print('Cursor updated: bid: $bid, page: $page, offset: $offset');
  }
}
