import 'dart:math';

import 'package:alchemist_hunter/app/session/app_session.dart';
import 'package:alchemist_hunter/features/battle/domain/use_cases/configure_battle_assignment_use_case.dart';
import 'package:alchemist_hunter/features/battle/domain/use_cases/auto_battle_use_case.dart';
import 'package:alchemist_hunter/features/battle/domain/repositories/battle_catalog_repository.dart';
import 'package:alchemist_hunter/features/battle/domain/services/battle_service.dart';
import 'package:alchemist_hunter/features/battle/battle_catalog.dart';
import 'package:alchemist_hunter/features/characters/domain/models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final Provider<BattleService> battleServiceProvider = Provider<BattleService>(
  (Ref ref) => BattleService(random: Random(11)),
);

class BattleController {
  BattleController(
    this._session,
    this._battleService, {
    AutoBattleUseCase battleDomain = const AutoBattleUseCase(),
    ConfigureBattleAssignmentUseCase configureBattleAssignmentUseCase =
        const ConfigureBattleAssignmentUseCase(),
    required BattleCatalogRepository battleCatalogRepository,
  }) : _battleDomain = battleDomain,
       _configureBattleAssignmentUseCase = configureBattleAssignmentUseCase,
       _battleCatalogRepository = battleCatalogRepository;

  final SessionController _session;
  final BattleService _battleService;
  final AutoBattleUseCase _battleDomain;
  final ConfigureBattleAssignmentUseCase _configureBattleAssignmentUseCase;
  final BattleCatalogRepository _battleCatalogRepository;

  void runAutoBattle(String stageId) {
    final SessionState current = _session.snapshot();
    final List<String> assigned = current.battle.stageAssignments[stageId] ??
        const <String>[];
    if (assigned.isEmpty) {
      _session.appendLog('Battle assignment missing for $stageId');
      return;
    }
    final SessionState nextState = _battleDomain.runAutoBattle(
      state: current,
      stageId: stageId,
      battleService: _battleService,
      battleCatalogRepository: _battleCatalogRepository,
    );
    final int essenceGain = nextState.player.essence - current.player.essence;
    final bool success = essenceGain >= 6;
    _session.applyState(nextState);
    _session.appendLog(
      'Battle ${success ? 'win' : 'fail'} on $stageId / essence+$essenceGain / xp+${_xpGainForStage(stageId, success)}',
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

  int _xpGainForStage(String stageId, bool success) {
    final int stageNumber =
        int.tryParse(stageId.replaceFirst('stage_', '')) ?? 1;
    if (success) {
      return 16 + (stageNumber * 4);
    }
    return 6 + (stageNumber * 2);
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

final Provider<BattleController> battleControllerProvider =
    Provider<BattleController>((Ref ref) {
      return BattleController(
        ref.read(sessionControllerProvider.notifier),
        ref.read(battleServiceProvider),
        battleCatalogRepository: ref.read(battleCatalogRepositoryProvider),
      );
    });
