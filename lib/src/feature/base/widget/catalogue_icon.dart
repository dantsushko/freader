import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

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
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: Theme.of(context).textTheme.bodyLarge!.color,
                shape: BoxShape.circle,
              ),
              child:  Icon(
                widget.icon ?? Icons.camera,
                color: Theme.of(context).iconTheme.color,
                size: 40,
              ),
            ),
            const SizedBox(height: 8),
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
              width: 64,
              height: 64,
              decoration:  BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                shape: BoxShape.circle,
              ),
              child:  Icon(
                Icons.add,
                color: Theme.of(context).colorScheme.background,
                size: 32,
              ),
            ),
          ],
        ),
      );
}
