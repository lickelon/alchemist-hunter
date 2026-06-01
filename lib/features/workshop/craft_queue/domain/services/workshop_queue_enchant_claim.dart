import 'package:alchemist_hunter/app/session/session_state.dart';
import 'package:alchemist_hunter/features/characters/domain/models.dart';
import 'package:alchemist_hunter/features/town/domain/models.dart';
import 'package:alchemist_hunter/features/workshop/domain/models.dart';

SessionState claimEnchantJob({
  required SessionState state,
  required List<CraftQueueJob> queue,
  required CraftQueueJob job,
}) {
  final EquipmentInstance? equipment = job.completedEquipment;
  if (equipment == null) {
    return state;
  }
  List<EquipmentInstance> townInventory = <EquipmentInstance>[
    ...state.town.equipmentInventory,
  ];
  List<CharacterProgress> mercenaries = <CharacterProgress>[
    ...state.characters.mercenaries,
  ];
  List<CharacterProgress> homunculi = <CharacterProgress>[
    ...state.characters.homunculi,
  ];

  final CharacterType? ownerType = job.equipmentOwnerType;
  final String? ownerCharacterId = job.equipmentOwnerId;
  if (ownerType == null || ownerCharacterId == null) {
    townInventory = <EquipmentInstance>[equipment, ...townInventory];
  } else if (ownerType == CharacterType.mercenary) {
    final ({List<CharacterProgress> characters, bool equipped}) result =
        applyEquipmentClaimToList(
          characters: mercenaries,
          ownerCharacterId: ownerCharacterId,
          equipment: equipment,
        );
    mercenaries = result.characters;
    if (!result.equipped) {
      townInventory = <EquipmentInstance>[equipment, ...townInventory];
    }
  } else {
    final ({List<CharacterProgress> characters, bool equipped}) result =
        applyEquipmentClaimToList(
          characters: homunculi,
          ownerCharacterId: ownerCharacterId,
          equipment: equipment,
        );
    homunculi = result.characters;
    if (!result.equipped) {
      townInventory = <EquipmentInstance>[equipment, ...townInventory];
    }
  }

  return state.copyWith(
    town: state.town.copyWith(equipmentInventory: townInventory),
    workshop: state.workshop.copyWith(
      queue: queue,
      enchantCount: state.workshop.enchantCount + 1,
    ),
    characters: state.characters.copyWith(
      mercenaries: mercenaries,
      homunculi: homunculi,
    ),
  );
}

({List<CharacterProgress> characters, bool equipped})
applyEquipmentClaimToList({
  required List<CharacterProgress> characters,
  required String ownerCharacterId,
  required EquipmentInstance equipment,
}) {
  final List<CharacterProgress> nextCharacters = <CharacterProgress>[
    ...characters,
  ];
  for (int index = 0; index < nextCharacters.length; index++) {
    final CharacterProgress character = nextCharacters[index];
    if (character.id != ownerCharacterId) {
      continue;
    }
    final EquipmentInstance? current = character.equipment.itemForSlot(
      equipment.slot,
    );
    if (current != null) {
      return (characters: nextCharacters, equipped: false);
    }
    nextCharacters[index] = character.copyWith(
      equipment: character.equipment.equip(equipment),
    );
    return (characters: nextCharacters, equipped: true);
  }
  return (characters: nextCharacters, equipped: false);
}
