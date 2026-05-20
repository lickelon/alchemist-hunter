import 'package:alchemist_hunter/app/session/app_session.dart';
import 'package:alchemist_hunter/app/catalog/app_catalog_providers.dart';
import 'package:alchemist_hunter/features/battle/domain/services/battle_party_power_service.dart';
import 'package:alchemist_hunter/features/battle/presentation/viewmodels/battle_stage_state_selectors.dart';
import 'package:alchemist_hunter/features/characters/domain/models.dart';
import 'package:alchemist_hunter/features/workshop/domain/models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BattleAssignmentCharacterView {
  const BattleAssignmentCharacterView({
    required this.id,
    required this.name,
    required this.typeLabel,
    required this.power,
    required this.assigned,
    required this.assignable,
    required this.assignmentHint,
  });

  final String id;
  final String name;
  final String typeLabel;
  final int power;
  final bool assigned;
  final bool assignable;
  final String assignmentHint;
}

class BattleAssignmentPotionView {
  const BattleAssignmentPotionView({
    required this.stackKey,
    required this.label,
    required this.ownedCount,
    required this.selectedCount,
  });

  final String stackKey;
  final String label;
  final int ownedCount;
  final int selectedCount;
}

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
      final BattlePartyPowerService powerService =
          const BattlePartyPowerService();
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
              name: character.name,
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

final battleStagePotionLoadoutProvider =
    Provider.family<Map<String, int>, String>((Ref ref, String stageId) {
      return ref.watch(
        sessionControllerProvider.select(
          (SessionState state) =>
              state.battle.stagePotionLoadouts[stageId] ??
              const <String, int>{},
        ),
      );
    });

final battleStageAssignmentPotionViewsProvider =
    Provider.family<List<BattleAssignmentPotionView>, String>((
      Ref ref,
      String stageId,
    ) {
      final SessionState state = ref.watch(sessionControllerProvider);
      final Map<String, int> selectedCounts = ref.watch(
        battleStagePotionLoadoutProvider(stageId),
      );
      final List<PotionBlueprint> potions = ref.watch(potionsProvider);

      final List<BattleAssignmentPotionView> views = state
          .workshop
          .craftedPotionStacks
          .entries
          .where((MapEntry<String, int> entry) => entry.value > 0)
          .map((MapEntry<String, int> entry) {
            final CraftedPotion? detail =
                state.workshop.craftedPotionDetails[entry.key];
            if (detail == null) {
              return null;
            }
            final PotionBlueprint? potion = potions
                .where((PotionBlueprint item) => item.id == detail.typePotionId)
                .firstOrNull;
            if (potion == null || potion.useType == PotionUseType.sell) {
              return null;
            }
            final String qualityLabel = detail.qualityGrade.name.toUpperCase();
            return BattleAssignmentPotionView(
              stackKey: entry.key,
              label: '${potion.name} $qualityLabel',
              ownedCount: entry.value,
              selectedCount: selectedCounts[entry.key] ?? 0,
            );
          })
          .whereType<BattleAssignmentPotionView>()
          .toList(growable: false);

      views.sort((
        BattleAssignmentPotionView left,
        BattleAssignmentPotionView right,
      ) {
        return left.label.compareTo(right.label);
      });
      return views;
    });
