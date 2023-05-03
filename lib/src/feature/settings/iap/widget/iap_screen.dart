import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
const title = 'Встроенные покупки';

@RoutePage()
class IapScreen extends StatelessWidget {
  const IapScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(title: const Text(title), centerTitle: true,),
      body:  const Center(
        child: Text(title),
      ),
    );
}
