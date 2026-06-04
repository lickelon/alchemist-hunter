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
                    Wrap(
                      spacing: AppSpacing.sm,
                      runSpacing: AppSpacing.sm,
                      children: <Widget>[
                        AppBadge(label: preview!.currentEnchantLabel),
                        AppBadge(label: preview!.nextEnchantLabel),
                        AppBadge(label: preview!.currentStatLabel),
                        AppBadge(label: preview!.nextStatLabel),
                        if (preview!.replaceRequired)
                          const AppBadge(label: '교체 예정'),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(preview!.deltaStatLabel, style: dataEmphasisStyle),
                  ],
                ),
        ),
      ],
    );
  }
}
