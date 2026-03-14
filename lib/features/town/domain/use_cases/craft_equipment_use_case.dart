import 'package:alchemist_hunter/core/session/session_providers.dart';
import 'package:alchemist_hunter/features/town/domain/models.dart';

class CraftEquipmentUseCase {
  const CraftEquipmentUseCase();

  SessionState craftEquipment({
    required SessionState state,
    required EquipmentBlueprint blueprint,
    required DateTime now,
  }) {
    if (state.player.gold < blueprint.goldCost) {
      return state;
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

    return state.copyWith(
      player: state.player.copyWith(gold: state.player.gold - blueprint.goldCost),
      town: state.town.copyWith(
        equipmentInventory: <EquipmentInstance>[
          instance,
          ...state.town.equipmentInventory,
        ],
      ),
    );
  }
}
