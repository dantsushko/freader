import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:freader/src/core/router/router.gr.dart';
import 'package:freader/src/core/utils/extensions/context_extension.dart';
import 'package:freader/src/feature/sample/localization/sample_localization_delegate.dart';

/// {@template sample_page}
/// SamplePage widget
/// {@endtemplate}
@RoutePage()
class SampleScreen extends StatelessWidget {
  /// {@macro sample_page}
  const SampleScreen({super.key});

  @override
  Widget build(BuildContext context) => AutoTabsScaffold(
        routes: const [ReadingRoute(), LibraryRoute(), CataloguesRoute(), SettingsRoute()],
        bottomNavigationBuilder: (_, tabsRouter) => BottomNavigationBar(
          currentIndex: tabsRouter.activeIndex,
          onTap: tabsRouter.setActiveIndex,
          type: BottomNavigationBarType.fixed,
          items: const [
            
            BottomNavigationBarItem(label: 'Reading', icon: Icon(Icons.book)),
            BottomNavigationBarItem(label: 'Library', icon: Icon(Icons.shelves)),
            BottomNavigationBarItem(label: 'Catalogues', icon: Icon(Icons.public)),
            BottomNavigationBarItem(label: 'Settings', icon: Icon(Icons.settings)),
          ],
        ),
      );
}
