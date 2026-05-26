import 'package:alchemist_hunter/app/catalog/app_catalog_providers.dart';
import 'package:alchemist_hunter/app/catalog/icon_asset_paths.dart';
import 'package:alchemist_hunter/common/themes/app_spacing.dart';
import 'package:alchemist_hunter/features/battle/domain/models.dart';
import 'package:alchemist_hunter/features/battle/presentation/battle_providers.dart';
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

    return AlertDialog(
      title: Text('$stageName 보상 수령'),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            _ClaimSection(
              title: '런 요약',
              lines: <String>[
                '성공 ${claim.victoryCount}회 / 실패 ${claim.wipeCount}회',
                '진행 시간 ${_durationLabel(claim.elapsedRealTime)}',
                '경험치 ${battleSignedValueLabel(claim.xp)}',
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
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

    final List<MapEntry<String, int>> entries = materials.entries.toList();
    return SizedBox(
      width: 280,
      child: Wrap(
        spacing: AppSpacing.sm,
        runSpacing: AppSpacing.sm,
        children: entries.map((MapEntry<String, int> entry) {
          final String name =
              materialCatalog.materialName(entry.key) ?? entry.key;
          return SizedBox.square(
            dimension: 52,
            child: Tooltip(
              message: '$name x${entry.value}',
              child: _MaterialRewardTile(
                materialId: entry.key,
                quantity: entry.value,
                label: name,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _MaterialRewardTile extends StatelessWidget {
  const _MaterialRewardTile({
    required this.materialId,
    required this.quantity,
    required this.label,
  });

  final String materialId;
  final int quantity;
  final String label;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    return Semantics(
      label: '$label x$quantity',
      child: Container(
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest,
          border: Border.all(color: colorScheme.outlineVariant),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Stack(
          children: <Widget>[
            Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.sm),
                child: Image.asset(
                  CatalogIconAssetPaths.material(materialId),
                  fit: BoxFit.contain,
                  filterQuality: FilterQuality.none,
                  isAntiAlias: false,
                  errorBuilder:
                      (BuildContext context, Object error, StackTrace? stack) {
                        return Icon(
                          Icons.category_outlined,
                          color: colorScheme.onSurfaceVariant,
                        );
                      },
                ),
              ),
            ),
            Positioned(
              right: AppSpacing.xs,
              bottom: AppSpacing.xs,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: colorScheme.outlineVariant),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xs,
                    vertical: 1,
                  ),
                  child: Text(
                    'x$quantity',
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
