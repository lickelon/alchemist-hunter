import 'package:alchemist_hunter/app/session/app_session.dart';
import 'package:alchemist_hunter/features/town/domain/models.dart';

class CraftEquipmentUseCase {
  const CraftEquipmentUseCase();

  SessionState craftEquipment({
    required SessionState state,
    required EquipmentBlueprint blueprint,
    required DateTime now,
  }) {
    final Map<String, int> inventory = <String, int>{
      ...state.player.materialInventory,
    };
    for (final MapEntry<String, int> entry in blueprint.materialCosts.entries) {
      if ((inventory[entry.key] ?? 0) < entry.value) {
        return state;
      }
    }

    final EquipmentInstance instance = EquipmentInstance(
      id: 'equip_${now.microsecondsSinceEpoch}_${blueprint.id}',
      blueprintId: blueprint.id,
      name: blueprint.name,
      slot: blueprint.slot,
      attack: blueprint.attack,
      defense: blueprint.defense,
      health: blueprint.health,
      createdAt: now,
    );

    for (final MapEntry<String, int> entry in blueprint.materialCosts.entries) {
      final int nextValue = (inventory[entry.key] ?? 0) - entry.value;
      if (nextValue <= 0) {
        inventory.remove(entry.key);
      } else {
        inventory[entry.key] = nextValue;
      }
    }

    return state.copyWith(
      player: state.player.copyWith(materialInventory: inventory),
      town: state.town.copyWith(
        equipmentInventory: <EquipmentInstance>[
          instance,
          ...state.town.equipmentInventory,
        ],
        equipmentCraftCount: state.town.equipmentCraftCount + 1,
      ),
    );
  }
}
