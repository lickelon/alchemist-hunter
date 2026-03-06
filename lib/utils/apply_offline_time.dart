Duration clampOfflineDuration(Duration elapsed, {int maxHours = 8}) {
  final Duration limit = Duration(hours: maxHours);
  if (elapsed < Duration.zero) {
    return Duration.zero;
  }
  return elapsed > limit ? limit : elapsed;
}
