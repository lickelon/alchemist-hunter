import 'package:alchemist_hunter/features/battle/domain/models.dart';
import 'package:alchemist_hunter/features/battle/combat/domain/services/battle_equipment_stat_service.dart';
import 'package:alchemist_hunter/features/battle/domain/repositories/battle_catalog_repository.dart';
import 'package:alchemist_hunter/features/characters/domain/models.dart';

part 'battle_summary_power_calculator.dart';

class BattleCombatStatService {
  BattleCombatStatService({
    required BattleCatalogRepository battleCatalogRepository,
    BattleEquipmentStatService equipmentStatService =
        const BattleEquipmentStatService(),
  }) : _battleCatalogRepository = battleCatalogRepository,
       _equipmentStatService = equipmentStatService;

  final BattleCatalogRepository _battleCatalogRepository;
  final BattleEquipmentStatService _equipmentStatService;

  HeroProfile buildHeroProfile(CharacterProgress character) {
    final BattleCombatStats stats = buildStats(character);
    final String jobId = character.resolvedCombatJobId;
    final BattleCombatJobDefinition combatJob = _battleCatalogRepository
        .combatJobDefinition(jobId);
    final BattleCombatJobRankDefinition rankDefinition = combatJob
        .rankDefinition(
          tierIndex: character.tierIndex,
          rank: character.rankInCurrentTier,
        );
    final (List<BattleModifier>, List<BattlePassiveEffect>) equipmentEffects =
        _equipmentStatService.effectsForLoadout(character.equipment);
    final List<BattleModifier> modifiers = equipmentEffects.$1;
    final List<BattlePassiveEffect> passives = <BattlePassiveEffect>[
      ...rankDefinition.passiveIds.map(
        _battleCatalogRepository.combatPassiveEffect,
      ),
      ...equipmentEffects.$2,
    ];
    return HeroProfile(
      id: character.id,
      name: character.name,
      faction: combatJob.faction,
      discipline: combatJob.discipline,
      jobId: jobId,
      stats: stats,
      modifiers: modifiers,
      passives: passives,
      skills: rankDefinition.skillIds
          .map(_battleCatalogRepository.combatSkillDefinition)
          .toList(growable: false),
      power:
          _summaryPowerForStats(stats) +
          _summaryPowerForEffects(modifiers, passives),
    );
  }

  CombatFaction factionFor(CharacterProgress character) {
    return _battleCatalogRepository
        .combatJobDefinition(character.resolvedCombatJobId)
        .faction;
  }

  CombatDiscipline disciplineFor(String jobId) {
    return _battleCatalogRepository.combatJobDefinition(jobId).discipline;
  }

  BattleCombatStats buildStats(CharacterProgress character) {
    final String jobId = character.resolvedCombatJobId;
    final BattleCombatJobDefinition combatJob = _battleCatalogRepository
        .combatJobDefinition(jobId);
    final BattleCombatJobRankDefinition rankDefinition = combatJob
        .rankDefinition(
          tierIndex: character.tierIndex,
          rank: character.rankInCurrentTier,
        );

    return rankDefinition.stats +
        BattleCombatStats(
          maxHp: combatJob.levelHpGrowth * (character.level - 1),
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
