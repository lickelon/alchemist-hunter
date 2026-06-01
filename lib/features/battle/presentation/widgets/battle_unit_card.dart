import 'package:alchemist_hunter/common/themes/app_radius.dart';
import 'package:alchemist_hunter/common/themes/app_spacing.dart';
import 'package:alchemist_hunter/features/battle/domain/models.dart';
import 'package:alchemist_hunter/features/battle/presentation/viewmodels/battle_unit_effect_labels.dart';
import 'package:alchemist_hunter/features/battle/presentation/widgets/battle_resource_bar.dart';
import 'package:flutter/material.dart';

class BattleUnitCard extends StatelessWidget {
  const BattleUnitCard({super.key, required this.unit, required this.enemy});

  final BattleRunUnitState unit;
  final bool enemy;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final double hpRatio = unit.maxHp == 0 ? 0 : unit.currentHp / unit.maxHp;
    final double manaRatio = unit.maxMp == 0 ? 0 : unit.currentMp / unit.maxMp;
    final List<String> effectLabels = battleUnitEffectLabels(unit);
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
                  Text('사망', style: TextStyle(color: colorScheme.error)),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),
            BattleResourceBar(
              semanticsLabel: '체력',
              value: hpRatio,
              color: Colors.redAccent,
            ),
            if (unit.maxMp > 0) ...<Widget>[
              const SizedBox(height: AppSpacing.xs),
              BattleResourceBar(
                semanticsLabel: '마나',
                value: manaRatio,
                color: Colors.blueAccent,
              ),
            ],
            if (unit.shield > 0) ...<Widget>[
              const SizedBox(height: AppSpacing.xs),
              Text('보호막 ${unit.shield}'),
            ],
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
  }
}
