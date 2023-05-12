import 'package:auto_route/auto_route.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:freader/src/core/localization/app_localization.dart';
import 'package:freader/src/feature/initialization/widget/dependencies_scope.dart';

class NavObserver extends AutoRouterObserver {
  @override
  void didPush(Route route, Route? previousRoute) {
    print('Push ${route.settings.name}');

    super.didPush(route, previousRoute);
  }

  @override
  void didPop(Route route, Route? previousRoute) {
    print('Pop ${route.settings.name}');

    super.didPop(route, previousRoute);
  }

  @override
  void didReplace({Route? newRoute, Route? oldRoute}) {
    print('Replace ${newRoute!.settings.name}');
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
  }

  @override
  void didRemove(Route route, Route? previousRoute) {
    print('Remove ${route.settings.name}');
    super.didRemove(route, previousRoute);
  }

  @override
  void didChangeTabRoute(TabPageRoute route, TabPageRoute previousRoute) {
    print('Tab route: ${route.name}');
  }
}

/// A widget which is responsible for providing the app context.
class AppContext extends StatelessWidget {
  const AppContext({super.key});
  @override
  Widget build(BuildContext context) {
    final router = DependenciesScope.dependenciesOf(context).router;
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
                    routerConfig: router.config(
                      navigatorObservers: () => [NavObserver()],
                    ),
                    debugShowCheckedModeBanner: false,
                    supportedLocales: AppLocalization.supportedLocales,
                    localizationsDelegates: AppLocalization.localizationsDelegates,
                    locale: const Locale('ru'),
                  ),
                );
              },
            ),);
  }
}
