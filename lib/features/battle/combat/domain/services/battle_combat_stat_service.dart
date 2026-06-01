import 'package:alchemist_hunter/features/battle/domain/models.dart';
import 'package:alchemist_hunter/features/battle/combat/domain/services/battle_equipment_stat_service.dart';
import 'package:alchemist_hunter/features/characters/domain/models.dart';

part 'battle_base_stat_tables.dart';
part 'battle_rank_growth_tables.dart';
part 'battle_combat_skill_tables.dart';
part 'battle_level_growth_tables.dart';
part 'battle_tier_growth_tables.dart';
part 'battle_summary_power_calculator.dart';

class BattleCombatStatService {
  const BattleCombatStatService({
    BattleEquipmentStatService equipmentStatService =
        const BattleEquipmentStatService(),
  }) : _equipmentStatService = equipmentStatService;

  final BattleEquipmentStatService _equipmentStatService;

  HeroProfile buildHeroProfile(CharacterProgress character) {
    final BattleCombatStats stats = buildStats(character);
    final String jobId = character.resolvedCombatJobId;
    final (List<BattleModifier>, List<BattlePassiveEffect>) equipmentEffects =
        _equipmentStatService.effectsForLoadout(character.equipment);
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
      skills: _skillsByJob[jobId] ?? const <BattleSkillDefinition>[],
      power:
          _summaryPowerForStats(stats) +
          _summaryPowerForEffects(modifiers, passives),
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
          maxMp: 0,
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
          mpRegen: 0,
        ) +
        _equipmentStatService.statsForLoadout(character.equipment) +
        _equipmentStatService.statModifiersForLoadout(character.equipment);
  }
}
