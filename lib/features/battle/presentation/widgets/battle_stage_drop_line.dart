import 'package:alchemist_hunter/app/catalog/icon_asset_paths.dart';
import 'package:alchemist_hunter/common/themes/app_spacing.dart';
import 'package:alchemist_hunter/common/widgets/catalog_asset_icon.dart';
import 'package:alchemist_hunter/features/battle/presentation/viewmodels/battle_drop_selectors.dart';
import 'package:flutter/material.dart';

class BattleStageDropLine extends StatelessWidget {
  const BattleStageDropLine({super.key, required this.drop});

  final BattleDropChanceView drop;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        CatalogAssetIcon(
          assetPath: CatalogIconAssetPaths.material(drop.materialId),
          size: 28,
          padding: 3,
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Text(
            '${drop.materialName} ${drop.quantityLabel} / ${drop.chanceLabel}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
      ],
    );
  }
}
