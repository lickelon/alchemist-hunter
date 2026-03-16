import 'dart:math';

import 'package:alchemist_hunter/app/session/app_session.dart';
import 'package:alchemist_hunter/features/battle/battle_catalog.dart';
import 'package:alchemist_hunter/features/battle/domain/use_cases/configure_battle_assignment_use_case.dart';
import 'package:alchemist_hunter/features/battle/domain/use_cases/battle_expedition_use_case.dart';
import 'package:alchemist_hunter/features/battle/domain/repositories/battle_catalog_repository.dart';
import 'package:alchemist_hunter/features/battle/domain/services/battle_expedition_resolver.dart';
import 'package:alchemist_hunter/features/battle/domain/services/battle_service.dart';
import 'package:alchemist_hunter/features/battle/domain/models.dart';
import 'package:alchemist_hunter/features/characters/domain/models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final Provider<BattleService> battleServiceProvider = Provider<BattleService>(
  (Ref ref) => BattleService(random: Random(11)),
);

class BattleController {
  BattleController(
    this._session, {
    BattleService? battleService,
    BattleExpeditionUseCase battleExpeditionUseCase =
        const BattleExpeditionUseCase(),
    ConfigureBattleAssignmentUseCase configureBattleAssignmentUseCase =
        const ConfigureBattleAssignmentUseCase(),
    BattleCatalogRepository? battleCatalogRepository,
  }) : _battleExpeditionUseCase = battleExpeditionUseCase,
       _configureBattleAssignmentUseCase = configureBattleAssignmentUseCase,
       _battleService = battleService,
       _battleCatalogRepository =
           battleCatalogRepository ?? const _MissingBattleCatalogRepository();

  final SessionController _session;
  final BattleExpeditionUseCase _battleExpeditionUseCase;
  final ConfigureBattleAssignmentUseCase _configureBattleAssignmentUseCase;
  final BattleService? _battleService;
  final BattleCatalogRepository _battleCatalogRepository;

  void runAutoBattle(String stageId) {
    final SessionState current = _session.snapshot();
    final BattleService battleService =
        _battleService ?? BattleService(random: Random(11));
    final BattleCatalogRepository battleCatalogRepository =
        _battleCatalogRepository;
    final SessionState started = _battleExpeditionUseCase.startExpedition(
      state: current,
      stageId: stageId,
      now: _session.now(),
    );
    if (identical(started, current)) {
      _session.appendLog('Battle assignment missing for $stageId');
      return;
    }

    final BattleCycleResolution resolution = DefaultBattleExpeditionResolver(
      battleService: battleService,
    ).resolveCycle(
      state: started,
      stageId: stageId,
      battleCatalogRepository: battleCatalogRepository,
    );
    final BattleExpeditionState expedition =
        started.battle.stageExpeditions[stageId]!;
    final Map<String, BattleExpeditionState> nextExpeditions =
        <String, BattleExpeditionState>{...started.battle.stageExpeditions};
    nextExpeditions[stageId] = expedition.copyWith(
      pendingClaim: resolution.pendingClaim,
      lastSummary: resolution.summary,
    );
    final SessionState pendingState = started.copyWith(
      battle: started.battle.copyWith(stageExpeditions: nextExpeditions),
    );
    final SessionState claimedState = _battleExpeditionUseCase.claimStageRewards(
      state: pendingState,
      stageId: stageId,
    );
    _session.applyState(claimedState);
    _session.appendLog('Battle ${resolution.summary} on $stageId');
  }

  void startExpedition(String stageId) {
    final SessionState current = _session.snapshot();
    final List<String> assigned = current.battle.stageAssignments[stageId] ??
        const <String>[];
    if (assigned.isEmpty) {
      _session.appendLog('원정 시작 실패 / 편성 없음');
      return;
    }

    final SessionState nextState = _battleExpeditionUseCase.startExpedition(
      state: current,
      stageId: stageId,
      now: _session.now(),
    );
    _session.applyState(nextState);
    _session.appendLog(
      identical(nextState, current)
          ? '이미 원정 중 / $stageId'
          : '${stageId.replaceFirst('stage_', 'Stage ')} 원정 시작',
    );
  }

  void stopExpedition(String stageId) {
    final SessionState current = _session.snapshot();
    final SessionState nextState = _battleExpeditionUseCase.stopExpedition(
      state: current,
      stageId: stageId,
      now: _session.now(),
    );
    _session.applyState(nextState);
    _session.appendLog(
      identical(nextState, current)
          ? '중지할 원정 없음 / $stageId'
          : '${stageId.replaceFirst('stage_', 'Stage ')} 원정 정지',
    );
  }

  void claimStageRewards(String stageId) {
    final SessionState current = _session.snapshot();
    final SessionState nextState = _battleExpeditionUseCase.claimStageRewards(
      state: current,
      stageId: stageId,
    );
    _session.applyState(nextState);
    _session.appendLog(
      identical(nextState, current)
          ? '수령할 원정 보상 없음'
          : '${stageId.replaceFirst('stage_', 'Stage ')} 보상 수령',
    );
  }

  void toggleStageAssignment(String stageId, String characterId) {
    final SessionState current = _session.snapshot();
    final List<String> before = current.battle.stageAssignments[stageId] ??
        const <String>[];
    final CharacterProgress? character = _findCharacter(current, characterId);
    final bool workshopAssigned = current.workshop.supportAssignmentsByFunction
        .values
        .contains(characterId);
    final bool assignedToOtherStage = current.battle.stageAssignments.entries.any((
      MapEntry<String, List<String>> entry,
    ) {
      return entry.key != stageId && entry.value.contains(characterId);
    });
    if (workshopAssigned && !before.contains(characterId)) {
      _session.appendLog('Character assigned to workshop');
      return;
    }
    if (assignedToOtherStage && !before.contains(characterId)) {
      _session.appendLog('Character assigned to another stage');
      return;
    }
    final SessionState nextState = _configureBattleAssignmentUseCase
        .toggleCharacter(
          state: current,
          stageId: stageId,
          characterId: characterId,
        );
    final List<String> after = nextState.battle.stageAssignments[stageId] ??
        const <String>[];

    if (character == null) {
      _session.appendLog('Character not found');
      return;
    }

    _session.applyState(nextState);
    if (identical(nextState, current)) {
      _session.appendLog('Battle party full for $stageId');
      return;
    }

    final bool added = !before.contains(characterId) && after.contains(characterId);
    _session.appendLog(
      added
          ? 'Assigned ${character.name} to $stageId'
          : 'Removed ${character.name} from $stageId',
    );
  }

  CharacterProgress? _findCharacter(SessionState state, String characterId) {
    for (final CharacterProgress character in state.characters.mercenaries) {
      if (character.id == characterId) {
        return character;
      }
    }
    for (final CharacterProgress character in state.characters.homunculi) {
      if (character.id == characterId) {
        return character;
      }
    }
    return null;
  }
}

class _MissingBattleCatalogRepository implements BattleCatalogRepository {
  const _MissingBattleCatalogRepository();

  @override
  BattleDropTable dropTable(String stageId) {
    throw StateError('BattleCatalogRepository is required');
  }

  @override
  List<String> stageCatalog() {
    throw StateError('BattleCatalogRepository is required');
  }
}

final Provider<BattleController> battleControllerProvider =
    Provider<BattleController>((Ref ref) {
      return BattleController(
        ref.read(sessionControllerProvider.notifier),
        battleService: ref.read(battleServiceProvider),
        battleCatalogRepository: ref.read(battleCatalogRepositoryProvider),
      );
    });
