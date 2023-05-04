import 'package:flutter/material.dart';
import 'package:freader/src/core/utils/mixin/context_menu_mixin.dart';

import 'model/opds_link.model.dart';

class DownloadButton extends StatefulWidget {
  const DownloadButton({
    required this.links,
    super.key,
  });

  final Iterable<OpdsLinkDownload> links;

  @override
  State<DownloadButton> createState() => _DownloadButtonState();
}

class _DownloadButtonState extends State<DownloadButton> with ContextMenuMixin {
  @override
  Widget build(BuildContext context) => GestureDetector(
        onTapDown: getTapPosition,
        child: Builder(
          builder: (context) {
            return ElevatedButton(
                onPressed: widget.links.isEmpty
                    ? null
                    : () {
                        if (widget.links.length > 1) {
                          print('More than one link');
                          showContextMenu(
                              context,
                              widget.links
                                  .map((e) => PopupMenuItem(child: Text(e.uri.toString())))
                                  .toList());
                        } else {
                          print(widget.links.first.uri);
                        }
                      },
                child: const Text('Скачать'));
          },
        ),
      );
}
