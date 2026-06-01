part of 'battle_equipment_stat_service.dart';

(List<BattleModifier>, List<BattlePassiveEffect>) _effectsForEquipmentLoadout(
  CharacterEquipmentLoadout equipment,
) {
  final List<BattleModifier> modifiers = <BattleModifier>[
    ...?equipment.weapon?.totalModifiers,
    ...?equipment.armor?.totalModifiers,
    ...?equipment.accessory?.totalModifiers,
  ];
  final List<BattlePassiveEffect> passives = <BattlePassiveEffect>[
    ...?equipment.weapon?.totalPassives,
    ...?equipment.armor?.totalPassives,
    ...?equipment.accessory?.totalPassives,
  ];
  return (modifiers, passives);
}
