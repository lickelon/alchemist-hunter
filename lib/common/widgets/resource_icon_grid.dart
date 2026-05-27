import 'package:alchemist_hunter/common/themes/app_radius.dart';
import 'package:alchemist_hunter/common/themes/app_spacing.dart';
import 'package:alchemist_hunter/common/widgets/catalog_asset_icon.dart';
import 'package:flutter/material.dart';

class ResourceIconGridItem {
  const ResourceIconGridItem({
    required this.assetPath,
    required this.badgeLabel,
    required this.semanticLabel,
    this.tooltipMessage,
    this.key,
    this.onTap,
    this.selected = false,
  });

  final String assetPath;
  final String badgeLabel;
  final String semanticLabel;
  final String? tooltipMessage;
  final Key? key;
  final VoidCallback? onTap;
  final bool selected;
}

class ResourceIconGrid extends StatelessWidget {
  const ResourceIconGrid({
    super.key,
    required this.items,
    this.tileSize = 52,
    this.spacing = AppSpacing.sm,
  });

  final List<ResourceIconGridItem> items;
  final double tileSize;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const SizedBox.shrink();
    }
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final int columnCount = _columnCountForWidth(
          constraints.maxWidth,
          items.length,
        );
        return SizedBox(
          width: double.infinity,
          child: SingleChildScrollView(
            child: Center(
              child: SizedBox(
                width: _gridWidthForColumns(columnCount),
                child: Wrap(
                  alignment: WrapAlignment.start,
                  spacing: spacing,
                  runSpacing: spacing,
                  children: items.map(_buildTile).toList(growable: false),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTile(ResourceIconGridItem item) {
    return _ResourceIconTile(key: item.key, item: item, size: tileSize);
  }

  int _columnCountForWidth(double width, int itemCount) {
    if (itemCount <= 0) {
      return 0;
    }
    if (!width.isFinite || width <= 0) {
      return itemCount;
    }

    final int fittingCount = ((width + spacing) / (tileSize + spacing)).floor();
    if (fittingCount < 1) {
      return 1;
    }
    return fittingCount;
  }

  double _gridWidthForColumns(int columnCount) {
    if (columnCount <= 1) {
      return tileSize;
    }
    return (columnCount * tileSize) + ((columnCount - 1) * spacing);
  }
}

class _ResourceIconTile extends StatelessWidget {
  const _ResourceIconTile({super.key, required this.item, required this.size});

  final ResourceIconGridItem item;
  final double size;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final BorderSide borderSide = BorderSide(
      color: item.selected ? colorScheme.primary : colorScheme.outlineVariant,
      width: item.selected ? 2 : 1,
    );
    final Widget tile = SizedBox.square(
      dimension: size,
      child: Material(
        color: item.selected
            ? colorScheme.primaryContainer
            : colorScheme.surfaceContainerHighest,
        shape: RoundedRectangleBorder(
          side: borderSide,
          borderRadius: AppRadius.card,
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: item.onTap,
          child: Stack(
            children: <Widget>[
              Center(
                child: CatalogAssetIcon(
                  assetPath: item.assetPath,
                  size: size - 8,
                  padding: AppSpacing.sm,
                ),
              ),
              if (item.selected)
                Positioned(
                  right: AppSpacing.xs,
                  top: AppSpacing.xs,
                  child: Icon(
                    Icons.check_circle,
                    size: 16,
                    color: colorScheme.primary,
                  ),
                ),
              Positioned(
                right: AppSpacing.xs,
                bottom: AppSpacing.xs,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    borderRadius: AppRadius.badge,
                    border: Border.all(color: colorScheme.outlineVariant),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.xs,
                      vertical: AppSpacing.xs,
                    ),
                    child: Text(
                      item.badgeLabel,
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    return Tooltip(
      message: item.tooltipMessage ?? item.semanticLabel,
      child: Semantics(
        button: item.onTap != null,
        selected: item.selected,
        label: item.semanticLabel,
        child: tile,
      ),
    );
  }
}
