import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:freader/src/core/data/database/daos/book_dao.dart';
import 'package:freader/src/core/utils/downloader.dart';
import 'package:freader/src/core/utils/path.dart';
import 'package:freader/src/feature/book/book_reading_screen.dart';
import 'package:freader/src/feature/catalogues/opds/model/opds_entry.model.dart';
import 'package:freader/src/feature/initialization/widget/dependencies_scope.dart';
import 'package:go_router/go_router.dart';

class BookDetailScreen extends StatefulWidget {
  const BookDetailScreen({super.key, this.opdsEntry, this.book})
      : assert(opdsEntry != null || book != null);
  final OpdsEntry? opdsEntry;
  final BookWithMetadata? book;
  @override
  State<BookDetailScreen> createState() => _BookDetailScreenState();
}

class _BookDetailScreenState extends State<BookDetailScreen> {
  Downloader? downloader;
  DownloadStatus? status;
  StreamSubscription<DownloadStatus>? downloadProgressSubscription;
  late BookWithMetadata? book;
  late final OpdsEntry? opdsEntry;
  Future<String?>? _getBookName;
  @override
  void initState() {
    opdsEntry = widget.opdsEntry;

    book = widget.book;
    if (opdsEntry != null && book == null) {
   
      downloader = DependenciesScope.dependenciesOf(context).downloader;
      downloadProgressSubscription = downloader!.downloadProgress.listen((event) {
        setState(() {
          status = event;
        });
      });
      _getBookName = getBookName();
    } else {}

    super.initState();
  }

  @override
  void dispose() {
    downloadProgressSubscription?.cancel();
    super.dispose();
  }

  Future<String?> getBookName() async {
    if (downloader == null) return null;
    final downloadUri = opdsEntry!.download?.uri;
    if (downloadUri == null) return null;
    final uri = await downloader!.getRedirectedUri(downloadUri.toString());
    return getFileName(uri);
  }

  @override
  Widget build(BuildContext context) => PlatformScaffold(
        appBar: PlatformAppBar(
          title: const Text('Книжная карточка'),
          leading: InkWell(
            child: const Icon(
              Icons.close,
              size: 20,
            ),
            onTap: () => context.pop(),
          ),
        ),
        body: FutureBuilder<String?>(
          future: _getBookName,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(
                child: Text(snapshot.error.toString()),
              );
            }
            // if (!snapshot.hasData) {
            //   return const Center(
            //     child: CircularProgressIndicator(),
            //   );
            // }
            return StreamBuilder<BookWithMetadata?>(
              stream: DependenciesScope.dependenciesOf(context)
                  .database
                  .bookDao
                  .watchByFileName(snapshot.data ?? ''),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  book = snapshot.data;
                }
                return Padding(
                  padding: const EdgeInsets.all(8),
                  child: SizedBox(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          if (book != null)
                            BookColumn(bookWithMetadata: book!)
                          else
                            OpdsColumn(
                                opdsEntry: opdsEntry, status: status, downloader: downloader!),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          },
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
            bookWithMetadata.book.cover!,
            fit: BoxFit.contain,
            errorBuilder: (ctx, _, __) => Image.asset(
              'assets/images/book-cover-placeholder.png',
              fit: BoxFit.contain,
            )
          ),
          ElevatedButton(
            onPressed: () {
              context
                ..pop()
                ..pushNamed('book', extra: {'id': bookWithMetadata.book.bid.toString()});
            },
            child: const Text('Читать'),
          ),
          Text(
            bookWithMetadata.metadata.title,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          ),
          const SizedBox(
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
          if (status?.status != DownloadState.downloading)
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
              child: Text('Загружается: ${(status!.percentage * 100).toStringAsFixed(2)}%'),
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
                            Expanded(child: Text(e.name!)),
                          ],
                        ),
                      )
                      .toList(),
                ),
              ),
            ],
          ),
          HtmlWidget(opdsEntry!.content!)
        ],
      );
}
