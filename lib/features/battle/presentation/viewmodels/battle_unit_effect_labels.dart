import 'package:alchemist_hunter/features/battle/domain/models.dart';

List<String> battleUnitEffectLabels(BattleRunUnitState unit) {
  return <String>[
    ...unit.statuses.map(_statusLabel),
    ...unit.activeModifiers.map(_modifierLabel),
  ];
}

String _statusLabel(BattleStatusEffect status) {
  final String typeLabel = switch (status.type) {
    BattleStatusType.poison => '중독',
    BattleStatusType.stun => '기절',
  };
  final String powerLabel = status.power > 0 ? ' ${status.power}' : '';
  return '$typeLabel$powerLabel / ${status.remainingLifecycles}행동';
}

String _modifierLabel(BattleTimedModifier timedModifier) {
  final BattleModifier modifier = timedModifier.modifier;
  final String typeLabel = switch (modifier.type) {
    BattleModifierType.damageDealt => '주는 피해',
    BattleModifierType.damageTaken => '받는 피해',
  };
  final String valueLabel = _modifierValueLabel(modifier);
  return '$typeLabel $valueLabel / ${timedModifier.remainingLifecycles}행동';
}

String _modifierValueLabel(BattleModifier modifier) {
  final String sign = modifier.value > 0 ? '+' : '';
  if (modifier.mode == BattleModifierMode.percent) {
    return '$sign${(modifier.value * 100).round()}%';
  }
  return '$sign${modifier.value.toStringAsFixed(1)}';
}
