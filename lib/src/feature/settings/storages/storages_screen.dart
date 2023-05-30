import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:freader/src/core/storages/storage_inteface.dart';
import 'package:go_router/go_router.dart';
import 'package:settings_ui/settings_ui.dart';

const title = 'Хранилища файлов';

class StoragesScreen extends StatefulWidget {
  const StoragesScreen({super.key});

  @override
  State<StoragesScreen> createState() => _StoragesScreenState();
}

class _StoragesScreenState extends State<StoragesScreen> {
  @override
  Widget build(BuildContext context) => PlatformScaffold(
        appBar: PlatformAppBar(title: const Text(title)),
        body: SettingsList(
          platform: DevicePlatform.iOS,
          lightTheme: SettingsThemeData(
            settingsListBackground: Theme.of(context).scaffoldBackgroundColor,
            settingsSectionBackground: Theme.of(context).cardColor,
            trailingTextColor: Theme.of(context).textTheme.bodyLarge!.color,
            dividerColor: Theme.of(context).dividerColor,
            settingsTileTextColor: Theme.of(context).textTheme.bodyLarge!.color,
          ),
          sections: [SettingsSection(
            margin: EdgeInsetsDirectional.zero,
            tiles: storages
                .map(
                  (e) => SettingsTile.navigation(
                    trailing: const Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                    ),
                    onPressed: (ctx) => e.connect(),
                    // onPressed: (ctx) => GoRouter.of(context).push('/settings/storages/${e.route}'),
                    title: Text(e.name),
                  ),
                )
                .toList(),
          )],
        ),
      );
}
