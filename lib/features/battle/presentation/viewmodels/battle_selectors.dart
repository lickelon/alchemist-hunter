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
  });

  final String id;
  final String name;
  final String typeLabel;
  final int power;
  final bool assigned;
  final bool assignable;
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

final battleStageAssignmentCharacterViewsProvider =
    Provider.family<List<BattleAssignmentCharacterView>, String>((
      Ref ref,
      String stageId,
    ) {
      final SessionState state = ref.watch(sessionControllerProvider);
      final List<String> assignedIds = ref.watch(
        battleStageAssignmentProvider(stageId),
      );
      final int assignedCount = assignedIds.length;
      final BattlePartyPowerService powerService = const BattlePartyPowerService();
      final List<CharacterProgress> characters = <CharacterProgress>[
        ...state.characters.mercenaries,
        ...state.characters.homunculi,
      ];

      return characters.map((CharacterProgress character) {
        final bool assigned = assignedIds.contains(character.id);
        return BattleAssignmentCharacterView(
          id: character.id,
          name: character.name,
          typeLabel: character.type == CharacterType.mercenary ? '용병' : '호문쿨루스',
          power: powerService.powerForCharacter(character),
          assigned: assigned,
          assignable: assigned || assignedCount < 3,
        );
      }).toList(growable: false);
    });
