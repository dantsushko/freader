import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:freader/src/core/data/database/daos/settings_dao.dart';
import 'package:freader/src/core/data/database/database.dart';
import 'package:freader/src/core/data/database/tables.dart';
import 'package:freader/src/feature/initialization/widget/dependencies_scope.dart';
import 'package:settings_ui/settings_ui.dart';

class BookSettingsScren extends StatefulWidget {
  const BookSettingsScren({super.key});

  @override
  State<BookSettingsScren> createState() => _BookSettingsScrenState();
}

class _BookSettingsScrenState extends State<BookSettingsScren> {
  late final SettingsDao _settingsDao;
  @override
  void initState() {
    _settingsDao = DependenciesScope.of(context).dependencies.database.settingsDao;
    super.initState();
  }

  @override
  Widget build(BuildContext context) => PlatformScaffold(
        appBar: PlatformAppBar(
          title: const Text('Настройки'),
          leading: InkWell(
            child: const Icon(
              Icons.close,
              size: 20,
            ),
            onTap: () => Navigator.of(context).pop(),
          ),
        ),
        body: StreamBuilder<SettingsModel>(
          stream: _settingsDao.watch(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(child: Text(snapshot.error.toString()));
            }
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            final settings = snapshot.data!;
            return SettingsList(
              platform: DevicePlatform.iOS,
              shrinkWrap: true,
              lightTheme: SettingsThemeData(
                settingsListBackground: Theme.of(context).scaffoldBackgroundColor,
                settingsSectionBackground: Theme.of(context).cardColor,
                trailingTextColor: Theme.of(context).textTheme.bodyLarge!.color,
                dividerColor: Theme.of(context).dividerColor,
                settingsTileTextColor: Theme.of(context).textTheme.bodyLarge!.color,
              ),
              sections: [
                SettingsSection(
                  title: const Text('ТЕМЫ'),
                  tiles: [
                    SettingsTile(
                      title: const Text(''),
                      leading: StreamBuilder<List<ThemeEntry>>(
                        stream: _settingsDao.watchThemes(),
                        builder: (context, snapshot) {
                          if (snapshot.hasError) {
                            return Center(child: Text(snapshot.error.toString()));
                          }
                          if (!snapshot.hasData) {
                            return const Center(child: CircularProgressIndicator());
                          }
                          return Padding(
                            padding: const EdgeInsets.all(8),
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: snapshot.data!
                                    .map(
                                      (e) => InkWell(
                                        onTap: () => DependenciesScope.of(context)
                                            .dependencies
                                            .database
                                            .settingsDao
                                            .setTheme(e.id),
                                        child: ThemeCircle(
                                          theme: e,
                                        ),
                                      ),
                                    )
                                    .toList(),
                              ),
                            ),
                          );
                        },
                      ),
                    )
                  ],
                ),
                SettingsSection(
                  title: const Text('ПОЛЯ СТРАНИЦЫ'),
                  tiles: [
                    SettingsTile(
                        title: const Text('Слева/Справа'),
                        value: PlusMinusButton<int>(
                          value: settings.pageHorizontalPadding,
                          unit: 'px',
                          minValue: 5,
                          maxValue: 75,
                          onChanged: (value) => _settingsDao.setPageHorizontalPadding(value),
                        )),
                    SettingsTile(
                        title: const Text('Верх'),
                        value: PlusMinusButton<int>(
                          value: settings.pageTopPadding,
                          unit: 'px',
                          minValue: 0,
                          maxValue: 75,
                          onChanged: (value) => _settingsDao.setPageTopPadding(value),
                        )),
                    SettingsTile(
                        title: const Text('Низ'),
                        value: PlusMinusButton<int>(
                          value: settings.pageBottomPadding,
                          unit: 'px',
                          minValue: 0,
                          maxValue: 75,
                          onChanged: (value) => _settingsDao.setPageBottomPadding(value),
                        ))
                  ],
                ),
                SettingsSection(
                  tiles: [
                    SettingsTile(
                        title: const Text('Размер шрифта'),
                        value: PlusMinusButton<int>(
                          value: settings.fontSize,
                          unit: 'pt',
                          minValue: 8,
                          maxValue: 32,
                          onChanged: (value) => _settingsDao.setFontSize(value),
                        ))
                  ],
                ),
                SettingsSection(
                  title: const Text('РЕЖИМ СМЕНЫ СТРАНИЦ'),
                  tiles: PageScrollStyle.values
                      .map(
                        (e) => SettingsTile(
                          onPressed: (ctx) => _settingsDao.setPageScrollStyle(e),
                          trailing: settings.pageScrollStyle == e
                              ? Icon(
                                  Icons.check,
                                  color: Theme.of(context).primaryColor,
                                )
                              : null,
                          title: Text(e.label),
                        ),
                      )
                      .toList(),
                ),
              ],
            );
          },
        ),
      );
}

class ThemeCircle extends StatelessWidget {
  const ThemeCircle({required this.theme, super.key});
  final ThemeEntry theme;
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: Color(theme.backgroundColor),
            shape: BoxShape.circle,
            border: Border.all(
              color: Color(theme.accentColor),
              width: 2,
            ),
          ),
          child: Center(
            child: Text(
              theme.name,
              style: TextStyle(color: Color(theme.textColor)),
            ),
          ),
        ),
      );
}

class PlusMinusButton<T> extends StatelessWidget {
  const PlusMinusButton({
    required this.unit,
    required this.value,
    required this.minValue,
    required this.maxValue,
    required this.onChanged,
    super.key,
  });
  final String unit;
  final int value;
  final int minValue;
  final int maxValue;
  final void Function(T value) onChanged;
  @override
  Widget build(BuildContext context) => Row(
        children: [
          Text('$value$unit'),
          const SizedBox(
            width: 10,
          ),
          SizedBox(
            height: 25,
            child: ToggleButtons(
              disabledBorderColor: Theme.of(context).textTheme.labelLarge!.color,
              selectedBorderColor: Theme.of(context).textTheme.labelLarge!.color,
              disabledColor: Theme.of(context).textTheme.labelLarge!.color,
              borderColor: Theme.of(context).textTheme.labelLarge!.color,
              borderRadius: const BorderRadius.all(Radius.circular(4)),
              onPressed: (index) {
                int newValue;
                if (index == 0) {
                  newValue = value - 1;
                } else {
                  newValue = value + 1;
                }
                if (value < minValue) {
                  newValue = minValue;
                }
                if (value > maxValue) {
                  newValue = maxValue;
                }
                onChanged(newValue as T);
              },
              isSelected: const [false, false],
              children: [
                Icon(
                  Icons.remove,
                  color: Theme.of(context).textTheme.labelLarge!.color,
                ),
                Icon(
                  Icons.add,
                  color: Theme.of(context).textTheme.labelLarge!.color,
                )
              ],
            ),
          ),
        ],
      );
}
