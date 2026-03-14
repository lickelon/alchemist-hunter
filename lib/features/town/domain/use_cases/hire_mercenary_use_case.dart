import 'package:alchemist_hunter/app/session/app_session.dart';
import 'package:alchemist_hunter/features/characters/domain/models.dart';
import 'package:alchemist_hunter/features/town/domain/models.dart';
import 'package:alchemist_hunter/features/town/domain/repositories/town_skill_tree_repository.dart';
import 'package:alchemist_hunter/features/town/domain/services/town_skill_tree_service.dart';

class HireMercenaryUseCase {
  const HireMercenaryUseCase();

  SessionState hireCandidate({
    required SessionState state,
    required String candidateId,
    required TownSkillTreeRepository townSkillTreeRepository,
    required TownSkillTreeService townSkillTreeService,
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
    final List<CharacterProgress> nextMercenaries = <CharacterProgress>[
      ...state.characters.mercenaries,
      CharacterProgress(
        id: 'mercenary_${state.characters.mercenaries.length + 1}_${candidate.id}',
        name: candidate.name,
        type: CharacterType.mercenary,
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
