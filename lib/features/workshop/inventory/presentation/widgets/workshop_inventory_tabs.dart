import 'package:alchemist_hunter/app/catalog/icon_asset_paths.dart';
import 'package:alchemist_hunter/common/widgets/app_empty_state.dart';
import 'package:alchemist_hunter/common/widgets/resource_icon_grid.dart';
import 'package:alchemist_hunter/features/workshop/crafting/presentation/viewmodels/crafted_inventory_selectors.dart';
import 'package:alchemist_hunter/features/workshop/extraction/presentation/viewmodels/extraction_inventory_selectors.dart';
import 'package:alchemist_hunter/features/workshop/extraction/presentation/viewmodels/workshop_display_labels.dart';
import 'package:alchemist_hunter/features/workshop/inventory/presentation/widgets/workshop_resource_detail_dialogs.dart';
import 'package:flutter/material.dart';

class InventoryMaterialTab extends StatelessWidget {
  const InventoryMaterialTab({super.key, required this.materials});

  final List<MaterialInventoryView> materials;

  @override
  Widget build(BuildContext context) {
    if (materials.isEmpty) {
      return const AppEmptyState('보유 재료가 없습니다');
    }
    return ResourceIconGrid(
      items: materials
          .map((MaterialInventoryView entry) {
            return ResourceIconGridItem(
              key: ValueKey<String>('inventory_material_${entry.id}'),
              assetPath: CatalogIconAssetPaths.material(entry.id),
              badgeLabel: 'x${entry.quantity}',
              semanticLabel: '${entry.name} x${entry.quantity}',
              tooltipMessage:
                  '${entry.name} x${entry.quantity}\n${workshopMaterialRarityLabel(entry.rarity)} / 원소 ${entry.traitSummary}',
              onTap: () {
                showDialog<void>(
                  context: context,
                  builder: (BuildContext context) {
                    return WorkshopMaterialResourceDetailDialog(
                      material: entry,
                    );
                  },
                );
              },
            );
          })
          .toList(growable: false),
    );
  }
}

class InventoryTraitTab extends StatelessWidget {
  const InventoryTraitTab({super.key, required this.traits});

  final List<ExtractedTraitInventoryView> traits;

  @override
  Widget build(BuildContext context) {
    if (traits.isEmpty) {
      return const AppEmptyState('보유 추출 원소가 없습니다');
    }
    return ResourceIconGrid(
      items: traits
          .map((ExtractedTraitInventoryView entry) {
            final String amountLabel = workshopTraitAmountLabel(entry.amount);
            return ResourceIconGridItem(
              key: ValueKey<String>('inventory_trait_${entry.id}'),
              assetPath: CatalogIconAssetPaths.element(entry.id),
              badgeLabel: amountLabel,
              semanticLabel: '${entry.name} 원소 $amountLabel',
              tooltipMessage: '${entry.name} 원소 $amountLabel',
              onTap: () {
                showDialog<void>(
                  context: context,
                  builder: (BuildContext context) {
                    return WorkshopTraitResourceDetailDialog(trait: entry);
                  },
                );
              },
            );
          })
          .toList(growable: false),
    );
  }
}

class InventoryPotionTab extends StatelessWidget {
  const InventoryPotionTab({super.key, required this.potions});

  final List<CraftedPotionStackView> potions;

  @override
  Widget build(BuildContext context) {
    if (potions.isEmpty) {
      return const AppEmptyState('보유 포션이 없습니다');
    }
    return ResourceIconGrid(
      items: potions
          .map((CraftedPotionStackView entry) {
            return ResourceIconGridItem(
              key: ValueKey<String>('inventory_potion_${entry.stackKey}'),
              assetPath: CatalogIconAssetPaths.potion(entry.potionId),
              badgeLabel: 'x${entry.quantity}',
              semanticLabel: '${entry.name} x${entry.quantity}',
              tooltipMessage:
                  '${entry.name} x${entry.quantity}\n품질 ${entry.qualityLabel} / 점수 ${entry.scoreLabel}',
              onTap: () {
                showDialog<void>(
                  context: context,
                  builder: (BuildContext context) {
                    return WorkshopPotionResourceDetailDialog(potion: entry);
                  },
                );
              },
            );
          })
          .toList(growable: false),
    );
  }
}
