import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
@RoutePage()
class ReadingScreen extends StatelessWidget {
  const ReadingScreen({super.key});

  @override
  Widget build(BuildContext context) => SafeArea(
    child: Scaffold(
          body: CustomScrollView(
            slivers: <Widget>[
              SliverAppBar(
                snap: true,
                floating: true,
                expandedHeight: 40,
                
                title: const Text('Читаю'),
                centerTitle: true,
                actions: [
                  IconButton(
                    icon: const Icon(Icons.list_alt_rounded),
                    onPressed: () {},
                  ),
                ],
              ),
              SliverGrid.count(
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
            ],
          ),
        ),
  );
}
