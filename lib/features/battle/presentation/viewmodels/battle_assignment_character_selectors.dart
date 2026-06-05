import 'package:alchemist_hunter/app/session/app_session.dart';
import 'package:alchemist_hunter/app/catalog/app_catalog_providers.dart';
import 'package:alchemist_hunter/features/battle/domain/models.dart';
import 'package:alchemist_hunter/features/battle/domain/repositories/battle_catalog_repository.dart';
import 'package:alchemist_hunter/features/battle/combat/domain/services/battle_party_power_service.dart';
import 'package:alchemist_hunter/features/battle/presentation/viewmodels/battle_assignment_view_models.dart';
import 'package:alchemist_hunter/features/battle/presentation/viewmodels/battle_stage_progress_selectors.dart';
import 'package:alchemist_hunter/features/battle/presentation/viewmodels/battle_stage_runtime_selectors.dart';
import 'package:alchemist_hunter/features/characters/domain/models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final battleStageAssignmentCharacterViewsProvider =
    Provider.family<List<BattleAssignmentCharacterView>, String>((
      Ref ref,
      String stageId,
    ) {
      final SessionState state = ref.watch(sessionControllerProvider);
      final List<String> assignedIds = ref.watch(
        battleStageAssignmentProvider(stageId),
      );
      final Set<String> workshopAssignedIds = ref.watch(
        sessionControllerProvider.select(
          (SessionState state) =>
              state.workshop.supportAssignmentsByFunction.values.toSet(),
        ),
      );
      final int assignedCount = assignedIds.length;
      final BattleCatalogRepository battleCatalogRepository = ref.watch(
        battleCatalogRepositoryProvider,
      );
      final BattlePartyPowerService powerService = BattlePartyPowerService(
        battleCatalogRepository: battleCatalogRepository,
      );
      final List<CharacterProgress> characters = <CharacterProgress>[
        ...state.characters.mercenaries,
        ...state.characters.homunculi,
      ];

      return characters
          .map((CharacterProgress character) {
            final bool assigned = assignedIds.contains(character.id);
            final String? assignedOtherStage = state
                .battle
                .stageAssignments
                .entries
                .where((MapEntry<String, List<String>> entry) {
                  return entry.key != stageId &&
                      entry.value.contains(character.id);
                })
                .map((MapEntry<String, List<String>> entry) {
                  return ref.watch(battleStageDisplayNameProvider(entry.key));
                })
                .firstOrNull;
            final bool workshopAssigned = workshopAssignedIds.contains(
              character.id,
            );
            final bool assignable =
                assigned ||
                (!workshopAssigned &&
                    assignedOtherStage == null &&
                    assignedCount < 3);
            return BattleAssignmentCharacterView(
              id: character.id,
              name: _battleAssignmentCharacterName(
                character,
                battleCatalogRepository,
              ),
              typeLabel: character.type == CharacterType.mercenary
                  ? '용병'
                  : '호문쿨루스',
              power: powerService.powerForCharacter(character),
              assigned: assigned,
              assignable: assignable,
              assignmentHint: workshopAssigned && !assigned
                  ? '작업실 배치 중'
                  : assignedOtherStage != null && !assigned
                  ? '$assignedOtherStage 배치 중'
                  : '',
            );
          })
          .toList(growable: false);
    });

String _battleAssignmentCharacterName(
  CharacterProgress character,
  BattleCatalogRepository battleCatalogRepository,
) {
  return '${_tierName(character)} ${_jobName(character, battleCatalogRepository)}';
}

String _tierName(CharacterProgress character) {
  if (character.type == CharacterType.mercenary) {
    return switch (character.mercenaryTier ?? MercenaryTier.rookie) {
      MercenaryTier.rookie => 'Rookie',
      MercenaryTier.veteran => 'Veteran',
      MercenaryTier.elite => 'Elite',
      MercenaryTier.champion => 'Champion',
      MercenaryTier.legend => 'Legend',
    };
  }
  return switch (character.homunculusTier ?? HomunculusTier.nigredo) {
    HomunculusTier.nigredo => 'Nigredo',
    HomunculusTier.albedo => 'Albedo',
    HomunculusTier.citrinitas => 'Citrinitas',
    HomunculusTier.rubedo => 'Rubedo',
  };
}

String _jobName(
  CharacterProgress character,
  BattleCatalogRepository battleCatalogRepository,
) {
  final BattleCombatJobDefinition job = battleCatalogRepository
      .combatJobDefinition(character.resolvedCombatJobId);
  return switch (job.discipline) {
    CombatDiscipline.warrior => '전사',
    CombatDiscipline.mage => '마법사',
    CombatDiscipline.rogue => '도적',
    CombatDiscipline.archer => '궁수',
  };
}
