import 'package:alchemist_hunter/app/session/app_session.dart';
import 'package:alchemist_hunter/features/battle/domain/models.dart';
import 'package:alchemist_hunter/features/battle/domain/repositories/battle_catalog_repository.dart';
import 'package:alchemist_hunter/features/battle/domain/services/battle_expedition_progress_service.dart';
import 'package:alchemist_hunter/features/battle/domain/services/battle_expedition_resolver.dart';
import 'package:alchemist_hunter/features/battle/domain/services/battle_service.dart';
import 'package:alchemist_hunter/features/battle/domain/use_cases/battle_expedition_use_case.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const BattleExpeditionProgressService service =
      BattleExpeditionProgressService();
  const _FakeBattleCatalogRepository repository =
      _FakeBattleCatalogRepository();
  final DateTime start = DateTime(2026, 1, 1, 10);

  test('success encounter keeps ally hp for the next encounter search', () {
    final _ScriptedBattleExpeditionResolver resolver =
        _ScriptedBattleExpeditionResolver(
          steps: <_StepScript>[
            _StepScript(
              allies: <BattleRunUnitState>[_ally('merc_1', currentHp: 25)],
              success: true,
            ),
          ],
        );
    final SessionState state = _sessionWithExpedition(
      start,
      status: BattleExpeditionStatus.battling,
      runState: _runState(
        allies: <BattleRunUnitState>[_ally('merc_1', currentHp: 30)],
        currentEncounter: _encounter(),
      ),
    );

    final BattleExpeditionSyncResult result = service.syncExpeditions(
      state: state,
      syncFrom: start,
      now: start.add(const Duration(seconds: 1)),
      speedMultiplier: 1,
      battleActionInterval: const Duration(seconds: 1),
      battleExpeditionResolver: resolver,
      battleCatalogRepository: repository,
    );

    final BattleExpeditionState expedition =
        result.battle.stageExpeditions['stage_1']!;
    expect(expedition.status, BattleExpeditionStatus.searching);
    expect(expedition.runState!.currentEncounter, isNull);
    expect(expedition.runState!.allies.single.currentHp, 25);
  });

  test('search recovery heals only living allies', () {
    final _ScriptedBattleExpeditionResolver resolver =
        _ScriptedBattleExpeditionResolver();
    final SessionState state = _sessionWithExpedition(
      start,
      status: BattleExpeditionStatus.searching,
      runState: _runState(
        allies: <BattleRunUnitState>[
          _ally('merc_1', currentHp: 40),
          _ally('homo_1', currentHp: 0),
        ],
      ),
    );

    final BattleExpeditionSyncResult result = service.syncExpeditions(
      state: state,
      syncFrom: start,
      now: start.add(const Duration(seconds: 1)),
      speedMultiplier: 1,
      battleActionInterval: const Duration(seconds: 1),
      battleExpeditionResolver: resolver,
      battleCatalogRepository: repository,
    );

    final List<BattleRunUnitState> allies =
        result.battle.stageExpeditions['stage_1']!.runState!.allies;
    expect(allies[0].currentHp, greaterThan(40));
    expect(allies[1].currentHp, 0);
  });

  test('wipe switches to recovering and preserves pending claim', () {
    final _ScriptedBattleExpeditionResolver resolver =
        _ScriptedBattleExpeditionResolver(
          steps: <_StepScript>[
            _StepScript(
              allies: <BattleRunUnitState>[_ally('merc_1', currentHp: 0)],
              success: false,
              wiped: true,
            ),
          ],
        );
    final SessionState state = _sessionWithExpedition(
      start,
      status: BattleExpeditionStatus.battling,
      pendingClaim: const BattlePendingClaim(
        gold: 24,
        essence: 4,
        materials: <String, int>{'m_1': 1},
        hasSuccessfulBattle: true,
      ),
      runState: _runState(
        allies: <BattleRunUnitState>[_ally('merc_1', currentHp: 10)],
        currentEncounter: _encounter(),
      ),
    );

    final BattleExpeditionSyncResult result = service.syncExpeditions(
      state: state,
      syncFrom: start,
      now: start.add(const Duration(seconds: 1)),
      speedMultiplier: 1,
      battleActionInterval: const Duration(seconds: 1),
      battleExpeditionResolver: resolver,
      battleCatalogRepository: repository,
    );

    final BattleExpeditionState expedition =
        result.battle.stageExpeditions['stage_1']!;
    expect(expedition.status, BattleExpeditionStatus.recovering);
    expect(expedition.pendingClaim.gold, 24);
    expect(expedition.pendingClaim.essence, 4);
    expect(expedition.pendingClaim.materials, <String, int>{'m_1': 1});
    expect(result.battle.progress.stageCurrentWinStreaks['stage_1'], 0);
  });

  test('recovery completion resets allies to full hp', () {
    final _ScriptedBattleExpeditionResolver resolver =
        _ScriptedBattleExpeditionResolver(
          encounterAllies: <BattleRunUnitState>[_ally('merc_1')],
        );
    final SessionState state = _sessionWithExpedition(
      start,
      status: BattleExpeditionStatus.recovering,
      runState: _runState(
        allies: <BattleRunUnitState>[_ally('merc_1', currentHp: 0)],
      ),
    );

    final BattleExpeditionSyncResult result = service.syncExpeditions(
      state: state,
      syncFrom: start,
      now: start.add(const Duration(seconds: 2)),
      speedMultiplier: 1,
      battleActionInterval: const Duration(seconds: 1),
      battleExpeditionResolver: resolver,
      battleCatalogRepository: repository,
    );

    final BattleExpeditionState expedition =
        result.battle.stageExpeditions['stage_1']!;
    expect(expedition.status, BattleExpeditionStatus.searching);
    expect(expedition.runState!.allies.single.currentHp, 100);
  });

  test(
    'successful encounter grants xp immediately and claim does not duplicate xp',
    () {
      final _ScriptedBattleExpeditionResolver resolver =
          _ScriptedBattleExpeditionResolver(
            steps: <_StepScript>[
              _StepScript(
                allies: <BattleRunUnitState>[_ally('merc_1', currentHp: 80)],
                success: true,
              ),
            ],
          );
      final SessionState state = _sessionWithExpedition(
        start,
        status: BattleExpeditionStatus.battling,
        runState: _runState(
          allies: <BattleRunUnitState>[_ally('merc_1')],
          currentEncounter: _encounter(),
        ),
      );

      final BattleExpeditionSyncResult result = service.syncExpeditions(
        state: state,
        syncFrom: start,
        now: start.add(const Duration(seconds: 1)),
        speedMultiplier: 1,
        battleActionInterval: const Duration(seconds: 1),
        battleExpeditionResolver: resolver,
        battleCatalogRepository: repository,
      );
      final int xpAfterEncounter = result.characters.mercenaries.first.xp;

      final SessionState claimed = const BattleExpeditionUseCase()
          .claimStageRewards(
            state: state.copyWith(
              battle: result.battle,
              characters: result.characters,
            ),
            stageId: 'stage_1',
            battleCatalogRepository: repository,
          );

      expect(xpAfterEncounter, greaterThan(0));
      expect(claimed.characters.mercenaries.first.xp, xpAfterEncounter);
    },
  );

  test('loadout fallback remains on current encounter and recent log', () {
    final _ScriptedBattleExpeditionResolver resolver =
        _ScriptedBattleExpeditionResolver(
          fallback: true,
          steps: <_StepScript>[
            _StepScript(
              allies: <BattleRunUnitState>[_ally('merc_1', currentHp: 80)],
              success: true,
            ),
          ],
        );
    final SessionState searchingState = _sessionWithExpedition(
      start,
      status: BattleExpeditionStatus.searching,
    );

    final BattleExpeditionSyncResult encounterResult = service.syncExpeditions(
      state: searchingState,
      syncFrom: start,
      now: start.add(const Duration(seconds: 1)),
      speedMultiplier: 1,
      battleActionInterval: const Duration(seconds: 1),
      battleExpeditionResolver: resolver,
      battleCatalogRepository: repository,
    );
    final BattleEncounterRuntimeState currentEncounter = encounterResult
        .battle
        .stageExpeditions['stage_1']!
        .runState!
        .currentEncounter!;
    expect(currentEncounter.usedLoadoutFallback, isTrue);
    expect(encounterResult.consumedPotionStacks, isEmpty);

    final BattleExpeditionSyncResult finishedResult = service.syncExpeditions(
      state: searchingState.copyWith(
        battle: encounterResult.battle,
        characters: encounterResult.characters,
      ),
      syncFrom: start.add(const Duration(seconds: 1)),
      now: start.add(const Duration(seconds: 2)),
      speedMultiplier: 1,
      battleActionInterval: const Duration(seconds: 1),
      battleExpeditionResolver: resolver,
      battleCatalogRepository: repository,
    );

    expect(
      finishedResult
          .battle
          .stageExpeditions['stage_1']!
          .recentLogs
          .first
          .usedLoadoutFallback,
      isTrue,
    );
  });
}

class _FakeBattleCatalogRepository implements BattleCatalogRepository {
  const _FakeBattleCatalogRepository();

  @override
  List<String> stageCatalog() => const <String>['stage_1', 'stage_2'];

  @override
  BattleStageDefinition stageDefinition(String stageId) {
    if (stageId == 'stage_2') {
      return const BattleStageDefinition(
        id: 'stage_2',
        name: 'Stage 2',
        recommendedPower: 1,
        searchDuration: Duration(seconds: 1),
        recoveryDuration: Duration(seconds: 2),
        encounters: <BattleStageEncounterDefinition>[],
        goldSuccess: 24,
        goldFailurePenalty: 0,
        essenceSuccess: 4,
        essenceFailure: 0,
        xpSuccessBase: 8,
        xpFailureBase: 0,
        unlockCondition: BattleStageUnlockCondition(
          requiredStageId: 'stage_1',
          requiredWinStreakCount: 3,
          label: '잠금 조건: Stage 1에서 실패 없이 3회 연속 승리',
        ),
      );
    }
    return const BattleStageDefinition(
      id: 'stage_1',
      name: 'Stage 1',
      recommendedPower: 1,
      searchDuration: Duration(seconds: 1),
      recoveryDuration: Duration(seconds: 2),
      encounters: <BattleStageEncounterDefinition>[
        BattleStageEncounterDefinition(
          id: 'encounter_1',
          enemySetId: 'enemy_set_1',
          chance: 1,
        ),
      ],
      goldSuccess: 24,
      goldFailurePenalty: 0,
      essenceSuccess: 4,
      essenceFailure: 0,
      xpSuccessBase: 8,
      xpFailureBase: 0,
      clearUnlockFlags: <String>{'stage_2'},
    );
  }

  @override
  List<BattleStageEncounterDefinition> encounterDefinitionsForStage(
    String stageId,
  ) => stageDefinition(stageId).encounters;

  @override
  List<BattleEnemyDefinition> enemyDefinitionsForStage(String stageId) =>
      const <BattleEnemyDefinition>[];

  @override
  List<BattleEnemyDefinition> enemyDefinitionsForSet(String enemySetId) =>
      const <BattleEnemyDefinition>[];

  @override
  BattleDropTable dropTable(String stageId) => const BattleDropTable(
    stageId: 'stage_1',
    normalDrops: <BattleDropEntry>[],
    specialDrops: <BattleDropEntry>[],
  );

  @override
  BattleDropTable dropTableForEnemySet({
    required String stageId,
    required String enemySetId,
  }) => dropTable(stageId);
}

class _ScriptedBattleExpeditionResolver implements BattleExpeditionResolver {
  _ScriptedBattleExpeditionResolver({
    this.fallback = false,
    List<BattleRunUnitState>? encounterAllies,
    List<_StepScript> steps = const <_StepScript>[],
  }) : encounterAllies =
           encounterAllies ?? <BattleRunUnitState>[_ally('merc_1')],
       _steps = steps;

  final bool fallback;
  final List<BattleRunUnitState> encounterAllies;
  final List<_StepScript> _steps;
  int _stepIndex = 0;

  @override
  BattleEncounterResolution resolveEncounter({
    required SessionState state,
    required String stageId,
    BattleRunState? currentRunState,
    required BattleCatalogRepository battleCatalogRepository,
  }) {
    final List<BattleRunUnitState> allies =
        currentRunState?.allies.isNotEmpty ?? false
        ? currentRunState!.allies
        : encounterAllies;
    final BattleEncounterRuntimeState encounter = _encounter(
      usedLoadoutFallback: fallback,
    );
    return BattleEncounterResolution(
      runState: (currentRunState ?? const BattleRunState()).copyWith(
        allies: allies,
        currentEncounter: encounter,
      ),
      summary: 'encounter',
      consumedPotionLoadout: fallback
          ? const <String, int>{}
          : const <String, int>{'p_1|a': 1},
      usedLoadoutFallback: fallback,
    );
  }

  @override
  BattleEncounterStepResult runEncounterStep({
    required List<BattleRunUnitState> allies,
    required BattleEncounterRuntimeState encounter,
    required int potionBoost,
  }) {
    final _StepScript script = _stepIndex < _steps.length
        ? _steps[_stepIndex++]
        : _StepScript(allies: allies, success: true);
    final int lifecycle = encounter.turnInEncounter + 1;
    return BattleEncounterStepResult(
      allies: script.allies,
      encounter: encounter.copyWith(
        recentActionLogs: <BattleActionLog>[
          ...encounter.recentActionLogs,
          BattleActionLog(
            lifecycle: lifecycle,
            turn: lifecycle,
            type: BattleActionType.attack,
            actorId: 'merc_1',
            actorName: 'Rookie Swordsman',
            actorTeam: BattleTeam.ally,
            targetId: 'enemy_1',
            targetName: 'Enemy',
            targetTeam: BattleTeam.enemy,
            damage: script.success ? 10 : 0,
            actorHpAfter: script.allies.first.currentHp,
            targetHpAfter: script.success ? 0 : 10,
          ),
        ],
        turnInEncounter: lifecycle,
      ),
      ended: true,
      success: script.success,
      wiped: script.wiped,
    );
  }

  @override
  Map<String, int> resolveRewards({
    required bool success,
    required BattleDropTable table,
  }) {
    return success ? const <String, int>{'m_1': 1} : const <String, int>{};
  }
}

class _StepScript {
  const _StepScript({
    required this.allies,
    required this.success,
    this.wiped = false,
  });

  final List<BattleRunUnitState> allies;
  final bool success;
  final bool wiped;
}

SessionState _sessionWithExpedition(
  DateTime now, {
  required BattleExpeditionStatus status,
  BattleRunState? runState,
  BattlePendingClaim pendingClaim = const BattlePendingClaim(),
}) {
  final SessionState state = createInitialSessionState(now);
  return state.copyWith(
    battle: state.battle.copyWith(
      stageExpeditions: <String, BattleExpeditionState>{
        'stage_1': BattleExpeditionState(
          status: status,
          lastProgressedAt: now,
          phaseProgress: Duration.zero,
          runState: runState,
          pendingClaim: pendingClaim,
        ),
      },
    ),
  );
}

BattleRunState _runState({
  required List<BattleRunUnitState> allies,
  BattleEncounterRuntimeState? currentEncounter,
}) {
  return BattleRunState(allies: allies, currentEncounter: currentEncounter);
}

BattleEncounterRuntimeState _encounter({bool usedLoadoutFallback = false}) {
  return BattleEncounterRuntimeState(
    encounterId: 'encounter_1',
    encounterIndex: 1,
    enemySetId: 'enemy_set_1',
    enemies: <BattleRunUnitState>[_enemy('enemy_1')],
    usedLoadoutFallback: usedLoadoutFallback,
  );
}

BattleRunUnitState _ally(String id, {int currentHp = 100}) {
  return BattleRunUnitState(
    unitId: id,
    name: id,
    team: BattleTeam.ally,
    faction: CombatFaction.mercenary,
    stats: _stats(maxHp: 100, regen: 0.1),
    currentHp: currentHp,
  );
}

BattleRunUnitState _enemy(String id, {int currentHp = 10}) {
  return BattleRunUnitState(
    unitId: id,
    name: id,
    team: BattleTeam.enemy,
    faction: CombatFaction.mercenary,
    stats: _stats(maxHp: 10),
    currentHp: currentHp,
  );
}

BattleCombatStats _stats({required int maxHp, double regen = 0}) {
  return BattleCombatStats(
    maxHp: maxHp,
    physicalAttack: 10,
    physicalDefense: 1,
    magicalAttack: 0,
    magicalDefense: 1,
    speed: 10,
    critChance: 0,
    critDamage: 0.5,
    accuracy: 1,
    evasion: 0,
    statusAccuracy: 0,
    statusResistance: 0,
    physicalPenetration: 0,
    magicalPenetration: 0,
    lifesteal: 0,
    healingPower: 0,
    regen: regen,
  );
}
