import 'package:flutter/material.dart';
import 'package:freader/src/feature/catalogues/opds/model/opds_entry.model.dart';
import 'package:freader/src/feature/catalogues/opds/model/opds_page.model.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

import 'opds_card.dart';

class OpdsViewer extends StatefulWidget {
  const OpdsViewer({required this.uri, super.key});
  final Uri uri;
  @override
  State<OpdsViewer> createState() => _OpdsViewerState();
}

class _OpdsViewerState extends State<OpdsViewer> {
  late Uri uri;
  final PagingController<int, OpdsEntry> _pagingController = PagingController(firstPageKey: 0);

  @override
  void initState() {
    uri = widget.uri;
    _pagingController.addPageRequestListener(_fetchPage);
    super.initState();
  }

  @override
  void dispose() {
    _pagingController.dispose();
    super.dispose();
  }

  Future<void> _fetchPage(int pageKey) async {
    try {
      final content = await http.get(uri);
      final page = OpdsPage(content.body, uri);
      final newItems = page.entries;
      final isLastPage = page.next == null;
      if (isLastPage) {
        _pagingController.appendLastPage(newItems);
      } else {
        uri = uri.replace(path: page.next);
        final nextPageKey = pageKey + newItems.length;
        _pagingController.appendPage(newItems, nextPageKey);
      }
    } catch (error) {
      if(mounted){
        _pagingController.error = error;
      }
      
    }
  }

  @override
  Widget build(BuildContext context) => PagedListView<int, OpdsEntry>(
    pagingController: _pagingController,
    shrinkWrap: true,
    builderDelegate: PagedChildBuilderDelegate<OpdsEntry>(
      itemBuilder: (context, item, index) => OpdsCard(
        entry: item,
      ),
    ),
  );
}
