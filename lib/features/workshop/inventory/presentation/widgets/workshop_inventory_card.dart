import 'package:alchemist_hunter/app/catalog/icon_asset_paths.dart';
import 'package:alchemist_hunter/common/widgets/app_bottom_sheet.dart';
import 'package:alchemist_hunter/common/widgets/app_empty_state.dart';
import 'package:alchemist_hunter/common/widgets/app_sheet_layout.dart';
import 'package:alchemist_hunter/common/widgets/list_card.dart';
import 'package:alchemist_hunter/features/workshop/crafting/presentation/viewmodels/crafted_inventory_selectors.dart';
import 'package:alchemist_hunter/features/workshop/extraction/presentation/viewmodels/extraction_inventory_selectors.dart';
import 'package:alchemist_hunter/features/workshop/extraction/presentation/viewmodels/workshop_display_labels.dart';
import 'package:alchemist_hunter/features/workshop/presentation/widgets/workshop_resource_detail_dialogs.dart';
import 'package:alchemist_hunter/common/widgets/resource_icon_grid.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class WorkshopInventoryCard extends StatelessWidget {
  const WorkshopInventoryCard({
    super.key,
    required this.materialTypeCount,
    required this.traitTypeCount,
    required this.potionStackCount,
  });

  final int materialTypeCount;
  final int traitTypeCount;
  final int potionStackCount;

  @override
  Widget build(BuildContext context) {
    return ListCard(
      name: '작업실 보관함',
      summary: potionStackCount > 0
          ? '보유 포션 $potionStackCount스택'
          : traitTypeCount > 0
          ? '보유 원소 $traitTypeCount종'
          : materialTypeCount > 0
          ? '보유 재료 $materialTypeCount종'
          : '보관 중인 자원 없음',
      icon: Icons.inventory_2_outlined,
      onTap: () => _showInventorySheet(context),
    );
  }

  void _showInventorySheet(BuildContext context) {
    showAppBottomSheet<void>(
      context: context,
      builder: (BuildContext context) {
        return const WorkshopInventorySheet();
      },
    );
  }
}

class WorkshopInventorySheet extends ConsumerWidget {
  const WorkshopInventorySheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final List<MaterialInventoryView> materials = ref.watch(
      materialInventoryViewsProvider,
    );
    final List<ExtractedTraitInventoryView> traits = ref.watch(
      extractedTraitViewsProvider,
    );
    final List<CraftedPotionStackView> potions = ref.watch(
      craftedPotionStackViewsProvider,
    );

    return DefaultTabController(
      length: 3,
      child: AppSheetLayout(
        title: '작업실 인벤토리',
        header: const TabBar(
          tabs: <Widget>[
            Tab(text: '재료'),
            Tab(text: '원소'),
            Tab(text: '포션'),
          ],
        ),
        body: TabBarView(
          children: <Widget>[
            _InventoryMaterialTab(materials: materials),
            _InventoryTraitTab(traits: traits),
            _InventoryPotionTab(potions: potions),
          ],
        ),
      ),
    );
  }
}

class _InventoryMaterialTab extends StatelessWidget {
  const _InventoryMaterialTab({required this.materials});

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

class _InventoryTraitTab extends StatelessWidget {
  const _InventoryTraitTab({required this.traits});

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

class _InventoryPotionTab extends StatelessWidget {
  const _InventoryPotionTab({required this.potions});

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
