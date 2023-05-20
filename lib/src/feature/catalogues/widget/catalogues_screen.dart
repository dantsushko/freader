
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:freader/src/feature/base/widget/catalogue_icon.dart';
import 'package:freader/src/feature/initialization/widget/dependencies_scope.dart';
import 'package:go_router/go_router.dart';

import '../../../core/utils/mixin/context_menu_mixin.dart';
import 'add_opds_dialog.dart';

class CataloguesScreen extends StatefulWidget {
  const CataloguesScreen({super.key});

  @override
  State<CataloguesScreen> createState() => _CataloguesScreenState();
}

class _CataloguesScreenState extends State<CataloguesScreen> with ContextMenuMixin {
  @override
  void initState() {
    super.initState();
  }

  // Offset _tapPosition = Offset.zero;
  // void _getTapPosition(TapDownDetails details) {
  //   final referenceBox = context.findRenderObject() as RenderBox?;
  //   setState(() {
  //     _tapPosition = referenceBox!.globalToLocal(details.globalPosition);
  //   });
  // }

  // Future<void> _showContextMenu(BuildContext context, List<PopupMenuItem> items) async {
  //   final overlay = Overlay.of(context).context.findRenderObject();
  //   await showMenu(
  //     context: context,
  //     position: RelativeRect.fromRect(
  //       Rect.fromLTWH(_tapPosition.dx, _tapPosition.dy, 30, 30),
  //       Rect.fromLTWH(0, 0, overlay!.paintBounds.size.width, overlay.paintBounds.size.height),
  //     ),
  //     items: items,
  //   );
  // }

  @override
  Widget build(BuildContext context) => PlatformScaffold(
      appBar: PlatformAppBar(title: const Text('Каталоги'),),
      body: StreamBuilder(
        stream: DependenciesScope.dependenciesOf(context).database.opdsDao.watchAll(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          List<Widget> gridChildren = snapshot.data!
              .map(
                (opds) => GestureDetector(
                  onTapDown: getTapPosition,
                  onTapUp: (details) =>
                      context.goNamed('opds', extra: {'url': opds.url, 'name': opds.name}),
                  onLongPress: () => showContextMenu(context, [
                    PopupMenuItem(
                      child: const Text('Правка'),
                      onTap: () => print('asd'),
                    ),
                    PopupMenuItem(
                      child: const Text('Удалить'),
                      onTap: () => DependenciesScope.dependenciesOf(context)
                          .database
                          .opdsDao
                          .deleteOpds(opds.id),
                    ),
                  ]),
                  child: CatalogueIcon(name: opds.name),
                ),
              )
              .toList();
          gridChildren = [
            ...gridChildren,
            GestureDetector(
              onTap: () => showDialog<void>(
                context: context,
                builder: (ctx) => const CustomDialog(),
              ),
              child: const AddCatalogueIcon(),
            )
          ];

          return GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
            ),
            itemCount: gridChildren.length,
            itemBuilder: (context, index) => gridChildren[index],
          );
        },
      ),);
}
