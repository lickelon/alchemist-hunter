import 'package:alchemist_hunter/features/battle/domain/models.dart';
import 'package:alchemist_hunter/features/characters/domain/models.dart';
import 'package:alchemist_hunter/features/town/domain/models.dart';

class BattleCombatStatService {
  const BattleCombatStatService();

  HeroProfile buildHeroProfile(CharacterProgress character) {
    final BattleCombatStats stats = buildStats(character);
    final String jobId = character.resolvedCombatJobId;
    return HeroProfile(
      id: character.id,
      name: character.name,
      faction: factionFor(character),
      discipline: disciplineFor(jobId),
      jobId: jobId,
      stats: stats,
      modifiers: const <BattleModifier>[],
      passives: const <BattlePassiveEffect>[],
      power: summaryPowerForStats(stats),
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
        _equipmentStats(character.equipment, disciplineFor(jobId));
  }

  int summaryPowerForStats(BattleCombatStats stats) {
    final int offense =
        (stats.physicalAttack * 2) + (stats.magicalAttack * 2) + stats.speed;
    final int defense = stats.physicalDefense + stats.magicalDefense;
    final int health = stats.maxHp ~/ 4;
    final int utility =
        (stats.critChance * 100).round() +
        (stats.accuracy * 10).round() +
        (stats.evasion * 10).round() +
        (stats.regen * 100).round();
    return health + offense + defense + utility;
  }

  BattleCombatStats _equipmentStats(
    CharacterEquipmentLoadout equipment,
    CombatDiscipline discipline,
  ) {
    return _statsForItem(equipment.weapon, discipline) +
        _statsForItem(equipment.armor, discipline) +
        _statsForItem(equipment.accessory, discipline);
  }

  BattleCombatStats _statsForItem(
    EquipmentInstance? item,
    CombatDiscipline discipline,
  ) {
    if (item == null) {
      return const BattleCombatStats.zero();
    }

    final int physicalAttack = switch (discipline) {
      CombatDiscipline.mage => item.totalAttack ~/ 3,
      _ => item.totalAttack,
    };
    final int magicalAttack = switch (discipline) {
      CombatDiscipline.mage => item.totalAttack,
      _ => item.totalAttack ~/ 3,
    };
    final int magicalDefense = switch (discipline) {
      CombatDiscipline.mage => item.totalDefense,
      _ => item.totalDefense ~/ 2,
    };
    final double accuracy = discipline == CombatDiscipline.archer
        ? item.totalAttack * 0.002
        : 0;
    final double critChance = discipline == CombatDiscipline.rogue
        ? item.totalAttack * 0.001
        : 0;

    return BattleCombatStats(
      maxHp: item.totalHealth,
      physicalAttack: physicalAttack,
      physicalDefense: item.totalDefense,
      magicalAttack: magicalAttack,
      magicalDefense: magicalDefense,
      speed: discipline == CombatDiscipline.rogue ? item.totalAttack ~/ 8 : 0,
      critChance: critChance,
      critDamage: 0,
      accuracy: accuracy,
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
}

const Map<String, BattleCombatStats> _baseStatsByJob =
    <String, BattleCombatStats>{
      CombatJobIds.mercenaryWarrior: BattleCombatStats(
        maxHp: 74,
        physicalAttack: 16,
        physicalDefense: 13,
        magicalAttack: 5,
        magicalDefense: 9,
        speed: 8,
        critChance: 0.05,
        critDamage: 0.5,
        accuracy: 0.88,
        evasion: 0.04,
        statusAccuracy: 0.04,
        statusResistance: 0.08,
        physicalPenetration: 0.03,
        magicalPenetration: 0.02,
        lifesteal: 0.02,
        healingPower: 0,
        regen: 0.01,
      ),
      CombatJobIds.mercenaryMage: BattleCombatStats(
        maxHp: 60,
        physicalAttack: 5,
        physicalDefense: 8,
        magicalAttack: 18,
        magicalDefense: 11,
        speed: 9,
        critChance: 0.06,
        critDamage: 0.5,
        accuracy: 0.9,
        evasion: 0.05,
        statusAccuracy: 0.12,
        statusResistance: 0.08,
        physicalPenetration: 0.01,
        magicalPenetration: 0.06,
        lifesteal: 0,
        healingPower: 0.05,
        regen: 0.01,
      ),
      CombatJobIds.mercenaryRogue: BattleCombatStats(
        maxHp: 62,
        physicalAttack: 15,
        physicalDefense: 9,
        magicalAttack: 6,
        magicalDefense: 8,
        speed: 13,
        critChance: 0.1,
        critDamage: 0.55,
        accuracy: 0.92,
        evasion: 0.09,
        statusAccuracy: 0.06,
        statusResistance: 0.06,
        physicalPenetration: 0.06,
        magicalPenetration: 0.01,
        lifesteal: 0.03,
        healingPower: 0,
        regen: 0.01,
      ),
      CombatJobIds.mercenaryArcher: BattleCombatStats(
        maxHp: 64,
        physicalAttack: 15,
        physicalDefense: 9,
        magicalAttack: 5,
        magicalDefense: 9,
        speed: 11,
        critChance: 0.08,
        critDamage: 0.55,
        accuracy: 0.95,
        evasion: 0.07,
        statusAccuracy: 0.05,
        statusResistance: 0.06,
        physicalPenetration: 0.05,
        magicalPenetration: 0.01,
        lifesteal: 0.01,
        healingPower: 0,
        regen: 0.01,
      ),
      CombatJobIds.homunculusWarrior: BattleCombatStats(
        maxHp: 70,
        physicalAttack: 14,
        physicalDefense: 12,
        magicalAttack: 8,
        magicalDefense: 11,
        speed: 8,
        critChance: 0.04,
        critDamage: 0.5,
        accuracy: 0.88,
        evasion: 0.04,
        statusAccuracy: 0.05,
        statusResistance: 0.1,
        physicalPenetration: 0.03,
        magicalPenetration: 0.03,
        lifesteal: 0.01,
        healingPower: 0.03,
        regen: 0.02,
      ),
      CombatJobIds.homunculusMage: BattleCombatStats(
        maxHp: 62,
        physicalAttack: 5,
        physicalDefense: 8,
        magicalAttack: 17,
        magicalDefense: 13,
        speed: 9,
        critChance: 0.05,
        critDamage: 0.5,
        accuracy: 0.9,
        evasion: 0.05,
        statusAccuracy: 0.14,
        statusResistance: 0.1,
        physicalPenetration: 0.01,
        magicalPenetration: 0.05,
        lifesteal: 0,
        healingPower: 0.08,
        regen: 0.02,
      ),
      CombatJobIds.homunculusRogue: BattleCombatStats(
        maxHp: 60,
        physicalAttack: 14,
        physicalDefense: 8,
        magicalAttack: 8,
        magicalDefense: 8,
        speed: 14,
        critChance: 0.11,
        critDamage: 0.55,
        accuracy: 0.93,
        evasion: 0.1,
        statusAccuracy: 0.08,
        statusResistance: 0.07,
        physicalPenetration: 0.06,
        magicalPenetration: 0.03,
        lifesteal: 0.02,
        healingPower: 0.02,
        regen: 0.02,
      ),
      CombatJobIds.homunculusArcher: BattleCombatStats(
        maxHp: 61,
        physicalAttack: 14,
        physicalDefense: 8,
        magicalAttack: 7,
        magicalDefense: 9,
        speed: 12,
        critChance: 0.09,
        critDamage: 0.55,
        accuracy: 0.96,
        evasion: 0.08,
        statusAccuracy: 0.06,
        statusResistance: 0.07,
        physicalPenetration: 0.05,
        magicalPenetration: 0.02,
        lifesteal: 0.01,
        healingPower: 0.02,
        regen: 0.02,
      ),
    };

const Map<String, BattleCombatStats> _tierGrowthByJob =
    <String, BattleCombatStats>{
      CombatJobIds.mercenaryWarrior: BattleCombatStats(
        maxHp: 24,
        physicalAttack: 4,
        physicalDefense: 4,
        magicalAttack: 1,
        magicalDefense: 3,
        speed: 1,
        critChance: 0.005,
        critDamage: 0.02,
        accuracy: 0.005,
        evasion: 0.003,
        statusAccuracy: 0.003,
        statusResistance: 0.01,
        physicalPenetration: 0.004,
        magicalPenetration: 0.002,
        lifesteal: 0.002,
        healingPower: 0,
        regen: 0.003,
      ),
      CombatJobIds.mercenaryMage: BattleCombatStats(
        maxHp: 20,
        physicalAttack: 1,
        physicalDefense: 2,
        magicalAttack: 5,
        magicalDefense: 4,
        speed: 1,
        critChance: 0.005,
        critDamage: 0.02,
        accuracy: 0.006,
        evasion: 0.003,
        statusAccuracy: 0.01,
        statusResistance: 0.01,
        physicalPenetration: 0.001,
        magicalPenetration: 0.005,
        lifesteal: 0,
        healingPower: 0.01,
        regen: 0.003,
      ),
      CombatJobIds.mercenaryRogue: BattleCombatStats(
        maxHp: 18,
        physicalAttack: 4,
        physicalDefense: 1,
        magicalAttack: 1,
        magicalDefense: 1,
        speed: 2,
        critChance: 0.01,
        critDamage: 0.02,
        accuracy: 0.01,
        evasion: 0.01,
        statusAccuracy: 0.004,
        statusResistance: 0.005,
        physicalPenetration: 0.005,
        magicalPenetration: 0.001,
        lifesteal: 0.003,
        healingPower: 0,
        regen: 0.002,
      ),
      CombatJobIds.mercenaryArcher: BattleCombatStats(
        maxHp: 18,
        physicalAttack: 4,
        physicalDefense: 1,
        magicalAttack: 1,
        magicalDefense: 2,
        speed: 2,
        critChance: 0.008,
        critDamage: 0.02,
        accuracy: 0.012,
        evasion: 0.007,
        statusAccuracy: 0.004,
        statusResistance: 0.005,
        physicalPenetration: 0.005,
        magicalPenetration: 0.001,
        lifesteal: 0.001,
        healingPower: 0,
        regen: 0.002,
      ),
      CombatJobIds.homunculusWarrior: BattleCombatStats(
        maxHp: 22,
        physicalAttack: 3,
        physicalDefense: 4,
        magicalAttack: 2,
        magicalDefense: 4,
        speed: 1,
        critChance: 0.004,
        critDamage: 0.02,
        accuracy: 0.005,
        evasion: 0.003,
        statusAccuracy: 0.004,
        statusResistance: 0.012,
        physicalPenetration: 0.003,
        magicalPenetration: 0.003,
        lifesteal: 0.001,
        healingPower: 0.005,
        regen: 0.004,
      ),
      CombatJobIds.homunculusMage: BattleCombatStats(
        maxHp: 20,
        physicalAttack: 1,
        physicalDefense: 2,
        magicalAttack: 4,
        magicalDefense: 4,
        speed: 1,
        critChance: 0.004,
        critDamage: 0.02,
        accuracy: 0.006,
        evasion: 0.004,
        statusAccuracy: 0.012,
        statusResistance: 0.012,
        physicalPenetration: 0.001,
        magicalPenetration: 0.005,
        lifesteal: 0,
        healingPower: 0.012,
        regen: 0.004,
      ),
      CombatJobIds.homunculusRogue: BattleCombatStats(
        maxHp: 18,
        physicalAttack: 3,
        physicalDefense: 1,
        magicalAttack: 2,
        magicalDefense: 1,
        speed: 2,
        critChance: 0.01,
        critDamage: 0.02,
        accuracy: 0.01,
        evasion: 0.012,
        statusAccuracy: 0.006,
        statusResistance: 0.006,
        physicalPenetration: 0.004,
        magicalPenetration: 0.003,
        lifesteal: 0.002,
        healingPower: 0.004,
        regen: 0.004,
      ),
      CombatJobIds.homunculusArcher: BattleCombatStats(
        maxHp: 18,
        physicalAttack: 3,
        physicalDefense: 1,
        magicalAttack: 2,
        magicalDefense: 2,
        speed: 2,
        critChance: 0.008,
        critDamage: 0.02,
        accuracy: 0.012,
        evasion: 0.008,
        statusAccuracy: 0.005,
        statusResistance: 0.006,
        physicalPenetration: 0.004,
        magicalPenetration: 0.002,
        lifesteal: 0.001,
        healingPower: 0.004,
        regen: 0.004,
      ),
    };

const Map<String, BattleCombatStats> _rankGrowthByJob =
    <String, BattleCombatStats>{
      CombatJobIds.mercenaryWarrior: BattleCombatStats(
        maxHp: 18,
        physicalAttack: 3,
        physicalDefense: 3,
        magicalAttack: 1,
        magicalDefense: 2,
        speed: 1,
        critChance: 0.005,
        critDamage: 0.02,
        accuracy: 0.004,
        evasion: 0.002,
        statusAccuracy: 0.002,
        statusResistance: 0.006,
        physicalPenetration: 0.003,
        magicalPenetration: 0.001,
        lifesteal: 0.001,
        healingPower: 0,
        regen: 0.002,
      ),
      CombatJobIds.mercenaryMage: BattleCombatStats(
        maxHp: 15,
        physicalAttack: 1,
        physicalDefense: 1,
        magicalAttack: 4,
        magicalDefense: 3,
        speed: 1,
        critChance: 0.005,
        critDamage: 0.02,
        accuracy: 0.004,
        evasion: 0.002,
        statusAccuracy: 0.008,
        statusResistance: 0.006,
        physicalPenetration: 0.001,
        magicalPenetration: 0.004,
        lifesteal: 0,
        healingPower: 0.008,
        regen: 0.002,
      ),
      CombatJobIds.mercenaryRogue: BattleCombatStats(
        maxHp: 14,
        physicalAttack: 3,
        physicalDefense: 1,
        magicalAttack: 1,
        magicalDefense: 1,
        speed: 2,
        critChance: 0.01,
        critDamage: 0.02,
        accuracy: 0.008,
        evasion: 0.01,
        statusAccuracy: 0.004,
        statusResistance: 0.004,
        physicalPenetration: 0.004,
        magicalPenetration: 0.001,
        lifesteal: 0.002,
        healingPower: 0,
        regen: 0.001,
      ),
      CombatJobIds.mercenaryArcher: BattleCombatStats(
        maxHp: 14,
        physicalAttack: 3,
        physicalDefense: 1,
        magicalAttack: 1,
        magicalDefense: 2,
        speed: 1,
        critChance: 0.008,
        critDamage: 0.02,
        accuracy: 0.01,
        evasion: 0.006,
        statusAccuracy: 0.003,
        statusResistance: 0.004,
        physicalPenetration: 0.004,
        magicalPenetration: 0.001,
        lifesteal: 0.001,
        healingPower: 0,
        regen: 0.001,
      ),
      CombatJobIds.homunculusWarrior: BattleCombatStats(
        maxHp: 16,
        physicalAttack: 2,
        physicalDefense: 3,
        magicalAttack: 2,
        magicalDefense: 3,
        speed: 1,
        critChance: 0.004,
        critDamage: 0.02,
        accuracy: 0.004,
        evasion: 0.002,
        statusAccuracy: 0.003,
        statusResistance: 0.007,
        physicalPenetration: 0.002,
        magicalPenetration: 0.002,
        lifesteal: 0.001,
        healingPower: 0.004,
        regen: 0.003,
      ),
      CombatJobIds.homunculusMage: BattleCombatStats(
        maxHp: 14,
        physicalAttack: 1,
        physicalDefense: 1,
        magicalAttack: 3,
        magicalDefense: 3,
        speed: 1,
        critChance: 0.004,
        critDamage: 0.02,
        accuracy: 0.004,
        evasion: 0.002,
        statusAccuracy: 0.008,
        statusResistance: 0.007,
        physicalPenetration: 0.001,
        magicalPenetration: 0.004,
        lifesteal: 0,
        healingPower: 0.008,
        regen: 0.003,
      ),
      CombatJobIds.homunculusRogue: BattleCombatStats(
        maxHp: 13,
        physicalAttack: 2,
        physicalDefense: 1,
        magicalAttack: 2,
        magicalDefense: 1,
        speed: 2,
        critChance: 0.01,
        critDamage: 0.02,
        accuracy: 0.008,
        evasion: 0.01,
        statusAccuracy: 0.004,
        statusResistance: 0.004,
        physicalPenetration: 0.003,
        magicalPenetration: 0.002,
        lifesteal: 0.001,
        healingPower: 0.003,
        regen: 0.003,
      ),
      CombatJobIds.homunculusArcher: BattleCombatStats(
        maxHp: 13,
        physicalAttack: 2,
        physicalDefense: 1,
        magicalAttack: 2,
        magicalDefense: 1,
        speed: 1,
        critChance: 0.008,
        critDamage: 0.02,
        accuracy: 0.01,
        evasion: 0.006,
        statusAccuracy: 0.003,
        statusResistance: 0.004,
        physicalPenetration: 0.003,
        magicalPenetration: 0.001,
        lifesteal: 0.001,
        healingPower: 0.003,
        regen: 0.003,
      ),
    };

const Map<String, int> _levelHpGrowthByJob = <String, int>{
  CombatJobIds.mercenaryWarrior: 14,
  CombatJobIds.mercenaryMage: 10,
  CombatJobIds.mercenaryRogue: 11,
  CombatJobIds.mercenaryArcher: 11,
  CombatJobIds.homunculusWarrior: 12,
  CombatJobIds.homunculusMage: 11,
  CombatJobIds.homunculusRogue: 10,
  CombatJobIds.homunculusArcher: 10,
};
