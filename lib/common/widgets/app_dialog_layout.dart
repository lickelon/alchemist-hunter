import 'package:alchemist_hunter/common/themes/app_spacing.dart';
import 'package:flutter/material.dart';

class AppDialogLayout extends StatelessWidget {
  const AppDialogLayout({
    super.key,
    required this.title,
    required this.body,
    this.actions,
    this.showCloseButton = true,
    this.contentWidth = 360,
  });

  final String title;
  final Widget body;
  final List<Widget>? actions;
  final bool showCloseButton;
  final double contentWidth;

  @override
  Widget build(BuildContext context) {
    final List<Widget>? actionWidgets =
        actions ??
        (showCloseButton
            ? <Widget>[
                TextButton.icon(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  icon: const Icon(Icons.close),
                  label: const Text('닫기'),
                ),
              ]
            : null);

    return AlertDialog(
      title: Text(title),
      content: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: contentWidth),
        child: body,
      ),
      actions: actionWidgets,
      actionsPadding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        0,
        AppSpacing.lg,
        AppSpacing.md,
      ),
    );
  }
}
