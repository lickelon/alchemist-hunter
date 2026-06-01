import 'package:alchemist_hunter/app/catalog/icon_asset_paths.dart';
import 'package:alchemist_hunter/common/themes/app_spacing.dart';
import 'package:alchemist_hunter/common/widgets/catalog_asset_icon.dart';
import 'package:alchemist_hunter/features/workshop/extraction/presentation/viewmodels/extraction_detail_selector.dart';
import 'package:alchemist_hunter/features/workshop/extraction/presentation/viewmodels/workshop_display_labels.dart';
import 'package:flutter/material.dart';

class WorkshopExtractionTraitSelector extends StatelessWidget {
  const WorkshopExtractionTraitSelector({
    super.key,
    required this.traits,
    required this.selectedTraits,
    required this.onSelectionChanged,
  });

  final List<ExtractionTraitOptionView> traits;
  final Set<String> selectedTraits;
  final void Function(String traitId, bool selected) onSelectionChanged;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.md,
      runSpacing: AppSpacing.md,
      children: traits.map((ExtractionTraitOptionView trait) {
        return FilterChip(
          avatar: CatalogAssetIcon(
            assetPath: CatalogIconAssetPaths.element(trait.id),
            size: 24,
            padding: 2,
          ),
          label: Text(
            '${trait.name} 원소 ${workshopTraitAmountLabel(trait.amount)}',
          ),
          selected: selectedTraits.contains(trait.id),
          onSelected: (bool selected) {
            onSelectionChanged(trait.id, selected);
          },
        );
      }).toList(),
    );
  }
}
