import 'package:alchemist_hunter/features/battle/domain/models.dart';
import 'package:alchemist_hunter/features/characters/domain/models.dart';
import 'package:alchemist_hunter/features/town/domain/models.dart';

part 'battle_equipment_effect_collector.dart';
part 'battle_equipment_stat_conversion.dart';

class BattleEquipmentStatService {
  const BattleEquipmentStatService();

  BattleCombatStats statsForLoadout(CharacterEquipmentLoadout equipment) {
    return _statsForEquipmentItems(equipment);
  }

  BattleCombatStats statModifiersForLoadout(
    CharacterEquipmentLoadout equipment,
  ) {
    return _statsForEquipmentModifiers(equipment);
  }

  (List<BattleModifier>, List<BattlePassiveEffect>) effectsForLoadout(
    CharacterEquipmentLoadout equipment,
  ) {
    return _effectsForEquipmentLoadout(equipment);
  }
}
