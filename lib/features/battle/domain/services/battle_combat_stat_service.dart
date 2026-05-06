import 'package:alchemist_hunter/features/battle/domain/models.dart';
import 'package:alchemist_hunter/features/characters/domain/models.dart';
import 'package:alchemist_hunter/features/town/domain/models.dart';

part 'battle_combat_stat_tables.dart';

class BattleCombatStatService {
  const BattleCombatStatService();

  HeroProfile buildHeroProfile(CharacterProgress character) {
    final BattleCombatStats stats = buildStats(character);
    final String jobId = character.resolvedCombatJobId;
    final (List<BattleModifier>, List<BattlePassiveEffect>) equipmentEffects =
        _equipmentEffects(character.equipment);
    final List<BattleModifier> modifiers = equipmentEffects.$1;
    final List<BattlePassiveEffect> passives = equipmentEffects.$2;
    return HeroProfile(
      id: character.id,
      name: character.name,
      faction: factionFor(character),
      discipline: disciplineFor(jobId),
      jobId: jobId,
      stats: stats,
      modifiers: modifiers,
      passives: passives,
      power:
          summaryPowerForStats(stats) +
          summaryPowerForEffects(modifiers, passives),
    );
  }

  CombatFaction factionFor(CharacterProgress character) {
    return switch (character.type) {
      CharacterType.mercenary => CombatFaction.mercenary,
      CharacterType.homunculus => CombatFaction.homunculus,
    };
  }

  CombatDiscipline disciplineFor(String jobId) {
    switch (jobId) {
      case CombatJobIds.mercenaryMage:
      case CombatJobIds.homunculusMage:
        return CombatDiscipline.mage;
      case CombatJobIds.mercenaryRogue:
      case CombatJobIds.homunculusRogue:
        return CombatDiscipline.rogue;
      case CombatJobIds.mercenaryArcher:
      case CombatJobIds.homunculusArcher:
        return CombatDiscipline.archer;
      default:
        return CombatDiscipline.warrior;
    }
  }

  BattleCombatStats buildStats(CharacterProgress character) {
    final String jobId = character.resolvedCombatJobId;
    final BattleCombatStats baseStats =
        _baseStatsByJob[jobId] ??
        _baseStatsByJob[CombatJobIds.mercenaryWarrior]!;
    final BattleCombatStats tierGrowth =
        _tierGrowthByJob[jobId] ??
        _tierGrowthByJob[CombatJobIds.mercenaryWarrior]!;
    final BattleCombatStats rankGrowth =
        _rankGrowthByJob[jobId] ??
        _rankGrowthByJob[CombatJobIds.mercenaryWarrior]!;
    final int hpGrowth =
        _levelHpGrowthByJob[jobId] ??
        _levelHpGrowthByJob[CombatJobIds.mercenaryWarrior]!;

    return baseStats +
        tierGrowth.scale(character.tierIndex - 1) +
        rankGrowth.scale(character.rankInCurrentTier - 1) +
        BattleCombatStats(
          maxHp: hpGrowth * (character.level - 1),
          physicalAttack: 0,
          physicalDefense: 0,
          magicalAttack: 0,
          magicalDefense: 0,
          speed: 0,
          critChance: 0,
          critDamage: 0,
          accuracy: 0,
          evasion: 0,
          statusAccuracy: 0,
          statusResistance: 0,
          physicalPenetration: 0,
          magicalPenetration: 0,
          lifesteal: 0,
          healingPower: 0,
          regen: 0,
        ) +
        _equipmentStats(character.equipment) +
        _equipmentStatModifiers(character.equipment);
  }

  int summaryPowerForStats(BattleCombatStats stats) {
    final int offense =
        (stats.physicalAttack * 2) + (stats.magicalAttack * 2) + stats.speed;
    final int defense = stats.physicalDefense + stats.magicalDefense;
    final int health = stats.maxHp ~/ 4;
    final int utility =
        (stats.critChance * 100).round() +
        (stats.critDamage * 80).round() +
        (stats.accuracy * 10).round() +
        (stats.evasion * 10).round() +
        (stats.statusAccuracy * 10).round() +
        (stats.statusResistance * 10).round() +
        (stats.physicalPenetration * 80).round() +
        (stats.magicalPenetration * 80).round() +
        (stats.lifesteal * 120).round() +
        (stats.healingPower * 100).round() +
        (stats.regen * 100).round();
    return health + offense + defense + utility;
  }

  int summaryPowerForEffects(
    List<BattleModifier> modifiers,
    List<BattlePassiveEffect> passives,
  ) {
    final int modifierPower = modifiers.fold<int>(0, (
      int total,
      BattleModifier modifier,
    ) {
      final double weightedValue = modifier.mode == BattleModifierMode.percent
          ? modifier.value.abs() * 100
          : modifier.value.abs() * 80;
      return total + weightedValue.round();
    });
    final int passivePower = passives.fold<int>(0, (
      int total,
      BattlePassiveEffect passive,
    ) {
      return total +
          switch (passive.type) {
            BattlePassiveEffectType.alwaysHit => 10,
            BattlePassiveEffectType.extraAttack => 14 * (passive.value ?? 1),
          };
    });
    return modifierPower + passivePower;
  }

  BattleCombatStats _equipmentStats(CharacterEquipmentLoadout equipment) {
    return _statsForItem(equipment.weapon) +
        _statsForItem(equipment.armor) +
        _statsForItem(equipment.accessory);
  }

  BattleCombatStats _equipmentStatModifiers(
    CharacterEquipmentLoadout equipment,
  ) {
    return _statsForModifiers(equipment.weapon?.totalStatModifiers) +
        _statsForModifiers(equipment.armor?.totalStatModifiers) +
        _statsForModifiers(equipment.accessory?.totalStatModifiers);
  }

  (List<BattleModifier>, List<BattlePassiveEffect>) _equipmentEffects(
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

  BattleCombatStats _statsForItem(EquipmentInstance? item) {
    if (item == null) {
      return const BattleCombatStats.zero();
    }

    return BattleCombatStats(
      maxHp: item.totalMaxHp,
      physicalAttack: item.totalPhysicalAttack,
      physicalDefense: item.totalPhysicalDefense,
      magicalAttack: item.totalMagicalAttack,
      magicalDefense: item.totalMagicalDefense,
      speed: item.totalSpeed,
      critChance: 0,
      critDamage: 0,
      accuracy: 0,
      evasion: 0,
      statusAccuracy: 0,
      statusResistance: 0,
      physicalPenetration: 0,
      magicalPenetration: 0,
      lifesteal: 0,
      healingPower: 0,
      regen: 0,
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
      BattleStatModifierType.maxHp => BattleCombatStats(
        maxHp: intValue,
        physicalAttack: 0,
        physicalDefense: 0,
        magicalAttack: 0,
        magicalDefense: 0,
        speed: 0,
        critChance: 0,
        critDamage: 0,
        accuracy: 0,
        evasion: 0,
        statusAccuracy: 0,
        statusResistance: 0,
        physicalPenetration: 0,
        magicalPenetration: 0,
        lifesteal: 0,
        healingPower: 0,
        regen: 0,
      ),
      BattleStatModifierType.physicalAttack => BattleCombatStats(
        maxHp: 0,
        physicalAttack: intValue,
        physicalDefense: 0,
        magicalAttack: 0,
        magicalDefense: 0,
        speed: 0,
        critChance: 0,
        critDamage: 0,
        accuracy: 0,
        evasion: 0,
        statusAccuracy: 0,
        statusResistance: 0,
        physicalPenetration: 0,
        magicalPenetration: 0,
        lifesteal: 0,
        healingPower: 0,
        regen: 0,
      ),
      BattleStatModifierType.physicalDefense => BattleCombatStats(
        maxHp: 0,
        physicalAttack: 0,
        physicalDefense: intValue,
        magicalAttack: 0,
        magicalDefense: 0,
        speed: 0,
        critChance: 0,
        critDamage: 0,
        accuracy: 0,
        evasion: 0,
        statusAccuracy: 0,
        statusResistance: 0,
        physicalPenetration: 0,
        magicalPenetration: 0,
        lifesteal: 0,
        healingPower: 0,
        regen: 0,
      ),
      BattleStatModifierType.magicalAttack => BattleCombatStats(
        maxHp: 0,
        physicalAttack: 0,
        physicalDefense: 0,
        magicalAttack: intValue,
        magicalDefense: 0,
        speed: 0,
        critChance: 0,
        critDamage: 0,
        accuracy: 0,
        evasion: 0,
        statusAccuracy: 0,
        statusResistance: 0,
        physicalPenetration: 0,
        magicalPenetration: 0,
        lifesteal: 0,
        healingPower: 0,
        regen: 0,
      ),
      BattleStatModifierType.magicalDefense => BattleCombatStats(
        maxHp: 0,
        physicalAttack: 0,
        physicalDefense: 0,
        magicalAttack: 0,
        magicalDefense: intValue,
        speed: 0,
        critChance: 0,
        critDamage: 0,
        accuracy: 0,
        evasion: 0,
        statusAccuracy: 0,
        statusResistance: 0,
        physicalPenetration: 0,
        magicalPenetration: 0,
        lifesteal: 0,
        healingPower: 0,
        regen: 0,
      ),
      BattleStatModifierType.speed => BattleCombatStats(
        maxHp: 0,
        physicalAttack: 0,
        physicalDefense: 0,
        magicalAttack: 0,
        magicalDefense: 0,
        speed: intValue,
        critChance: 0,
        critDamage: 0,
        accuracy: 0,
        evasion: 0,
        statusAccuracy: 0,
        statusResistance: 0,
        physicalPenetration: 0,
        magicalPenetration: 0,
        lifesteal: 0,
        healingPower: 0,
        regen: 0,
      ),
      BattleStatModifierType.critRate => BattleCombatStats(
        maxHp: 0,
        physicalAttack: 0,
        physicalDefense: 0,
        magicalAttack: 0,
        magicalDefense: 0,
        speed: 0,
        critChance: value,
        critDamage: 0,
        accuracy: 0,
        evasion: 0,
        statusAccuracy: 0,
        statusResistance: 0,
        physicalPenetration: 0,
        magicalPenetration: 0,
        lifesteal: 0,
        healingPower: 0,
        regen: 0,
      ),
      BattleStatModifierType.critDamage => BattleCombatStats(
        maxHp: 0,
        physicalAttack: 0,
        physicalDefense: 0,
        magicalAttack: 0,
        magicalDefense: 0,
        speed: 0,
        critChance: 0,
        critDamage: value,
        accuracy: 0,
        evasion: 0,
        statusAccuracy: 0,
        statusResistance: 0,
        physicalPenetration: 0,
        magicalPenetration: 0,
        lifesteal: 0,
        healingPower: 0,
        regen: 0,
      ),
      BattleStatModifierType.accuracy => BattleCombatStats(
        maxHp: 0,
        physicalAttack: 0,
        physicalDefense: 0,
        magicalAttack: 0,
        magicalDefense: 0,
        speed: 0,
        critChance: 0,
        critDamage: 0,
        accuracy: value,
        evasion: 0,
        statusAccuracy: 0,
        statusResistance: 0,
        physicalPenetration: 0,
        magicalPenetration: 0,
        lifesteal: 0,
        healingPower: 0,
        regen: 0,
      ),
      BattleStatModifierType.evasion => BattleCombatStats(
        maxHp: 0,
        physicalAttack: 0,
        physicalDefense: 0,
        magicalAttack: 0,
        magicalDefense: 0,
        speed: 0,
        critChance: 0,
        critDamage: 0,
        accuracy: 0,
        evasion: value,
        statusAccuracy: 0,
        statusResistance: 0,
        physicalPenetration: 0,
        magicalPenetration: 0,
        lifesteal: 0,
        healingPower: 0,
        regen: 0,
      ),
      BattleStatModifierType.statusAccuracy => BattleCombatStats(
        maxHp: 0,
        physicalAttack: 0,
        physicalDefense: 0,
        magicalAttack: 0,
        magicalDefense: 0,
        speed: 0,
        critChance: 0,
        critDamage: 0,
        accuracy: 0,
        evasion: 0,
        statusAccuracy: value,
        statusResistance: 0,
        physicalPenetration: 0,
        magicalPenetration: 0,
        lifesteal: 0,
        healingPower: 0,
        regen: 0,
      ),
      BattleStatModifierType.statusResistance => BattleCombatStats(
        maxHp: 0,
        physicalAttack: 0,
        physicalDefense: 0,
        magicalAttack: 0,
        magicalDefense: 0,
        speed: 0,
        critChance: 0,
        critDamage: 0,
        accuracy: 0,
        evasion: 0,
        statusAccuracy: 0,
        statusResistance: value,
        physicalPenetration: 0,
        magicalPenetration: 0,
        lifesteal: 0,
        healingPower: 0,
        regen: 0,
      ),
      BattleStatModifierType.physicalPenetration => BattleCombatStats(
        maxHp: 0,
        physicalAttack: 0,
        physicalDefense: 0,
        magicalAttack: 0,
        magicalDefense: 0,
        speed: 0,
        critChance: 0,
        critDamage: 0,
        accuracy: 0,
        evasion: 0,
        statusAccuracy: 0,
        statusResistance: 0,
        physicalPenetration: value,
        magicalPenetration: 0,
        lifesteal: 0,
        healingPower: 0,
        regen: 0,
      ),
      BattleStatModifierType.magicalPenetration => BattleCombatStats(
        maxHp: 0,
        physicalAttack: 0,
        physicalDefense: 0,
        magicalAttack: 0,
        magicalDefense: 0,
        speed: 0,
        critChance: 0,
        critDamage: 0,
        accuracy: 0,
        evasion: 0,
        statusAccuracy: 0,
        statusResistance: 0,
        physicalPenetration: 0,
        magicalPenetration: value,
        lifesteal: 0,
        healingPower: 0,
        regen: 0,
      ),
      BattleStatModifierType.lifesteal => BattleCombatStats(
        maxHp: 0,
        physicalAttack: 0,
        physicalDefense: 0,
        magicalAttack: 0,
        magicalDefense: 0,
        speed: 0,
        critChance: 0,
        critDamage: 0,
        accuracy: 0,
        evasion: 0,
        statusAccuracy: 0,
        statusResistance: 0,
        physicalPenetration: 0,
        magicalPenetration: 0,
        lifesteal: value,
        healingPower: 0,
        regen: 0,
      ),
      BattleStatModifierType.healingPower => BattleCombatStats(
        maxHp: 0,
        physicalAttack: 0,
        physicalDefense: 0,
        magicalAttack: 0,
        magicalDefense: 0,
        speed: 0,
        critChance: 0,
        critDamage: 0,
        accuracy: 0,
        evasion: 0,
        statusAccuracy: 0,
        statusResistance: 0,
        physicalPenetration: 0,
        magicalPenetration: 0,
        lifesteal: 0,
        healingPower: value,
        regen: 0,
      ),
      BattleStatModifierType.regen => BattleCombatStats(
        maxHp: 0,
        physicalAttack: 0,
        physicalDefense: 0,
        magicalAttack: 0,
        magicalDefense: 0,
        speed: 0,
        critChance: 0,
        critDamage: 0,
        accuracy: 0,
        evasion: 0,
        statusAccuracy: 0,
        statusResistance: 0,
        physicalPenetration: 0,
        magicalPenetration: 0,
        lifesteal: 0,
        healingPower: 0,
        regen: value,
      ),
    };
  }
}
