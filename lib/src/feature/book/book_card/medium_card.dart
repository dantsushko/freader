import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:freader/src/core/data/database/daos/book_dao.dart';
import 'package:freader/src/core/utils/dominant_color.dart';
import 'package:freader/src/core/utils/extensions/context_extension.dart';

import '../book_detail/book_detail.dart';

class MediumCard extends StatelessWidget {
  const MediumCard({
    required this.entity,
    super.key,
  });

  final BookWithMetadata entity;

  @override
  Widget build(BuildContext context) => SizedBox(
        height: 120,
        child: InkWell(
          onTap: () => showModalBottomSheet<void>(
            context: context,
            useRootNavigator: true,
            isScrollControlled: true,
            builder: (ctx) => SizedBox(
              height: MediaQuery.of(context).size.height * 0.9,
              child: BookDetailScreen(
                book: entity,
              ),
            ),
          ),
          child: DecoratedBox(
            decoration: BoxDecoration(
                gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(entity.book.coverDominantColor1),
                Color(entity.book.coverDominantColor2),
              ],
            )),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Flexible(
                          child: Text(
                            entity.metadata.title,
                            style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w400,
                                color: Color(entity.book.coverFontColor)),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                       
                        Row(
                          children: [
                            Text(
                              entity.book.format,
                              style: TextStyle(color: Color(entity.book.coverFontColor)),
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            Icon(
                              Icons.circle,
                              size: 5,
                              color: Color(entity.book.coverFontColor),
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            Text(entity.book.filesize.prettyBytes,
                                style: TextStyle(color: Color(entity.book.coverFontColor))),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
                                 Padding(
                                   padding: const EdgeInsets.symmetric(horizontal: 14.0),
                                   child: Image.memory(
                                     entity.book.cover ?? Uint8List(0),
                                     width: 50,
                                     height: 75,
                                     errorBuilder: (ctx, _, __) => Image.asset(
                      width: 50,
                      height: 75,
                                       'assets/images/book-cover-placeholder.png',
                                     ),
                                   ),
                                 ),
              ],
            ),
          ),
        ),
      );
}
