import 'package:alchemist_hunter/common/themes/app_radius.dart';
import 'package:alchemist_hunter/common/themes/app_spacing.dart';
import 'package:alchemist_hunter/common/themes/app_text_styles.dart';
import 'package:alchemist_hunter/common/widgets/app_badge.dart';
import 'package:alchemist_hunter/features/workshop/enchanting/presentation/viewmodels/enchant_preview_selector.dart';
import 'package:flutter/material.dart';

class WorkshopEnchantPreviewSection extends StatelessWidget {
  const WorkshopEnchantPreviewSection({super.key, required this.preview});

  final EnchantPreviewView? preview;

  @override
  Widget build(BuildContext context) {
    final TextStyle subsectionTitleStyle = AppTextStyles.of(
      context,
    ).subsectionTitle;
    final TextStyle dataEmphasisStyle = AppTextStyles.of(context).dataEmphasis;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text('결과', style: subsectionTitleStyle),
        const SizedBox(height: AppSpacing.md),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: AppRadius.interactive,
          ),
          child: preview == null
              ? const AppBadge(label: '선택 대기')
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(preview!.equipmentName, style: subsectionTitleStyle),
                    const SizedBox(height: AppSpacing.sm),
                    _PreviewComparisonRow(
                      label: '인챈트',
                      currentLabel: preview!.currentEnchantLabel,
                      nextLabel: preview!.nextEnchantLabel,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    _PreviewComparisonRow(
                      label: '스탯',
                      currentLabel: preview!.currentStatLabel,
                      nextLabel: preview!.nextStatLabel,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    if (preview!.replaceRequired) ...<Widget>[
                      const AppBadge(label: '교체 예정'),
                      const SizedBox(height: AppSpacing.sm),
                    ],
                    Text(preview!.deltaStatLabel, style: dataEmphasisStyle),
                  ],
                ),
        ),
      ],
    );
  }
}

class _PreviewComparisonRow extends StatelessWidget {
  const _PreviewComparisonRow({
    required this.label,
    required this.currentLabel,
    required this.nextLabel,
  });

  final String label;
  final String currentLabel;
  final String nextLabel;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Expanded(
              child: _PreviewValue(label: '현재', value: currentLabel),
            ),
            const SizedBox(width: AppSpacing.sm),
            Icon(
              Icons.arrow_forward,
              size: 16,
              color: colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: _PreviewValue(
                label: '다음',
                value: nextLabel,
                emphasized: true,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _PreviewValue extends StatelessWidget {
  const _PreviewValue({
    required this.label,
    required this.value,
    this.emphasized = false,
  });

  final String label;
  final String value;
  final bool emphasized;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          value,
          style: emphasized
              ? AppTextStyles.of(context).dataEmphasis
              : theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
        ),
      ],
    );
  }
}
