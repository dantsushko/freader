import 'package:flutter/material.dart';

class CatalogueIcon extends StatefulWidget {
  const CatalogueIcon({
    required this.name,
    this.icon,
    super.key,
  });
  final String name;
  final IconData? icon;

  @override
  State<CatalogueIcon> createState() => _CatalogueIconState();
}

class _CatalogueIconState extends State<CatalogueIcon> {
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          children: [
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: Theme.of(context).textTheme.bodyLarge!.color,
                shape: BoxShape.circle,
              ),
              child:  Icon(
                widget.icon ?? Icons.camera,
                color: Theme.of(context).iconTheme.color,
                size: 50,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              widget.name,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
}

class AddCatalogueIcon extends StatelessWidget {
  const AddCatalogueIcon({
    super.key,
  });
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          children: [
            Container(
              width: 70,
              height: 70,
              decoration:  BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                shape: BoxShape.circle,
              ),
              child:  Icon(
                Icons.add,
                color: Theme.of(context).colorScheme.background,
                size: 40,
              ),
            ),
          ],
        ),
      );
}
