import 'package:auto_route/auto_route.dart';
import 'package:freader/src/core/router/router.gr.dart';

@AutoRouterConfig(replaceInRouteName: 'Screen,Route')
class AppRouter extends $AppRouter {
  AppRouter();
  @override
  List<AutoRoute> get routes => [
        AutoRoute(
          page: SampleRoute.page,
          path: '/',
          children: [
            AutoRoute(page: ReadingRoute.page, path: 'reading'),
            AutoRoute(page: LibraryRoute.page, path: 'library'),
            AutoRoute(page: CataloguesRoute.page, path: 'catalogues'),
            AutoRoute(page: SettingsRoute.page, path: 'settings'),
          ],
        ),
      ];
}
