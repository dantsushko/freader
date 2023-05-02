import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

@RoutePage()
class CataloguesScreen extends StatelessWidget {
  const CataloguesScreen({super.key});

  @override
  Widget build(BuildContext context) => const Center(
      child: Text('Catalogues'),
    );
}
