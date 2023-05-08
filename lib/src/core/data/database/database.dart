import 'package:drift/drift.dart';
import 'connection/connection.dart' as impl;
import 'daos/book_dao.dart';
import 'daos/metadata_dao.dart';
import 'daos/opds_dao.dart';
import 'tables.dart';

part 'database.g.dart';

@DriftDatabase(tables: [OpdsCatalogueEntries, BookEntries, MetadataEntries, FileEntries], daos: [OpdsDao, BookDao, MetadataDao])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(impl.connect());

  AppDatabase.forTesting(DatabaseConnection super.connection);

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        // onUpgrade: (m, from, to) async {
        //   for (var step = from + 1; step <= to; step++) {
        //     switch (step) {
        //       case 2:
        //         // add table
        //         await m.createTable(downloadEntries);
        //         break;
        //     }
        //   }
        // },
        beforeOpen: (details) async {
          await customStatement('PRAGMA foreign_keys = ON');
          if (details.wasCreated) {
            await batch((b) {
              b.insertAll(
                opdsCatalogueEntries,
                [
                  OpdsCatalogueEntriesCompanion.insert(
                      url: 'https://flibusta.is/opds', name: 'Flibusta',),
                  OpdsCatalogueEntriesCompanion.insert(
                      url: 'https://theanarchistlibrary.org/opds', name: 'The Anarchist Library',),
                  OpdsCatalogueEntriesCompanion.insert(
                      url: 'https://coollib.com/opds', name: 'CoolLib',),
                ],
              );
            });
          }
          await impl.validateDatabaseSchema(this);
        },
      );
}
