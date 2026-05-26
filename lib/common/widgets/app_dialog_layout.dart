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
    const double horizontalInset = AppSpacing.xl;
    final double availableWidth =
        (MediaQuery.sizeOf(context).width - horizontalInset * 2)
            .clamp(0.0, contentWidth)
            .toDouble();
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
      insetPadding: const EdgeInsets.symmetric(
        horizontal: horizontalInset,
        vertical: AppSpacing.xxl,
      ),
      title: Text(title),
      content: SizedBox(width: availableWidth, child: body),
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
