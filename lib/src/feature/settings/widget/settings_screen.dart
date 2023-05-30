
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

import 'package:freader/src/feature/settings/iap/widget/iap_screen.dart';
import 'package:go_router/go_router.dart';
import 'package:settings_ui/settings_ui.dart';

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
                margin: const EdgeInsetsDirectional.all(4),
                tiles: [
                  SettingsTile.navigation(
                    onPressed: (ctx) => GoRouter.of(context).push('/settings/iap'),
                    trailing: const Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                    ),
                    title: const Text('Встроенные покупки'),
                  )
                ],
              ),
              SettingsSection(
                margin: const EdgeInsetsDirectional.all(4),
                title: const Text('Службы'),
                tiles: [
                  SettingsTile.navigation(
                    trailing: const Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                    ),
                    onPressed: (ctx) => GoRouter.of(context).push('/settings/storages'),
                    title: const Text('Хранилища файлов'),
                  ),
                  SettingsTile.navigation(
                    trailing: const Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                    ),
                    onPressed: (ctx) => GoRouter.of(context).push('/settings/iap'),
                    title: const Text('Словари'),
                  ),
                  SettingsTile.navigation(
                    trailing: const Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                    ),
                    // onPressed: (ctx) => context.navigateTo(
                        // CataloguesTab(children: [OpdsRoute(name: 'Flibusta', url: 'https://flibusta.is/opds')])),

                    onPressed: (ctx) => context.go('opds?name=Flibusta&url=https://flibusta.is/opds'),
                    title: const Text('Загрузки'),
                  ),
                  SettingsTile.navigation(
                    trailing: const Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                    ),
                    onPressed: (ctx) => GoRouter.of(context).push('/settings/iap'),
                    title: const Text('Синхронизация'),
                  )
                ],
              ),
              SettingsSection(
                margin: const EdgeInsetsDirectional.all(4),
                title: const Text('Настройки'),
                tiles: [
                  SettingsTile.navigation(
                    trailing: const Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                    ),
                    onPressed: (ctx) => GoRouter.of(context).push('/settings/iap'),
                    title: const Text('Читалка'),
                  ),
                  SettingsTile.navigation(
                    trailing: const Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                    ),
                    onPressed: (ctx) => GoRouter.of(context).push('/settings/iap'),
                    title: const Text('Сервис перевода'),
                  ),
                  SettingsTile.navigation(
                    trailing: const Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                    ),
                    onPressed: (ctx) => GoRouter.of(context).push('/settings/themes'),
                    title: const Text('Темы'),
                  ),
                ],
              ),
              SettingsSection(
                margin: const EdgeInsetsDirectional.all(4),
                tiles: [
                  SettingsTile.navigation(
                    trailing: const Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                    ),
                    onPressed: (ctx) => GoRouter.of(context).push('/settings/iap'),
                    title: const Text('О программе'),
                  )
                ],
              ),
            ],
          ),
        ),
      );
}
