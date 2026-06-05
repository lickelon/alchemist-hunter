import 'package:alchemist_hunter/features/town/domain/models.dart';
import 'package:alchemist_hunter/features/town/equipment/equipment_effect_labels.dart';
import 'package:alchemist_hunter/features/town/equipment/equipment_stat_labels.dart';

String equipmentBlueprintDetailLabel(EquipmentBlueprint blueprint) {
  return equipmentBlueprintDetailLabels(blueprint).join(' / ');
}

List<String> equipmentBlueprintDetailLabels(EquipmentBlueprint blueprint) {
  return <String>[
    ...equipmentBlueprintStatLabels(blueprint),
    if (blueprint.statModifiers.isNotEmpty ||
        blueprint.modifiers.isNotEmpty ||
        blueprint.passives.isNotEmpty)
      ...equipmentBlueprintEffectLabels(blueprint),
  ];
}

String equipmentInstanceDetailLabel(EquipmentInstance equipment) {
  return equipmentInstanceDetailLabels(equipment).join(' / ');
}

List<String> equipmentInstanceDetailLabels(EquipmentInstance equipment) {
  return <String>[
    ...equipmentInstanceStatLabels(equipment),
    if (equipment.enchant != null)
      '인챈트 ${equipmentEnchantLabel(equipment.enchant!)}',
    if (equipment.totalStatModifiers.isNotEmpty ||
        equipment.totalModifiers.isNotEmpty ||
        equipment.totalPassives.isNotEmpty)
      ...equipmentInstanceEffectLabels(equipment),
  ];
}

String equipmentEnchantLabel(EquipmentEnchant enchant) {
  return '${enchant.potionName} ${enchant.qualityLabel}';
}
