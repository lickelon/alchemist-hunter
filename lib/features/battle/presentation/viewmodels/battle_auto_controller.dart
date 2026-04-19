import 'dart:math';

import 'package:alchemist_hunter/app/session/app_session.dart';
import 'package:alchemist_hunter/features/battle/domain/models.dart';
import 'package:alchemist_hunter/features/battle/domain/repositories/battle_catalog_repository.dart';
import 'package:alchemist_hunter/features/battle/domain/services/battle_expedition_resolver.dart';
import 'package:alchemist_hunter/features/battle/domain/services/battle_service.dart';
import 'package:alchemist_hunter/features/battle/domain/use_cases/battle_expedition_use_case.dart';

class BattleAutoController {
  BattleAutoController(
    this._session, {
    BattleService? battleService,
    BattleExpeditionUseCase battleExpeditionUseCase =
        const BattleExpeditionUseCase(),
    required BattleCatalogRepository battleCatalogRepository,
  }) : _battleService = battleService,
       _battleExpeditionUseCase = battleExpeditionUseCase,
       _battleCatalogRepository = battleCatalogRepository;

  final SessionController _session;
  final BattleService? _battleService;
  final BattleExpeditionUseCase _battleExpeditionUseCase;
  final BattleCatalogRepository _battleCatalogRepository;

  void runAutoBattle(String stageId) {
    final SessionState current = _session.snapshot();
    final BattleService battleService =
        _battleService ?? BattleService(random: Random(11));
    final SessionState started = _battleExpeditionUseCase.startExpedition(
      state: current,
      stageId: stageId,
      now: _session.now(),
    );
    if (identical(started, current)) {
      _session.appendLog('Battle assignment missing for $stageId');
      return;
    }

    final BattleCycleResolution resolution =
        DefaultBattleExpeditionResolver(
          battleService: battleService,
        ).resolveCycle(
          state: started,
          stageId: stageId,
          battleCatalogRepository: _battleCatalogRepository,
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
    final SessionState claimedState = _battleExpeditionUseCase
        .claimStageRewards(state: pendingState, stageId: stageId);
    _session.applyState(claimedState);
    _session.appendLog('Battle ${resolution.summary} on $stageId');
  }
}
