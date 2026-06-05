import 'package:alchemist_hunter/app/session/session_state.dart';
import 'package:alchemist_hunter/features/battle/domain/models.dart';
import 'package:alchemist_hunter/features/battle/domain/repositories/battle_catalog_repository.dart';
import 'package:alchemist_hunter/features/characters/domain/models.dart';
import 'package:alchemist_hunter/features/characters/domain/services/character_id_factory.dart';
import 'package:alchemist_hunter/features/town/domain/models.dart';
import 'package:alchemist_hunter/features/town/domain/repositories/town_skill_tree_repository.dart';
import 'package:alchemist_hunter/features/town/domain/services/town_skill_tree_service.dart';

class HireMercenaryUseCase {
  const HireMercenaryUseCase();

  SessionState hireCandidate({
    required SessionState state,
    required String candidateId,
    required DateTime now,
    required TownSkillTreeRepository townSkillTreeRepository,
    required TownSkillTreeService townSkillTreeService,
    required BattleCatalogRepository battleCatalogRepository,
  }) {
    MercenaryCandidate? candidate;
    for (final MercenaryCandidate entry in state.town.mercenaryCandidates) {
      if (entry.id == candidateId) {
        candidate = entry;
        break;
      }
    }
    if (candidate == null) {
      return state;
    }
    final int effectiveHireCost = townSkillTreeService.discountedGoldCost(
      baseCost: candidate.hireCost,
      discountRate: townSkillTreeService.mercenaryHireDiscountRate(
        state,
        townSkillTreeRepository.nodes(),
      ),
    );
    if (state.player.gold < effectiveHireCost) {
      return state;
    }

    final List<MercenaryCandidate> nextCandidates = state
        .town
        .mercenaryCandidates
        .where((MercenaryCandidate entry) => entry.id != candidateId)
        .toList(growable: false);
    final int characterCount =
        state.characters.mercenaries.length + state.characters.homunculi.length;
    final String characterId = createOpaqueCharacterId(
      now: now,
      seed: characterCount + state.workshop.queue.length,
      reservedIds: collectCharacterIds(
        state.characters,
        pendingCharacters: state.workshop.queue.map(
          (job) => job.completedHomunculus,
        ),
      ),
    );
    final List<CharacterProgress> nextMercenaries = <CharacterProgress>[
      ...state.characters.mercenaries,
      CharacterProgress(
        id: characterId,
        name: mercenaryCandidateJobName(
          candidate.combatJobId,
          battleCatalogRepository,
        ),
        type: CharacterType.mercenary,
        combatJobId: candidate.combatJobId,
        level: 1,
        rank: 1,
        xp: 0,
        mercenaryTier: _tierFromIndex(candidate.tierIndex),
      ),
    ];

    return state.copyWith(
      player: state.player.copyWith(
        gold: state.player.gold - effectiveHireCost,
      ),
      town: state.town.copyWith(mercenaryCandidates: nextCandidates),
      characters: state.characters.copyWith(mercenaries: nextMercenaries),
    );
  }

  MercenaryTier _tierFromIndex(int tierIndex) {
    switch (tierIndex) {
      case 1:
        return MercenaryTier.rookie;
      case 2:
        return MercenaryTier.veteran;
      case 3:
        return MercenaryTier.elite;
      case 4:
        return MercenaryTier.champion;
      default:
        return MercenaryTier.legend;
    }
  }
}

String mercenaryCandidateDisplayName(
  MercenaryCandidate candidate,
  BattleCatalogRepository battleCatalogRepository,
) {
  return '${_tierName(candidate.tierIndex)} '
      '${mercenaryCandidateJobName(candidate.combatJobId, battleCatalogRepository)}';
}

String mercenaryCandidateJobName(
  String combatJobId,
  BattleCatalogRepository battleCatalogRepository,
) {
  final BattleCombatJobDefinition job = battleCatalogRepository
      .combatJobDefinition(combatJobId);
  return switch (job.discipline) {
    CombatDiscipline.warrior => '전사',
    CombatDiscipline.mage => '마법사',
    CombatDiscipline.rogue => '도적',
    CombatDiscipline.archer => '궁수',
  };
}

String _tierName(int tierIndex) {
  return switch (tierIndex) {
    1 => 'Rookie',
    2 => 'Veteran',
    3 => 'Elite',
    4 => 'Champion',
    _ => 'Legend',
  };
}
