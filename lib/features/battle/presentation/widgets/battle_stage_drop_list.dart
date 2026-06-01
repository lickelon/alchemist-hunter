import 'package:alchemist_hunter/common/themes/app_radius.dart';
import 'package:alchemist_hunter/common/themes/app_spacing.dart';
import 'package:alchemist_hunter/features/battle/presentation/viewmodels/battle_drop_selectors.dart';
import 'package:alchemist_hunter/features/battle/presentation/widgets/battle_stage_drop_line.dart';
import 'package:flutter/material.dart';

class BattleStageDropList extends StatelessWidget {
  const BattleStageDropList({super.key, required this.overview});

  final BattleStageDropOverviewView overview;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: overview.enemies.length,
      separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.md),
      itemBuilder: (BuildContext context, int index) {
        final BattleEnemyDropView enemy = overview.enemies[index];
        return Card(
          color: Theme.of(context).colorScheme.surfaceContainerLowest,
          child: ExpansionTile(
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: AppRadius.interactive,
              ),
              child: Icon(
                Icons.pets_outlined,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            title: Text(
              enemy.enemyName,
              style: Theme.of(context).textTheme.titleSmall,
            ),
            childrenPadding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              0,
              AppSpacing.lg,
              AppSpacing.lg,
            ),
            children: <Widget>[
              Align(
                alignment: Alignment.centerLeft,
                child: Text(enemy.identityLabel),
              ),
              const SizedBox(height: AppSpacing.md),
              _DropSection(title: '전투 스탯', lines: enemy.statLines),
              const SizedBox(height: AppSpacing.md),
              _DropSection(title: '전투 특징', lines: enemy.effectLines),
              const SizedBox(height: AppSpacing.md),
              _DropChanceSection(title: '일반 드롭', drops: enemy.normalDrops),
              if (enemy.specialDrops.isNotEmpty) ...<Widget>[
                const SizedBox(height: AppSpacing.md),
                _DropChanceSection(title: '특수 드롭', drops: enemy.specialDrops),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _DropSection extends StatelessWidget {
  const _DropSection({required this.title, required this.lines});

  final String title;
  final List<String> lines;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(title, style: Theme.of(context).textTheme.bodyMedium),
        const SizedBox(height: AppSpacing.xs),
        ...lines.map((String line) {
          return Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.xs),
            child: Text(line, style: Theme.of(context).textTheme.bodySmall),
          );
        }),
      ],
    );
  }
}

class _DropChanceSection extends StatelessWidget {
  const _DropChanceSection({required this.title, required this.drops});

  final String title;
  final List<BattleDropChanceView> drops;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(title, style: Theme.of(context).textTheme.bodyMedium),
        const SizedBox(height: AppSpacing.xs),
        ...drops.map((BattleDropChanceView drop) {
          return Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.xs),
            child: BattleStageDropLine(drop: drop),
          );
        }),
      ],
    );
  }
}
