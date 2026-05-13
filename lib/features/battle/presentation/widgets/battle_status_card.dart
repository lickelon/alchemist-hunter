import 'package:alchemist_hunter/common/themes/app_spacing.dart';
import 'package:alchemist_hunter/common/widgets/section_card.dart';
import 'package:flutter/material.dart';

class BattleStatusCard extends StatelessWidget {
  const BattleStatusCard({super.key, required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      title: title,
      titleStyle: Theme.of(context).textTheme.titleSmall,
      titleSpacing: AppSpacing.sm,
      child: child,
    );
  }
}
