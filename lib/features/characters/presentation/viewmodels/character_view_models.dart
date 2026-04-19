import 'package:alchemist_hunter/features/characters/domain/models.dart';
import 'package:alchemist_hunter/features/town/domain/models.dart';

class CharacterEquipmentSlotView {
  const CharacterEquipmentSlotView({
    required this.slot,
    required this.equippedItem,
    required this.availableItems,
  });

  final EquipmentSlot slot;
  final EquipmentInstance? equippedItem;
  final List<EquipmentInstance> availableItems;

  String get slotLabel {
    switch (slot) {
      case EquipmentSlot.weapon:
        return '무기';
      case EquipmentSlot.armor:
        return '방어구';
      case EquipmentSlot.accessory:
        return '장신구';
    }
  }

  String get currentLabel => equippedItem?.name ?? '미장착';

  String get statLabel {
    final EquipmentInstance? item = equippedItem;
    if (item == null) {
      return '장착 가능한 장비 ${availableItems.length}개';
    }
    final String baseLabel =
        'ATK ${item.totalAttack} / DEF ${item.totalDefense} / HP ${item.totalHealth}';
    final String? enchantLabel = item.enchant?.label;
    if (enchantLabel == null) {
      return baseLabel;
    }
    return '$baseLabel / $enchantLabel';
  }
}

class CharacterListItemView {
  const CharacterListItemView({
    required this.character,
    required this.typeLabel,
    required this.summaryLine,
    required this.growthLabel,
    required this.rankHint,
    required this.tierHint,
    required this.tierMaterialLabel,
    required this.equipmentSlots,
    required this.detailLines,
    required this.assignmentLabel,
    required this.assignmentGuideLabel,
  });

  final CharacterProgress character;
  final String typeLabel;
  final String summaryLine;
  final String growthLabel;
  final String rankHint;
  final String tierHint;
  final String tierMaterialLabel;
  final List<CharacterEquipmentSlotView> equipmentSlots;
  final List<String> detailLines;
  final String assignmentLabel;
  final String assignmentGuideLabel;
}
