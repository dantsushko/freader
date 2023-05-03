import 'package:auto_route/auto_route.dart';
import 'package:freader/src/core/router/router.gr.dart';

@AutoRouterConfig(replaceInRouteName: 'Screen,Route')
class AppRouter extends $AppRouter {
  AppRouter();
  @override
  RouteType get defaultRouteType => const RouteType.adaptive();
  @override
  List<AutoRoute> get routes => [
        AutoRoute(
          page: BaseRoute.page,
          initial: true,
          path: '/',
          children: [
            AutoRoute(page: ReadingRoute.page, path: 'reading'),
            AutoRoute(page: LibraryRoute.page, path: 'library'),
            AutoRoute(page: CataloguesRoute.page, path: 'catalogues'),
            AutoRoute(
              page: SettingsTab.page,
              path: 'settings',
              children: [
                AutoRoute(page: SettingsRoute.page, path: ''),
                AutoRoute(page: IapRoute.page, path: 'iap')],
            ),
          ],
        ),
      ];
}


@RoutePage(name: 'SettingsTab')
class SettingsTabPage extends AutoRouter {
  const SettingsTabPage({super.key});
}
