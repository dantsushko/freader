import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:freader/src/core/data/database/database.dart';
import 'package:freader/src/feature/initialization/widget/dependencies_scope.dart';

@RoutePage()
class ThemeScreen extends StatefulWidget {
  const ThemeScreen({super.key});

  @override
  State<ThemeScreen> createState() => _ThemeScreenState();
}

class _ThemeScreenState extends State<ThemeScreen> {
  @override
  Widget build(BuildContext context) => PlatformScaffold(
      appBar: PlatformAppBar(
        title: const Text('Темы'),
      ),
      body: StreamBuilder<List<ThemeEntry>>(
        stream: DependenciesScope.dependenciesOf(context).database.settingsDao.watchThemes(),
        builder: (context, snapshot) {
          if(!snapshot.hasData){
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          final themes = snapshot.data!;
          return  ListView.builder(
            itemCount: themes.length,
            itemBuilder: (ctx, index) => ListTile(
              title: Text(themes[index].name),
              onTap: () {
                DependenciesScope.dependenciesOf(context).database.settingsDao.updateSetting(themeId: themes[index].id);
              },

            ),
          );
        },
      ),);
}
