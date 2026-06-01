import 'package:alchemist_hunter/app/catalog/icon_asset_paths.dart';
import 'package:alchemist_hunter/common/widgets/resource_icon_grid.dart';
import 'package:alchemist_hunter/features/workshop/domain/models.dart';
import 'package:alchemist_hunter/features/workshop/extraction/presentation/viewmodels/workshop_display_labels.dart';
import 'package:flutter/material.dart';

class WorkshopBrewExperimentTraitGrid extends StatelessWidget {
  const WorkshopBrewExperimentTraitGrid({
    super.key,
    required this.ownedTraits,
    required this.traitMap,
    required this.selectedTraitIds,
    required this.onTraitSelected,
  });

  final List<MapEntry<String, double>> ownedTraits;
  final Map<String, TraitUnit> traitMap;
  final List<String> selectedTraitIds;
  final ValueChanged<String> onTraitSelected;

  @override
  Widget build(BuildContext context) {
    return ResourceIconGrid(
      items: ownedTraits
          .map((MapEntry<String, double> entry) {
            final TraitUnit? trait = traitMap[entry.key];
            final String amountLabel = workshopTraitAmountLabel(entry.value);
            return ResourceIconGridItem(
              key: ValueKey<String>('brew_experiment_trait_${entry.key}'),
              assetPath: CatalogIconAssetPaths.element(entry.key),
              badgeLabel: amountLabel,
              semanticLabel: '${trait?.name ?? entry.key} 원소 $amountLabel',
              tooltipMessage: '${trait?.name ?? entry.key} 원소 $amountLabel',
              selected: selectedTraitIds.contains(entry.key),
              onTap: () => onTraitSelected(entry.key),
            );
          })
          .toList(growable: false),
    );
  }
}
