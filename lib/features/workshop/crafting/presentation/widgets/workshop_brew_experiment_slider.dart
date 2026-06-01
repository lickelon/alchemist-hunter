import 'package:alchemist_hunter/common/themes/app_spacing.dart';
import 'package:flutter/material.dart';

class WorkshopBrewExperimentSlider extends StatelessWidget {
  const WorkshopBrewExperimentSlider({
    super.key,
    required this.primaryName,
    required this.secondaryName,
    required this.value,
    required this.onChanged,
  });

  final String primaryName;
  final String secondaryName;
  final double value;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    final double secondaryValue = 1 - value;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(child: Text(primaryName)),
              Text(
                '주 ${(value * 100).round()}%',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          Slider(
            value: value.clamp(0.55, 0.95).toDouble(),
            min: 0.55,
            max: 0.95,
            divisions: 8,
            onChanged: onChanged,
          ),
          Row(
            children: <Widget>[
              Expanded(child: Text(secondaryName)),
              Text(
                '부 ${(secondaryValue * 100).round()}%',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
