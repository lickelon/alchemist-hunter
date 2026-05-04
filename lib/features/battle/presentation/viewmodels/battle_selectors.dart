import 'package:alchemist_hunter/app/session/app_session.dart';
import 'package:alchemist_hunter/features/battle/battle_catalog.dart';
import 'package:alchemist_hunter/features/battle/domain/models.dart';
import 'package:alchemist_hunter/features/battle/domain/repositories/battle_catalog_repository.dart';
import 'package:alchemist_hunter/features/battle/domain/services/battle_party_power_service.dart';
import 'package:alchemist_hunter/features/characters/domain/models.dart';
import 'package:alchemist_hunter/features/workshop/domain/repositories/material_catalog_repository.dart';
import 'package:alchemist_hunter/features/workshop/workshop_catalog.dart';
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

class BattleDropChanceView {
  const BattleDropChanceView({
    required this.materialName,
    required this.quantityLabel,
    required this.chanceLabel,
  });

  final String materialName;
  final String quantityLabel;
  final String chanceLabel;
}

class BattleEnemyDropView {
  const BattleEnemyDropView({
    required this.enemyName,
    required this.identityLabel,
    required this.statLines,
    required this.effectLines,
    required this.normalDrops,
    required this.specialDrops,
  });

  final String enemyName;
  final String identityLabel;
  final List<String> statLines;
  final List<String> effectLines;
  final List<BattleDropChanceView> normalDrops;
  final List<BattleDropChanceView> specialDrops;
}

class BattleStageDropOverviewView {
  const BattleStageDropOverviewView({
    required this.stageName,
    required this.recommendedPower,
    required this.enemies,
  });

  final String stageName;
  final int recommendedPower;
  final List<BattleEnemyDropView> enemies;
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

final battleStageAssignmentProvider = Provider.family<List<String>, String>((
  Ref ref,
  String stageId,
) {
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

final battleStageRecentLogsProvider =
    Provider.family<List<BattleLogEntry>, String>((Ref ref, String stageId) {
      return ref.watch(battleStageExpeditionStateProvider(stageId)).recentLogs;
    });

final battleStagePartyPowerProvider = Provider.family<int, String>((
  Ref ref,
  String stageId,
) {
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

final battleStageStatusLabelProvider = Provider.family<String, String>((
  Ref ref,
  String stageId,
) {
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

final battleStagePendingClaimLabelProvider = Provider.family<String, String>((
  Ref ref,
  String stageId,
) {
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

final battleStageLastResultLabelProvider = Provider.family<String, String>((
  Ref ref,
  String stageId,
) {
  final List<BattleLogEntry> logs = ref.watch(
    battleStageRecentLogsProvider(stageId),
  );
  if (logs.isEmpty) {
    return '최근 결과 없음';
  }
  final BattleLogEntry log = logs.first;
  return '최근 결과 ${log.success ? '성공' : '실패'} / Gold ${log.gold >= 0 ? '+' : ''}${log.gold} / 재료 ${log.materials.length}종';
});

final battleStageDropOverviewProvider =
    Provider.family<BattleStageDropOverviewView, String>((
      Ref ref,
      String stageId,
    ) {
      final BattleCatalogRepository battleCatalog = ref.watch(
        battleCatalogRepositoryProvider,
      );
      final MaterialCatalogRepository materialCatalog = ref.watch(
        materialCatalogRepositoryProvider,
      );
      final BattleStageDefinition stage = battleCatalog.stageDefinition(
        stageId,
      );
      final List<BattleEnemyDefinition> enemies = battleCatalog
          .enemyDefinitionsForStage(stageId);

      return BattleStageDropOverviewView(
        stageName: stage.name,
        recommendedPower: stage.recommendedPower,
        enemies: enemies
            .map((BattleEnemyDefinition enemy) {
              return BattleEnemyDropView(
                enemyName: enemy.name,
                identityLabel:
                    '${_factionLabel(enemy.faction)} / ${enemy.summary}',
                statLines: _enemyStatLines(enemy.stats),
                effectLines: _enemyEffectLines(enemy),
                normalDrops: enemy.normalDrops
                    .map(
                      (BattleDropEntry drop) => BattleDropChanceView(
                        materialName:
                            materialCatalog.materialName(drop.materialId) ??
                            drop.materialId,
                        quantityLabel: _quantityLabel(drop),
                        chanceLabel: _chanceLabel(drop.chance),
                      ),
                    )
                    .toList(growable: false),
                specialDrops: enemy.specialDrops
                    .map(
                      (BattleDropEntry drop) => BattleDropChanceView(
                        materialName:
                            materialCatalog.materialName(drop.materialId) ??
                            drop.materialId,
                        quantityLabel: _quantityLabel(drop),
                        chanceLabel: _chanceLabel(drop.chance),
                      ),
                    )
                    .toList(growable: false),
              );
            })
            .toList(growable: false),
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
                  return entry.key.replaceFirst('stage_', 'Stage ');
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

String _factionLabel(CombatFaction faction) {
  return switch (faction) {
    CombatFaction.mercenary => '용병',
    CombatFaction.homunculus => '호문쿨루스',
  };
}

String _quantityLabel(BattleDropEntry drop) {
  if (drop.min == drop.max) {
    return 'x${drop.min}';
  }
  return 'x${drop.min}-${drop.max}';
}

String _chanceLabel(double chance) {
  return '${(chance * 100).round()}%';
}

List<String> _enemyStatLines(BattleCombatStats stats) {
  return <String>[
    'HP ${stats.maxHp} / 물공 ${stats.physicalAttack} / 물방 ${stats.physicalDefense}',
    '마공 ${stats.magicalAttack} / 마방 ${stats.magicalDefense} / 속도 ${stats.speed}',
    '치확 ${_chanceLabel(stats.critChance)} / 치피 ${_chanceLabel(stats.critDamage)}',
    '명중 ${_chanceLabel(stats.accuracy)} / 회피 ${_chanceLabel(stats.evasion)}',
    '상태적중 ${_chanceLabel(stats.statusAccuracy)} / 상태저항 ${_chanceLabel(stats.statusResistance)}',
    '물관 ${_chanceLabel(stats.physicalPenetration)} / 마관 ${_chanceLabel(stats.magicalPenetration)}',
    '흡혈 ${_chanceLabel(stats.lifesteal)} / 회복력 ${_chanceLabel(stats.healingPower)} / 재생 ${_chanceLabel(stats.regen)}',
  ];
}

List<String> _enemyEffectLines(BattleEnemyDefinition enemy) {
  final List<String> lines = <String>[
    ...enemy.modifiers.map(_modifierLabel),
    ...enemy.passives.map(_passiveLabel),
  ];
  if (lines.isEmpty) {
    return const <String>['특수 효과 없음'];
  }
  return lines;
}

String _modifierLabel(BattleModifier modifier) {
  final String schoolLabel = switch (modifier.school) {
    DamageSchool.any => '',
    DamageSchool.physical => ' / 물리',
    DamageSchool.magical => ' / 마법',
  };
  final String targetLabel = modifier.targetFaction == null
      ? ''
      : ' / 대 ${_factionLabel(modifier.targetFaction!)}';
  final String valueLabel = modifier.mode == BattleModifierMode.percent
      ? _signedChanceLabel(modifier.value)
      : _signedChanceLabel(modifier.value);
  final String baseLabel = switch (modifier.type) {
    BattleModifierType.damageDealt => '주는 피해 $valueLabel',
    BattleModifierType.damageTaken => '받는 피해 $valueLabel',
    BattleModifierType.critRate => '치확 $valueLabel',
    BattleModifierType.critDamage => '치피 $valueLabel',
    BattleModifierType.accuracy => '명중 $valueLabel',
    BattleModifierType.evasion => '회피 $valueLabel',
    BattleModifierType.lifesteal => '흡혈 $valueLabel',
    BattleModifierType.healingPower => '회복력 $valueLabel',
    BattleModifierType.regen => '재생 $valueLabel',
  };
  return '$baseLabel$schoolLabel$targetLabel';
}

String _passiveLabel(BattlePassiveEffect passive) {
  return switch (passive.type) {
    BattlePassiveEffectType.alwaysHit => '패시브: 필중',
    BattlePassiveEffectType.extraAttack => '패시브: 추가 공격 +${passive.value ?? 1}회',
  };
}

String _signedChanceLabel(double value) {
  final int percent = (value * 100).round();
  if (percent > 0) {
    return '+$percent%';
  }
  return '$percent%';
}
