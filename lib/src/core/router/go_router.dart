import 'package:flutter/material.dart';
import 'package:freader/src/feature/base/widget/base_screen.dart';
import 'package:freader/src/feature/reading/widget/reading_screen.dart';
import 'package:freader/src/feature/settings/widget/settings_screen.dart';
import 'package:go_router/go_router.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();
final GoRouter goRouter = GoRouter(
  initialLocation: '/reading',
  navigatorKey: _rootNavigatorKey,
  routes: [
    ShellRoute(
       navigatorKey: _shellNavigatorKey,
      builder: (BuildContext context, GoRouterState state, child) {
        return const BaseScreen();
      },
      routes: [
          GoRoute(
            path: '/reading',
            builder: (BuildContext context, GoRouterState state) {
              return const ReadingScreen();
            },
          ),
        GoRoute(
          path: '/settings',
          builder: (BuildContext context, GoRouterState state) {
            return const SettingsScreen();
          },
        ),
      ]
    ),
    // GoRoute(
    //     path: '/article', builder: (BuildContext context, GoRouterState state) => SingleArticle()),
  ],
);
