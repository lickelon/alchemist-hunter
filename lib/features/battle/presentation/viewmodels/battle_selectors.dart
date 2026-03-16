import 'package:alchemist_hunter/app/session/app_session.dart';
import 'package:alchemist_hunter/features/battle/domain/models.dart';
import 'package:alchemist_hunter/features/battle/domain/services/battle_party_power_service.dart';
import 'package:alchemist_hunter/features/characters/domain/models.dart';
import 'package:alchemist_hunter/features/battle/battle_catalog.dart';
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

final Provider<List<String>> unlockedStageListProvider = Provider<List<String>>(
  (Ref ref) {
    return ref.watch(stageCatalogProvider);
  },
);

final Provider<int> battleGoldProvider = Provider<int>((Ref ref) {
  return ref.watch(
    sessionControllerProvider.select((SessionState state) => state.player.gold),
  );
});

final Provider<int> battleEssenceProvider = Provider<int>((Ref ref) {
  return ref.watch(
    sessionControllerProvider.select(
      (SessionState state) => state.player.essence,
    ),
  );
});

final Provider<ProgressState> battleProgressProvider = Provider<ProgressState>((
  Ref ref,
) {
  return ref.watch(
    sessionControllerProvider.select(
      (SessionState state) => state.battle.progress,
    ),
  );
});

final battleStageAssignmentProvider =
    Provider.family<List<String>, String>((Ref ref, String stageId) {
      return ref.watch(
        sessionControllerProvider.select(
          (SessionState state) =>
              state.battle.stageAssignments[stageId] ?? const <String>[],
        ),
      );
    });

final battleStageExpeditionStateProvider =
    Provider.family<BattleExpeditionState, String>((Ref ref, String stageId) {
      return ref.watch(
        sessionControllerProvider.select(
          (SessionState state) =>
              state.battle.stageExpeditions[stageId] ??
              const BattleExpeditionState(
                status: BattleExpeditionStatus.idle,
                lastResolvedAt: null,
                cycleProgress: Duration.zero,
              ),
        ),
      );
    });

final battleStagePartyPowerProvider =
    Provider.family<int, String>((Ref ref, String stageId) {
      final List<String> assignedIds = ref.watch(
        battleStageAssignmentProvider(stageId),
      );
      return const BattlePartyPowerService().totalPower(
        ref.watch(
          sessionControllerProvider.select(
            (SessionState state) => state.characters,
          ),
        ),
        assignedCharacterIds: assignedIds,
      );
    });

final battleStageStatusLabelProvider =
    Provider.family<String, String>((Ref ref, String stageId) {
      final BattleExpeditionState expedition = ref.watch(
        battleStageExpeditionStateProvider(stageId),
      );
      return switch (expedition.status) {
        BattleExpeditionStatus.idle => '대기',
        BattleExpeditionStatus.running =>
          '원정 중 / ${expedition.cycleProgress.inSeconds}s 진행',
        BattleExpeditionStatus.paused =>
          '정지 / ${expedition.cycleProgress.inSeconds}s 진행',
      };
    });

final battleStagePendingClaimLabelProvider =
    Provider.family<String, String>((Ref ref, String stageId) {
      final BattleExpeditionState expedition = ref.watch(
        battleStageExpeditionStateProvider(stageId),
      );
      final BattlePendingClaim claim = expedition.pendingClaim;
      final int materialKinds = claim.materials.length;
      if (claim.isEmpty) {
        return '수령 대기 보상 없음';
      }
      return 'Gold ${claim.gold >= 0 ? '+' : ''}${claim.gold} / Essence +${claim.essence} / 재료 $materialKinds종 / XP ${claim.characterXp.values.fold<int>(0, (int total, int value) => total + value)}';
    });

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
      final BattlePartyPowerService powerService = const BattlePartyPowerService();
      final List<CharacterProgress> characters = <CharacterProgress>[
        ...state.characters.mercenaries,
        ...state.characters.homunculi,
      ];

      return characters.map((CharacterProgress character) {
        final bool assigned = assignedIds.contains(character.id);
        final String? assignedOtherStage = state.battle.stageAssignments.entries
            .where((MapEntry<String, List<String>> entry) {
              return entry.key != stageId && entry.value.contains(character.id);
            })
            .map((MapEntry<String, List<String>> entry) {
              return entry.key.replaceFirst('stage_', 'Stage ');
            })
            .firstOrNull;
        final bool workshopAssigned = workshopAssignedIds.contains(character.id);
        final bool assignable =
            assigned ||
            (!workshopAssigned && assignedOtherStage == null && assignedCount < 3);
        return BattleAssignmentCharacterView(
          id: character.id,
          name: character.name,
          typeLabel: character.type == CharacterType.mercenary ? '용병' : '호문쿨루스',
          power: powerService.powerForCharacter(character),
          assigned: assigned,
          assignable: assignable,
          assignmentHint: workshopAssigned && !assigned
              ? '작업실 배치 중'
              : assignedOtherStage != null && !assigned
              ? '$assignedOtherStage 배치 중'
              : '',
        );
      }).toList(growable: false);
    });
