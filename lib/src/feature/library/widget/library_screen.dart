import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:freader/src/core/constants/constants.dart';
import 'package:freader/src/core/file/directory_content_screen.dart';
import 'package:freader/src/core/router/router.gr.dart';
import 'package:freader/src/core/utils/downloader.dart';
import 'package:freader/src/feature/base/widget/catalogue_icon.dart';
import 'package:freader/src/feature/initialization/widget/dependencies_scope.dart';
import 'package:path_provider/path_provider.dart';

@RoutePage()
class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  late final Downloader downloader;
  late final Directory downloadDir;
  late final Directory inboxDir;
  @override
  void initState() {
    downloader = DependenciesScope.dependenciesOf(context).downloader;
    downloadDir = Directory(downloadDirPath);
    inboxDir = Directory(inboxDirPath);
    super.initState();
  }

  @override
  Widget build(BuildContext context) => PlatformScaffold(
        appBar: PlatformAppBar(title: const Text('Библиотека')),
        body: 
           GridView.custom(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                  ),
                  childrenDelegate: SliverChildListDelegate([
                    InkWell(
                      onTap: () => context.router.push(DirectoryContentRoute(directoryPath: baseBookDirPath)),
                      child: const CatalogueIcon(name: 'Local', icon: Icons.smartphone)),
                  ]),
                ),
      );
}
