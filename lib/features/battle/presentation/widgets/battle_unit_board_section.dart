import 'package:alchemist_hunter/common/themes/app_spacing.dart';
import 'package:alchemist_hunter/features/battle/domain/models.dart';
import 'package:alchemist_hunter/features/battle/presentation/widgets/battle_unit_card.dart';
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
            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: BattleUnitCard(unit: unit, enemy: enemy),
            );
          }),
      ],
    );
  }
}
