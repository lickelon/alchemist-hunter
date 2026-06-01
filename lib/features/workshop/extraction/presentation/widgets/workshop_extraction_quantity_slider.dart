import 'package:flutter/material.dart';

class WorkshopExtractionQuantitySlider extends StatelessWidget {
  const WorkshopExtractionQuantitySlider({
    super.key,
    required this.selectedQuantity,
    required this.value,
    required this.maxQuantity,
    required this.onChanged,
  });

  final int selectedQuantity;
  final double value;
  final int maxQuantity;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    final bool enabled = maxQuantity > 1;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              child: Text(
                '선택 $selectedQuantity개',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
            Text(
              '최대 $maxQuantity개',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        Slider(
          value: value,
          min: 1,
          max: maxQuantity.toDouble(),
          onChanged: enabled ? onChanged : null,
        ),
      ],
    );
  }
}
