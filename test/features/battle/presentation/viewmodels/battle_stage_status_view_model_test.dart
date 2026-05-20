import 'package:alchemist_hunter/features/battle/domain/models.dart';
import 'package:alchemist_hunter/features/battle/presentation/viewmodels/battle_stage_status_view_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('timeline labels show skill use and targeted healing', () {
    const BattleActionLog skillUse = BattleActionLog(
      lifecycle: 1,
      turn: 1,
      type: BattleActionType.skillUse,
      actorId: 'healer',
      actorName: 'Ash Adept',
      actorTeam: BattleTeam.ally,
      skillId: 'mend',
      skillName: '재구성',
    );
    const BattleActionLog heal = BattleActionLog(
      lifecycle: 1,
      turn: 1,
      type: BattleActionType.heal,
      actorId: 'healer',
      actorName: 'Ash Adept',
      actorTeam: BattleTeam.ally,
      targetId: 'ally',
      targetName: 'Rookie Swordsman',
      targetTeam: BattleTeam.ally,
      healing: 24,
    );

    expect(battleActionTimelineLabel(skillUse), 'Ash Adept 재구성 사용');
    expect(
      battleActionTimelineLabel(heal),
      'Ash Adept -> Rookie Swordsman 회복 +24',
    );
  });
}
