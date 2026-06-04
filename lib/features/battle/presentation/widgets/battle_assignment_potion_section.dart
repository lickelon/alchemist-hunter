import 'package:alchemist_hunter/app/catalog/icon_asset_paths.dart';
import 'package:alchemist_hunter/common/themes/app_spacing.dart';
import 'package:alchemist_hunter/common/widgets/app_badge.dart';
import 'package:alchemist_hunter/common/widgets/app_empty_state.dart';
import 'package:alchemist_hunter/common/widgets/catalog_asset_icon.dart';
import 'package:alchemist_hunter/features/battle/presentation/viewmodels/battle_assignment_view_models.dart';
import 'package:alchemist_hunter/features/battle/presentation/viewmodels/battle_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BattleAssignmentPotionSection extends ConsumerWidget {
  const BattleAssignmentPotionSection({
    super.key,
    required this.stageId,
    required this.potions,
  });

  final String stageId;
  final List<BattleAssignmentPotionView> potions;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.xl,
            AppSpacing.md,
            AppSpacing.xl,
            AppSpacing.sm,
          ),
          child: Text(
            '포션 로드아웃',
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        if (potions.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.xl),
            child: AppEmptyState('포션 없음'),
          )
        else
          ...potions.map((BattleAssignmentPotionView potion) {
            return ListTile(
              leading: CatalogAssetIcon(
                assetPath: CatalogIconAssetPaths.potion(potion.potionId),
                size: 36,
                padding: 5,
              ),
              title: Text(potion.label),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: AppSpacing.sm),
                child: Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: <Widget>[
                    AppBadge(label: '보유 ${potion.ownedCount}'),
                    AppBadge(label: '선택 ${potion.selectedCount}'),
                  ],
                ),
              ),
              trailing: _PotionCountControls(stageId: stageId, potion: potion),
            );
          }),
      ],
    );
  }
}

class _PotionCountControls extends ConsumerWidget {
  const _PotionCountControls({required this.stageId, required this.potion});

  final String stageId;
  final BattleAssignmentPotionView potion;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        IconButton(
          onPressed: potion.selectedCount == 0
              ? null
              : () {
                  ref
                      .read(battleControllerProvider)
                      .setStagePotionCount(
                        stageId,
                        potion.stackKey,
                        count: potion.selectedCount - 1,
                        maxOwned: potion.ownedCount,
                      );
                },
          icon: const Icon(Icons.remove_circle_outline),
        ),
        Text('${potion.selectedCount}'),
        IconButton(
          onPressed: potion.selectedCount >= potion.ownedCount
              ? null
              : () {
                  ref
                      .read(battleControllerProvider)
                      .setStagePotionCount(
                        stageId,
                        potion.stackKey,
                        count: potion.selectedCount + 1,
                        maxOwned: potion.ownedCount,
                      );
                },
          icon: const Icon(Icons.add_circle_outline),
        ),
      ],
    );
  }
}
