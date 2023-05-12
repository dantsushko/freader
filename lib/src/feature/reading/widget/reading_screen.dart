import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
@RoutePage()
class ReadingScreen extends StatelessWidget {
  const ReadingScreen({super.key});

  @override
  Widget build(BuildContext context) => PlatformScaffold(
    appBar: PlatformAppBar(title: const Text('Читаю')),
        body: GridView.count(
              crossAxisCount: 2,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              children: [
                Card(
                  color: Colors.blue[200],
                  child: Container(),
                ),
                Card(
                  color: Colors.blue[200],
                  child: Container(),
                ),
                Card(
                  color: Colors.blue[200],
                  child: Container(),
                ),
                Card(
                  color: Colors.blue[200],
                  child: Container(),
                ),
                Card(
                  color: Colors.blue[200],
                  child: Container(),
                ),
                Card(
                  color: Colors.blue[400],
                  child: Container(),
                ),
                Card(
                  color: Colors.blue[600],
                  child: Container(),
                ),
                Card(
                  color: Colors.blue[100],
                  child: Container(),
                ),
              ],
            ),
          
      
      );
}
