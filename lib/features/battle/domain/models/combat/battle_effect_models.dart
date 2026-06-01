import 'package:alchemist_hunter/features/battle/domain/models/combat/combat_enums.dart';
import 'package:flutter/foundation.dart';

@immutable
class BattleModifier {
  const BattleModifier({
    required this.type,
    required this.mode,
    required this.value,
    this.school = DamageSchool.any,
    this.targetFaction,
    required this.sourceId,
  });

  final BattleModifierType type;
  final BattleModifierMode mode;
  final double value;
  final DamageSchool school;
  final CombatFaction? targetFaction;
  final String sourceId;
}

@immutable
class BattleTimedModifier {
  const BattleTimedModifier({
    required this.modifier,
    required this.remainingLifecycles,
  });

  final BattleModifier modifier;
  final int remainingLifecycles;

  BattleTimedModifier copyWith({int? remainingLifecycles}) {
    return BattleTimedModifier(
      modifier: modifier,
      remainingLifecycles: remainingLifecycles ?? this.remainingLifecycles,
    );
  }
}

@immutable
class BattleStatusEffect {
  const BattleStatusEffect({
    required this.type,
    required this.sourceId,
    required this.remainingLifecycles,
    this.power = 0,
  });

  final BattleStatusType type;
  final String sourceId;
  final int remainingLifecycles;
  final int power;

  BattleStatusEffect copyWith({int? remainingLifecycles}) {
    return BattleStatusEffect(
      type: type,
      sourceId: sourceId,
      remainingLifecycles: remainingLifecycles ?? this.remainingLifecycles,
      power: power,
    );
  }
}

@immutable
class BattleStatModifier {
  const BattleStatModifier({
    required this.type,
    required this.mode,
    required this.value,
    required this.sourceId,
  });

  final BattleStatModifierType type;
  final BattleModifierMode mode;
  final double value;
  final String sourceId;
}

@immutable
class BattlePassiveCondition {
  const BattlePassiveCondition({
    this.type = BattlePassiveConditionType.always,
    this.threshold = 0,
    this.faction,
    this.statusType,
  });

  final BattlePassiveConditionType type;
  final double threshold;
  final CombatFaction? faction;
  final BattleStatusType? statusType;
}

@immutable
class BattlePassiveEffect {
  const BattlePassiveEffect({
    required this.trigger,
    required this.type,
    required this.sourceId,
    this.value,
    this.durationLifecycles = 1,
    this.modifier,
    this.statusType,
    this.condition = const BattlePassiveCondition(),
  });

  final BattlePassiveTrigger trigger;
  final BattlePassiveEffectType type;
  final String sourceId;
  final int? value;
  final int durationLifecycles;
  final BattleModifier? modifier;
  final BattleStatusType? statusType;
  final BattlePassiveCondition condition;
}
