import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:freader/src/core/data/database/tables.dart';
import 'package:freader/src/feature/catalogues/widget/catalogue_icon.dart';
import 'package:freader/src/feature/initialization/widget/dependencies_scope.dart';

import 'add_opds_dialog.dart';

@RoutePage()
class CataloguesScreen extends StatefulWidget {
  const CataloguesScreen({super.key});

  @override
  State<CataloguesScreen> createState() => _CataloguesScreenState();
}

class _CataloguesScreenState extends State<CataloguesScreen> {
  @override
  void initState() {
    super.initState();
  }

  Offset _tapPosition = Offset.zero;
  void _getTapPosition(TapDownDetails details) {
    final referenceBox = context.findRenderObject() as RenderBox?;
    setState(() {
      _tapPosition = referenceBox!.globalToLocal(details.globalPosition);
    });
  }

  Future<void> _showContextMenu(BuildContext context, List<PopupMenuItem> items) async {
    final overlay = Overlay.of(context).context.findRenderObject();
    await showMenu(
      context: context,
      position: RelativeRect.fromRect(
        Rect.fromLTWH(_tapPosition.dx, _tapPosition.dy, 30, 30),
        Rect.fromLTWH(0, 0, overlay!.paintBounds.size.width, overlay.paintBounds.size.height),
      ),
      items: items,
    );

  
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        body: CustomScrollView(
          slivers: [
            const SliverAppBar(
              snap: true,
              floating: true,
              expandedHeight: 40,
              title: Text('Каталоги'),
              centerTitle: true,
            ),
            StreamBuilder(
              stream: DependenciesScope.dependenciesOf(context).database.opdsDao.watchAll(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const SliverToBoxAdapter(
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                List<Widget> gridChildren = snapshot.data!
                    .map(
                      (opds) => GestureDetector(
                        onTapDown: _getTapPosition,
                        onLongPress: () => _showContextMenu(context, [
                          PopupMenuItem(
                            child: Text('Правка'),
                            onTap: () => print('asd'),
                          ),
                          PopupMenuItem(
                            child: Text('Удалить'),
                            onTap: () => DependenciesScope.dependenciesOf(context).database.opdsDao.deleteOpds(opds.id),
                          ),
                        ]),
                        child: CatalogueIcon(name: opds.name),
                      ),
                    )
                    .toList();
                    gridChildren = [...gridChildren, GestureDetector(
                      onTap: () => showDialog<void>(
                        context: context,
                        builder: (ctx) => const CustomDialog(),
                      ),
                      child: const AddCatalogueIcon(),
                    )];


                return SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                  ),
                  delegate: SliverChildListDelegate(gridChildren),
                );
              },
            ),
          ],
        ),
      );
}
