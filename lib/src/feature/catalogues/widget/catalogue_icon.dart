import 'package:flutter/material.dart';

class CatalogueIcon extends StatelessWidget {
  const CatalogueIcon({
    required this.name,
    super.key,
  });
  final String name;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: Colors.brown[800],
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.camera,
                color: Colors.white,
                size: 32,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              name,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.black87,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
}

class AddCatalogueIcon extends StatelessWidget{
  const AddCatalogueIcon({
    super.key,
  });
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.add,
                color: Colors.white,
                size: 32,
              ),
            ),
          ],
        ),
      );
}
