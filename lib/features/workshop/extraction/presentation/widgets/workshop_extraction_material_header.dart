import 'package:alchemist_hunter/app/catalog/icon_asset_paths.dart';
import 'package:alchemist_hunter/common/themes/app_spacing.dart';
import 'package:alchemist_hunter/common/widgets/catalog_asset_icon.dart';
import 'package:flutter/material.dart';

class WorkshopExtractionMaterialHeader extends StatelessWidget {
  const WorkshopExtractionMaterialHeader({
    super.key,
    required this.materialId,
    required this.ownedQuantity,
  });

  final String materialId;
  final int ownedQuantity;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        CatalogAssetIcon(assetPath: CatalogIconAssetPaths.material(materialId)),
        const SizedBox(width: AppSpacing.md),
        Text('보유 $ownedQuantity개'),
      ],
    );
  }
}
