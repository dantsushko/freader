import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:settings_ui/settings_ui.dart';

@RoutePage()
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('Настройки'),
          centerTitle: true,
        ),
        body: SettingsList(
          sections: [
            SettingsSection(
              tiles: [
                SettingsTile.navigation(
                  onPressed: (ctx) => context.router.pushNamed('iap'),
                  trailing: const Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: Colors.black54,
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
                    color: Colors.black54,
                  ),
                  onPressed: (ctx) => context.router.pushNamed('iap'),
                  title: const Text('Словари'),
                ),
                SettingsTile.navigation(
                  trailing: const Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: Colors.black54,
                  ),
                  onPressed: (ctx) => context.router.pushNamed('iap'),
                  title: const Text('Загрузки'),
                ),
                SettingsTile.navigation(
                  trailing: const Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: Colors.black54,
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
                    color: Colors.black54,
                  ),
                  onPressed: (ctx) => context.router.pushNamed('iap'),
                  title: const Text('Читалка'),
                ),
                SettingsTile.navigation(
                  trailing: const Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: Colors.black54,
                  ),
                  onPressed: (ctx) => context.router.pushNamed('iap'),
                  title: const Text('Сервис перевода'),
                ),
                SettingsTile.navigation(
                  trailing: const Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: Colors.black54,
                  ),
                  onPressed: (ctx) => context.router.pushNamed('iap'),
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
                    color: Colors.black54,
                  ),
                  onPressed: (ctx) => context.router.pushNamed('iap'),
                  title: const Text('О программе'),
                )
              ],
            ),
          ],
        ),
      );
}
