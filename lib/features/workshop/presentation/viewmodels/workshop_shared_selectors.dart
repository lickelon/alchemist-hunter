import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:alchemist_hunter/app/session/app_session.dart';
import 'package:alchemist_hunter/features/workshop/domain/models.dart';
import 'package:alchemist_hunter/features/workshop/workshop_catalog.dart';
import 'package:alchemist_hunter/features/workshop/presentation/viewmodels/workshop_service_providers.dart';
import 'package:alchemist_hunter/features/workshop/presentation/viewmodels/crafted_inventory_selectors.dart';
import 'package:alchemist_hunter/features/workshop/presentation/viewmodels/extraction/extraction_inventory_selectors.dart';

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

final Provider<int> workshopEssenceProvider = Provider<int>((Ref ref) {
  return ref.watch(
    sessionControllerProvider.select(
      (SessionState state) => state.player.essence,
    ),
  );
});

final Provider<int> workshopArcaneDustProvider = Provider<int>((Ref ref) {
  return ref.watch(
    sessionControllerProvider.select(
      (SessionState state) => state.player.arcaneDust,
    ),
  );
});

final Provider<int> workshopSkillNodeCountProvider = Provider<int>((Ref ref) {
  return ref.watch(
    workshopSkillNodesProvider.select(
      (List<WorkshopSkillNode> nodes) => nodes.length,
    ),
  );
});

final Provider<int> workshopUnlockedSkillNodeCountProvider = Provider<int>((
  Ref ref,
) {
  return ref.watch(
    sessionControllerProvider.select(
      (SessionState state) => state.workshop.skillTree.unlockedNodes.length,
    ),
  );
});

final Provider<int> workshopQueueCapacityProvider = Provider<int>((Ref ref) {
  final SessionState state = ref.watch(sessionControllerProvider);
  return ref
      .watch(workshopSkillTreeServiceProvider)
      .craftQueueCapacity(state, ref.watch(workshopSkillNodesProvider)) +
      ref.watch(workshopSupportServiceProvider).craftQueueCapacityBonus(state);
});

final Provider<double> workshopExtractionYieldBonusRateProvider =
    Provider<double>((Ref ref) {
      final SessionState state = ref.watch(sessionControllerProvider);
      return ref
              .watch(workshopSkillTreeServiceProvider)
              .extractionYieldBonusRate(state, ref.watch(workshopSkillNodesProvider)) +
          ref.watch(workshopSupportServiceProvider).extractionYieldBonusRate(state);
    });

final Provider<double> workshopEnchantPotencyBonusRateProvider =
    Provider<double>((Ref ref) {
      final SessionState state = ref.watch(sessionControllerProvider);
      return ref
              .watch(workshopSkillTreeServiceProvider)
              .enchantPotencyBonusRate(state, ref.watch(workshopSkillNodesProvider)) +
          ref.watch(workshopSupportServiceProvider).enchantPotencyBonusRate(state);
    });

final Provider<List<String>> recentLogsProvider = Provider<List<String>>((
  Ref ref,
) {
  return ref.watch(
    sessionControllerProvider.select(
      (SessionState state) => state.workshop.logs,
      ),
  );
});

final Provider<WorkshopDashboardSummaryView> workshopDashboardSummaryProvider =
    Provider<WorkshopDashboardSummaryView>((Ref ref) {
      final int essence = ref.watch(workshopEssenceProvider);
      final int arcaneDust = ref.watch(workshopArcaneDustProvider);
      return WorkshopDashboardSummaryView(
        essenceLabel: 'Essence $essence',
        arcaneDustLabel: 'ArcaneDust $arcaneDust',
      );
    });

final Provider<WorkshopInventorySummaryView> workshopInventorySummaryProvider =
    Provider<WorkshopInventorySummaryView>((Ref ref) {
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
            '재료 ${materials.length}종 / 특성 ${traits.length}종 / 포션 ${potionStacks.length}스택',
      );
    });
