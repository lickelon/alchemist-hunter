import 'package:alchemist_hunter/features/workshop/domain/models.dart';

int statusRank(QueueJobStatus status) {
  return switch (status) {
    QueueJobStatus.processing => 0,
    QueueJobStatus.blocked => 1,
    QueueJobStatus.queued => 2,
    QueueJobStatus.completed => 3,
  };
}

String formatTraitRequirements(
  Map<String, double>? requirements,
  Map<String, String> traitNames,
) {
  if (requirements == null || requirements.isEmpty) {
    return '필요 특성 계산 불가';
  }
  return requirements.entries
      .map(
        (MapEntry<String, double> entry) =>
            '${traitNames[entry.key] ?? entry.key} ${entry.value.toStringAsFixed(2)}',
      )
      .join(', ');
}

String queueStatusText({
  required CraftQueueJob job,
  required bool canResume,
  required String? lackingTraits,
}) {
  if (job.status == QueueJobStatus.blocked) {
    if (canResume) {
      return '상태 진행 불가, 추출 특성 보충 후 재개 가능';
    }
    if (lackingTraits != null && lackingTraits.isNotEmpty) {
      return '상태 진행 불가, 부족 특성: $lackingTraits';
    }
    return '상태 진행 불가, 추출 특성 부족';
  }
  if (job.status == QueueJobStatus.completed) {
    return '상태 완료';
  }
  if (job.status == QueueJobStatus.processing) {
    return '상태 진행 중, ETA ${job.eta.inSeconds}s';
  }
  return '상태 대기 중, ${job.currentRepeat}/${job.repeatCount}';
}

String? formatMissingTraits({
  required Map<String, double>? requirements,
  required Map<String, double> extractedInventory,
  required Map<String, String> traitNames,
}) {
  if (requirements == null || requirements.isEmpty) {
    return null;
  }
  final List<String> missing = <String>[];
  for (final MapEntry<String, double> entry in requirements.entries) {
    final double owned = extractedInventory[entry.key] ?? 0;
    if (owned + 0.0001 >= entry.value) {
      continue;
    }
    missing.add(
      '${traitNames[entry.key] ?? entry.key} ${(entry.value - owned).toStringAsFixed(2)}',
    );
  }
  if (missing.isEmpty) {
    return null;
  }
  return missing.join(', ');
}
