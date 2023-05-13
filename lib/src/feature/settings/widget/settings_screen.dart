import 'package:auto_route/auto_route.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:freader/src/core/router/router.gr.dart';
import 'package:settings_ui/settings_ui.dart';

@RoutePage()
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) => PlatformScaffold(
        appBar: PlatformAppBar(
          title: const Text('Настройки'),
          automaticallyImplyLeading: true,
          cupertino: (context, platform) => CupertinoNavigationBarData(
            backgroundColor: CupertinoTheme.of(context).barBackgroundColor,
          ),
        ),
        body: Center(
          child: SettingsList(
            platform: DevicePlatform.iOS,
            shrinkWrap: true,
            lightTheme: SettingsThemeData(
              settingsListBackground: Theme.of(context).scaffoldBackgroundColor,
              settingsSectionBackground: Theme.of(context).cardColor,
              trailingTextColor: Theme.of(context).textTheme.bodyLarge!.color,
              dividerColor: Theme.of(context).dividerColor,
              settingsTileTextColor: Theme.of(context).textTheme.bodyLarge!.color,
            ),
            sections: [
              SettingsSection(
                tiles: [
                  SettingsTile.navigation(
                    onPressed: (ctx) => context.router.pushNamed('iap'),
                    trailing: const Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                    ),
                    title: const Text('Встроенные покупки'),
                  )
                ],
              ),
              SettingsSection(
                title: const Text('Службы'),
                tiles: [
                  SettingsTile.navigation(
                    trailing: const Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                    ),
                    onPressed: (ctx) => context.router.pushNamed('iap'),
                    title: const Text('Словари'),
                  ),
                  SettingsTile.navigation(
                    trailing: const Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                    ),
                    // onPressed: (ctx) => context.navigateTo(
                        // CataloguesTab(children: [OpdsRoute(name: 'Flibusta', url: 'https://flibusta.is/opds')])),

                    onPressed: (ctx) => context.router.pushAll([ BaseRoute(), CataloguesRoute(), OpdsRoute()]),
                    title: const Text('Загрузки'),
                  ),
                  SettingsTile.navigation(
                    trailing: const Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                    ),
                    onPressed: (ctx) => context.router.pushNamed('iap'),
                    title: const Text('Синхронизация'),
                  )
                ],
              ),
              SettingsSection(
                title: const Text('Настройки'),
                tiles: [
                  SettingsTile.navigation(
                    trailing: const Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                    ),
                    onPressed: (ctx) => context.router.pushNamed('iap'),
                    title: const Text('Читалка'),
                  ),
                  SettingsTile.navigation(
                    trailing: const Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                    ),
                    onPressed: (ctx) => context.router.pushNamed('iap'),
                    title: const Text('Сервис перевода'),
                  ),
                  SettingsTile.navigation(
                    trailing: const Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                    ),
                    onPressed: (ctx) => context.router.pushNamed('themes'),
                    title: const Text('Темы'),
                  ),
                ],
              ),
              SettingsSection(
                tiles: [
                  SettingsTile.navigation(
                    trailing: const Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                    ),
                    onPressed: (ctx) => context.router.pushNamed('iap'),
                    title: const Text('О программе'),
                  )
                ],
              ),
            ],
          ),
        ),
      );
}
