import 'dart:async';
import 'dart:convert';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:freader/src/core/data/database/daos/book_dao.dart';
import 'package:freader/src/core/utils/downloader.dart';
import 'package:freader/src/feature/catalogues/opds/model/opds_entry.model.dart';
import 'package:freader/src/feature/initialization/widget/dependencies_scope.dart';
import 'package:freader/src/feature/reading/widget/reading_screen.dart';

import '../../../core/parser/parser.dart';
import '../../../core/router/router.gr.dart';
import '../book_reading_screen.dart';

class BookDetailScreen extends StatefulWidget {
  const BookDetailScreen({super.key, this.opdsEntry, this.book})
      : assert(opdsEntry != null || book != null);
  final OpdsEntry? opdsEntry;
  final BookWithMetadata? book;
  @override
  State<BookDetailScreen> createState() => _BookDetailScreenState();
}

class _BookDetailScreenState extends State<BookDetailScreen> {
  late final Downloader downloader;
  DownloadStatus? status;
  StreamSubscription<DownloadStatus?>? downloadProgressSubscription;
  late BookWithMetadata? book;
  late final OpdsEntry? opdsEntry;
  @override
  void initState() {
    opdsEntry = widget.opdsEntry;
    book = widget.book;
    if (opdsEntry != null) {
      downloader = DependenciesScope.dependenciesOf(context).downloader;
      downloadProgressSubscription = downloader.downloadProgress.listen((event) {
        setState(() {
          status = event;
        });
      });
    } else {

    }

    super.initState();
  }

  @override
  void dispose() {
    downloadProgressSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => SizedBox(
        height: MediaQuery.of(context).size.height * 0.9,
        width: MediaQuery.of(context).size.width,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: SingleChildScrollView(
            child: Column(
              children: [
                if (book != null) BookColumn(bookWithMetadata: book!) else OpdsColumn(opdsEntry: opdsEntry, status: status, downloader: downloader),
              ],
            ),
          ),
        ),
      );
}

class BookColumn extends StatelessWidget {
  const BookColumn({required this.bookWithMetadata, super.key});
  final BookWithMetadata bookWithMetadata;
  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Image.memory(
            base64Decode(bookWithMetadata.book.cover!.replaceAll(RegExp(r'\s+'), '')),
            fit: BoxFit.contain,
            errorBuilder: (ctx, _, __) => SizedBox.shrink(),
          ),
          ElevatedButton(onPressed: () =>context.router.push(
            
            BookReadingRoute(bookWithMetadata: bookWithMetadata,)), child: Text('Читать')),
          Text(bookWithMetadata.metadata.title,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
          SizedBox(
            height: 10,
          ),
          HtmlWidget(bookWithMetadata.metadata.annotation),
        ],
      );
}

class OpdsColumn extends StatelessWidget {
  const OpdsColumn({
    required this.opdsEntry,
    required this.status,
    required this.downloader,
    super.key,

  });

  final OpdsEntry? opdsEntry;
  final DownloadStatus? status;
  final Downloader downloader;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (opdsEntry!.images.isNotEmpty)
            SizedBox(
              width: 300,
              child: Image.network(
                opdsEntry!.images.first.uri.toString(),
                fit: BoxFit.contain,
                errorBuilder: (ctx, _, __) => const SizedBox.shrink(),
              ),
            )
          else
            const SizedBox.shrink(),
          if (status == null)
            ElevatedButton(
              onPressed: opdsEntry!.download != null
                  ? () async {
                      await downloader.startDownload(opdsEntry!.download!.uri.toString());
                    }
                  : null,
              child: const Text('Скачать'),
            )
          else
            ElevatedButton(
              onPressed: downloader.cancelDownload,
              child: Text('Загружается: ${status!.percentage}%'),
            ),
          Row(
            children: [
              Expanded(
                child: Text(
                  opdsEntry!.title,
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: opdsEntry!.authors
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
          HtmlWidget(opdsEntry!.content)
        ],
      );
}
