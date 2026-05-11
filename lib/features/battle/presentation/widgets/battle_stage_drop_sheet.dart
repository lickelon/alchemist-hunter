import 'package:alchemist_hunter/common/themes/app_spacing.dart';
import 'package:alchemist_hunter/common/widgets/app_bottom_sheet.dart';
import 'package:alchemist_hunter/common/widgets/app_sheet_layout.dart';
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

    return AppBottomSheet(
      child: AppSheetLayout(
        title: '${overview.stageName} 적 정보',
        header: Text(
          '권장 전투력 ${overview.recommendedPower} / 조합 ${overview.encounterCount}종 / 적 ${overview.enemyCount}종',
        ),
        body: ListView.separated(
          itemCount: overview.encounters.length,
          separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.md),
          itemBuilder: (BuildContext context, int index) {
            final BattleStageEncounterDropView encounter =
                overview.encounters[index];
            return Card(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      '${encounter.name} / ${encounter.chanceLabel}',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      encounter.summary,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    ...encounter.enemies.map((BattleEnemyDropView enemy) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.md),
                        child: Card(
                          color: Theme.of(
                            context,
                          ).colorScheme.surfaceContainerLowest,
                          child: ExpansionTile(
                            leading: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: Theme.of(
                                  context,
                                ).colorScheme.surfaceContainerHighest,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                Icons.pets_outlined,
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
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
                                  padding: const EdgeInsets.only(
                                    bottom: AppSpacing.xs,
                                  ),
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      line,
                                      style: Theme.of(
                                        context,
                                      ).textTheme.bodySmall,
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
                                  padding: const EdgeInsets.only(
                                    bottom: AppSpacing.xs,
                                  ),
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      line,
                                      style: Theme.of(
                                        context,
                                      ).textTheme.bodySmall,
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
                              ...enemy.normalDrops.map((
                                BattleDropChanceView drop,
                              ) {
                                return Padding(
                                  padding: const EdgeInsets.only(
                                    bottom: AppSpacing.xs,
                                  ),
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      '${drop.materialName} ${drop.quantityLabel} / ${drop.chanceLabel}',
                                      style: Theme.of(
                                        context,
                                      ).textTheme.bodySmall,
                                    ),
                                  ),
                                );
                              }),
                              if (enemy.specialDrops.isNotEmpty) ...<Widget>[
                                const SizedBox(height: AppSpacing.md),
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    '특수 드롭',
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodyMedium,
                                  ),
                                ),
                                const SizedBox(height: AppSpacing.xs),
                                ...enemy.specialDrops.map((
                                  BattleDropChanceView drop,
                                ) {
                                  return Padding(
                                    padding: const EdgeInsets.only(
                                      bottom: AppSpacing.xs,
                                    ),
                                    child: Align(
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        '${drop.materialName} ${drop.quantityLabel} / ${drop.chanceLabel}',
                                        style: Theme.of(
                                          context,
                                        ).textTheme.bodySmall,
                                      ),
                                    ),
                                  );
                                }),
                              ],
                            ],
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
