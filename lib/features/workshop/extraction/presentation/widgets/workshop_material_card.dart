import 'package:alchemist_hunter/app/catalog/icon_asset_paths.dart';
import 'package:alchemist_hunter/common/widgets/app_bottom_sheet.dart';
import 'package:alchemist_hunter/common/widgets/app_sheet_layout.dart';
import 'package:alchemist_hunter/common/widgets/list_card.dart';
import 'package:alchemist_hunter/features/workshop/extraction/presentation/viewmodels/extraction_inventory_selectors.dart';
import 'package:alchemist_hunter/features/workshop/extraction/presentation/viewmodels/workshop_display_labels.dart';
import 'package:alchemist_hunter/features/workshop/presentation/widgets/workshop_resource_detail_dialogs.dart';
import 'package:alchemist_hunter/features/workshop/presentation/widgets/workshop_resource_icon_grid.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class WorkshopMaterialCard extends StatelessWidget {
  const WorkshopMaterialCard({
    super.key,
    required this.materialTypeCount,
    required this.totalCount,
  });

  final int materialTypeCount;
  final int totalCount;

  @override
  Widget build(BuildContext context) {
    return ListCard(
      name: '재료',
      summary: materialTypeCount == 0
          ? '보유 재료 없음'
          : '보유 재료 $materialTypeCount종',
      icon: Icons.inventory_2_outlined,
      onTap: () => _showItemList(context),
    );
  }

  void _showItemList(BuildContext context) {
    showAppBottomSheet<void>(
      context: context,
      builder: (BuildContext context) {
        return const _WorkshopMaterialSheet();
      },
    );
  }
}

class _WorkshopMaterialSheet extends ConsumerWidget {
  const _WorkshopMaterialSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final List<MaterialInventoryView> materials = ref.watch(
      materialInventoryViewsProvider,
    );

    return AppSheetLayout(
      title: '보유 재료 목록',
      body: materials.isEmpty
          ? const Center(child: Text('보유 재료가 없습니다'))
          : WorkshopResourceIconGrid(
              items: materials
                  .map((MaterialInventoryView entry) {
                    return WorkshopResourceIconGridItem(
                      key: ValueKey<String>('material_inventory_${entry.id}'),
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
            ),
    );
  }
}
