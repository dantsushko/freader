import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../book/book_detail/book_detail.dart';
import 'model/opds_entry.model.dart';
import 'model/opds_link.model.dart';

class OpdsCard extends StatelessWidget {
  const OpdsCard({
    required this.entry,
    super.key,
  });

  final OpdsEntry entry;

  void _handleCardTap(BuildContext context) {
    final catalogLink =
        entry.links.firstWhereOrNull((link) => link is OpdsLinkCatalog) as OpdsLinkCatalog?;
    if (!entry.id!.contains(':book:')) {
      context.pushNamed('opds',
          extra: {'url': catalogLink!.uri.toString(), 'name': entry.title});
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
      return Image.network(
        
        imageLink.uri.toString(),
        height: 110,
        width: 50,
        fit: BoxFit.contain,
        errorBuilder: (ctx, _, __) => const SizedBox.shrink(),
      );
    } else {
      return const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: () => _handleCardTap(context),
        child: SizedBox(
          height:entry.categories.isNotEmpty ?110 : 70,
          child: Card(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    child: Column(
                      
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          entry.title,
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                        if (entry.authors.firstOrNull?.name != null)
                          Text(entry.authors.firstOrNull!.name!,  style: const TextStyle(fontSize: 12),
                          )
                        else if (entry.content != null)
                          Text(entry.content!,  overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12),),
                        if (entry.categories.isNotEmpty)
                          Expanded(
                            child: Text(
                              entry.categories.map((e) => e.term).join(', '),
                              style: const TextStyle(overflow: TextOverflow.ellipsis, fontSize: 12),
                              maxLines: 2,
                            ),
                          ),
                        if (entry.format != null) Text(entry.format!,
                            style: const TextStyle(fontSize: 12),
                          ),
                      ],
                    ),
                  ),
                ),
                _buildThumbnail(),
              ],
            ),
          ),
        ),
      );
}
