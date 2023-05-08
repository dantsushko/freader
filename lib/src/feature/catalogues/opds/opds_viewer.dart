import 'package:auto_route/auto_route.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:freader/src/core/router/router.gr.dart';
import 'package:freader/src/feature/book/book_detail/book_detail.dart';
import 'package:freader/src/feature/catalogues/opds/model/opds_entry.model.dart';
import 'package:freader/src/feature/catalogues/opds/model/opds_page.model.dart';

import 'model/opds_link.model.dart';

class OpdsViewer extends StatefulWidget {
  const OpdsViewer({required this.content, required this.uri, super.key});
  final String content;
  final Uri uri;
  @override
  State<OpdsViewer> createState() => _OpdsViewerState();
}

class _OpdsViewerState extends State<OpdsViewer> {
  late final OpdsPage page;
  @override
  void initState() {
    page = OpdsPage(widget.content, widget.uri);
    super.initState();
  }

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
        child: Column(
          children: page.entries
              .map(
                (e) => OpdsCard(
                  entry: e,
                ),
              )
              .toList(),
        ),
      );
}

class OpdsCard extends StatefulWidget {
  const OpdsCard({
    required this.entry,
    super.key,
  });
  final OpdsEntry entry;
  @override
  State<OpdsCard> createState() => _OpdsCardState();
}

class _OpdsCardState extends State<OpdsCard> {
  @override
  Widget build(BuildContext context) => InkWell(
        onTap: () {
          final catalogLink = widget.entry.links.firstWhereOrNull((link) => link is OpdsLinkCatalog)
              as OpdsLinkCatalog?;
          if (widget.entry.authors.isNotEmpty) {
            showBottomSheet<void>(
                context: context,
                builder: (ctx) => BookDetailScreen(
                      key: ValueKey(widget.entry),
                      opdsEntry: widget.entry,
                    ));
          } else {
            if (catalogLink != null) {
              context.router.push(
                OpdsRoute(
                  url: catalogLink.uri.toString(),
                  name: widget.entry.title,
                ),
              );
            }
          }
        },
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.entry.title,
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                      if (widget.entry.authors.isNotEmpty)
                        Text(widget.entry.authors.first.name)
                      else
                        Text(widget.entry.content),
                      if (widget.entry.categories.isNotEmpty)
                        Text(
                          widget.entry.categories.map((e) => e.term).join(', '),
                          style: TextStyle(overflow: TextOverflow.ellipsis),
                          maxLines: 3,
                        ),
                      Row(
                        children: [if (widget.entry.format != null) Text(widget.entry.format!)
                        
                      ],
                      )
                      
                    ],
                  ),
                ),
                if (widget.entry.links.whereType<OpdsLinkImage>().isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.all(4),
                    child: Image.network(
                      widget.entry.links.whereType<OpdsLinkImage>().first.uri.toString(),
                      width: 120,
                      height: 100,
                      errorBuilder: (ctx, _, __) => const SizedBox.shrink(),
                    ),
                  )
                else
                  const SizedBox(
                    width: 120,
                  )
              ],
            ),
          ),
        ),
      );
}
