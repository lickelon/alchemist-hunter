import 'package:alchemist_hunter/common/widgets/app_bottom_sheet.dart';
import 'package:alchemist_hunter/common/widgets/app_sheet_layout.dart';
import 'package:alchemist_hunter/common/themes/app_spacing.dart';
import 'package:alchemist_hunter/features/battle/presentation/viewmodels/battle_display_labels.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:alchemist_hunter/features/battle/presentation/battle_providers.dart';

class BattleAssignmentSheet extends ConsumerWidget {
  const BattleAssignmentSheet({super.key, required this.stageId});

  final String stageId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final List<String> assignedIds = ref.watch(
      battleStageAssignmentProvider(stageId),
    );
    final int partyPower = ref.watch(battleStagePartyPowerProvider(stageId));
    final List<BattleAssignmentCharacterView> characters = ref.watch(
      battleStageAssignmentCharacterViewsProvider(stageId),
    );
    final List<BattleAssignmentPotionView> potions = ref.watch(
      battleStageAssignmentPotionViewsProvider(stageId),
    );

    return AppBottomSheet(
      child: AppSheetLayout(
        title: '${battleStageDisplayName(stageId)} 편성',
        header: Text('배치 ${assignedIds.length}/3명 / 전투력 $partyPower'),
        body: ListView(
          children: <Widget>[
            ...characters.map((BattleAssignmentCharacterView character) {
              return CheckboxListTile(
                value: character.assigned,
                onChanged: character.assignable
                    ? (_) {
                        ref
                            .read(battleControllerProvider)
                            .toggleStageAssignment(stageId, character.id);
                      }
                    : null,
                title: Text(character.name),
                subtitle: Text(
                  '${character.typeLabel} / 전투력 ${character.power}${character.assignmentHint.isNotEmpty
                      ? " / ${character.assignmentHint}"
                      : character.assignable
                      ? ""
                      : " / 파티가 가득 참"}',
                ),
                controlAffinity: ListTileControlAffinity.trailing,
              );
            }),
            const Divider(),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.xl,
                AppSpacing.md,
                AppSpacing.xl,
                AppSpacing.sm,
              ),
              child: Text(
                '포션 loadout',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            if (potions.isEmpty)
              const ListTile(
                title: Text('전투용 포션 없음'),
                subtitle: Text('제조 완료된 전투 포션이 있으면 여기서 선택할 수 있습니다'),
              )
            else
              ...potions.map((BattleAssignmentPotionView potion) {
                return ListTile(
                  title: Text(potion.label),
                  subtitle: Text(
                    '보유 ${potion.ownedCount} / 선택 ${potion.selectedCount}',
                  ),
                  trailing: Row(
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
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }
}
