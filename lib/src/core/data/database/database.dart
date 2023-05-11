import 'package:drift/drift.dart';
import 'package:freader/src/core/data/database/daos/settings_dao.dart';
import 'connection/connection.dart' as impl;
import 'daos/book_dao.dart';
import 'daos/metadata_dao.dart';
import 'daos/opds_dao.dart';
import 'tables.dart';

part 'database.g.dart';

@DriftDatabase(tables: [
  OpdsCatalogueEntries,
  BookEntries,
  MetadataEntries,
  FileEntries,
  ThemeEntries,
  SettingsEntries
], daos: [
  OpdsDao,
  BookDao,
  MetadataDao,
  SettingsDao,
])
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
              b
                ..insertAll(themeEntries, [
                  ThemeEntriesCompanion.insert(
                    name: 'Сумрак',
                    accentColor: 0xFFFFC66D,
                    textColor: 0xFF82B8E0,
                    backgroundColor: 0xFF26292C,
                    separatorColor: 0xFF565669,
                    greyColor: 0xFFCDCDCD,
                    controlColor: 0xFF2C3E50,
                    highlightColor: 0xFF7299F9,
                    secondaryTextColor: 0xFF6F9BBC,
                  ),
                  ThemeEntriesCompanion.insert(
                    name: 'Сепия',
                    accentColor: 0xFFF2473F,
                    textColor: 0xFF3D1C07,
                    backgroundColor: 0xFFF5EFDC,
                    separatorColor: 0xFFECD6C5,
                    greyColor: 0xFFD6D5D4,
                    controlColor: 0xFFFFF5E8,
                    highlightColor: 0xFF7299F9,
                    secondaryTextColor: 0xFF614631,
                  ),
                ])
                ..insertAll(
                  opdsCatalogueEntries,
                  [
                    OpdsCatalogueEntriesCompanion.insert(
                      url: 'https://flibusta.is/opds',
                      name: 'Flibusta',
                    ),
                    OpdsCatalogueEntriesCompanion.insert(
                      url: 'https://theanarchistlibrary.org/opds',
                      name: 'The Anarchist Library',
                    ),
                    OpdsCatalogueEntriesCompanion.insert(
                      url: 'https://coollib.com/opds',
                      name: 'CoolLib',
                    ),
                  ],
                )
                ..insert(settingsEntries, const SettingsEntriesCompanion(
                  tid: Value(1),
                  pageScrollStyle: Value(PageScrollStyle.scroll),
                ));
            });
          }
          await impl.validateDatabaseSchema(this);
        },
      );
}
