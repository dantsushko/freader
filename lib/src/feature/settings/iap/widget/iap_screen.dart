import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
const title = 'Встроенные покупки';

@RoutePage()
class IapScreen extends StatelessWidget {
  const IapScreen({super.key});

  @override
  Widget build(BuildContext context) => PlatformScaffold(
      appBar: PlatformAppBar(title: const Text(title)),
      body:  const Center(
        child: Text(title),
      ),
    );
}
