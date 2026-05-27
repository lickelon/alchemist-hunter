import 'package:alchemist_hunter/common/themes/app_radius.dart';
import 'package:alchemist_hunter/common/themes/app_spacing.dart';
import 'package:alchemist_hunter/common/themes/app_text_styles.dart';
import 'package:flutter/material.dart';

class AppBadge extends StatelessWidget {
  const AppBadge({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondaryContainer,
        borderRadius: AppRadius.badge,
      ),
      child: Text(
        label,
        style: AppTextStyles.of(context).dataEmphasis.copyWith(
          color: Theme.of(context).colorScheme.onSecondaryContainer,
          fontSize: Theme.of(context).textTheme.labelSmall?.fontSize,
        ),
      ),
    );
  }
}
