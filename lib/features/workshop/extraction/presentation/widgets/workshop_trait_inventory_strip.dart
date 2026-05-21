import 'package:alchemist_hunter/app/catalog/icon_asset_paths.dart';
import 'package:alchemist_hunter/common/widgets/catalog_asset_icon.dart';
import 'package:flutter/material.dart';

import 'package:alchemist_hunter/features/workshop/extraction/presentation/viewmodels/extraction_inventory_selectors.dart';
import 'package:alchemist_hunter/features/workshop/extraction/presentation/viewmodels/workshop_display_labels.dart';

class WorkshopTraitInventoryStrip extends StatelessWidget {
  const WorkshopTraitInventoryStrip({super.key, required this.traits});

  final List<ExtractedTraitInventoryView> traits;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 72,
      child: traits.isEmpty
          ? const Center(child: Text('추출된 원소가 없습니다'))
          : ListView.separated(
              scrollDirection: Axis.horizontal,
              itemBuilder: (BuildContext context, int index) {
                final ExtractedTraitInventoryView entry = traits[index];
                return Chip(
                  avatar: CatalogAssetIcon(
                    assetPath: CatalogIconAssetPaths.element(entry.id),
                    size: 24,
                    padding: 2,
                  ),
                  label: Text(
                    '${entry.name} 원소 ${workshopTraitAmountLabel(entry.amount)}',
                  ),
                );
              },
              separatorBuilder: (_, __) => const SizedBox(width: 6),
              itemCount: traits.length,
            ),
    );
  }
}
