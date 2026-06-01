import 'package:flutter/material.dart';

class BattleResourceBar extends StatelessWidget {
  const BattleResourceBar({
    super.key,
    required this.semanticsLabel,
    required this.value,
    required this.color,
  });

  final String semanticsLabel;
  final double value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticsLabel,
      value: '${(value.clamp(0, 1) * 100).round()}%',
      child: LinearProgressIndicator(
        value: value.clamp(0, 1),
        minHeight: 8,
        color: color,
        backgroundColor: color.withValues(alpha: 0.18),
      ),
    );
  }
}
