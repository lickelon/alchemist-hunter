import 'package:alchemist_hunter/features/workshop/crafting/presentation/viewmodels/crafted_inventory_selectors.dart';
import 'package:alchemist_hunter/features/workshop/extraction/presentation/viewmodels/extraction_inventory_selectors.dart';
import 'package:alchemist_hunter/features/workshop/shared/presentation/viewmodels/workshop_resource_selectors.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class WorkshopDashboardSummaryView {
  const WorkshopDashboardSummaryView({
    required this.essenceLabel,
    required this.arcaneDustLabel,
  });

  final String essenceLabel;
  final String arcaneDustLabel;
}

class WorkshopInventorySummaryView {
  const WorkshopInventorySummaryView({
    required this.materialTypeCount,
    required this.totalMaterialCount,
    required this.traitTypeCount,
    required this.potionStackCount,
    required this.description,
  });

  final int materialTypeCount;
  final int totalMaterialCount;
  final int traitTypeCount;
  final int potionStackCount;
  final String description;
}

final Provider<WorkshopDashboardSummaryView> workshopDashboardSummaryProvider =
    Provider<WorkshopDashboardSummaryView>((Ref ref) {
      final int essence = ref.watch(workshopEssenceProvider);
      final int arcaneDust = ref.watch(workshopArcaneDustProvider);
      return WorkshopDashboardSummaryView(
        essenceLabel: '정수 $essence',
        arcaneDustLabel: '신비 $arcaneDust',
      );
    });

final Provider<WorkshopInventorySummaryView>
workshopInventorySummaryProvider = Provider<WorkshopInventorySummaryView>((
  Ref ref,
) {
  final List<MapEntry<String, int>> materials = ref.watch(
    sortedMaterialInventoryProvider,
  );
  final List<ExtractedTraitInventoryView> traits = ref.watch(
    extractedTraitViewsProvider,
  );
  final List<CraftedPotionStackView> potionStacks = ref.watch(
    craftedPotionStackViewsProvider,
  );
  final int totalMaterialCount = materials.fold<int>(
    0,
    (int total, MapEntry<String, int> entry) => total + entry.value,
  );
  return WorkshopInventorySummaryView(
    materialTypeCount: materials.length,
    totalMaterialCount: totalMaterialCount,
    traitTypeCount: traits.length,
    potionStackCount: potionStacks.length,
    description:
        '재료 ${materials.length}종, 원소 ${traits.length}종, 포션 ${potionStacks.length}스택',
  );
});
