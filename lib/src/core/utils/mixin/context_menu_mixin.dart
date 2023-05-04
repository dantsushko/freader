import 'package:flutter/material.dart';

mixin ContextMenuMixin<T extends StatefulWidget> on State<T> {
  Offset _tapPosition = Offset.zero;
  void getTapPosition(TapDownDetails details) {
    final referenceBox = context.findRenderObject() as RenderBox?;
    setState(() {
      _tapPosition = referenceBox!.globalToLocal(details.globalPosition);
    });
  }

  Future<void> showContextMenu(BuildContext context, List<PopupMenuItem> items) async {
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
}
