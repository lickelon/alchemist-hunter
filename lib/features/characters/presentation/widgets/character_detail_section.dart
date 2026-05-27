import 'package:alchemist_hunter/common/themes/app_spacing.dart';
import 'package:alchemist_hunter/common/themes/app_text_styles.dart';
import 'package:alchemist_hunter/common/widgets/section_card.dart';
import 'package:flutter/material.dart';

class CharacterDetailSection extends StatelessWidget {
  const CharacterDetailSection({
    super.key,
    required this.title,
    required this.child,
    this.trailing,
  });

  final String title;
  final Widget child;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: SectionCard(
        margin: EdgeInsets.zero,
        title: title,
        titleStyle: AppTextStyles.of(context).subsectionTitle.copyWith(
          color: Theme.of(context).colorScheme.primary,
        ),
        trailing: trailing,
        child: child,
      ),
    );
  }
}
