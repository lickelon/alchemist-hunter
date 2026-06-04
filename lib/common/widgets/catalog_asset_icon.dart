import 'package:alchemist_hunter/common/themes/app_radius.dart';
import 'package:flutter/material.dart';

class CatalogAssetIcon extends StatelessWidget {
  const CatalogAssetIcon({
    super.key,
    required this.assetPath,
    this.size = 40,
    this.padding = 6,
    this.fallbackIcon = Icons.image_not_supported_outlined,
    this.semanticLabel,
  });

  final String assetPath;
  final double size;
  final double padding;
  final IconData fallbackIcon;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final Widget icon = Container(
      width: size,
      height: size,
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: AppRadius.card,
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

    if (semanticLabel == null) {
      return icon;
    }
    return Semantics(label: semanticLabel, image: true, child: icon);
  }
}
