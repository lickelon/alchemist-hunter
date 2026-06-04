import 'package:alchemist_hunter/common/themes/app_spacing.dart';
import 'package:flutter/material.dart';

class AppEmptyState extends StatelessWidget {
  const AppEmptyState(
    this.message, {
    super.key,
    this.icon,
    this.alignment = Alignment.center,
  });

  final String message;
  final IconData? icon;
  final AlignmentGeometry alignment;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextStyle? textStyle = Theme.of(
      context,
    ).textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant);
    final Widget content = Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        if (icon != null) ...<Widget>[
          Icon(icon, color: colorScheme.onSurfaceVariant),
          const SizedBox(height: AppSpacing.sm),
        ],
        Text(message, style: textStyle, textAlign: TextAlign.center),
      ],
    );

    return Align(alignment: alignment, child: content);
  }
}
