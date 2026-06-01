String signedValue(int value) => value >= 0 ? '+$value' : '$value';

String signedPercent(double value) {
  final int percent = (value * 100).round();
  if (percent > 0) {
    return '+$percent%';
  }
  return '$percent%';
}
