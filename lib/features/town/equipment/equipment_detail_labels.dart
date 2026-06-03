import 'package:alchemist_hunter/features/town/domain/models.dart';
import 'package:alchemist_hunter/features/town/equipment/equipment_effect_labels.dart';
import 'package:alchemist_hunter/features/town/equipment/equipment_stat_labels.dart';

String equipmentBlueprintDetailLabel(EquipmentBlueprint blueprint) {
  final String statLabel = equipmentBlueprintStatLabel(blueprint);
  if (blueprint.statModifiers.isEmpty &&
      blueprint.modifiers.isEmpty &&
      blueprint.passives.isEmpty) {
    return statLabel;
  }
  return '$statLabel\n${equipmentBlueprintEffectLabel(blueprint)}';
}

String equipmentInstanceDetailLabel(EquipmentInstance equipment) {
  final List<String> lines = <String>[
    equipmentInstanceStatLabel(equipment),
    if (equipment.enchant != null)
      '인챈트 ${equipmentEnchantLabel(equipment.enchant!)}',
  ];
  if (equipment.totalStatModifiers.isNotEmpty ||
      equipment.totalModifiers.isNotEmpty ||
      equipment.totalPassives.isNotEmpty) {
    lines.add(equipmentInstanceEffectLabel(equipment));
  }
  return lines.join('\n');
}

String equipmentEnchantLabel(EquipmentEnchant enchant) {
  return '${enchant.potionName} ${enchant.qualityLabel}';
}
