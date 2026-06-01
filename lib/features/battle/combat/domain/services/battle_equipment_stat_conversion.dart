part of 'battle_equipment_stat_service.dart';

BattleCombatStats _statsForEquipmentItems(CharacterEquipmentLoadout equipment) {
  return _statsForItem(equipment.weapon) +
      _statsForItem(equipment.armor) +
      _statsForItem(equipment.accessory);
}

BattleCombatStats _statsForEquipmentModifiers(
  CharacterEquipmentLoadout equipment,
) {
  return _statsForModifiers(equipment.weapon?.totalStatModifiers) +
      _statsForModifiers(equipment.armor?.totalStatModifiers) +
      _statsForModifiers(equipment.accessory?.totalStatModifiers);
}

BattleCombatStats _statsForItem(EquipmentInstance? item) {
  if (item == null) {
    return const BattleCombatStats.zero();
  }

  return _stats(
    maxHp: item.totalMaxHp,
    physicalAttack: item.totalPhysicalAttack,
    physicalDefense: item.totalPhysicalDefense,
    magicalAttack: item.totalMagicalAttack,
    magicalDefense: item.totalMagicalDefense,
    speed: item.totalSpeed,
  );
}

BattleCombatStats _statsForModifiers(List<BattleStatModifier>? modifiers) {
  if (modifiers == null || modifiers.isEmpty) {
    return const BattleCombatStats.zero();
  }

  return modifiers.fold<BattleCombatStats>(const BattleCombatStats.zero(), (
    BattleCombatStats total,
    BattleStatModifier modifier,
  ) {
    return total + _statModifierToStats(modifier);
  });
}

BattleCombatStats _statModifierToStats(BattleStatModifier modifier) {
  final double value = modifier.value;
  final int intValue = value.round();

  return switch (modifier.type) {
    BattleStatModifierType.maxHp => _stats(maxHp: intValue),
    BattleStatModifierType.maxMp => _stats(maxMp: intValue),
    BattleStatModifierType.physicalAttack => _stats(physicalAttack: intValue),
    BattleStatModifierType.physicalDefense => _stats(physicalDefense: intValue),
    BattleStatModifierType.magicalAttack => _stats(magicalAttack: intValue),
    BattleStatModifierType.magicalDefense => _stats(magicalDefense: intValue),
    BattleStatModifierType.speed => _stats(speed: intValue),
    BattleStatModifierType.critRate => _stats(critChance: value),
    BattleStatModifierType.critDamage => _stats(critDamage: value),
    BattleStatModifierType.accuracy => _stats(accuracy: value),
    BattleStatModifierType.evasion => _stats(evasion: value),
    BattleStatModifierType.statusAccuracy => _stats(statusAccuracy: value),
    BattleStatModifierType.statusResistance => _stats(statusResistance: value),
    BattleStatModifierType.physicalPenetration => _stats(
      physicalPenetration: value,
    ),
    BattleStatModifierType.magicalPenetration => _stats(
      magicalPenetration: value,
    ),
    BattleStatModifierType.lifesteal => _stats(lifesteal: value),
    BattleStatModifierType.healingPower => _stats(healingPower: value),
    BattleStatModifierType.regen => _stats(regen: value),
    BattleStatModifierType.mpRegen => _stats(mpRegen: intValue),
  };
}

BattleCombatStats _stats({
  int maxHp = 0,
  int maxMp = 0,
  int physicalAttack = 0,
  int physicalDefense = 0,
  int magicalAttack = 0,
  int magicalDefense = 0,
  int speed = 0,
  double critChance = 0,
  double critDamage = 0,
  double accuracy = 0,
  double evasion = 0,
  double statusAccuracy = 0,
  double statusResistance = 0,
  double physicalPenetration = 0,
  double magicalPenetration = 0,
  double lifesteal = 0,
  double healingPower = 0,
  double regen = 0,
  int mpRegen = 0,
}) {
  return BattleCombatStats(
    maxHp: maxHp,
    maxMp: maxMp,
    physicalAttack: physicalAttack,
    physicalDefense: physicalDefense,
    magicalAttack: magicalAttack,
    magicalDefense: magicalDefense,
    speed: speed,
    critChance: critChance,
    critDamage: critDamage,
    accuracy: accuracy,
    evasion: evasion,
    statusAccuracy: statusAccuracy,
    statusResistance: statusResistance,
    physicalPenetration: physicalPenetration,
    magicalPenetration: magicalPenetration,
    lifesteal: lifesteal,
    healingPower: healingPower,
    regen: regen,
    mpRegen: mpRegen,
  );
}
