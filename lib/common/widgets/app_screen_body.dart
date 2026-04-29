import 'package:alchemist_hunter/common/themes/app_spacing.dart';
import 'package:flutter/material.dart';

class AppScreenBody extends StatelessWidget {
  const AppScreenBody({
    super.key,
    required this.children,
    this.padding = const EdgeInsets.all(AppSpacing.lg),
    this.gap = AppSpacing.md,
  });

  final List<Widget> children;
  final EdgeInsetsGeometry padding;
  final double gap;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: padding,
      itemCount: children.length,
      separatorBuilder: (_, _) => SizedBox(height: gap),
      itemBuilder: (_, int index) => children[index],
    );
  }
}
