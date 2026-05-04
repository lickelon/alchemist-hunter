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
