import 'package:flutter/material.dart';

class BattleSmoothProgressBar extends StatelessWidget {
  const BattleSmoothProgressBar({super.key, required this.value});

  final double value;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(end: value),
      duration: const Duration(milliseconds: 100),
      curve: Curves.linear,
      builder: (BuildContext context, double animatedValue, Widget? child) {
        return LinearProgressIndicator(value: animatedValue, minHeight: 8);
      },
    );
  }
}
