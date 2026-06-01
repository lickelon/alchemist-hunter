import 'package:alchemist_hunter/app/catalog/icon_asset_paths.dart';
import 'package:alchemist_hunter/common/widgets/catalog_asset_icon.dart';
import 'package:alchemist_hunter/features/workshop/crafting/presentation/viewmodels/craft_queue_option_selectors.dart';
import 'package:flutter/material.dart';

class WorkshopMaterialCraftCostChip extends StatelessWidget {
  const WorkshopMaterialCraftCostChip({
    super.key,
    required this.cost,
    required this.requiredQuantity,
    required this.enough,
  });

  final WorkshopMaterialCraftCostView cost;
  final int requiredQuantity;
  final bool enough;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    return InputChip(
      avatar: CatalogAssetIcon(
        assetPath: CatalogIconAssetPaths.material(cost.materialId),
        size: 28,
        padding: 3,
        fallbackIcon: Icons.auto_fix_high_outlined,
      ),
      label: Text('${cost.name} ${cost.ownedQuantity}/$requiredQuantity'),
      side: BorderSide(
        color: enough ? colorScheme.outlineVariant : colorScheme.error,
      ),
    );
  }
}
