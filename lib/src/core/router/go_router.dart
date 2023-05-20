import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:freader/src/feature/library/widget/directory_content_screen.dart';
import 'package:freader/src/feature/base/widget/base_screen.dart';
import 'package:freader/src/feature/book/book_reading_screen.dart';
import 'package:freader/src/feature/catalogues/opds/opds_screen.dart';
import 'package:freader/src/feature/catalogues/widget/catalogues_screen.dart';
import 'package:freader/src/feature/library/widget/library_screen.dart';
import 'package:freader/src/feature/reading/widget/reading_screen.dart';
import 'package:freader/src/feature/settings/iap/widget/iap_screen.dart';
import 'package:freader/src/feature/settings/theme/theme_screen.dart';
import 'package:freader/src/feature/settings/widget/settings_screen.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

extension Extra on Object {
  Map<String, dynamic> toMap() {
    if (this is Map<String, dynamic>) {
      return this as Map<String, dynamic>;
    }
    return {};
  }

  T getExtra<T>(String key) {
    final extra = toMap();
    if (T == int) {
      return int.parse(extra[key].toString()) as T;
    }
    return extra[key] as T;
  }
}

final routeObserverProvider = RouteObserver<ModalRoute<void>>();
final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();
late final GoRouter goRouter;
void initRouter({required SharedPreferences prefs}) {
  final location = prefs.getString('location') ?? '/';
  final extraString = prefs.getString('extra');
  final extra = extraString != null ? jsonDecode(extraString) : null;
  goRouter = GoRouter(
    redirect: (context, state) async {
      final extraString = prefs.getString('extra');
      if (extraString == null) {
        await prefs.setString('extra', jsonEncode(state.extra));
      } else {
        final extra = (jsonDecode(extraString) as Map<String, dynamic>)
          ..addAll(state.extra as Map<String, dynamic>? ?? {});
        await prefs.setString('extra', jsonEncode(extra));
      }
    },
    observers: [routeObserverProvider],
    initialLocation: location,
    initialExtra: extra,
    navigatorKey: _rootNavigatorKey,
    routes: [
      GoRoute(
        path: '/',
        redirect: (context, state) => '/reading',
      ),
      
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) => BaseScreen(
          child: child,
        ),
        routes: [

          GoRoute(
            name: 'reading',
            path: '/reading',
            builder: (context, state) => const ReadingScreen(),
          ),
          GoRoute(
              name: 'library',
              path: '/library',
              builder: (context, state) => const LibraryScreen(),
              routes: [
                GoRoute(
                    name: 'directory_content',
                    path: 'directory_content',
                    builder: (context, state) => DirectoryContentScreen(
                          directoryPath: state.extra!.getExtra('directoryPath'),
                        ),
                    routes: [
                      GoRoute(
                          parentNavigatorKey: _rootNavigatorKey,
                          name: 'book',
                          path: 'book',
                          builder: (context, state) =>
                              BookReadingScreen(bookId: state.extra!.getExtra<int>('id'))),
                    ]
                    ),
                    
              ]),
          GoRoute(
            name: 'catalogues',
            path: '/catalogues',
            builder: (context, state) => const CataloguesScreen(),
            routes: [
              GoRoute(
                name: 'opds',
                path: 'opds',
                builder: (context, state) => OpdsScreen(
                  url: state.extra!.getExtra<String>('url'),
                  name: state.extra!.getExtra<String>('name'),
                ),
              ),
            ],
          ),
          GoRoute(
            name: 'settings',
            path: '/settings',
            builder: (context, state) => const SettingsScreen(),
            routes: [
              GoRoute(
                name: 'iap',
                path: 'iap',
                builder: (context, state) => const IapScreen(),
              ),
              GoRoute(
                name: 'themes',
                path: 'themes',
                builder: (context, state) => const ThemeScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
  goRouter.addListener(() async {
    print(goRouter.location);
    await prefs.setString('location', goRouter.location);
  });
}
