import 'package:alchemist_hunter/app/catalog/app_catalog_providers.dart';
import 'package:alchemist_hunter/app/session/app_session.dart';
import 'package:alchemist_hunter/features/town/domain/models.dart';
import 'package:alchemist_hunter/features/town/equipment/equipment_effect_labels.dart';
import 'package:alchemist_hunter/features/town/equipment/equipment_slot_labels.dart';
import 'package:alchemist_hunter/features/town/equipment/equipment_stat_labels.dart';
import 'package:alchemist_hunter/features/town/presentation/viewmodels/town_equipment_view_models.dart';
import 'package:alchemist_hunter/features/town/presentation/viewmodels/town_service_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final Provider<List<TownEquipmentBlueprintView>>
townEquipmentBlueprintViewsProvider = Provider<List<TownEquipmentBlueprintView>>((
  Ref ref,
) {
  final SessionState state = ref.watch(sessionControllerProvider);
  final List<EquipmentBlueprint> blueprints = ref.watch(
    townEquipmentBlueprintsProvider,
  );
  final Map<String, String> materialNames = ref.watch(
    townEquipmentMaterialNamesProvider,
  );
  final service = ref.watch(townSkillTreeServiceProvider);
  final Map<String, int> inventory = state.player.materialInventory;
  final List<TownSkillNode> nodes = ref.watch(townSkillNodesProvider);

  return blueprints
      .map((EquipmentBlueprint blueprint) {
        final Map<String, int> adjustedCosts = service.adjustedMaterialCosts(
          baseCosts: blueprint.materialCosts,
          efficiencyRate: service.equipmentCraftEfficiencyRate(state, nodes),
        );
        final bool canCraft = adjustedCosts.entries.every(
          (MapEntry<String, int> entry) =>
              (inventory[entry.key] ?? 0) >= entry.value,
        );
        return TownEquipmentBlueprintView(
          id: blueprint.id,
          name: blueprint.name,
          slotLabel: equipmentSlotLabel(blueprint.slot),
          statLabels: equipmentBlueprintStatLabels(blueprint),
          effectLabels: equipmentBlueprintEffectLabels(blueprint),
          materialCostLabel: adjustedCosts.entries
              .map(
                (MapEntry<String, int> entry) =>
                    '${materialNames[entry.key] ?? entry.key} x${entry.value}',
              )
              .join(', '),
          durationLabel: '${blueprint.craftDuration.inSeconds}s',
          canCraft: canCraft,
        );
      })
      .toList(growable: false);
});
