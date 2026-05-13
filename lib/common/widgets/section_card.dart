import 'package:alchemist_hunter/common/themes/app_spacing.dart';
import 'package:flutter/material.dart';

class SectionCard extends StatelessWidget {
  const SectionCard({
    super.key,
    required this.title,
    required this.child,
    this.trailing,
    this.titleStyle,
    this.titleSpacing = AppSpacing.md,
    this.margin,
  });

  final String title;
  final Widget child;
  final Widget? trailing;
  final TextStyle? titleStyle;
  final double titleSpacing;
  final EdgeInsetsGeometry? margin;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: margin,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(child: Text(title, style: titleStyle)),
                if (trailing != null) trailing!,
              ],
            ),
            SizedBox(height: titleSpacing),
            child,
          ],
        ),
      ),
    );
  }
}
