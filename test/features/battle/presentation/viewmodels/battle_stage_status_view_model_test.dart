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
    const BattleActionLog statusGrant = BattleActionLog(
      lifecycle: 1,
      turn: 1,
      type: BattleActionType.status,
      actorId: 'caster',
      actorName: 'Ash Adept',
      actorTeam: BattleTeam.ally,
      targetId: 'enemy',
      targetName: 'Shade Stalker',
      targetTeam: BattleTeam.enemy,
      statusType: BattleStatusType.poison,
    );
    const BattleActionLog statusDamage = BattleActionLog(
      lifecycle: 2,
      turn: 2,
      type: BattleActionType.status,
      actorId: 'enemy',
      actorName: 'Shade Stalker',
      actorTeam: BattleTeam.enemy,
      statusType: BattleStatusType.poison,
      damage: 7,
    );
    const BattleActionLog stunBlocked = BattleActionLog(
      lifecycle: 3,
      turn: 3,
      type: BattleActionType.status,
      actorId: 'enemy',
      actorName: 'Shade Stalker',
      actorTeam: BattleTeam.enemy,
      statusType: BattleStatusType.stun,
    );

    expect(battleActionTimelineLabel(skillUse), 'Ash Adept 재구성 사용');
    expect(
      battleActionTimelineLabel(heal),
      'Ash Adept -> Rookie Swordsman 회복 +24',
    );
    expect(
      battleActionTimelineLabel(statusGrant),
      'Ash Adept -> Shade Stalker 중독 부여',
    );
    expect(battleActionTimelineLabel(statusDamage), 'Shade Stalker 중독 피해 7');
    expect(battleActionTimelineLabel(stunBlocked), 'Shade Stalker 기절로 행동 불가');
  });
}
