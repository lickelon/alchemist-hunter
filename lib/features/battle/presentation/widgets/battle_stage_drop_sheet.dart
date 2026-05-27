import 'package:alchemist_hunter/app/catalog/icon_asset_paths.dart';
import 'package:alchemist_hunter/common/themes/app_dialog_heights.dart';
import 'package:alchemist_hunter/common/themes/app_radius.dart';
import 'package:alchemist_hunter/common/themes/app_spacing.dart';
import 'package:alchemist_hunter/common/widgets/app_dialog_layout.dart';
import 'package:alchemist_hunter/common/widgets/app_sheet_layout.dart';
import 'package:alchemist_hunter/common/widgets/catalog_asset_icon.dart';
import 'package:alchemist_hunter/features/battle/presentation/battle_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BattleStageDropSheet extends ConsumerWidget {
  const BattleStageDropSheet({super.key, required this.stageId});

  final String stageId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final BattleStageDropOverviewView overview = ref.watch(
      battleStageDropOverviewProvider(stageId),
    );

    return AppSheetLayout(
      title: '${overview.stageName} 적 정보',
      header: Text(
        '권장 전투력 ${overview.recommendedPower} / 적 ${overview.enemyCount}종',
      ),
      body: _BattleStageDropList(overview: overview),
    );
  }
}

class BattleStageDropDialog extends ConsumerWidget {
  const BattleStageDropDialog({super.key, required this.stageId});

  final String stageId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final BattleStageDropOverviewView overview = ref.watch(
      battleStageDropOverviewProvider(stageId),
    );

    return AppDialogLayout(
      title: '${overview.stageName} 적 정보',
      body: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            '권장 전투력 ${overview.recommendedPower} / 적 ${overview.enemyCount}종',
          ),
          const SizedBox(height: AppSpacing.md),
          SizedBox(
            width: double.maxFinite,
            height: MediaQuery.sizeOf(context).height * AppDialogHeights.medium,
            child: _BattleStageDropList(overview: overview),
          ),
        ],
      ),
    );
  }
}

class _BattleStageDropList extends StatelessWidget {
  const _BattleStageDropList({required this.overview});

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
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '전투 스탯',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              ...enemy.statLines.map((String line) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      line,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                );
              }),
              const SizedBox(height: AppSpacing.md),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '전투 특징',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              ...enemy.effectLines.map((String line) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      line,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                );
              }),
              const SizedBox(height: AppSpacing.md),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '일반 드롭',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              ...enemy.normalDrops.map((BattleDropChanceView drop) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                  child: _DropLine(drop: drop),
                );
              }),
              if (enemy.specialDrops.isNotEmpty) ...<Widget>[
                const SizedBox(height: AppSpacing.md),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '특수 드롭',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                ...enemy.specialDrops.map((BattleDropChanceView drop) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                    child: _DropLine(drop: drop),
                  );
                }),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _DropLine extends StatelessWidget {
  const _DropLine({required this.drop});

  final BattleDropChanceView drop;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        CatalogAssetIcon(
          assetPath: CatalogIconAssetPaths.material(drop.materialId),
          size: 28,
          padding: 3,
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Text(
            '${drop.materialName} ${drop.quantityLabel} / ${drop.chanceLabel}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
      ],
    );
  }
}
