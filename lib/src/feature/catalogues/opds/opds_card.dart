import 'package:auto_route/auto_route.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:freader/src/core/router/router.gr.dart';

import '../../book/book_detail/book_detail.dart';
import 'model/opds_entry.model.dart';
import 'model/opds_link.model.dart';

class OpdsCard extends StatelessWidget {
  const OpdsCard({
    required this.entry,
    Key? key,
  }) : super(key: key);

  final OpdsEntry entry;

  void _handleCardTap(BuildContext context) {
    final catalogLink =
        entry.links.firstWhereOrNull((link) => link is OpdsLinkCatalog) as OpdsLinkCatalog?;
    if (!entry.id!.contains(':book:')) {
      context.router.push(
        OpdsRoute(
          url: catalogLink!.uri.toString(),
          name: entry.title,
        ),
      );
    } else {
      showModalBottomSheet<void>(
        context: context,
        useRootNavigator: true,
        isScrollControlled: true,
        builder: (ctx) => SizedBox(
          height: MediaQuery.of(context).size.height * 0.9,
          child: BookDetailScreen(
            opdsEntry: entry,
          ),
        ),
      );
    }
  }

  Widget _buildThumbnail() {
    final imageLink = entry.links.whereType<OpdsLinkImage>().firstOrNull;
    if (imageLink != null) {
      return Padding(
        padding: const EdgeInsets.all(4),
        child: Image.network(
          imageLink.uri.toString(),
          width: 120,
          height: 100,
          errorBuilder: (ctx, _, __) => const SizedBox.shrink(),
        ),
      );
    } else {
      return const SizedBox(
        width: 120,
      );
    }
  }

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: () => _handleCardTap(context),
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
                        entry.title,
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                      if (entry.authors.firstOrNull?.name != null)
                        Text(entry.authors.firstOrNull!.name!)
                      else if (entry.content != null)
                        Text(entry.content!),
                      if (entry.categories.isNotEmpty)
                        Text(
                          entry.categories.map((e) => e.term).join(', '),
                          style: const TextStyle(overflow: TextOverflow.ellipsis),
                          maxLines: 3,
                        ),
                      if (entry.format != null) Text(entry.format!),
                    ],
                  ),
                ),
                _buildThumbnail(),
              ],
            ),
          ),
        ),
      );
}
