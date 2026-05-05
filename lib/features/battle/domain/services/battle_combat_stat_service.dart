import 'package:alchemist_hunter/features/battle/domain/models.dart';
import 'package:alchemist_hunter/features/characters/domain/models.dart';
import 'package:alchemist_hunter/features/town/domain/models.dart';

part 'battle_combat_stat_tables.dart';

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
