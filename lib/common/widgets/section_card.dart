import 'package:alchemist_hunter/common/themes/app_text_styles.dart';
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
    this.padding = const EdgeInsets.all(AppSpacing.md),
    this.margin,
  });

  final String title;
  final Widget child;
  final Widget? trailing;
  final TextStyle? titleStyle;
  final double titleSpacing;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: margin,
      child: Padding(
        padding: padding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    title,
                    style:
                        titleStyle ?? AppTextStyles.of(context).subsectionTitle,
                  ),
                ),
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
