import 'package:alchemist_hunter/features/characters/domain/models.dart';
import 'package:alchemist_hunter/features/characters/presentation/viewmodels/character_view_models.dart';
import 'package:alchemist_hunter/features/town/domain/models.dart';

List<CharacterEquipmentSlotView> buildCharacterEquipmentSlots({
  required CharacterProgress character,
  required List<EquipmentInstance> equipmentInventory,
}) {
  return EquipmentSlot.values
      .map((EquipmentSlot slot) {
        return CharacterEquipmentSlotView(
          slot: slot,
          equippedItem: character.equipment.itemForSlot(slot),
          availableItems: equipmentInventory
              .where((EquipmentInstance item) => item.slot == slot)
              .toList(growable: false),
        );
      })
      .toList(growable: false);
}

String characterTotalStatLabel(List<CharacterEquipmentSlotView> slots) {
  int attack = 0;
  int defense = 0;
  int health = 0;
  for (final CharacterEquipmentSlotView slot in slots) {
    final EquipmentInstance? item = slot.equippedItem;
    if (item == null) {
      continue;
    }
    attack += item.totalAttack;
    defense += item.totalDefense;
    health += item.totalHealth;
  }
  return 'ATK $attack / DEF $defense / HP $health';
}
