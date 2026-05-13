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
            return Container(
              margin: const EdgeInsets.only(bottom: AppSpacing.sm),
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(12),
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
                  const SizedBox(height: AppSpacing.xs),
                  LinearProgressIndicator(
                    value: hpRatio.clamp(0, 1),
                    minHeight: 8,
                  ),
                ],
              ),
            );
          }),
      ],
    );
  }
}
