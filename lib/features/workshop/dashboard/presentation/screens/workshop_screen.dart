import 'package:alchemist_hunter/common/widgets/app_screen_body.dart';
import 'package:alchemist_hunter/features/workshop/craft_queue/presentation/viewmodels/craft_queue_job_selectors.dart';
import 'package:alchemist_hunter/features/workshop/crafting/presentation/viewmodels/craft_queue_option_selectors.dart';
import 'package:alchemist_hunter/features/workshop/crafting/presentation/viewmodels/crafted_inventory_selectors.dart';
import 'package:alchemist_hunter/features/workshop/dashboard/presentation/widgets/workshop_sections.dart';
import 'package:alchemist_hunter/features/workshop/dashboard/presentation/viewmodels/workshop_shared_selectors.dart';
import 'package:alchemist_hunter/features/workshop/enchanting/presentation/viewmodels/enchant_equipment_selectors.dart';
import 'package:alchemist_hunter/features/workshop/extraction/presentation/viewmodels/extraction_inventory_selectors.dart';
import 'package:alchemist_hunter/features/workshop/hatchery/presentation/viewmodels/hatch_selectors.dart';
import 'package:alchemist_hunter/features/workshop/support/presentation/viewmodels/workshop_support_selectors.dart';
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
    final int unlockedSkillNodes = ref.watch(
      workshopUnlockedSkillNodeCountProvider,
    );
    final int totalSkillNodes = ref.watch(workshopSkillNodeCountProvider);
    final int supportAssignedCount = ref.watch(
      workshopSupportAssignedCountProvider,
    );
    final int supportSlotLimit = ref.watch(workshopSupportSlotLimitProvider);
    final List<HomunculusHatchRecipeView> hatchRecipes = ref.watch(
      homunculusHatchRecipeViewsProvider,
    );
    final List<MapEntry<String, int>> materials = ref.watch(
      sortedMaterialInventoryProvider,
    );
    final Map<String, int> craftedPotionStacks = ref.watch(
      craftedPotionStacksProvider,
    );
    final List<EnchantEquipmentView> enchantEquipmentViews = ref.watch(
      enchantEquipmentViewsProvider,
    );

    return AppScreenBody(
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
        WorkshopQueueCard(jobCount: queueSummary.jobCount),
        WorkshopExtractionCard(materialTypeCount: materials.length),
        WorkshopCraftCard(craftableCount: craftSummary.craftableCount),
        WorkshopEnchantCard(
          canEnchant:
              craftedPotionStacks.isNotEmpty &&
              enchantEquipmentViews.isNotEmpty,
        ),
        WorkshopHatchCard(recipeCount: hatchRecipes.length),
        WorkshopInventoryCard(
          materialTypeCount: inventorySummary.materialTypeCount,
          traitTypeCount: inventorySummary.traitTypeCount,
          potionStackCount: inventorySummary.potionStackCount,
        ),
        WorkshopSupportCard(
          assignedCount: supportAssignedCount,
          slotLimit: supportSlotLimit,
        ),
        WorkshopSkillTreeCard(
          unlockedCount: unlockedSkillNodes,
          totalCount: totalSkillNodes,
        ),
      ],
    );
  }
}
