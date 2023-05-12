import 'package:drift/drift.dart';
import 'package:freader/src/core/data/database/database.dart';
import 'package:freader/src/core/data/database/tables.dart';

part 'metadata_dao.g.dart';

@DriftAccessor(tables: [MetadataEntries])
class MetadataDao extends DatabaseAccessor<AppDatabase> with _$MetadataDaoMixin {
  MetadataDao(super.db);
}
