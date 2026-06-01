import 'package:alchemist_hunter/common/themes/app_spacing.dart';
import 'package:flutter/material.dart';

class WorkshopBrewExperimentPreviewPanel extends StatelessWidget {
  const WorkshopBrewExperimentPreviewPanel({
    super.key,
    required this.selectedCount,
    required this.hintLabel,
    required this.alreadyDiscovered,
  });

  final int selectedCount;
  final String hintLabel;
  final bool alreadyDiscovered;

  @override
  Widget build(BuildContext context) {
    final String status = switch (selectedCount) {
      0 => '원소 2종 선택 필요',
      1 => '원소를 하나 더 선택하세요',
      _ => hintLabel,
    };
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        border: Border.all(color: colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: <Widget>[
            Icon(
              alreadyDiscovered
                  ? Icons.bookmark_added_outlined
                  : Icons.science_outlined,
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(child: Text(status)),
          ],
        ),
      ),
    );
  }
}
