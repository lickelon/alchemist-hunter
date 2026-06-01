import 'package:alchemist_hunter/common/themes/app_spacing.dart';
import 'package:alchemist_hunter/features/battle/domain/models.dart';
import 'package:alchemist_hunter/features/battle/presentation/widgets/battle_unit_board_section.dart';
import 'package:flutter/material.dart';

class BattleStageStatusUnitBoard extends StatelessWidget {
  const BattleStageStatusUnitBoard({
    super.key,
    required this.allies,
    required this.enemies,
  });

  final List<BattleRunUnitState> allies;
  final List<BattleRunUnitState> enemies;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          BattleUnitBoardSection(units: allies),
          const SizedBox(height: AppSpacing.md),
          BattleUnitBoardSection(units: enemies, enemy: true),
        ],
      ),
    );
  }
}
