import 'package:alchemist_hunter/app/session/app_session.dart';
import 'package:alchemist_hunter/features/battle/data/repositories/static_battle_catalog_repository.dart';
import 'package:alchemist_hunter/features/battle/domain/models.dart';
import 'package:alchemist_hunter/features/battle/domain/use_cases/battle_expedition_use_case.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('claimStageRewards does not unlock next stage for failed zero-payout battle', () {
    final DateTime now = DateTime(2026, 1, 1, 10);
    final BattleExpeditionUseCase useCase = BattleExpeditionUseCase();
    final SessionState state = createInitialSessionState(now).copyWith(
      battle: createInitialSessionState(now).battle.copyWith(
        progress: createInitialSessionState(now).battle.progress.copyWith(
          clearedStageIds: const <String>{'stage_1'},
        ),
        stageExpeditions: const <String, BattleExpeditionState>{
          'stage_2': BattleExpeditionState(
            status: BattleExpeditionStatus.paused,
            lastProgressedAt: null,
            phaseProgress: Duration.zero,
            pendingClaim: BattlePendingClaim(
              materials: <String, int>{},
              gold: 0,
              essence: 0,
              characterXp: <String, int>{},
              hasSuccessfulBattle: false,
            ),
          ),
        },
      ),
    );

    final SessionState nextState = useCase.claimStageRewards(
      state: state,
      stageId: 'stage_2',
      battleCatalogRepository: const StaticBattleCatalogRepository(),
    );

    expect(nextState.battle.progress.clearedStageIds, isNot(contains('stage_2')));
    expect(nextState.battle.progress.unlockFlags, isNot(contains('potion_special_1')));
  });
}
