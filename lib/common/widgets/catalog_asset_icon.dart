import 'package:flutter/material.dart';

class CatalogAssetIcon extends StatelessWidget {
  const CatalogAssetIcon({
    super.key,
    required this.assetPath,
    this.size = 40,
    this.padding = 6,
    this.fallbackIcon = Icons.image_not_supported_outlined,
  });

  final String assetPath;
  final double size;
  final double padding;
  final IconData fallbackIcon;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    return Container(
      width: size,
      height: size,
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Image.asset(
        assetPath,
        fit: BoxFit.contain,
        filterQuality: FilterQuality.none,
        isAntiAlias: false,
        errorBuilder: (BuildContext context, Object error, StackTrace? stack) {
          return Icon(
            fallbackIcon,
            size: size * 0.55,
            color: colorScheme.onSurfaceVariant,
          );
        },
      ),
    );
  }
}
