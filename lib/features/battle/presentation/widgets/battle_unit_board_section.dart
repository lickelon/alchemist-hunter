import 'package:alchemist_hunter/common/themes/app_radius.dart';
import 'package:alchemist_hunter/common/themes/app_spacing.dart';
import 'package:alchemist_hunter/features/battle/domain/models.dart';
import 'package:flutter/material.dart';

class BattleUnitBoardSection extends StatelessWidget {
  const BattleUnitBoardSection({
    super.key,
    required this.units,
    this.emptyLabel,
    this.enemy = false,
  });

  final List<BattleRunUnitState> units;
  final String? emptyLabel;
  final bool enemy;

  @override
  Widget build(BuildContext context) {
    if (units.isEmpty && emptyLabel == null) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        if (units.isEmpty && emptyLabel != null)
          Text(emptyLabel!)
        else if (units.isNotEmpty)
          ...units.map((BattleRunUnitState unit) {
            final ColorScheme colorScheme = Theme.of(context).colorScheme;
            final double hpRatio = unit.maxHp == 0
                ? 0
                : unit.currentHp / unit.maxHp;
            final List<String> effectLabels = _unitEffectLabels(unit);
            final Color backgroundColor = !unit.isAlive
                ? colorScheme.surfaceContainerLow
                : enemy
                ? colorScheme.errorContainer
                : colorScheme.surfaceContainerLowest;
            final Color foregroundColor = !unit.isAlive
                ? colorScheme.onSurface.withValues(alpha: 0.5)
                : enemy
                ? colorScheme.onErrorContainer
                : colorScheme.onSurface;
            return Container(
              margin: const EdgeInsets.only(bottom: AppSpacing.sm),
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: AppRadius.interactive,
                border: enemy && unit.isAlive
                    ? Border.all(color: colorScheme.error, width: 1.5)
                    : null,
              ),
              child: DefaultTextStyle.merge(
                style: TextStyle(color: foregroundColor),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Expanded(child: Text(unit.name)),
                        if (!unit.isAlive)
                          Text(
                            '사망',
                            style: TextStyle(color: colorScheme.error),
                          ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text('HP ${unit.currentHp} / ${unit.maxHp}'),
                    if (unit.maxMp > 0) ...<Widget>[
                      const SizedBox(height: AppSpacing.xs),
                      Text('마나 ${unit.currentMp} / ${unit.maxMp}'),
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
