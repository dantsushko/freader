import 'package:auto_route/auto_route.dart';
import 'package:freader/src/core/router/router.gr.dart';

@AutoRouterConfig(replaceInRouteName: 'Screen,Route')
class AppRouter extends $AppRouter {
  AppRouter();
  @override
  RouteType get defaultRouteType => RouteType.custom(
        reverseDurationInMilliseconds: 0,
        
      );
  @override
  List<AutoRoute> get routes => [
        AutoRoute(
          page: BaseRoute.page,
          path: '/',
          
          children: [
            // RedirectRoute(path: '', redirectTo: 'reading'),
            AutoRoute(page: ReadingRoute.page, path: 'reading'),
            AutoRoute(
              page: LibraryTab.page,
              path: 'library',
              children: [
                AutoRoute(page: LibraryRoute.page, path: ''),
                AutoRoute(page: DirectoryContentRoute.page, path: 'directory'),
                AutoRoute(
                  page: BookReadingRoute.page,
                  path: 'book_reading',
                ),
              ],
            ),
            AutoRoute(
              page: CataloguesTab.page,
              path: 'catalogues',
              children: [
                AutoRoute(page: CataloguesRoute.page, path: ''),
                AutoRoute(page: OpdsRoute.page, path: 'opds')
              ],
            ),
            AutoRoute(
              page: SettingsTab.page,
              path: 'settings',
              children: [
                AutoRoute(page: SettingsRoute.page, path: ''),
                AutoRoute(page: IapRoute.page, path: 'iap'),
                AutoRoute(
                  page: ThemeRoute.page,
                  path: 'themes',
                )
              ],
            ),
          ],
        ),
      ];
}

@RoutePage(name: 'SettingsTab')
class SettingsTabPage extends AutoRouter {
  const SettingsTabPage({super.key});
}

@RoutePage(name: 'CataloguesTab')
class CataloguesTabPage extends AutoRouter {
  const CataloguesTabPage({super.key});
}

@RoutePage(name: 'LibraryTab')
class LibraryTabPage extends AutoRouter {
  const LibraryTabPage({super.key});
}
