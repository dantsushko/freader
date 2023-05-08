import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:freader/src/core/router/router.gr.dart';
import 'package:freader/src/core/utils/path.dart';
import 'package:freader/src/feature/initialization/widget/dependencies_scope.dart';
import 'package:path/path.dart' as path;

import '../../feature/book/book_card/small_card.dart';
import '../data/database/daos/book_dao.dart';

@RoutePage()
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
    entities = Directory(widget.directoryPath).listSync().whereType<Directory>().toList();
    super.initState();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(),
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
            final allEntities = [...entities, ...books];
            return ListView.builder(
              itemCount: allEntities.length,
              itemBuilder: (context, index) {
                final entity = allEntities[index];
                if (entity is Directory) {
                  return ListTile(
                    leading: const Icon(Icons.folder),
                    trailing: const Icon(Icons.chevron_right),
                    title: Text(path.basename(entity.path)),
                    onTap: () {
                      context.router.push(DirectoryContentRoute(directoryPath: entity.path));
                    },
                  );
                } else if (entity is BookWithMetadata) {
                  return SmallCard(entity: entity);
                }
                return const SizedBox.shrink();
              },
            );
          },
        ),
      );
}



