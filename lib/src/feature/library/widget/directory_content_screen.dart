import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:freader/src/core/utils/path.dart';
import 'package:freader/src/feature/book/book_card/card.dart';
import 'package:freader/src/feature/initialization/widget/dependencies_scope.dart';
import 'package:freader/src/feature/library/widget/book_card_type_button.dart';
import 'package:go_router/go_router.dart';
import 'package:path/path.dart' as path;

import '../../../core/data/database/daos/book_dao.dart';

class DirectoryContentScreen extends StatefulWidget {
  const DirectoryContentScreen({required this.directoryPath, super.key});
  final String directoryPath;

  @override
  State<DirectoryContentScreen> createState() => _DirectoryContentScreenState();
}

class _DirectoryContentScreenState extends State<DirectoryContentScreen> {
  late final List<FileSystemEntity> entities;
  @override
  void initState() {
    final dir = Directory(widget.directoryPath);
    if (!dir.existsSync()) {
      dir.createSync(recursive: true);
    }
    entities = dir.listSync().whereType<Directory>().toList();
    super.initState();
  }

  @override
  Widget build(BuildContext context) => PlatformScaffold(
        appBar: PlatformAppBar(
          trailingActions: const [BookCardTypeButton()],
        ),
        body: StreamBuilder<List<BookWithMetadata>>(
          stream: DependenciesScope.of(context)
              .dependencies
              .database
              .bookDao
              .watchAll(directory: getDirName(widget.directoryPath)),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(child: Text(snapshot.error.toString()));
            }
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            final books = snapshot.data!;
            return Column(
              children: [
                if (entities.isNotEmpty)
                  Expanded(
                      child: ListView(
                    children: entities
                        .map((e) => ListTile(
                            leading: const Icon(Icons.folder),
                            trailing: const Icon(Icons.chevron_right),
                            title: Text(path.basename(e.path)),
                            onTap: () {
                              context.pushNamed(
                                'directory_content',
                                extra: {'directoryPath': e.path},
                              );
                            },),)
                        .toList(),
                  ),),
                StreamBuilder(
                    stream: DependenciesScope.of(context).dependencies.database.settingsDao.watch(),
                    builder: (ctx, snapshot) {
                      if (!snapshot.hasData) {
                        return const SizedBox.shrink();
                      }
                      final settings = snapshot.data!;
                      if (settings.bookCardType == BookCardType.medium) {
                        return Expanded(
                            child: ListView(
                          children: books.map((e) => MediumCard(entity: e)).toList(),
                        ),);
                      } else if (settings.bookCardType == BookCardType.small) {
                        return Expanded(
                            child: ListView(
                          children: books.map((e) => SmallCard(entity: e)).toList(),
                        ),);
                      } else {
                        return Expanded(
                          child: GridView.count(
                            crossAxisCount: 2,
                            mainAxisSpacing: 10,
                            childAspectRatio: 0.75,
                            children: books
                                .map((book) => LargeCard(
                                      entity: book,
                                    ),)
                                .toList(),
                          ),
                        );
                      }
                    },),
              ],
            );
            // return ListView.builder(
            //   itemCount: allEntities.length,
            //   itemBuilder: (context, index) {
            //     final entity = allEntities[index];
            //     if (entity is Directory) {
            //       return ListTile(
            //         leading: const Icon(Icons.folder),
            //         trailing: const Icon(Icons.chevron_right),
            //         title: Text(path.basename(entity.path)),
            //         onTap: () {
            //           context.pushNamed(
            //             'directory_content',
            //             extra: {'directoryPath': entity.path},
            //           );
            //         },
            //       );
            //     } else if (entity is BookWithMetadata) {
            //       return StreamBuilder(
            //           stream:
            //               DependenciesScope.of(context).dependencies.database.settingsDao.watch(),
            //           builder: (ctx, snapshot) {
            //             if (!snapshot.hasData) {
            //               return const SizedBox.shrink();
            //             }
            //             final settings = snapshot.data!;
            //             if (settings.bookCardType == BookCardType.large) {
            //               return LargeCard(entity: entity);
            //             } else if (settings.bookCardType == BookCardType.small) {
            //               return SmallCard(entity: entity);
            //             }
            //             return MediumCard(entity: entity);
            //           });
            //     }
            //     return const SizedBox.shrink();
            //   },
            // );
          },
        ),
      );
}
