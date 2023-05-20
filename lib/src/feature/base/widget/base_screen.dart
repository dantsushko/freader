
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:freader/src/core/file/watcher.dart';
import 'package:freader/src/core/utils/downloader.dart';
import 'package:freader/src/feature/initialization/widget/dependencies_scope.dart';
import 'package:go_router/go_router.dart';



class BaseScreen extends StatefulWidget {
  const BaseScreen({super.key, required this.child});
  final Widget child;
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

int _calculateSelectedIndex(BuildContext context) {
    final route = GoRouter.of(context);
    final location = route.location;
    if (location.startsWith('/reading')) {
      return 0;
    }
    if (location.startsWith('/library')) {
      return 1;
    }
    if (location.startsWith('/catalogues')) {
      return 2;
    }
    if (location.startsWith('/settings')) {
      return 3;
    }
    return 0;
  }

  void onTap(int value) {
    switch (value) {
      case 0:
        return context.go('/reading');
      case 1:
        return context.go('/library');
      case 2:
        return context.go('/catalogues');
      case 3:
        return context.go('/settings');
      default: return;
    }
  }
  @override
  Widget build(BuildContext context) => 
  Scaffold(
    body: widget.child,
    bottomNavigationBar:   
            PlatformNavBar(
                currentIndex: _calculateSelectedIndex(context),
                material: (context, platform) => MaterialNavBarData(
                  itemChanged: onTap,
                  type: BottomNavigationBarType.fixed,
                ),
                cupertino: (context, platform) => CupertinoTabBarData(
                   itemChanged: onTap,
                  inactiveColor: Theme.of(context).bottomNavigationBarTheme.unselectedItemColor
                ),
                items: const [
                  BottomNavigationBarItem(label: 'Reading', icon: Icon(Icons.book)),
                  BottomNavigationBarItem(label: 'Library', icon: Icon(Icons.shelves)),
                  BottomNavigationBarItem(label: 'Catalogues', icon: Icon(Icons.public)),
                  BottomNavigationBarItem(label: 'Settings', icon: Icon(Icons.settings)),
                ],
              ),
  );
}
