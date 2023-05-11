import 'package:drift/drift.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:freader/src/core/data/database/database.dart';
import 'package:freader/src/core/data/database/tables.dart';
import 'package:freader/src/core/theme/color_schemes.dart';

part 'settings_dao.g.dart';

class SettingsModel {
  SettingsModel(this.pageScrollStyle, ThemeEntry themeEntry) {
    materialTheme = themeFromDB(themeEntry);
  }
  late final ThemeData materialTheme;
  PageScrollStyle pageScrollStyle;
}

@DriftAccessor(tables: [SettingsEntries])
class SettingsDao extends DatabaseAccessor<AppDatabase> with _$SettingsDaoMixin {
  SettingsDao(super.db);
  late final  SettingsModel initialSettings;

  Future<void> init() async {
    final query = select(settingsEntries).join([
      leftOuterJoin(themeEntries, themeEntries.id.equalsExp(settingsEntries.tid)),
    ]);
    final typed = await query.getSingle();
    initialSettings = SettingsModel(
        typed.readTable(settingsEntries).pageScrollStyle, typed.readTable(themeEntries));
  }

  Stream<SettingsModel> watch() {
    final query = select(settingsEntries).join([
      leftOuterJoin(themeEntries, themeEntries.id.equalsExp(settingsEntries.tid)),
    ]);
    return query.watchSingle().map(
          (d) => SettingsModel(
              d.readTable(settingsEntries).pageScrollStyle, d.readTable(themeEntries)),
        );
  }

  Stream<List<ThemeEntry>> watchThemes() {
    final query = select(themeEntries);
    return query.watch();
  }

  Future<void> setTheme(int themeId) async {
    await (update(settingsEntries)..where((tbl) => tbl.id.equals(1))).write(
      SettingsEntriesCompanion(
        tid: Value(themeId),
      ),
    );
  }
}
