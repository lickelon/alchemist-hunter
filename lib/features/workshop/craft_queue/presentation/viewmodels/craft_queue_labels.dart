import 'package:alchemist_hunter/features/workshop/domain/models.dart';

int statusRank(QueueJobStatus status) {
  return switch (status) {
    QueueJobStatus.processing => 0,
    QueueJobStatus.queued => 1,
    QueueJobStatus.blocked => 2,
    QueueJobStatus.completed => 3,
  };
}

List<String> formatTraitRequirementLabels(
  Map<String, double>? requirements,
  Map<String, String> traitNames,
) {
  if (requirements == null || requirements.isEmpty) {
    return <String>['원소 없음'];
  }
  return requirements.entries
      .map(
        (MapEntry<String, double> entry) =>
            '${traitNames[entry.key] ?? entry.key} 원소 ${entry.value.toStringAsFixed(2)}',
      )
      .toList();
}

String queueStatusBadgeLabel(QueueJobStatus status) {
  return switch (status) {
    QueueJobStatus.processing => '진행',
    QueueJobStatus.queued => '대기',
    QueueJobStatus.completed => '완료',
    QueueJobStatus.blocked => '막힘',
  };
}

String? queueTimeLabel(CraftQueueJob job) {
  return switch (job.status) {
    QueueJobStatus.processing => '${job.eta.inSeconds}s',
    QueueJobStatus.queued => '${job.duration.inSeconds}s',
    QueueJobStatus.completed || QueueJobStatus.blocked => null,
  };
}
