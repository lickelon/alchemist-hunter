import 'package:alchemist_hunter/common/themes/app_spacing.dart';
import 'package:flutter/material.dart';

class AppSheetLayout extends StatelessWidget {
  const AppSheetLayout({
    super.key,
    required this.title,
    required this.body,
    this.header,
    this.footer,
    this.expandBody = true,
    this.showCloseButton = true,
  });

  final String title;
  final Widget body;
  final Widget? header;
  final Widget? footer;
  final bool expandBody;
  final bool showCloseButton;

  @override
  Widget build(BuildContext context) {
    final Widget bodyWidget = expandBody ? Expanded(child: body) : body;
    final Widget? footerWidget =
        footer ??
        (showCloseButton
            ? SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  icon: const Icon(Icons.close),
                  label: const Text('닫기'),
                ),
              )
            : null);

    return Column(
      mainAxisSize: expandBody ? MainAxisSize.max : MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(title, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: AppSpacing.md),
        if (header != null) ...<Widget>[
          header!,
          const SizedBox(height: AppSpacing.md),
        ],
        bodyWidget,
        if (footerWidget != null) ...<Widget>[
          const SizedBox(height: AppSpacing.lg),
          footerWidget,
        ],
      ],
    );
  }
}
