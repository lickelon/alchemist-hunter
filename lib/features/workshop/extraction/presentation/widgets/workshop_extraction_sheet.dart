import 'package:alchemist_hunter/app/catalog/icon_asset_paths.dart';
import 'package:alchemist_hunter/common/themes/app_spacing.dart';
import 'package:alchemist_hunter/common/widgets/app_sheet_layout.dart';
import 'package:alchemist_hunter/common/widgets/catalog_asset_icon.dart';
import 'package:alchemist_hunter/features/workshop/extraction/presentation/viewmodels/extraction_inventory_selectors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'workshop_material_extraction_detail.dart';

class WorkshopExtractionSheet extends ConsumerWidget {
  const WorkshopExtractionSheet({super.key});

  static const double _tileSize = 52;
  static const double _gridSpacing = AppSpacing.sm;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final List<MaterialInventoryView> materials = ref.watch(
      materialInventoryViewsProvider,
    );

    return AppSheetLayout(
      title: '추출',
      header: const Text(
        '재료 선택',
        style: TextStyle(fontWeight: FontWeight.w700),
      ),
      body: materials.isEmpty
          ? const Center(child: Text('추출 가능한 재료가 없습니다'))
          : LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                final int columnCount = _columnCountForWidth(
                  constraints.maxWidth,
                  materials.length,
                );
                return SizedBox(
                  width: double.infinity,
                  child: SingleChildScrollView(
                    child: Center(
                      child: SizedBox(
                        width: _gridWidthForColumns(columnCount),
                        child: Wrap(
                          alignment: WrapAlignment.start,
                          spacing: _gridSpacing,
                          runSpacing: _gridSpacing,
                          children: materials
                              .map((MaterialInventoryView material) {
                                return _ExtractionMaterialTile(
                                  material: material,
                                  size: _tileSize,
                                );
                              })
                              .toList(growable: false),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }

  static int _columnCountForWidth(double width, int itemCount) {
    if (itemCount <= 0) {
      return 0;
    }
    if (!width.isFinite || width <= 0) {
      return itemCount;
    }

    final int fittingCount =
        ((width + _gridSpacing) / (_tileSize + _gridSpacing)).floor();
    if (fittingCount < 1) {
      return 1;
    }
    if (fittingCount > itemCount) {
      return itemCount;
    }
    return fittingCount;
  }

  static double _gridWidthForColumns(int columnCount) {
    if (columnCount <= 1) {
      return _tileSize;
    }
    return (columnCount * _tileSize) + ((columnCount - 1) * _gridSpacing);
  }
}

class _ExtractionMaterialTile extends StatelessWidget {
  const _ExtractionMaterialTile({required this.material, required this.size});

  final MaterialInventoryView material;
  final double size;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    return SizedBox.square(
      dimension: size,
      child: Tooltip(
        message:
            '${material.name} x${material.quantity}\n${material.traitSummary}',
        child: Semantics(
          button: true,
          label: '${material.name} x${material.quantity}',
          child: InkWell(
            key: ValueKey<String>('extraction_material_${material.id}'),
            borderRadius: BorderRadius.circular(8),
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
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
                border: Border.all(color: colorScheme.outlineVariant),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Stack(
                children: <Widget>[
                  Center(
                    child: CatalogAssetIcon(
                      assetPath: CatalogIconAssetPaths.material(material.id),
                      size: 44,
                      padding: AppSpacing.sm,
                    ),
                  ),
                  Positioned(
                    right: AppSpacing.xs,
                    bottom: AppSpacing.xs,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: colorScheme.surface,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: colorScheme.outlineVariant),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.xs,
                          vertical: 1,
                        ),
                        child: Text(
                          'x${material.quantity}',
                          style: Theme.of(context).textTheme.labelSmall,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
