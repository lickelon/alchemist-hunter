import 'package:alchemist_hunter/common/themes/app_spacing.dart';
import 'package:flutter/material.dart';

class DetailLines extends StatelessWidget {
  const DetailLines({super.key, this.description, required this.lines});

  final String? description;
  final List<String> lines;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final TextStyle? detailStyle = theme.textTheme.bodySmall?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        if (description != null) Text(description!),
        if (description != null && lines.isNotEmpty)
          const SizedBox(height: AppSpacing.xs),
        ...lines.map((String line) {
          return Padding(
            padding: const EdgeInsets.only(top: AppSpacing.xs),
            child: Text(line, style: detailStyle),
          );
        }),
      ],
    );
  }
}
