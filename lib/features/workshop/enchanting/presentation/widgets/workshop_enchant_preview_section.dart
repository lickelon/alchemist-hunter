import 'package:alchemist_hunter/common/themes/app_radius.dart';
import 'package:alchemist_hunter/common/themes/app_spacing.dart';
import 'package:alchemist_hunter/common/themes/app_text_styles.dart';
import 'package:alchemist_hunter/common/widgets/detail_lines.dart';
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
        Text('예상 결과', style: subsectionTitleStyle),
        const SizedBox(height: AppSpacing.md),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: AppRadius.interactive,
          ),
          child: preview == null
              ? const Text('포션과 장비를 선택하면 인챈트 결과를 미리 볼 수 있습니다')
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(preview!.equipmentName, style: subsectionTitleStyle),
                    const SizedBox(height: AppSpacing.sm),
                    DetailLines(
                      lines: <String>[
                        '현재 ${preview!.currentEnchantLabel}',
                        '예상 ${preview!.nextEnchantLabel}',
                        preview!.currentStatLabel,
                        preview!.nextStatLabel,
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(preview!.deltaStatLabel, style: dataEmphasisStyle),
                    if (preview!.replaceRequired) ...<Widget>[
                      const SizedBox(height: AppSpacing.sm),
                      const Text('기존 인챈트가 교체됩니다'),
                    ],
                  ],
                ),
        ),
      ],
    );
  }
}
