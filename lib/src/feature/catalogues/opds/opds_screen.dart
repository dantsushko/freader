import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:freader/src/feature/catalogues/opds/opds_viewer.dart';
import 'package:http/http.dart' as http;

@RoutePage()
class OpdsScreen extends StatefulWidget {
  const OpdsScreen({
    required this.url,
    required this.name,
    super.key,
  });
  final String url;
  final String name;
  @override
  State<OpdsScreen> createState() => _OpdsScreenState();
}

class _OpdsScreenState extends State<OpdsScreen> {


  @override
  Widget build(BuildContext context) => PlatformScaffold(
        appBar: PlatformAppBar(
          title: Text(widget.name),
        ),
        body:  OpdsViewer( uri: Uri.parse(widget.url)),
      );
}
