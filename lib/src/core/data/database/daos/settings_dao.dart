import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import 'package:freader/src/core/data/database/database.dart';
import 'package:freader/src/core/data/database/tables.dart';
import 'package:freader/src/core/theme/color_schemes.dart';

part 'settings_dao.g.dart';

class SettingsModel {
  SettingsModel(SettingsEntry settingsEntry, ThemeEntry themeEntry) {
    materialTheme = themeFromDB(themeEntry);
    pageScrollStyle = settingsEntry.pageScrollStyle;
    fontSize = settingsEntry.fontSize;
    pageHorizontalPadding = settingsEntry.pageHorizontalPadding;
    pageTopPadding = settingsEntry.pageTopPadding;
    pageBottomPadding = settingsEntry.pageBottomPadding;

  }
  late final ThemeData materialTheme;
  late final PageScrollStyle pageScrollStyle;
  late final int fontSize;
  late final int pageHorizontalPadding;
  late final int pageTopPadding;
  late final int pageBottomPadding;
}





@DriftAccessor(tables: [SettingsEntries])
class SettingsDao extends DatabaseAccessor<AppDatabase> with _$SettingsDaoMixin {
  SettingsDao(super.db);
  late final SettingsModel initialSettings;

  Future<void> init() async {
    final query = select(settingsEntries).join([
      leftOuterJoin(themeEntries, themeEntries.id.equalsExp(settingsEntries.tid)),
    ]);
    final typed = await query.getSingle();
    initialSettings =
        SettingsModel(typed.readTable(settingsEntries), typed.readTable(themeEntries));
  }

  Stream<SettingsModel> watch() {
    final query = select(settingsEntries).join([
      leftOuterJoin(themeEntries, themeEntries.id.equalsExp(settingsEntries.tid)),
    ]);
    return query.watchSingle().map(
          (d) => SettingsModel(d.readTable(settingsEntries), d.readTable(themeEntries)),
        );
  }

  Stream<ThemeData> watchTheme() {
    final query = select(settingsEntries).join([
      leftOuterJoin(themeEntries, themeEntries.id.equalsExp(settingsEntries.tid)),
    ]);
    return query
        .watchSingle()
        .distinct((s1, s2) => s1.readTable(themeEntries).id == s2.readTable(themeEntries).id)
        .map(
          (d) =>
              SettingsModel(d.readTable(settingsEntries), d.readTable(themeEntries)).materialTheme,
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

  Future<void> setPageScrollStyle(PageScrollStyle style) async {
    await (update(settingsEntries)..where((tbl) => tbl.id.equals(1))).write(
      SettingsEntriesCompanion(
        pageScrollStyle: Value(style),
      ),
    );
  }

  Future<void> setFontSize(int size) async {
    await (update(settingsEntries)..where((tbl) => tbl.id.equals(1))).write(
      SettingsEntriesCompanion(
        fontSize: Value(size),
      ),
    );
  }
  Future<void> setPageHorizontalPadding(int pageHorizontalPadding) async {
    await (update(settingsEntries)..where((tbl) => tbl.id.equals(1))).write(
      SettingsEntriesCompanion(
        pageHorizontalPadding: Value(pageHorizontalPadding),
      ),
    );
  }
    Future<void> setPageTopPadding(int pageTopPadding) async {
    await (update(settingsEntries)..where((tbl) => tbl.id.equals(1))).write(
      SettingsEntriesCompanion(
        pageTopPadding: Value(pageTopPadding),
      ),
    );
  }

  Future<void> setPageBottomPadding(int pageBottomPadding) async {
    await (update(settingsEntries)..where((tbl) => tbl.id.equals(1))).write(
      SettingsEntriesCompanion(
        pageBottomPadding: Value(pageBottomPadding),
      ),
    );
  }
}
