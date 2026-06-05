import 'package:alchemist_hunter/common/widgets/app_slider_field.dart';
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
    return AppRatioSlider(
      primaryName: primaryName,
      secondaryName: secondaryName,
      value: value,
      min: 0.55,
      max: 0.95,
      divisions: 8,
      onChanged: onChanged,
    );
  }
}
