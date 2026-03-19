import 'package:alchemist_hunter/features/workshop/presentation/workshop_providers.dart';
import 'package:alchemist_hunter/features/workshop/presentation/widgets/workshop_sections.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class WorkshopScreen extends ConsumerWidget {
  const WorkshopScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final WorkshopDashboardSummaryView dashboard = ref.watch(
      workshopDashboardSummaryProvider,
    );
    final WorkshopQueueCardSummaryView queueSummary = ref.watch(
      workshopQueueCardSummaryProvider,
    );
    final WorkshopCraftMenuSummaryView craftSummary = ref.watch(
      workshopCraftMenuSummaryProvider,
    );
    final WorkshopInventorySummaryView inventorySummary = ref.watch(
      workshopInventorySummaryProvider,
    );
    final int unlockedSkillNodes = ref.watch(workshopUnlockedSkillNodeCountProvider);
    final int totalSkillNodes = ref.watch(workshopSkillNodeCountProvider);
    final int homunculusCount = ref.watch(workshopHomunculusCountProvider);
    final int supportAssignedCount = ref.watch(workshopSupportAssignedCountProvider);
    final int supportSlotLimit = ref.watch(workshopSupportSlotLimitProvider);
    final String supportSummary = ref.watch(workshopSupportSummaryProvider);
    final List<ExtractedTraitInventoryView> extractedTraits = ref.watch(extractedTraitViewsProvider);
    final List<HomunculusHatchRecipeView> hatchRecipes = ref.watch(
      homunculusHatchRecipeViewsProvider,
    );
    final List<MapEntry<String, int>> materials = ref.watch(sortedMaterialInventoryProvider);
    final Map<String, int> craftedPotionStacks = ref.watch(craftedPotionStacksProvider);
    final List<EnchantEquipmentView> enchantEquipmentViews = ref.watch(
      enchantEquipmentViewsProvider,
    );

    return ListView(
      padding: const EdgeInsets.all(12),
      children: <Widget>[
        Card(
          child: ListTile(
            leading: const Icon(Icons.science_outlined),
            title: const Text('Workshop Resources'),
            subtitle: Text(
              '${dashboard.essenceLabel} / ${dashboard.arcaneDustLabel}',
            ),
          ),
        ),
        const SizedBox(height: 8),
        WorkshopQueueCard(
          jobCount: queueSummary.jobCount,
          description: queueSummary.description,
        ),
        const SizedBox(height: 8),
        WorkshopExtractionCard(
          materialTypeCount: materials.length,
          extractedTraitTypeCount: extractedTraits.length,
        ),
        const SizedBox(height: 8),
        WorkshopCraftCard(description: craftSummary.description),
        const SizedBox(height: 8),
        WorkshopEnchantCard(
          potionStackCount: craftedPotionStacks.length,
          equipmentCount: enchantEquipmentViews.length,
        ),
        const SizedBox(height: 8),
        WorkshopHatchCard(
          recipeCount: hatchRecipes.length,
          homunculusCount: homunculusCount,
        ),
        const SizedBox(height: 8),
        WorkshopInventoryCard(description: inventorySummary.description),
        const SizedBox(height: 8),
        WorkshopSupportCard(
          assignedCount: supportAssignedCount,
          slotLimit: supportSlotLimit,
          summary: supportSummary,
        ),
        const SizedBox(height: 8),
        WorkshopSkillTreeCard(
          unlockedCount: unlockedSkillNodes,
          totalCount: totalSkillNodes,
        ),
      ],
    );
  }
}
