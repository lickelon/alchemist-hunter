import 'package:alchemist_hunter/app/catalog/app_catalog_providers.dart';
import 'package:alchemist_hunter/common/themes/app_spacing.dart';
import 'package:alchemist_hunter/common/widgets/app_bottom_sheet.dart';
import 'package:alchemist_hunter/common/widgets/app_sheet_layout.dart';
import 'package:alchemist_hunter/features/battle/domain/models.dart';
import 'package:alchemist_hunter/features/battle/presentation/battle_providers.dart';
import 'package:alchemist_hunter/features/battle/presentation/viewmodels/battle_display_labels.dart';
import 'package:alchemist_hunter/features/workshop/extraction/domain/repositories/material_catalog_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BattleClaimSheet extends ConsumerWidget {
  const BattleClaimSheet({super.key, required this.stageId});

  final String stageId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final BattleExpeditionState expedition = ref.watch(
      battleStageExpeditionStateProvider(stageId),
    );
    final BattleRunState? runState = expedition.runState;
    final int assignedCount = ref
        .watch(battleStageAssignmentProvider(stageId))
        .length;
    final int partyPower = ref.watch(battleStagePartyPowerProvider(stageId));
    final BattlePendingClaim claim = expedition.pendingClaim;
    final MaterialCatalogRepository materialCatalog = ref.watch(
      materialCatalogRepositoryProvider,
    );
    final String stageName = ref.watch(battleStageDisplayNameProvider(stageId));

    return AppBottomSheet(
      child: AppSheetLayout(
        title: '$stageName 보상 수령',
        header: Text(
          claim.isEmpty
              ? '수령 대기 보상 없음'
              : '골드 ${battleSignedValueLabel(claim.gold)} / 정수 ${battleSignedValueLabel(claim.essence)} / 재료 ${claim.materials.length}종',
        ),
        expandBody: false,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            _ClaimSection(
              title: '런 요약',
              lines: <String>[
                '편성 $assignedCount명 / 전투력 $partyPower',
                '성공 ${runState?.victoryCount ?? 0}회 / 실패 ${runState?.wipeCount ?? 0}회',
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            _ClaimSection(
              title: '수령 예정',
              lines: <String>[
                '골드 ${battleSignedValueLabel(claim.gold)}',
                '정수 ${battleSignedValueLabel(claim.essence)}',
                _materialLine(claim.materials, materialCatalog),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            Row(
              children: <Widget>[
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('취소'),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: FilledButton(
                    onPressed: claim.isEmpty
                        ? null
                        : () {
                            ref
                                .read(battleControllerProvider)
                                .claimStageRewards(stageId);
                            Navigator.of(context).pop();
                          },
                    child: const Text('수령'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _materialLine(
    Map<String, int> materials,
    MaterialCatalogRepository materialCatalog,
  ) {
    if (materials.isEmpty) {
      return '재료 없음';
    }
    return '재료 ${materials.entries.map((MapEntry<String, int> entry) {
      final String name = materialCatalog.materialName(entry.key) ?? entry.key;
      return '$name x${entry.value}';
    }).join(', ')}';
  }
}

class _ClaimSection extends StatelessWidget {
  const _ClaimSection({required this.title, required this.lines});

  final String title;
  final List<String> lines;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(title, style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: AppSpacing.sm),
        ...lines.map((String line) {
          return Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.xs),
            child: Text(line),
          );
        }),
      ],
    );
  }
}
