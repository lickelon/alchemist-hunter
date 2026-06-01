import 'package:alchemist_hunter/app/catalog/icon_asset_paths.dart';
import 'package:alchemist_hunter/common/themes/app_spacing.dart';
import 'package:alchemist_hunter/common/widgets/catalog_asset_icon.dart';
import 'package:alchemist_hunter/features/workshop/craft_queue/presentation/viewmodels/craft_queue_submit_results.dart';
import 'package:alchemist_hunter/features/workshop/crafting/domain/use_cases/workshop_brew_experiment_use_case.dart';
import 'package:alchemist_hunter/features/workshop/crafting/presentation/widgets/workshop_brew_experiment_status_banner.dart';
import 'package:flutter/material.dart';

class WorkshopBrewExperimentResultBody extends StatelessWidget {
  const WorkshopBrewExperimentResultBody({
    super.key,
    required this.result,
    required this.potionId,
    required this.potionName,
    this.onPinRecipe,
  });

  final WorkshopBrewExperimentSubmitResult result;
  final String? potionId;
  final String? potionName;
  final VoidCallback? onPinRecipe;

  @override
  Widget build(BuildContext context) {
    final bool success = result.status == WorkshopBrewExperimentStatus.success;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final String gradeLabel = result.qualityGrade?.name.toUpperCase() ?? '-';
    final String discoveryLabel = !success
        ? '레시피 기록 없음'
        : result.isNewDiscovery
        ? '레시피 신규 발견'
        : result.discoveryChanged
        ? '레시피 갱신 ${result.previousGrade?.name.toUpperCase()} → $gradeLabel'
        : '기존 기록 유지';
    final String? qualityLabel = result.qualityScore == null
        ? null
        : '$gradeLabel · ${(result.qualityScore! * 100).round()}점';
    final String recipeActionLabel = onPinRecipe != null
        ? '이 비율로 레시피 고정'
        : discoveryLabel;
    final IconData statusIcon = switch (result.status) {
      WorkshopBrewExperimentStatus.success =>
        result.discoveryChanged
            ? Icons.auto_awesome_outlined
            : Icons.bookmark_added_outlined,
      WorkshopBrewExperimentStatus.elementMissing => Icons.inventory_2_outlined,
      WorkshopBrewExperimentStatus.unknownReaction => Icons.science_outlined,
      WorkshopBrewExperimentStatus.failed => Icons.error_outline,
    };
    final Color statusColor = switch (result.status) {
      WorkshopBrewExperimentStatus.success =>
        result.discoveryChanged ? colorScheme.primary : colorScheme.tertiary,
      WorkshopBrewExperimentStatus.elementMissing => colorScheme.error,
      WorkshopBrewExperimentStatus.unknownReaction => colorScheme.outline,
      WorkshopBrewExperimentStatus.failed => colorScheme.error,
    };

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            if (success && potionId != null)
              CatalogAssetIcon(
                assetPath: CatalogIconAssetPaths.potion(potionId!),
                size: 48,
                padding: 6,
                fallbackIcon: Icons.local_drink_outlined,
              )
            else
              WorkshopBrewExperimentStatusIcon(
                icon: statusIcon,
                color: statusColor,
              ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: _WorkshopBrewExperimentResultSummary(
                result: result,
                potionName: potionName,
                qualityLabel: qualityLabel,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        WorkshopBrewExperimentStatusBanner(
          icon: statusIcon,
          color: statusColor,
          label: recipeActionLabel,
          onTap: onPinRecipe,
        ),
      ],
    );
  }
}

class _WorkshopBrewExperimentResultSummary extends StatelessWidget {
  const _WorkshopBrewExperimentResultSummary({
    required this.result,
    required this.potionName,
    required this.qualityLabel,
  });

  final WorkshopBrewExperimentSubmitResult result;
  final String? potionName;
  final String? qualityLabel;

  @override
  Widget build(BuildContext context) {
    final bool success = result.status == WorkshopBrewExperimentStatus.success;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(
          success
              ? potionName ?? '포션 반응'
              : switch (result.status) {
                  WorkshopBrewExperimentStatus.elementMissing => '보유 원소가 부족합니다',
                  WorkshopBrewExperimentStatus.unknownReaction =>
                    '조합을 판정할 수 없습니다',
                  WorkshopBrewExperimentStatus.failed => '실험을 진행할 수 없습니다',
                  WorkshopBrewExperimentStatus.success => '',
                },
          style: success
              ? Theme.of(context).textTheme.titleMedium
              : Theme.of(context).textTheme.bodyMedium,
        ),
        if (success && qualityLabel != null) ...<Widget>[
          const SizedBox(height: AppSpacing.xs),
          Text(
            qualityLabel!,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ],
    );
  }
}
