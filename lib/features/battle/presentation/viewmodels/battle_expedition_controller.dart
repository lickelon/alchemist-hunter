import 'package:alchemist_hunter/app/session/app_session.dart';
import 'package:alchemist_hunter/features/battle/domain/use_cases/battle_expedition_use_case.dart';

class BattleExpeditionController {
  const BattleExpeditionController(
    this._session, {
    BattleExpeditionUseCase battleExpeditionUseCase =
        const BattleExpeditionUseCase(),
  }) : _battleExpeditionUseCase = battleExpeditionUseCase;

  final SessionController _session;
  final BattleExpeditionUseCase _battleExpeditionUseCase;

  void startExpedition(String stageId) {
    final SessionState current = _session.snapshot();
    final List<String> assigned =
        current.battle.stageAssignments[stageId] ?? const <String>[];
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
}
