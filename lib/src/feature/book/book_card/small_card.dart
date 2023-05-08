import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:freader/src/core/data/database/daos/book_dao.dart';
import 'package:freader/src/core/utils/extensions/context_extension.dart';

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
          onTap: () => showBottomSheet<void>(
              context: context,
              builder: (ctx) => BookDetailScreen(
                    book: entity,
                  )),
          child: Card(
            child: Row(
              children: [
                if (entity.book.cover == null)
                  const Icon(Icons.book)
                else
                  Padding(
                    padding: const EdgeInsets.all(2),
                    child: Image.memory(
                      base64Decode(entity.book.cover!.replaceAll(RegExp(r'\s+'), '')),
                      cacheWidth: 50,
                      cacheHeight: 75,
                      errorBuilder: (ctx, _, __) => Image.asset(
                        'assets/images/book-cover-placeholder.png',
                        cacheWidth: 50,
                        cacheHeight: 75,
                      ),
                    ),
                  ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
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
                Icon(Icons.more_vert)
              ],
            ),
          ),
        ),
      );
}
