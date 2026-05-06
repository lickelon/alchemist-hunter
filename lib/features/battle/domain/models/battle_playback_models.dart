import 'package:flutter/foundation.dart';

import 'combat_models.dart';

const Duration battleActionInterval = Duration(seconds: 1);

enum BattleTeam { ally, enemy }

enum BattleActionType { attack, lifesteal, regen }

@immutable
class BattleActionLog {
  const BattleActionLog({
    required this.lifecycle,
    required this.turn,
    required this.type,
    required this.actorId,
    required this.actorName,
    required this.actorTeam,
    this.targetId,
    this.targetName,
    this.targetTeam,
    this.school = DamageSchool.any,
    this.hit = true,
    this.critical = false,
    this.damage = 0,
    this.healing = 0,
    this.actorHpAfter = 0,
    this.targetHpAfter,
  });

  final int lifecycle;
  final int turn;
  final BattleActionType type;
  final String actorId;
  final String actorName;
  final BattleTeam actorTeam;
  final String? targetId;
  final String? targetName;
  final BattleTeam? targetTeam;
  final DamageSchool school;
  final bool hit;
  final bool critical;
  final int damage;
  final int healing;
  final int actorHpAfter;
  final int? targetHpAfter;
}
