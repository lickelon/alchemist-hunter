import 'package:alchemist_hunter/features/workshop/domain/models.dart';

int statusRank(QueueJobStatus status) {
  return switch (status) {
    QueueJobStatus.processing => 0,
    QueueJobStatus.queued => 1,
    QueueJobStatus.blocked => 2,
    QueueJobStatus.completed => 3,
  };
}

String jobTypeLabel(WorkshopJobType type) {
  return switch (type) {
    WorkshopJobType.extraction => '추출',
    WorkshopJobType.craft => '제조',
    WorkshopJobType.enchant => '인챈트',
    WorkshopJobType.hatch => '부화',
  };
}

String formatTraitRequirements(
  Map<String, double>? requirements,
  Map<String, String> traitNames,
) {
  if (requirements == null || requirements.isEmpty) {
    return '필요 특성 없음';
  }
  return requirements.entries
      .map(
        (MapEntry<String, double> entry) =>
            '${traitNames[entry.key] ?? entry.key} ${entry.value.toStringAsFixed(2)}',
      )
      .join(', ');
}

String queueStatusText(CraftQueueJob job) {
  return switch (job.status) {
    QueueJobStatus.processing => '진행 중 / 남은 시간 ${job.eta.inSeconds}s',
    QueueJobStatus.queued => '대기 중 / 예상 ${job.duration.inSeconds}s',
    QueueJobStatus.completed => '완료',
    QueueJobStatus.blocked => '진행 불가',
  };
}
