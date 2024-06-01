import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:freader/src/feature/catalogues/opds/opds_viewer.dart';
import 'package:go_router/go_router.dart';

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
  final controller = TextEditingController();
  @override
  Widget build(BuildContext context) => PlatformScaffold(
        appBar: PlatformAppBar(
          title: Text(widget.name),
          trailingActions: [
            IconButton(
                onPressed: () => showAdaptiveDialog<void>(
                    builder: (context) => AlertDialog(
                          content: TextField(
                            controller: controller,
                            decoration: InputDecoration(
                              hintText: 'Поиск...',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                          actions: [
                            ElevatedButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                                final searchUri = Uri.parse(widget.url).replace(
                                  path: '/opds/search',
                                  queryParameters: {'searchTerm': controller.text},
                                );
                                print(searchUri.toString());
                                context.pushNamed('opds', extra: {
                                  'url': searchUri.toString(),
                                  'name': 'Поиск: ${controller.text}'
                                });
                              },
                              child: const Text('Поиск'),
                            )
                          ]),
                    context: context),
                icon: const Icon(Icons.search)),
          ],
        ),
        body: OpdsViewer(uri: Uri.parse(widget.url)),
      );
}




//  TextFormField(
//               controller: controller,
//               decoration: InputDecoration(
//                 hintText: 'Поиск...',
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(10),
//                 ),
//                 suffixIcon: IconButton(
//                   icon: const Icon(Icons.search),
//                   onPressed: () async {
//                     final searchUri = widget.uri.replace(
//                       path: '/opds/search',
//                       queryParameters: {'searchTerm': controller.text},
//                     );
//                     print(searchUri.toString());
//                     context.pushNamed('opds',
//                         extra: {'url': searchUri.toString(), 'name': 'Поиск: ${controller.text}'});
//                   },
//                 ),
//               ),
//             )
