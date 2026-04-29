import 'package:alchemist_hunter/common/themes/app_spacing.dart';
import 'package:flutter/material.dart';

class AppSheetLayout extends StatelessWidget {
  const AppSheetLayout({
    super.key,
    required this.title,
    required this.body,
    this.header,
    this.expandBody = true,
  });

  final String title;
  final Widget body;
  final Widget? header;
  final bool expandBody;

  @override
  Widget build(BuildContext context) {
    final Widget bodyWidget = expandBody ? Expanded(child: body) : body;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(title, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: AppSpacing.md),
        if (header != null) ...<Widget>[
          header!,
          const SizedBox(height: AppSpacing.md),
        ],
        bodyWidget,
      ],
    );
  }
}
