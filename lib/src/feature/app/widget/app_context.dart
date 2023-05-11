import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:freader/src/core/data/database/daos/settings_dao.dart';
import 'package:freader/src/core/data/database/database.dart';
import 'package:freader/src/core/localization/app_localization.dart';
import 'package:freader/src/core/theme/color_schemes.dart';
import 'package:freader/src/feature/initialization/widget/dependencies_scope.dart';

/// A widget which is responsible for providing the app context.
class AppContext extends StatelessWidget {
  const AppContext({super.key});
  @override
  Widget build(BuildContext context) {
    final router = DependenciesScope.dependenciesOf(context).router;
    final database = DependenciesScope.dependenciesOf(context).database;

    return StreamBuilder<SettingsModel>(
        stream: database.settingsDao.watch(),
        builder: (context, snapshot) => PlatformProvider(
              settings: PlatformSettingsData(
                iosUsesMaterialWidgets: true,
                iosUseZeroPaddingForAppbarPlatformIcon: true,
              ),
              builder: (context) {
                final material = snapshot.data?.materialTheme ??
                    database.settingsDao.initialSettings.materialTheme;
                final cup = MaterialBasedCupertinoThemeData(materialTheme: material).copyWith(
                  barBackgroundColor: material.colorScheme.background.withAlpha(230),
                  scaffoldBackgroundColor: material.colorScheme.background,
                  textTheme: CupertinoTextThemeData(
                    primaryColor: material.textTheme.bodyLarge!.color!,
                    navTitleTextStyle: TextStyle(color: material.textTheme.bodyLarge!.color),
                    navActionTextStyle: TextStyle(color: material.primaryColor),
                    actionTextStyle: TextStyle(color: material.primaryColor),
                    textStyle: TextStyle(
                      color: material.textTheme.bodyLarge!.color,
                    ),
                  ),
                );
                return PlatformTheme(
                  materialLightTheme: material,
                  materialDarkTheme: material,
                  cupertinoLightTheme: cup,
                  cupertinoDarkTheme: cup,
                  builder: (ctx) => PlatformApp.router(
                    routerConfig: router.config(),
                    debugShowCheckedModeBanner: false,
                    supportedLocales: AppLocalization.supportedLocales,
                    localizationsDelegates: AppLocalization.localizationsDelegates,
                    locale: const Locale('ru'),
                  ),
                );
              },
            ));
  }
}
