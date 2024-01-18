import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:freader/src/feature/initialization/widget/dependencies_scope.dart';
import 'package:go_router/go_router.dart';

import '../../book/book_card/card.dart';

class BookCardTypeButton extends StatelessWidget {
  const BookCardTypeButton({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.dashboard_customize_sharp),
      onPressed: () => showModalBottomSheet<void>(
          context: context,
          useRootNavigator: true,
          isScrollControlled: true,
          builder: (ctx) => SizedBox(
                height: MediaQuery.of(context).size.height * 0.4,
                child: PlatformScaffold(
                  appBar: PlatformAppBar(
                    title: const Text('Вид книжных карточек'),
                    leading: InkWell(
                      child: const Icon(
                        Icons.close,
                        size: 20,
                      ),
                      onTap: () => context.pop(),
                    ),
                  ),
                  body: StreamBuilder(
                    stream: DependenciesScope.dependenciesOf(context).database.settingsDao.watch(),
                    builder: (ctx, snapshot) {
                      if (!snapshot.hasData) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }
                      final settings = snapshot.data;
                      return ListView(
                        children: BookCardType.values
                            .map((e) => ListTile(
                                  title: Text(e.label),
                                  trailing:
                                      settings?.bookCardType == e ? const Icon(Icons.check) : null,
                                  onTap: () {
                                    DependenciesScope.dependenciesOf(context)
                                        .database
                                        .settingsDao
                                        .updateSetting(bookCardType: e);
                                    context.pop();
                                  },
                                ))
                            .toList(),
                      );
                    },
                  ),
                ),
              )),
    );
  }
}
