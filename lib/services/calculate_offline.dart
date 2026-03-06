class OfflineResult {
  const OfflineResult({
    required this.gainedGold,
    required this.gainedMaterials,
    required this.processedQueueCycles,
  });

  final int gainedGold;
  final Map<String, int> gainedMaterials;
  final int processedQueueCycles;
}

OfflineResult calculateOfflineProgress({
  required Duration elapsed,
  required int goldPerMinute,
  required Map<String, int> materialPerMinute,
  int maxHours = 8,
}) {
  final Duration cap = Duration(hours: maxHours);
  final Duration used = elapsed > cap ? cap : elapsed;
  final int minutes = used.inMinutes;

  final Map<String, int> materials = <String, int>{};
  materialPerMinute.forEach((String key, int value) {
    materials[key] = value * minutes;
  });

  return OfflineResult(
    gainedGold: goldPerMinute * minutes,
    gainedMaterials: materials,
    processedQueueCycles: minutes ~/ 3,
  );
}
