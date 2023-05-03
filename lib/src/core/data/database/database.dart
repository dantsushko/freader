import 'package:drift/drift.dart';
import 'connection/connection.dart' as impl;
import 'daos/opds_dao.dart';
import 'tables.dart';

part 'database.g.dart';

@DriftDatabase(tables: [OpdsCatalogueEntries], daos: [OpdsDao])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(impl.connect());

  AppDatabase.forTesting(DatabaseConnection super.connection);

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        // onUpgrade: (m, from, to) async {
        //   for (var step = from + 1; step <= to; step++) {
        //     switch (step) {
        //       case 2:
        //         // The todoEntries.dueDate column was added in version 2.
        //         await m.addColumn(todoEntries, todoEntries.dueDate);
        //         break;
        //       case 3:
        //         // New triggers were added in version 3:
        //         await m.create(todosDelete);
        //         await m.create(todosUpdate);

        //         // Also, the `REFERENCES` constraint was added to
        //         // [TodoEntries.category]. Run a table migration to rebuild all
        //         // column constraints without loosing data.
        //         await m.alterTable(TableMigration(todoEntries));
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
                      url: 'http://theanatchistlibrary.org/opds', name: 'The Anarchist Library',),
                  OpdsCatalogueEntriesCompanion.insert(
                      url: 'http://coollib.com/opds', name: 'CoolLib',),
                ],
              );
            });
          }
          await impl.validateDatabaseSchema(this);
        },
      );
}
