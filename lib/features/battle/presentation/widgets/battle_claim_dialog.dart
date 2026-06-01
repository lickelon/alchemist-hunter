import 'package:alchemist_hunter/app/catalog/app_catalog_providers.dart';
import 'package:alchemist_hunter/app/catalog/icon_asset_paths.dart';
import 'package:alchemist_hunter/common/themes/app_spacing.dart';
import 'package:alchemist_hunter/common/widgets/app_dialog_layout.dart';
import 'package:alchemist_hunter/common/widgets/detail_lines.dart';
import 'package:alchemist_hunter/common/widgets/resource_icon_grid.dart';
import 'package:alchemist_hunter/common/widgets/section_card.dart';
import 'package:alchemist_hunter/features/battle/domain/models.dart';
import 'package:alchemist_hunter/features/battle/presentation/viewmodels/battle_controller.dart';
import 'package:alchemist_hunter/features/battle/presentation/viewmodels/battle_stage_progress_selectors.dart';
import 'package:alchemist_hunter/features/battle/presentation/viewmodels/battle_stage_runtime_selectors.dart';
import 'package:alchemist_hunter/features/battle/presentation/viewmodels/battle_display_labels.dart';
import 'package:alchemist_hunter/features/workshop/extraction/domain/repositories/material_catalog_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BattleClaimDialog extends ConsumerWidget {
  const BattleClaimDialog({super.key, required this.stageId});

  final String stageId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final BattleExpeditionState expedition = ref.watch(
      battleStageExpeditionStateProvider(stageId),
    );
    final BattlePendingClaim claim = expedition.pendingClaim;
    final MaterialCatalogRepository materialCatalog = ref.watch(
      materialCatalogRepositoryProvider,
    );
    final String stageName = ref.watch(battleStageDisplayNameProvider(stageId));

    return AppDialogLayout(
      title: '$stageName 보상 수령',
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            _ClaimSection(
              title: '수령 예정',
              lines: <String>[
                '골드 ${battleSignedValueLabel(claim.gold)}',
                '정수 ${battleSignedValueLabel(claim.essence)}',
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            _MaterialRewardGrid(
              materials: claim.materials,
              materialCatalog: materialCatalog,
            ),
            const SizedBox(height: AppSpacing.lg),
            _ClaimSection(
              title: '런 요약',
              lines: <String>[
                '성공 ${claim.victoryCount}회 / 실패 ${claim.wipeCount}회',
                '진행 시간 ${_durationLabel(claim.elapsedRealTime)}',
                '이미 반영된 경험치 ${battleSignedValueLabel(claim.xp)}',
              ],
            ),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('취소'),
        ),
        FilledButton(
          onPressed: claim.isEmpty
              ? null
              : () {
                  ref.read(battleControllerProvider).claimStageRewards(stageId);
                  Navigator.of(context).pop();
                },
          child: const Text('수령'),
        ),
      ],
    );
  }
}

String _durationLabel(Duration duration) {
  if (duration <= Duration.zero) {
    return '0초';
  }
  final int totalSeconds = duration.inSeconds;
  if (totalSeconds == 0) {
    return '1초 미만';
  }
  final int hours = totalSeconds ~/ Duration.secondsPerHour;
  final int minutes =
      (totalSeconds % Duration.secondsPerHour) ~/ Duration.secondsPerMinute;
  final int seconds = totalSeconds % Duration.secondsPerMinute;
  if (hours > 0) {
    if (minutes > 0) {
      return '$hours시간 $minutes분';
    }
    return '$hours시간';
  }
  if (minutes > 0) {
    if (seconds > 0) {
      return '$minutes분 $seconds초';
    }
    return '$minutes분';
  }
  return '$seconds초';
}

class _ClaimSection extends StatelessWidget {
  const _ClaimSection({required this.title, required this.lines});

  final String title;
  final List<String> lines;

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      title: title,
      margin: EdgeInsets.zero,
      child: DetailLines(lines: lines),
    );
  }
}

class _MaterialRewardGrid extends StatelessWidget {
  const _MaterialRewardGrid({
    required this.materials,
    required this.materialCatalog,
  });

  final Map<String, int> materials;
  final MaterialCatalogRepository materialCatalog;

  @override
  Widget build(BuildContext context) {
    if (materials.isEmpty) {
      return const Text('재료 없음');
    }

    return ResourceIconGrid(
      items: materials.entries
          .map((MapEntry<String, int> entry) {
            final String name =
                materialCatalog.materialName(entry.key) ?? entry.key;
            return ResourceIconGridItem(
              key: ValueKey<String>('claim_material_${entry.key}'),
              assetPath: CatalogIconAssetPaths.material(entry.key),
              badgeLabel: 'x${entry.value}',
              semanticLabel: '$name x${entry.value}',
            );
          })
          .toList(growable: false),
    );
  }
}
