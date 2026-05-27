import 'package:alchemist_hunter/app/catalog/icon_asset_paths.dart';
import 'package:alchemist_hunter/common/themes/app_text_styles.dart';
import 'package:alchemist_hunter/common/widgets/app_sheet_layout.dart';
import 'package:alchemist_hunter/features/workshop/extraction/presentation/viewmodels/extraction_inventory_selectors.dart';
import 'package:alchemist_hunter/common/widgets/resource_icon_grid.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'workshop_material_extraction_detail.dart';

class WorkshopExtractionSheet extends ConsumerWidget {
  const WorkshopExtractionSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final List<MaterialInventoryView> materials = ref.watch(
      materialInventoryViewsProvider,
    );

    return AppSheetLayout(
      title: '추출',
      header: Text('재료 선택', style: AppTextStyles.of(context).subsectionTitle),
      body: materials.isEmpty
          ? const Center(child: Text('추출 가능한 재료가 없습니다'))
          : ResourceIconGrid(
              items: materials
                  .map((MaterialInventoryView material) {
                    return ResourceIconGridItem(
                      key: ValueKey<String>(
                        'extraction_material_${material.id}',
                      ),
                      assetPath: CatalogIconAssetPaths.material(material.id),
                      badgeLabel: 'x${material.quantity}',
                      semanticLabel: '${material.name} x${material.quantity}',
                      tooltipMessage:
                          '${material.name} x${material.quantity}\n${material.traitSummary}',
                      onTap: () {
                        showDialog<void>(
                          context: context,
                          builder: (BuildContext context) {
                            return WorkshopMaterialExtractionDetailDialog(
                              materialId: material.id,
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
