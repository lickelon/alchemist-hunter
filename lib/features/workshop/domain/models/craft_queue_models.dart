import 'package:flutter/foundation.dart';

import 'enums.dart';

@immutable
class CraftRetryPolicy {
  const CraftRetryPolicy({required this.maxRetries});

  final int maxRetries;
}

@immutable
class CraftQueueJob {
  const CraftQueueJob({
    required this.id,
    required this.potionId,
    required this.repeatCount,
    required this.retryPolicy,
    required this.status,
    required this.eta,
    this.currentRepeat = 0,
    this.retryCount = 0,
  });

  final String id;
  final String potionId;
  final int repeatCount;
  final CraftRetryPolicy retryPolicy;
  final QueueJobStatus status;
  final Duration eta;
  final int currentRepeat;
  final int retryCount;

  CraftQueueJob copyWith({
    QueueJobStatus? status,
    Duration? eta,
    int? currentRepeat,
    int? retryCount,
  }) {
    return CraftQueueJob(
      id: id,
      potionId: potionId,
      repeatCount: repeatCount,
      retryPolicy: retryPolicy,
      status: status ?? this.status,
      eta: eta ?? this.eta,
      currentRepeat: currentRepeat ?? this.currentRepeat,
      retryCount: retryCount ?? this.retryCount,
    );
  }
}
