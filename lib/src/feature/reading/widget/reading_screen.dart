
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:freader/src/feature/book/book_card/card.dart';
import 'package:freader/src/feature/initialization/widget/dependencies_scope.dart';
import 'package:go_router/go_router.dart';

import '../../../core/data/database/daos/book_dao.dart';

class ReadingScreen extends StatelessWidget {
  const ReadingScreen({super.key});

  @override
  Widget build(BuildContext context) => PlatformScaffold(
    appBar: PlatformAppBar(title: const Text('Читаю')),
        body: StreamBuilder<List<BookWithMetadata>>(
          stream: DependenciesScope.dependenciesOf(context).database.bookDao.watchAll(lastRead: true),
          builder: (context, snapshot) {
            if(!snapshot.hasData){
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
            final books = snapshot.data!;
            return  GridView.count(
              crossAxisCount: 2,
              mainAxisSpacing: 10,
              childAspectRatio: 0.75,
              children: books
                  .map(
                    (book) => InkWell(
                      onTap: () => context.pushNamed('book', extra: {'id': book.book.bid.toString()}),
                      child: AbsorbPointer(
                        child: LargeCard(
                          entity: book,
                        ),
                      ),
                    ),
                  )
                  .toList(),
            );
          },
        ),
          
      
      );
}
