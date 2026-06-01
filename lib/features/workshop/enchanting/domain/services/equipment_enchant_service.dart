import 'dart:math';

import 'package:alchemist_hunter/features/battle/domain/models.dart';
import 'package:alchemist_hunter/features/town/domain/models.dart';
import 'package:alchemist_hunter/features/workshop/domain/models.dart';
import 'package:alchemist_hunter/features/workshop/enchanting/domain/services/equipment_enchant_formula_service.dart';

part 'equipment_enchant_builder.dart';
part 'equipment_enchant_effect_builder.dart';
part 'equipment_enchant_stat_modifiers.dart';
part 'equipment_enchant_combat_modifiers.dart';
part 'equipment_enchant_passives.dart';

class EquipmentEnchantService {
  const EquipmentEnchantService({
    EquipmentEnchantFormulaService formulaService =
        const EquipmentEnchantFormulaService(),
  }) : _formulaService = formulaService;

  final EquipmentEnchantFormulaService _formulaService;

  EquipmentEnchant buildEnchant({
    required EquipmentInstance equipment,
    required CraftedPotion potion,
    required PotionBlueprint blueprint,
    double potencyBonusRate = 0,
  }) {
    return buildEquipmentEnchant(
      equipment: equipment,
      potion: potion,
      blueprint: blueprint,
      potencyBonusRate: potencyBonusRate,
    );
  }
}
