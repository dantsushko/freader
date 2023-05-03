import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:freader/src/feature/catalogues/opds/model/opds_page.model.dart';
import 'package:freader/src/core/router/router.gr.dart';
import 'package:auto_route/auto_route.dart';

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
    page = OpdsPage(widget.content);
    super.initState();
  }

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    child: Column(
          children: page.entries
              .map((e) => ListTile(
                  title: Text(e.title),
                  subtitle: Text(e.content),
                  onTap: () {
                    print(e.links.first.uri.toString());
                    context.router.push(OpdsRoute(url: widget.uri.replace(path: e.links.first.uri.toString()).toString(), name: e.title));
                  }))
              .toList(),
        ),
  );
}
