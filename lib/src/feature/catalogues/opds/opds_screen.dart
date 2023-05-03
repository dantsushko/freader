import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
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
  Future<String> getContent() async {
    final content = await http.get(Uri.parse(widget.url));
    return content.body;
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text(widget.name),
          centerTitle: true,
        ),
        body: FutureBuilder<String>(
          future: getContent(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
            return OpdsViewer(content: snapshot.data!, uri: Uri.parse(widget.url));
          },
        ),
      );
}
