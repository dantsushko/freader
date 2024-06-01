
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:freader/src/core/localization/app_localization.dart';
import 'package:freader/src/core/router/go_router.dart';

import 'package:freader/src/feature/initialization/widget/dependencies_scope.dart';



/// A widget which is responsible for providing the app context.
class AppContext extends StatelessWidget {
  const AppContext({super.key});
  @override
  Widget build(BuildContext context) {
    final database = DependenciesScope.dependenciesOf(context).database;

    return StreamBuilder<ThemeData>(
      initialData: database.settingsDao.initialSettings.materialTheme,
      stream: database.settingsDao.watchTheme(),
      builder: (context, snapshot) => PlatformProvider(
        settings: PlatformSettingsData(
          iosUsesMaterialWidgets: true,
          iosUseZeroPaddingForAppbarPlatformIcon: true,
        ),
        builder: (context) {
          final material = snapshot.data!;
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
              material: (context, platform) => MaterialAppRouterData(
                theme: material,
                darkTheme: material,
                themeMode: ThemeMode.system,
              ),
              
              routerConfig: goRouter,
              debugShowCheckedModeBanner: false,
                supportedLocales: [
                Locale('en'), // English
                Locale('es'), // Spanish
              ],
              localizationsDelegates: const [
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              locale: const Locale('ru'),
            ),
          );
        },
      ),
    );
  }
}
