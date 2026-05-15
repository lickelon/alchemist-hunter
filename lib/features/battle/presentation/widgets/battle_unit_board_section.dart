import 'package:alchemist_hunter/common/themes/app_radius.dart';
import 'package:alchemist_hunter/common/themes/app_spacing.dart';
import 'package:alchemist_hunter/features/battle/domain/models.dart';
import 'package:flutter/material.dart';

class BattleUnitBoardSection extends StatelessWidget {
  const BattleUnitBoardSection({
    super.key,
    required this.title,
    required this.units,
    required this.emptyLabel,
  });

  final String title;
  final List<BattleRunUnitState> units;
  final String emptyLabel;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(title, style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: AppSpacing.sm),
        if (units.isEmpty)
          Text(emptyLabel)
        else
          ...units.map((BattleRunUnitState unit) {
            final double hpRatio = unit.maxHp == 0
                ? 0
                : unit.currentHp / unit.maxHp;
            final List<String> effectLabels = _unitEffectLabels(unit);
            return Container(
              margin: const EdgeInsets.only(bottom: AppSpacing.sm),
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerLowest,
                borderRadius: AppRadius.interactive,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Expanded(child: Text(unit.name)),
                      if (!unit.isAlive)
                        Text(
                          '사망',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text('HP ${unit.currentHp} / ${unit.maxHp}'),
                  if (unit.maxMp > 0) ...<Widget>[
                    const SizedBox(height: AppSpacing.xs),
                    Text('MP ${unit.currentMp} / ${unit.maxMp}'),
                  ],
                  if (unit.shield > 0) ...<Widget>[
                    const SizedBox(height: AppSpacing.xs),
                    Text('보호막 ${unit.shield}'),
                  ],
                  const SizedBox(height: AppSpacing.xs),
                  LinearProgressIndicator(
                    value: hpRatio.clamp(0, 1),
                    minHeight: 8,
                  ),
                  if (effectLabels.isNotEmpty) ...<Widget>[
                    const SizedBox(height: AppSpacing.sm),
                    Wrap(
                      spacing: AppSpacing.xs,
                      runSpacing: AppSpacing.xs,
                      children: effectLabels
                          .map(
                            (String label) => Chip(
                              label: Text(label),
                              visualDensity: VisualDensity.compact,
                            ),
                          )
                          .toList(growable: false),
                    ),
                  ],
                ],
              ),
            );
          }),
      ],
    );
  }
}

List<String> _unitEffectLabels(BattleRunUnitState unit) {
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
