import 'package:alchemist_hunter/common/themes/app_spacing.dart';
import 'package:flutter/material.dart';

class AppSliderField extends StatelessWidget {
  const AppSliderField({
    super.key,
    required this.leadingLabel,
    required this.trailingLabel,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
    this.divisions,
    this.bottomLabel,
    this.leadingTextStyle,
  });

  final String leadingLabel;
  final String trailingLabel;
  final String? bottomLabel;
  final double value;
  final double min;
  final double max;
  final int? divisions;
  final ValueChanged<double>? onChanged;
  final TextStyle? leadingTextStyle;

  @override
  Widget build(BuildContext context) {
    final TextStyle? helperStyle = Theme.of(context).textTheme.bodySmall
        ?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              child: Text(
                leadingLabel,
                style:
                    leadingTextStyle ?? Theme.of(context).textTheme.bodyMedium,
              ),
            ),
            Text(trailingLabel, style: helperStyle),
          ],
        ),
        Slider(
          value: value.clamp(min, max).toDouble(),
          min: min,
          max: max,
          divisions: divisions,
          onChanged: onChanged,
        ),
        if (bottomLabel != null) Text(bottomLabel!, style: helperStyle),
      ],
    );
  }
}

class AppQuantitySlider extends StatelessWidget {
  const AppQuantitySlider({
    super.key,
    required this.selectedQuantity,
    required this.value,
    required this.maxQuantity,
    required this.onChanged,
    this.divided = false,
    this.unit = '개',
  });

  final int selectedQuantity;
  final double value;
  final int maxQuantity;
  final ValueChanged<double> onChanged;
  final bool divided;
  final String unit;

  @override
  Widget build(BuildContext context) {
    final bool enabled = maxQuantity > 1;
    return AppSliderField(
      leadingLabel: '선택 $selectedQuantity$unit',
      trailingLabel: '최대 $maxQuantity$unit',
      value: value,
      min: 1,
      max: maxQuantity.toDouble(),
      divisions: divided && enabled ? maxQuantity - 1 : null,
      onChanged: enabled ? onChanged : null,
    );
  }
}

class AppRatioSlider extends StatelessWidget {
  const AppRatioSlider({
    super.key,
    required this.primaryName,
    required this.secondaryName,
    required this.value,
    required this.onChanged,
    this.min = 0,
    this.max = 1,
    this.divisions,
  });

  final String primaryName;
  final String secondaryName;
  final double value;
  final double min;
  final double max;
  final int? divisions;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    final double clampedValue = value.clamp(min, max).toDouble();
    final double secondaryValue = 1 - clampedValue;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: AppSliderField(
        leadingLabel: primaryName,
        trailingLabel: '주 ${(clampedValue * 100).round()}%',
        bottomLabel: '$secondaryName 부 ${(secondaryValue * 100).round()}%',
        value: clampedValue,
        min: min,
        max: max,
        divisions: divisions,
        onChanged: onChanged,
      ),
    );
  }
}
