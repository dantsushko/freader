import 'package:auto_route/auto_route.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:freader/src/core/file/watcher.dart';
import 'package:freader/src/core/router/router.gr.dart';
import 'package:freader/src/core/utils/downloader.dart';
import 'package:freader/src/feature/initialization/widget/dependencies_scope.dart';

class MyObersver extends AutoRouterObserver {
  MyObersver({required this.onRouteChanged});
  final Function(Route, bool) onRouteChanged;
  @override
  void didPush(Route route, Route? previousRoute) {
    onRouteChanged.call(route, false);
    super.didPush(route, previousRoute);
  }

  @override
  void didPop(Route route, Route? previousRoute) {
    onRouteChanged.call(route, true);
    super.didPop(route, previousRoute);
  }
}

@RoutePage()
class BaseScreen extends StatefulWidget {
  const BaseScreen({super.key});

  @override
  State<BaseScreen> createState() => _BaseScreenState();
}

class _BaseScreenState extends State<BaseScreen> {
  late final Downloader downloader;
  late final FileWatcher watcher;
  final ValueNotifier<bool> showBottomBar = ValueNotifier(true);
  @override
  void initState() {
    final deps = DependenciesScope.dependenciesOf(context);
    downloader = deps.downloader;
    watcher = deps.fileWatcher;
    super.initState();
  }

  @override
  void dispose() {
    downloader.dispose();
    watcher.dispose();
    super.dispose();
  }

  bool show = true;
  @override
  Widget build(BuildContext context) => AutoTabsScaffold(
        navigatorObservers: () => [
          MyObersver(onRouteChanged: (route, pop) async {
            if (route.settings.name == BookReadingRoute.name) {
              await Future<void>.delayed(const Duration(milliseconds: 10));
              setState(() {
                if (pop) {
                  show = true;
                } else {
                  show = false;
                }
              });
            }
          })
        ],
        routes: const [ReadingRoute(), LibraryRoute(), CataloguesRoute(), SettingsRoute()],
        bottomNavigationBuilder: (_, tabsRouter) => show
            ? PlatformNavBar(
                currentIndex: tabsRouter.activeIndex,
                material: (context, platform) => MaterialNavBarData(
                  itemChanged: tabsRouter.setActiveIndex,
                  type: BottomNavigationBarType.fixed,
                ),
                cupertino: (context, platform) => CupertinoTabBarData(
                  itemChanged: tabsRouter.setActiveIndex,
                  inactiveColor: Theme.of(context).bottomNavigationBarTheme.unselectedItemColor
                ),
                items: const [
                  BottomNavigationBarItem(label: 'Reading', icon: Icon(Icons.book)),
                  BottomNavigationBarItem(label: 'Library', icon: Icon(Icons.shelves)),
                  BottomNavigationBarItem(label: 'Catalogues', icon: Icon(Icons.public)),
                  BottomNavigationBarItem(label: 'Settings', icon: Icon(Icons.settings)),
                ],
              )
            : const SizedBox.shrink(),
      );
}
