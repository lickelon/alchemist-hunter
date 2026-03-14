import 'dart:math';

import 'package:alchemist_hunter/features/battle/domain/use_cases/auto_battle_use_case.dart';
import 'package:alchemist_hunter/features/battle/domain/services/battle_service.dart';
import 'package:alchemist_hunter/core/session/session_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final Provider<BattleService> battleServiceProvider = Provider<BattleService>(
  (Ref ref) => BattleService(random: Random(11)),
);

class BattleController {
  BattleController(
    this._session,
    this._battleService, {
    AutoBattleUseCase battleDomain = const AutoBattleUseCase(),
  }) : _battleDomain = battleDomain;

  final SessionController _session;
  final BattleService _battleService;
  final AutoBattleUseCase _battleDomain;

  void runAutoBattle(String stageId) {
    final SessionState current = _session.snapshot();
    final SessionState nextState = _battleDomain.runAutoBattle(
      state: current,
      stageId: stageId,
      battleService: _battleService,
    );
    final int essenceGain = nextState.player.essence - current.player.essence;
    final bool success = essenceGain >= 6;
    _session.applyState(nextState);
    _session.appendLog(
      'Battle ${success ? 'win' : 'fail'} on $stageId / essence+$essenceGain / xp+${_xpGainForStage(stageId, success)}',
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
}

final Provider<BattleController> battleControllerProvider =
    Provider<BattleController>((Ref ref) {
      return BattleController(
        ref.read(sessionControllerProvider.notifier),
        ref.read(battleServiceProvider),
      );
    });
