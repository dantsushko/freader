import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:freader/src/feature/catalogues/opds/model/opds_entry.model.dart';

import 'download_button.dart';
import 'model/opds_link.model.dart';
import 'util.dart';

class BookDetailScreen extends StatefulWidget {
  const BookDetailScreen({super.key, this.opdsEntry});
  final OpdsEntry? opdsEntry;
  @override
  State<BookDetailScreen> createState() => _BookDetailScreenState();
}

class _BookDetailScreenState extends State<BookDetailScreen> {
  @override
  Widget build(BuildContext context) => SizedBox(
        height: MediaQuery.of(context).size.height * 0.8,
        width: MediaQuery.of(context).size.width,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: SingleChildScrollView(
            child: widget.opdsEntry != null
                ? Column(
                    children: [
                      if (widget.opdsEntry!.links.whereType<OpdsLinkImage>().isNotEmpty)
                        Image.network(
                          widget.opdsEntry!
                              .getUri(widget.opdsEntry!.links.whereType<OpdsLinkImage>().first.uri),
                          fit: BoxFit.contain,
                          errorBuilder: (ctx, _, __) => const SizedBox.shrink(),
                        )
                      else
                        const SizedBox.shrink(),
                      Row(
                        children: [
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 26.0),
                              child: DownloadButton(links: widget.opdsEntry!.links
            .whereType<OpdsLinkDownload>()),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Expanded(
                              child: Text(
                            widget.opdsEntry!.title,
                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                          )),
                        ],
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: widget.opdsEntry!.authors
                                  .map(
                                    (e) => Row(
                                      children: [
                                        Expanded(child: Text(e.name)),
                                      ],
                                    ),
                                  )
                                  .toList(),
                            ),
                          ),
                        ],
                      ),
                      HtmlWidget(widget.opdsEntry!.content)
                    ],
                  )
                : const Placeholder(),
          ),
        ),
      );
}

