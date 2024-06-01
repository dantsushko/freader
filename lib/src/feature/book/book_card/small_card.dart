import 'package:flutter/material.dart';
import 'package:freader/src/core/data/database/daos/book_dao.dart';
import 'package:freader/src/core/utils/extensions/context_extension.dart';
import 'package:freader/src/feature/initialization/widget/dependencies_scope.dart';

import '../book_detail/book_detail.dart';

class SmallCard extends StatelessWidget {
  const SmallCard({
    required this.entity,
    super.key,
  });

  final BookWithMetadata entity;

  @override
  Widget build(BuildContext context) => SizedBox(
        height: 60,
        child: InkWell(
          onTap: () => showModalBottomSheet<void>(
            context: context,
            useRootNavigator: true,
            isScrollControlled: true,
            builder: (ctx) => SizedBox(
              height: MediaQuery.of(context).size.height * 0.9,
              child: BookDetailScreen(
                book: entity,
              ),
            ),
          ),
          child: Card(
            child: Row(
              children: [
                if (entity.book.cover == null)
                  const Icon(Icons.book)
                else
                  Image.memory(
                    entity.book.cover!,
                    cacheWidth: 50,
                    cacheHeight: 75,
                    errorBuilder: (ctx, _, __) => Image.asset(
                      'assets/images/book-cover-placeholder.png',
                      cacheWidth: 50,
                      cacheHeight: 75,
                    ),
                  ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(6),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                entity.metadata.title,
                                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Text(entity.book.format),
                            const SizedBox(
                              width: 10,
                            ),
                            const Icon(
                              Icons.circle,
                              size: 5,
                              color: Colors.grey,
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            Text(entity.book.filesize.prettyBytes),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
                BookContextMenu(entity: entity)
              ],
            ),
          ),
        ),
      );
}

class BookContextMenu extends StatelessWidget {
  const BookContextMenu({super.key, required this.entity});
  final BookWithMetadata entity;

  
  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: Icon(Icons.more_vert),
      onSelected: (String value) {
        // Handle menu item selection here
        print('Selected: $value');
      },
      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
        // PopupMenuItem<String>(
        //   value: 'move',
        //   child: ListTile(
        //     leading: Icon(Icons.drive_file_move),
        //     title: Text('Переместить'),
        //   ),
        // ),
        PopupMenuItem<String>(
          onTap: () {
            DependenciesScope.dependenciesOf(context).database.bookDao.deleteBook(entity.book.filepath);
          },
          child: ListTile(
            leading: Icon(Icons.delete),
            title: Text('Удалить'),
          ),
        ),
        PopupMenuItem<String>(
          value: 'share',
          child: ListTile(
            leading: Icon(Icons.share),
            title: Text('Поделиться'),
          ),
        ),
        PopupMenuItem<String>(
          value: 'info',
          child: ListTile(
            leading: Icon(Icons.info),
            title: Text('Инфо'),
          ),
        ),
        PopupMenuItem<String>(
          value: 'labels',
          child: ListTile(
            leading: Icon(Icons.label),
            title: Text('Метки'),
          ),
        ),
        PopupMenuItem<String>(
          value: 'read',
          child: ListTile(
            leading: Icon(Icons.visibility),
            title: Text('Читать'),
          ),
        ),
        PopupMenuItem<String>(
          value: 'select_all',
          child: ListTile(
            leading: Icon(Icons.select_all),
            title: Text('Выбрать всё'),
          ),
        ),
        PopupMenuItem<String>(
          value: 'collections',
          child: ListTile(
            leading: Icon(Icons.collections),
            title: Text('Коллекции'),
          ),
        ),
      ],
    );
  }
}
