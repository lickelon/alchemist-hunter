import 'package:alchemist_hunter/features/town/domain/models.dart';
import 'package:flutter/foundation.dart';

@immutable
class CharacterEquipmentLoadout {
  const CharacterEquipmentLoadout({this.weapon, this.armor, this.accessory});

  final EquipmentInstance? weapon;
  final EquipmentInstance? armor;
  final EquipmentInstance? accessory;

  EquipmentInstance? itemForSlot(EquipmentSlot slot) {
    switch (slot) {
      case EquipmentSlot.weapon:
        return weapon;
      case EquipmentSlot.armor:
        return armor;
      case EquipmentSlot.accessory:
        return accessory;
    }
  }

  CharacterEquipmentLoadout equip(EquipmentInstance item) {
    switch (item.slot) {
      case EquipmentSlot.weapon:
        return CharacterEquipmentLoadout(
          weapon: item,
          armor: armor,
          accessory: accessory,
        );
      case EquipmentSlot.armor:
        return CharacterEquipmentLoadout(
          weapon: weapon,
          armor: item,
          accessory: accessory,
        );
      case EquipmentSlot.accessory:
        return CharacterEquipmentLoadout(
          weapon: weapon,
          armor: armor,
          accessory: item,
        );
    }
  }

  CharacterEquipmentLoadout clearSlot(EquipmentSlot slot) {
    switch (slot) {
      case EquipmentSlot.weapon:
        return CharacterEquipmentLoadout(armor: armor, accessory: accessory);
      case EquipmentSlot.armor:
        return CharacterEquipmentLoadout(weapon: weapon, accessory: accessory);
      case EquipmentSlot.accessory:
        return CharacterEquipmentLoadout(weapon: weapon, armor: armor);
    }
  }
}
